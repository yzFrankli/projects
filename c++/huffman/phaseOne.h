#include <istream>
#include <string>
#include <queue>

#include "HuffmanTreeNode.h"




void count_freqs(std::istream &text);
std::string serialize_tree(HuffmanTreeNode *root);
HuffmanTreeNode *deserialize_tree(const std::string &s);

std::string tree_helper(HuffmanTreeNode *node);
HuffmanTreeNode *deserialize_helper(const std::string &s, std::priority_queue
    <HuffmanTreeNode*, std::vector<HuffmanTreeNode*>, NodeComparator> my_pq);