/*
 *  main.cpp
 *  Frank Li & Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project Gerp
 *
 *  get commands from the command line
 *
 */
#include "processing.h"
#include "Gerp.h"
#include "File.h"

using namespace std;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        cerr << "Usage: ./gerp inputDirectory outputFile\n";
        return EXIT_FAILURE;
    }
    Gerp theGerp;
    theGerp.run(argv[1], argv[2]);
}
