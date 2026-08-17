#include "processing.h"
#include <cctype> 
#include <string>

string stripNonAlphaNum(string input) {
    size_t start = firstAlphaNum(input);
    if (start == std::string::npos) {
        return "";
    }
    size_t end = lastAlphaNum(input);
    size_t length = end - start + 1;
    return input.substr(start, length);
}

size_t firstAlphaNum(const string &input) {
    for (size_t i = 0; i < input.length(); i++) {
        if (std::isalnum(input[i])) {
            return i;
        }
    }
    return std::string::npos;
}

size_t lastAlphaNum(const string &input) {
    for (size_t i = input.length() - 1; i >= 0; i--) {
        if (std::isalnum(input[i])) {
            return i;
        }
    }
    return std::string::npos;
}

/*
* traverseDirectory
* purpose: print paths of files
* parameters: string directory
* return: none
* effect: use recursion to print out paths of files
*/
void traverseDirectory(string directory) {
    FSTree dirTree(directory);
    DirNode *root = dirTree.getRoot();
    travHelper(root, "");
}

/*
* travHelper
* purpose: helper function to recursively traverse the tree
* parameters: DirNode and string path
* return: none
* effect: recursively traverse the tree
*/
void travHelper(DirNode *node, string path) { 

    // reaches the end nodes
    if (node->hasFiles()) {
        for (int i = 0; i < node->numFiles(); i++) {
            if (path == "") {
                cout << node->getName() << "/" << node->getFile(i) << endl;;
            }
            else {
                cout <<  path << "/" << node->getName() << "/" 
                << node->getFile(i) << endl;
            }
        }
    } 

    // recursive case
    if (node->hasSubDir()) {
        for (int i = 0; i < node->numSubDirs(); i++) {
            string dir = path + "/" + node->getName();
            if (path == "") {
                dir = node->getName();
            }
            // cout << "path:" << dir << endl;
            travHelper(node->getSubDir(i), dir);
        }
    }
}
