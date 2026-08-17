
/*
 *  File.cpp
 *  Frank Li & Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project Gerp
 *
 *  implementation for File.h, stores contents of file into a vector
 *
 */

#include "File.h"
#include <vector>
#include <sstream>


// initializing hashtable
int numBuckets = 10;
HashTable ht(numBuckets);

/*
* traverseFile
* purpose: go to every file
* parameters: string filename
* returns: none
* effect: use helper function to recurse through the end nodes
*/
void File::traverseFile(string filename) {
    // create a tree with the directory
    FSTree dirTree(filename);
    // get root of the directory
    DirNode *root = dirTree.getRoot();
    // traverse directory
    travHelper(root, "");
    // cout << files.size() << "File SIZE" << endl;
}

/*
* travHelper
* purpose: recurse through the file and add the path to the vector
* parameters: DirNode root and string path
* returns: none
* effect: use in order traversal to loop through the tree
*/
void File::travHelper(DirNode *node, string path) { 
    // reaches the end nodes
    if (node->hasFiles()) {
        for (int i = 0; i < node->numFiles(); i++) {
            if (path == "") {
                string currPath = node->getName() + "/" + node->getFile(i);
                // cout << currPath << endl;
                // push a new struct with the path to vector
                fileContent content;
                content.path = currPath;
                files.push_back(content);
            }
            else {
                string currPath = path + "/" + node->getName() + "/" 
                + node->getFile(i);
                // cout <<  path << "/" << node->getName() << "/" 
                // << node->getFile(i) << endl;

                // push to the vector
                fileContent content;
                content.path = currPath;
                files.push_back(content);
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
/*
* getLineNum()
* purpose: traverse through the file to store the line number in to the vector
in the struct
* parameters: none
* returns: none
* effect: go through all the file and store it in the given vector
*/ 
void File::getLineNum() {
    for (int i = 0; i < files.size(); i++) {
        // cout << "vector items: " << item.path << endl;

        string line;
        int lineNum = 0;
        // open file
        ifstream infile;
        infile.open(files.at(i).path);
        // add every lines to the vector
        while (getline(infile, line)) {
            if (line.size() == 0) {
                continue;
            }
            lineNum++; 
            
            // cout << line << endl;
            // push the string to the vector lines
            // cout << files.at(i).lines.size();
            files.at(i).lines.push_back(line);
            moveWord(line, lineNum, i);
        }
        
        // close file
        infile.close();
        

        // read line into hash until every word is in hash
        // pass it to gerp file
        // since we know the line number and file index

        // move to the next file repeat
                
    }
    moveHash();
    // print temp array words
    // for (int i = 0; i < temp.size(); i++) {
    //     cout << temp[i].word << endl;
    // }
}

void File::moveWord(string line, int lineNum, int fileIndex) {
    // cout << "lineNum: " << lineNum << endl;
    string word;
    istringstream ss(line);
    set <string> uniqueWords;
    // read and store each word 
    while(ss >> word) {
        // when there is repetition on the same line
        if (not uniqueWords.insert(word).second) {
            continue; // dont add to the set repetition found
        }
        wordInfo newWord;
        newWord.word = stripNonAlphaNum(word); // parse string when reading
        // store the line number
        newWord.lineOccurence = lineNum;
        // cout << "test fileIndex: " << fileIndex << endl;
        newWord.fileIndex = fileIndex;
        // cout << "lineNum: " << lineNum << endl;
        temp.push_back(newWord);
        // test output
        // cout << newWord.word << endl;
    }
}

void File::moveHash() {
    
    // add the words to hash and loop through the temp vectory
    for (int i = 0; i < temp.size(); i++) {
        // cout << temp[i].word;
        // cout << "test file: " << fileIndex << endl;
        // cout << "\n\n";
        // cout << "temp: " << temp.size() << endl;
        // cout << "size: " << temp[i].lineOccurence << endl;
        // cout << "fileIndex: " << temp[i].fileIndex << endl;
        ht.addWord(temp[i].word, temp[i].fileIndex, temp[i].lineOccurence);
    }
    // cout << ht.getWordLocation("we").size() << endl;
}

void File::searchDir(string word, ofstream &stream) {
    // result not found
    if (ht.getWordLocation(word).size() == 0) {
        stream << "query Not Found. Try with @insensitive or @i.\n";
        return;
    }
    int varNum = ht.getWordLocation(word).size();
    for (int i = 0; i < varNum; i++) {
        int wordNum = ht.getWordLocation(word).at(i)->fileLines.size();
        for (int j = 0; j < wordNum; j++) {
            int fileIndex = 
                ht.getWordLocation(word).at(i)->fileLines.at(j).first;
            for (set<int> :: iterator it=
                ht.getWordLocation(word).at(i)->fileLines.at(j).second.begin(); 
                it!=ht.getWordLocation(word).at(i)->fileLines.at(j).second.end(); 
                ++it)
            {  
                int lineNum = *it;
                stream << files.at(fileIndex).path << ":" << 
                *it << ": " << files.at(fileIndex).lines.at(lineNum - 1) 
                << endl;
                
            }
        }
        return;
    }
    // cout << ht.getWordLocation(word).at(0)->fileLines.size() << endl;

    // find number of occurences
    // int sizeWord = ht.getWordLocation(word).size();
    // cout << "size: " << sizeWord << endl;
    // // find the file index
    // for (int i = 0; i < sizeWord; i++) {
    //     stream << "file index: " << ht.getWordLocation(word).at(i)->file << endl;
    //     int fileIndex = ht.getWordLocation(word).at(i)->file;
        
        
        // iterate over the set in HashTable to get line number
        // for (set<int> :: iterator it=
        //     ht.getWordLocation(word).at(i)->lines.begin(); 
        //     it!=ht.getWordLocation(word).at(i)->lines.end(); ++it) 
        // {   
        //     // cout << "line number: " << *it << endl;
        //     stream << files[fileIndex].path;
        //     stream << ":" << *it << ": ";
        //     cout << *it << endl;
        //     cout << "size: " << files.at(fileIndex).lines.size() << endl;
        //     int size = files.at(fileIndex).lines.size();
            
        //     if (*it == size - 1) {
        //         return;
        //     }
        //     stream << files.at(fileIndex).lines.at(*it - 1) << endl;
        // }
    
    // }
}

void File::searchSensitive(string word, ofstream &stream) {
    // result not found
    if (ht.getWordLocation(word).size() == 0) {
        stream << "query Not Found.\n";
        return;
    }
    if (ht.getWordLocation(word).at(0)->fileLines.at(0).first != 0) {
        stream << "query Not Found.\n";
        return;
    }
    int wordNum = ht.getSensitiveLocation(word)->fileLines.size();
    for (int j = 0; j < wordNum; j++) {
        int fileIndex = 
            ht.getSensitiveLocation(word)->fileLines.at(j).first;
        for (set<int> :: iterator it=
            ht.getSensitiveLocation(word)->fileLines.at(j).second.begin(); 
            it!=ht.getSensitiveLocation(word)->fileLines.at(j).second.end(); 
            ++it)
        {  
            int lineNum = *it;
            stream << files.at(fileIndex).path << ":" << 
            *it << ": " << files.at(fileIndex).lines.at(lineNum - 1) 
            << endl;
            
        }
    }
}
