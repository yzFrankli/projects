#ifndef __PROCESSING_H
#define __PROCESSING_H

/*
 *   TODO: Update file header if you use this file in your solution to phase 2 
 */

#include <string>
using namespace std;

string stripNonAlphaNum(string input);
void traverseDirectory(string directory);

// Member helper functions
size_t firstAlphaNum(const string &input);
size_t lastAlphaNum(const string &input);
void travHelper(DirNode *node, string path);

#endif 
