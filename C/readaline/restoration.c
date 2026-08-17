#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "readaline.h"
#include <ctype.h>
#include <table.h>  // hanson table

void separate(const char *input, Table_T table);

int main() {
    // opening file
    FILE *fp = fopen("Makefile", "r");
    if (fp == NULL) {   // check if opening was successful
        fprintf(stderr, "could not open file for reading\n");
        exit(1);
    }
    printf("opened file\n");

    char *line = NULL;    // pointer to first byte
    size_t len = readaline(fp, &line);
    printf("%ld", len);
    free(line); // responsible for freeing up memory
    fclose(fp);
    
}

// filtering out corrupted rows using Table_T
void cleanRow(char *row) {
    /* plan 
    * create a temp table_t 
    * clean the rows by separating the numbers and characters 
    * insert sequence into temp table
    * put the resulting sequence into List_t
    * compare the sequence with items in table, if they are same put row in list
    */


    // clean up the row and separate the injected sequence
    size_t seq_size = 10;
    size_t curr_size = 0;
    // char *sequence = malloc(seq_size);  // store sequence in dym. sized string
  



    // create a temp table of 10 buckets
    Table_T table = Table_new(10, NULL, NULL);

    // pass to separate function
    separate(row, table);
    

}



void separate(const char *input, Table_T table) {
    int length = strlen(input);
    char key[16];  // Buffer for creating string keys for the table
    int idx = 0;   // Key index for letters
    int num_idx = 0;  // Key index for numbers

    for (int i = 0; i < length; i++) {
        if (isdigit(input[i])) {
            // Handle numbers
            int number = 0;
            while (i < length and isdigit(input[i])) {
                number = number * 10 + (input[i] - '0');
                i++;
            }
            // Create key for the number
            snprintf(key, sizeof(key), "num_%d", num_idx++); 
            int *num_ptr = malloc(sizeof(int));  // Allocate memory for the number
            *num_ptr = number;
            Table_put(table, Atom_string(key), num_ptr);
            i--;  // Adjust index after exiting the loop
        } else if (isalpha(input[i])) {
            // Handle letters
            printf(key, sizeof(key), "char_%d", idx++);  // e.g., "char_0", "char_1"
            char *char_ptr = malloc(2 * sizeof(char));  // Allocate memory for the character
            char_ptr[0] = input[i];
            char_ptr[1] = '\0';  // Null-terminate for easy string manipulation
            Table_put(table, Atom_string(key), char_ptr);
        }
    }
}
