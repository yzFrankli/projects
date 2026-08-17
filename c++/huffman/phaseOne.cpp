/*
phaseOne.cpp
*/

#include <iostream>
#include <map>
#include <queue>
#include <vector>
#include <sstream>

#include "phaseOne.h"
#include "HuffmanTreeNode.h"

// TODO: phaseOne
/*
* print frequencies
* serialize Huffmantree
* deserialize HuffmanTree
*/


void count_freqs(std::istream &text) {
    // get the input and store it in string var
    char curr_char;
    std::map<char, int> mymap;

    // insert frequencies in the map 
    while(text.get(curr_char)) {
        mymap[curr_char]+=1;
    }
    // print out the frequencies 
    for (std::map<char,int>::iterator it=mymap.begin(); it!=mymap.end(); ++it)
    std::cout << it->first << ": " << it->second << '\n';

}

std::string serialize_tree(HuffmanTreeNode *root) {
    std::string str = tree_helper(root);
    std::cout << str << std::endl;
    return str;
}


HuffmanTreeNode *deserialize_tree(const std::string &s) {
    std::priority_queue<HuffmanTreeNode*, std::vector<HuffmanTreeNode*>,
                   NodeComparator> my_pq;
    return deserialize_helper(s, my_pq);

}


HuffmanTreeNode *deserialize_helper(const std::string &s, std::priority_queue
    <HuffmanTreeNode*, std::vector<HuffmanTreeNode*>, NodeComparator> my_pq) {
    // base cases
    // when it reaches L it attaches leaves
    int length = s.length();
    std::cerr << "executing " << std::endl;

    // deal with internal nodes
    for (int i = 0; i < length; i++) {
        if (s[i] == 'I' and s[i+1] != 'L') {
            std::cerr << "s: " << s << std::endl;
            // create an internal node
            HuffmanTreeNode *in_node = new HuffmanTreeNode('\0', 0);
            in_node->set_left(deserialize_helper(s.substr(i+1, length), my_pq));
            in_node->set_right(deserialize_helper(s.substr(i+3, length), my_pq));
            my_pq.push(in_node);
            return my_pq.top();
        }
    }

    // deal with leaf nodes
    for (int i = 0; i < length; i++) {
        if (s[i] == 'L') {
            // create a leaf
            HuffmanTreeNode *leaf_a = new HuffmanTreeNode(s[i+1], 0);
            my_pq.push(leaf_a);
            HuffmanTreeNode *leaf_b = new HuffmanTreeNode(s[i+3], 0);
            my_pq.push(leaf_b);
            HuffmanTreeNode *node = new HuffmanTreeNode('\0', 0, 
                    leaf_a, leaf_b);
            s.substr(i+4, length);
            std::cerr << "s leaf: " << s << std::endl;

            return node;
        }
        
    }



}






std::string tree_helper(HuffmanTreeNode *node) {
    // base cases
    // return when the current node is a leaf
    std::ostringstream stream;
    if (node->isLeaf()) {
        stream << "L" << node->get_val();
        return stream.str();
    }

    // return if the tree is empty
    if (node == nullptr) {
        return stream.str();
    }

    // recursive cases
    // go to the left and right
    stream << "I";
    stream << tree_helper(node->get_left());
    stream << tree_helper(node->get_right());
    return stream.str();
    
}




