/*
 *  File.h
 *  Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project 4 Gerp
 *
 *  contains header for class File.h
 *
 */

#ifndef FILE_H
#define FILE_H

#include <iostream>
#include <vector>
#include <fstream>
#include <string>

using namespace std;

class File {
private:
    vector<string> filePaths;

public:
    void addFilePath(const string &path);
    size_t getSize();
    string getFilePath(size_t index) const;
    string readLine(const string &filePath, int lineNumber);

};

#endif
