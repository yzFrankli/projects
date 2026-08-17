#ifndef _HUFFMAN_CODER
#define _HUFFMAN_CODER

#include <string>
#include <map>
#include "HuffmanTreeNode.h"
#include <iostream>

using namespace std;

class HuffmanCoder {
    // Feel free to add additional private helper functions as well as a
    // constructor and destructor if necessary
   public:
    void encoder(const std::string &inputFile, const std::string &outputFile);
    void decoder(const std::string &inputFile, const std::string &outputFile);

    private:
    void count_freqs(std::istream &text, std::map<char, int> mymap);
    void build_tree(std::map<char, int> mymap);
};

#endif