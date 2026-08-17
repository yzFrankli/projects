#include "readaline.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

size_t readaline(File *inputfd, char **datapp);

int main() {    // used to test readaline
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


/*
readaline
purpose: read a single line of input from file input which has been opened
* each invocation retrieves the next line in the file
* the characters are placed in a contiguous array of bytes 
* datapp is set to the first byte
* readaline returns the number of bytes in the line
* the array is allocated using malloc 
* it is the responsibility of the caller to free memory
* readaline leaves the file seek pointer at the first character of the next 
  line or eof
* if no more lines it sets *datapp to NULL and return 0
* returns Checked Runtime Error if 
    1) either argument is NULL
    2) error in reading file
    3) memory allocation fail
* do not leave any dynamically allocated memory
** partial credit to readaline supporting less than 1000 char in length
*/

size_t readaline(FILE *inputfd, char **datapp) {
    // checking both parameters
    if (inputfd == NULL || datapp == NULL) {
        fprintf(stderr, "readaline: invalid arguement\n");
        exit(1);
    }

    // buffer
    size_t buffer_size = 128;
    size_t curr_size = 0;
    char *buffer = malloc(buffer_size);

    if (buffer == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }

    int ch; // next character
    while ((ch = fgetc(inputfd)) != EOF) {
        // resize buffer
        if (curr_size + 1 >= buffer_size) {
            buffer_size *= 2;
            char *new_buffer = realloc(buffer, buffer_size);
            if (new_buffer == NULL) {
                free(buffer);
                fprintf(stderr, "memory allocation failed\n");
                exit(1);
            }
            buffer = new_buffer;
        }
        // break when reach end of line
        if (ch == '\n') break;
    }

    if (curr_size == 0 && ch == EOF) {
        // no more lines to read
        free(buffer);
        *datapp = NULL;
        return 0;
    }

    // Null to terminate the string
    buffer[curr_size] = '\0';

    // set up pointer to dynamically allocated memory
    *datapp = buffer;

    return curr_size;
}
