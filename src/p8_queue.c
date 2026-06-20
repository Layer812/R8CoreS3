/**
 * \file    queue.c
 *
 * \brief   A double-ended queue (deque). Elements can be added or removed from
 *          either the front or the back side.
 * \warning The current implementation is NOT interrupt safe. Make sure interrupts
 *          are disabled before access the QUEUE otherwise the program might yield
 *          unexpected results.
 */

#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "p8_queue.h"

#define INCREASE_INDEX(queue, ptr) queue->ptr = (queue->ptr + queue->elements_size) >= (queue->data_buf + queue->elements_num_max * queue->elements_size) ? queue->data_buf : (queue->ptr + queue->elements_size)
#define DECREASE_INDEX(queue, ptr) queue->ptr = (queue->ptr - queue->elements_size) < queue->data_buf ? (queue->data_buf + (queue->elements_num_max - 1) * queue->elements_size) : (queue->ptr - queue->elements_size)
#define INCREASE_INDEX(queue, ptr) queue->ptr = (((uint8_t *)queue->ptr + queue->elements_size) >= ((uint8_t *)queue->data_buf + queue->elements_num_max * queue->elements_size)) ? queue->data_buf : ((uint8_t *)queue->ptr + queue->elements_size)
#define DECREASE_INDEX(queue, ptr) queue->ptr = ((uint8_t *)queue->ptr - queue->elements_size) < (uint8_t *)queue->data_buf ? ((uint8_t *)queue->data_buf + (queue->elements_num_max - 1) * queue->elements_size) : ((uint8_t *)queue->ptr - queue->elements_size)

/**
 * Initializes - resets the queue.
 */
void _queue_init(p8_queue_t *queue)
{
    queue->front = queue->data_buf;
    queue->back = queue->data_buf;
    queue->elements = 0;
}

/**
 * Checks whether the queue is full.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \retval      true        If the queue is full
 *              false       If the queue is not full
 */
bool queue_is_full(p8_queue_t *queue)
{
    return queue->elements == queue->elements_num_max;
}

/**
 * Checks whether the queue is empty.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \retval      true        If the queue is empty
 *              false       If the queue is not empty
 */
bool queue_is_empty(p8_queue_t *queue)
{
    return queue->elements == 0;
}

/**
 * Adds an element to the front side of the queue.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \param [in]  data        A pointer to the data buffer
 * \retval      true        If data have been successfully copied
 *              false       If queue is full
 */
bool queue_add_front(p8_queue_t *queue, void *data)
{
    if (queue_is_full(queue))
        return false;

    DECREASE_INDEX(queue, front);
    memcpy(queue->front, data, queue->elements_size);

    queue->elements++;

    return true;
}

/**
 * Adds an element to the back side of the queue.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \param [in]  data        A pointer to the data buffer
 * \retval      true        If data have been successfully copied
 *              false       If queue is full
 */
bool queue_add_back(p8_queue_t *queue, void *data)
{
    if (queue_is_full(queue))
        return false;

    memcpy(queue->back, data, queue->elements_size);
    INCREASE_INDEX(queue, back);

    queue->elements++;

    return true;
}

/**
 * Reads and removes the front element of the queue.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \param [out] data        A pointer to the data buffer
 * \retval      true        If data have been successfully copied
 *              false       If queue is empty
 */
bool queue_get_front(p8_queue_t *queue, void *data)
{
    if (queue_is_empty(queue))
        return false;

    memcpy(data, queue->front, queue->elements_size);
    INCREASE_INDEX(queue, front);

    queue->elements--;

    return true;
}

/**
 * Reads and removes the back element of the queue.
 *
 * \param [in]  queue       A pointer to the queue structure
 * \param [out] data        A pointer to the data buffer
 * \retval      true        If data have been successfully copied
 *              false       If queue is empty
 */
bool queue_get_back(p8_queue_t *queue, void *data)
{
    if (queue_is_empty(queue))
        return false;

    DECREASE_INDEX(queue, back);
    memcpy(data, queue->back, queue->elements_size);

    queue->elements--;

    return true;
}
