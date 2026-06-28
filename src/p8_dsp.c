/*
 * p8_dsp.c
 *
 *  Created on: Dec 13, 2023
 *      Author: bbaker
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "p8_audio.h"
/*
 * Modified by Layer8
 * - Rewrote dsp_noise to respect frequency (pitch) to reproduce crunchy drum sounds.
 */
#include "p8_dsp.h"

int random_range(int min, int max)
{
    return min + ((float)rand() / RAND_MAX) * (max - min);
}

void dsp_square_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        dest[dest_offset + i] += (int16_t)(offset + (*phase < 0.5f ? -amplitude : amplitude));
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_pulse_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float duty_cycle, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        dest[dest_offset + i] += (int16_t)(offset + (*phase < duty_cycle ? amplitude : -amplitude));
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_triangle_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        // Add 0.25 phase shift so it starts exactly at 0 to prevent clicks
        float p = *phase + 0.25f;
        if (p >= 1.0f) p -= 1.0f;
        
        if (p < 0.50f)
            dest[dest_offset + i] += (int16_t)(offset + amplitude - amplitude * 2 * (p / 0.5f));
        else
            dest[dest_offset + i] += (int16_t)(offset - amplitude + amplitude * 2 * ((p - 0.5f) / 0.5f));
            
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_sawtooth_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        // Add 0.5 phase shift so it starts exactly at 0 to prevent clicks
        float p = *phase + 0.5f;
        if (p >= 1.0f) p -= 1.0f;
        
        dest[dest_offset + i] += (int16_t)(offset - amplitude + amplitude * 2 * p);
        
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_tilted_sawtooth_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float duty_cycle, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        // Add phase shift to start at 0 amplitude
        float p = *phase + (duty_cycle * 0.5f);
        if (p >= 1.0f) p -= 1.0f;
        
        if (p < duty_cycle)
            dest[dest_offset + i] += (int16_t)(offset - amplitude + amplitude * 2 * (p / duty_cycle));
        else
        {
            float op = (p - duty_cycle) / (1.0f - duty_cycle);
            dest[dest_offset + i] += (int16_t)(offset + amplitude - amplitude * 2 * op);
        }
        
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_organ_wave(uint32_t frequency, int16_t amplitude, int16_t offset, float coefficient, float *phase, int dest_offset, int dest_length, int16_t *dest)
{
    float phase_step = (float)frequency / SAMPLE_RATE;
    for (int i = 0; i < dest_length; i++)
    {
        // Add 0.125 phase shift to start exactly at 0 amplitude
        float p = *phase + 0.125f;
        if (p >= 1.0f) p -= 1.0f;
        
        if (p < 0.25f)
            dest[dest_offset + i] += (int16_t)(offset + amplitude - amplitude * 2 * (p / 0.25f));
        else if (p < 0.50f)
            dest[dest_offset + i] += (int16_t)(offset - amplitude + amplitude * (1.0f + coefficient) * (p - 0.25f) / 0.25f);
        else if (p < 0.75f)
            dest[dest_offset + i] += (int16_t)(offset + amplitude * coefficient - amplitude * (1.0f + coefficient) * (p - 0.50f) / 0.25f);
        else
            dest[dest_offset + i] += (int16_t)(offset - amplitude + amplitude * 2 * (p - 0.75f) / 0.25f);
            
        *phase += phase_step;
        if (*phase >= 1.0f) *phase -= 1.0f;
    }
}

void dsp_noise(uint32_t frequency, int16_t amplitude, int position, int dest_offset, int dest_length, int16_t *dest)
{
    // PICO-8 noise is audible even at very low pitches (pitch 0) for short ticks.
    // If frequency is too low, the random value never changes during a short tick, resulting in silence (DC).
    // Ensure base clock is frequency * 4, with a minimum clock of 400Hz to guarantee edges on short ticks.
    int clock = frequency * 4;
    if (clock < 400) clock = 400;
    
    int samples_per_change = 44100 / clock;
    // Prevent ultra-high frequency clipping on the amplifier by limiting to max ~11kHz clock (min 4 samples per change).
    if (samples_per_change < 4) samples_per_change = 4;

    int last_chunk_index = -1;
    int16_t val = 0;

    for (int i = 0; i < dest_length; i++)
    {
        int chunk_index = position / samples_per_change;
        
        // Only recalculate the random value when the chunk changes (huge CPU optimization)
        if (chunk_index != last_chunk_index) {
            uint32_t hash = (uint32_t)chunk_index * 2654435761U;
            hash ^= hash >> 16;
            hash *= 2654435761U;
            hash ^= hash >> 16;
            
            if (amplitude > 0) {
                val = (int16_t)((hash % (uint32_t)(amplitude * 2 + 1)) - amplitude);
            } else {
                val = 0;
            }
            last_chunk_index = chunk_index;
        }

        dest[dest_offset + i] += val;
        position++;
    }
}

void dsp_fade_in(int16_t amplitude, int dest_offset, int dest_length, int16_t *dest)
{
    float incr = 1.0f / dest_length;
    for (int i = 0; i < dest_length; i++)
    {
        float v = dest[dest_offset + i] / (float)amplitude;
        dest[dest_offset + i] = (int16_t)(v * incr * i * amplitude);
    }
}

void dsp_fade_out(int16_t amplitude, int dest_offset, int dest_length, int16_t *dest)
{
    float incr = 1.0f / dest_length;
    for (int i = 0; i < dest_length; i++)
    {
        float v = dest[dest_offset + i] / (float)amplitude;
        dest[dest_offset + i] = (int16_t)(v * incr * (dest_length - i - 1) * amplitude);
    }
}
