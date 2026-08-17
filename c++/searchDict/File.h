/*
 *  File.h
 *  Frank Li & Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project Gerp
 *
 *  contains header for class File.h
 *
 */

#ifndef FILE_H
#define FILE_H

#include <iostream>
#include <vector>
#include <fstream>
#include "processing.h"
#include "HashTable.h"

using namespace std;

class File {
public:
    void traverseFile(string filename);
    void getLineNum();
    void searchDir(string word, ofstream &stream);
    void searchSensitive(string word, ofstream &stream);

private:
    struct fileContent {
        string path;
        vector <string> lines;
    };
    vector <fileContent> files;
    struct wordInfo {
        string word;
        int fileIndex;
        int lineOccurence;
    };
    vector <wordInfo> temp;


   void travHelper(DirNode *node, string path);
   void moveWord(string line, int lineNum, int fileIndex);
   void moveHash();
      
   

};

#endif // FILE_H
