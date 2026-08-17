/*
 *  File.cpp
 *  Peter Ren (jren03)
 *  4/21/2024
 *
 *  CS 15 Project 4 Gerp
 *
 *  Function definitions for File Class.
 *
 */

#include "File.h"

void File::addFilePath(const string &path) {
    filePaths.push_back(path);
}

size_t File::getSize() {
    return filePaths.size();
}

string File::getFilePath(size_t index) const {
    if (index < filePaths.size()) {
        return filePaths[index];
    } else {
        cerr << "File index out of range: " << index << endl;
        return "";
    }
}

string File::readLine(const string &filePath, int lineNumber) {
    std::ifstream file(filePath);
    std::string line;
    int currentLine = 0;

    while (getline(file, line)) {
        if (++currentLine == lineNumber) {
            return line;
        }
    }
    return "";
}