#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "bit2.h"
#include "stack.h"

typedef struct {
    int row;
    int col;
} Coordinate;

Bit2_T pbm_array;

void push_adjacent(Bit2_T bit2, Stack_T stack, int row, int col) {
    int rows = Bit2_height(bit2);
    int columns = Bit2_width(bit2);

    if (row > 0 && Bit2_get(bit2, row - 1, col) == 1) {
        Coordinate *coord = malloc(sizeof(Coordinate));
        coord->row = row - 1;
        coord->col = col;
        Stack_push(stack, coord);
        Bit2_put(bit2, row - 1, col, 0);
    }
    if (row < rows - 1 && Bit2_get(bit2, row + 1, col) == 1) { 
        Coordinate *coord = malloc(sizeof(Coordinate));
        coord->row = row + 1;
        coord->col = col;
        Stack_push(stack, coord);
        Bit2_put(bit2, row + 1, col, 0);
    }
    if (col > 0 && Bit2_get(bit2, row, col - 1) == 1) {
        Coordinate *coord = malloc(sizeof(Coordinate));
        coord->row = row;
        coord->col = col - 1;
        Stack_push(stack, coord);
        Bit2_put(bit2, row, col - 1, 0);
    }
    if (col < columns - 1 && Bit2_get(bit2, row, col + 1) == 1) {
        Coordinate *coord = malloc(sizeof(Coordinate));
        coord->row = row;
        coord->col = col + 1;
        Stack_push(stack, coord);
        Bit2_put(bit2, row, col + 1, 0);
    }
}

void process_perimeter(Bit2_T bit2) {
    int rows = Bit2_height(bit2);
    int columns = Bit2_width(bit2);
    Stack_T stack = Stack_new(); 

    for (int j = 0; j < columns; j++) {
        if (Bit2_get(bit2, 0, j) == 1) {
            Coordinate *coord = malloc(sizeof(Coordinate));
            coord->row = 0;
            coord->col = j;
            Stack_push(stack, coord);
            Bit2_put(bit2, 0, j, 0);
        }
        if (Bit2_get(bit2, rows - 1, j) == 1) {
            Coordinate *coord = malloc(sizeof(Coordinate));
            coord->row = rows - 1;
            coord->col = j;
            Stack_push(stack, coord);
            Bit2_put(bit2, rows - 1, j, 0);
        }
    }

    
    for (int i = 0; i < rows; i++) {
        if (Bit2_get(bit2, i, 0) == 1) {
            Coordinate *coord = malloc(sizeof(Coordinate));
            coord->row = i;
            coord->col = 0;
            Stack_push(stack, coord);
            Bit2_put(bit2, i, 0, 0);
        }
        if (Bit2_get(bit2, i, columns - 1) == 1) {
            Coordinate *coord = malloc(sizeof(Coordinate));
            coord->row = i;
            coord->col = columns - 1;
            Stack_push(stack, coord);
            Bit2_put(bit2, i, columns - 1, 0);
        }
    }

    while (!Stack_empty(stack)) {
        Coordinate *coord = Stack_pop(stack);
        push_adjacent(bit2, stack, coord->row, coord->col);
        free(coord);
    }

    Stack_free(&stack);
}

void read_pbm(FILE *input, Bit2_T bit2) {
    int rows = Bit2_height(bit2);
    int columns = Bit2_width(bit2);

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j += 8) {
            unsigned char byte;
            if (fread(&byte, sizeof(unsigned char), 1, input) != 1) {
                // fprintf(stderr, "Error reading PBM file at byte (%d, %d)\n", i, j);
                exit(1);
            }
            for (int bit = 0; bit < 8 && j + bit < columns; bit++) {
                Bit2_put(bit2, i, j + bit, (byte & (1 << (7 - bit))) ? 1 : 0);
            }
        }
    }
}

void print_pbm(Bit2_T bit2) {
    int rows = Bit2_height(bit2);
    int columns = Bit2_width(bit2);

    printf("P1\n");
    printf("%d %d\n", columns, rows);

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            int value = Bit2_get(bit2, i, j);
            printf("%d ", value);
        }
        printf("\n");
    }
}

int main(int argc, char *argv[]) {
    assert(argc == 2);

    FILE *input = fopen(argv[1], "rb");
    assert(input != NULL);

    char header[3];
    if (fscanf(input, "%2s", header) != 1 || strcmp(header, "P4") != 0) {
        fprintf(stderr, "Not a valid PBM file (must start with P4).\n");
        exit(1);
    }

    int rows, columns;
    if (fscanf(input, "%d %d", &columns, &rows) != 2 || rows <= 0 || columns <= 0) {
        fprintf(stderr, "Error reading dimensions from PBM file.\n");
        exit(1);
    }

    pbm_array = Bit2_new(columns, rows);

    read_pbm(input, pbm_array);
    process_perimeter(pbm_array);

    print_pbm(pbm_array);

    Bit2_free(&pbm_array);

    fclose(input);

    return 0;
}
