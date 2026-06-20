#ifndef P8_QUEUE_H
#define P8_QUEUE_H

#include <inttypes.h>
#include <stdbool.h>

typedef struct
{
    void *data_buf;
    void *front;
    void *back;
    const uint16_t elements_num_max;
    const uint16_t elements_size;
    uint16_t elements;
} p8_queue_t;

void _queue_init(p8_queue_t *queue);
bool queue_is_full(p8_queue_t *queue);
bool queue_is_empty(p8_queue_t *queue);
bool queue_add_front(p8_queue_t *queue, void *data);
bool queue_add_back(p8_queue_t *queue, void *data);
bool queue_get_front(p8_queue_t *queue, void *data);
bool queue_get_back(p8_queue_t *queue, void *data);

#endif
