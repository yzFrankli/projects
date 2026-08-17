/*
 *     uarray2.h
 *     By Sid & Frank
 *     9/24/2024
 *     CS40 HW2: iii
 *
 */

#ifndef UARRAY2_H
#define UARRAY2_H

#include <uarray.h>

typedef struct UArray2_T *UArray2_T;


UArray2_T UArray2_new(int width, int height, int element_size);
void UArray2_free(UArray2_T *uarray2);
void *UArray2_at(UArray2_T uarray2, int i, int j);
int UArray2_width(UArray2_T uarray2);
int UArray2_height(UArray2_T uarray2);
int UArray2_size(UArray2_T uarray2);
void UArray2_map_row_major(UArray2_T uarray2, void (*apply)(int i, int j, UArray2_T uarray2, void *p1, void *p2), void *cl);
void UArray2_map_col_major(UArray2_T uarray2, void (*apply)(int i, int j, UArray2_T uarray2, void *p1, void *p2), void *cl);

#endif /* UARRAY2_H */

