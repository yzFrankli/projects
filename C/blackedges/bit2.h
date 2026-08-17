/*
 *     bit2.h
 *     By Sid & Frank
 *     9/24/2024
 *     CS40 HW2: iii
 *
 */

#ifndef BIT2_INCLUDED
#define BIT2_INCLUDED

typedef struct Bit2_T *Bit2_T;

Bit2_T Bit2_new(int width, int height);
int Bit2_width(Bit2_T array);
int Bit2_height(Bit2_T array);
int Bit2_get(Bit2_T array, int row, int col);
int Bit2_put(Bit2_T array, int row, int col, int value);
void Bit2_free(Bit2_T *array);
void Bit2_map_row_major(Bit2_T array, void apply(int i, int j, Bit2_T a, int value, void *p1), void *p1);
void Bit2_map_col_major(Bit2_T array, void apply(int i, int j, Bit2_T a, int value, void *p1), void *p1);

#endif /* BIT2_INCLUDED */

