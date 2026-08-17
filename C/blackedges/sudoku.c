/*
 *     sudoku.c
 *     By Sid & Frank
 *     9/24/2024
 *     CS40 HW2: iii
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "uarray2.h"

void fill_array(FILE *input, UArray2_T arr) {
    int value;
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            fscanf(input, "%d", &value);
            int *element = (int *)UArray2_at(arr, i, j);
            *element = value;
        }
    }
}

int validate_section(int arr[]) {
    int traversed[9] = {0};

    for (int i = 0; i < 9; i++) {
        if (arr[i] < 1 || arr[i] > 9 || traversed[arr[i] - 1] != 0) {
            return 0;
        }
        traversed[arr[i] - 1] = 1;
    }
    return 1;
}

int validate_grid(UArray2_T arr) {
    int test_array[9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            test_array[j] = *(int *)UArray2_at(arr, i, j);
        }
        if (!validate_section(test_array)) {
            return 0;
        }
    }

    for (int j = 0; j < 9; j++) {
        for (int i = 0; i < 9; i++) {
            test_array[i] = *(int *)UArray2_at(arr, i, j);
        }
        if (!validate_section(test_array)) {
            return 0;
        }
    }

    for (int grid_row = 0; grid_row < 3; grid_row++) {
        for (int grid_col = 0; grid_col < 3; grid_col++) {
            int index = 0;
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    test_array[index++] = *(int *)UArray2_at(arr, grid_row * 3 + i, grid_col * 3 + j);
                }
            }
            if (!validate_section(test_array)) {
                return 0;
            }
        }
    }

    return 1;
}

int main(int argc, char *argv[]) {
    assert(argc < 3);

    FILE *sudoku;
    if (argc == 2) {
        sudoku = fopen(argv[1], "r");
        assert(sudoku != NULL);
    } else {
        sudoku = stdin;
    }

    UArray2_T newArr = UArray2_new(9, 9, sizeof(int));

    fill_array(sudoku, newArr);

    int is_valid = validate_grid(newArr);

    if (is_valid) {
        printf("The Sudoku puzzle is valid!\n");
    } else {
        printf("The Sudoku puzzle is invalid!\n");
    }

    UArray2_free(&newArr);
    if (argc == 2) {
        fclose(sudoku);
    }

    return 0;
}

