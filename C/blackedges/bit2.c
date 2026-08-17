/*
 *     bit2.c
 *     By Sid & Frank
 *     9/24/2024
 *     CS40 HW2: iii
 *
 *     Purpose: Defines the Bit2 structure and its associated operations
 */

#include <stdlib.h>
#include <assert.h>
#include "bit2.h"

struct Bit2_T {
    int width;
    int height;
    int **array;
};

Bit2_T Bit2_new(int width, int height) {
    assert(width > 0 && height > 0);

    Bit2_T bit2 = malloc(sizeof(*bit2));
    assert(bit2 != NULL);

    bit2->width = width;
    bit2->height = height;

    bit2->array = malloc(height * sizeof(int *));
    assert(bit2->array != NULL);

    for (int i = 0; i < height; i++) {
        bit2->array[i] = malloc(width * sizeof(int));
        assert(bit2->array[i] != NULL); 

        for (int j = 0; j < width; j++) {
            bit2->array[i][j] = 0;
        }
    }

    return bit2;
}

int Bit2_width(Bit2_T array) {
    return array->width;
}

int Bit2_height(Bit2_T array) {
    return array->height;
}

int Bit2_get(Bit2_T array, int row, int col) {
    assert(array != NULL);
    assert(row >= 0 && row < array->height);
    assert(col >= 0 && col < array->width);
    return array->array[row][col];
}

int Bit2_put(Bit2_T array, int row, int col, int value) {
    int prev = array->array[row][col];
    array->array[row][col] = value;
    return prev;
}

void Bit2_free(Bit2_T *array) {
    for (int i = 0; i < (*array)->height; i++) {
        free((*array)->array[i]);
    }
    free((*array)->array);
    free(*array);
    *array = NULL;
}

void Bit2_map_row_major(Bit2_T array, void apply(int i, int j, Bit2_T a, int value, void *p1), void *p1) {
    for (int i = 0; i < Bit2_height(array); i++) {
        for (int j = 0; j < Bit2_width(array); j++) {
            apply(i, j, array, Bit2_get(array, i, j), p1);
        }
    }
}

void Bit2_map_col_major(Bit2_T array, void apply(int i, int j, Bit2_T a, int value, void *p1), void *p1) {
    for (int j = 0; j < Bit2_width(array); j++) {
        for (int i = 0; i < Bit2_height(array); i++) {
            apply(i, j, array, Bit2_get(array, i, j), p1);
        }
    }
}
