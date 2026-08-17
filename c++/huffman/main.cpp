/* A simple program to demonstrate how to declare and use a min priority queue.
 * The min pq will contain pointers to instances of HuffmanTreeNode.
 *
 * Compile and link with the compiled HuffmanTreeNode class to run this program.
 * 
 * See C++ priority_queue documentation for more information:
 * https://cplusplus.com/reference/queue/priority_queue/
 *
 * Edited by: Milod Kazerounian, August 2022.
 */

#include "HuffmanTreeNode.h"
#include "phaseOne.h"
#include "ZapUtil.h"

#include <queue>
#include <iostream>
#include <fstream>

using namespace std;

int main()
{   
    // std::ifstream myfile;
    // myfile.open("hi.txt");
    // count_freqs(myfile);

    // printTree(makeFigure1Tree('\0'), '\0');
    // serialize_tree(makeFigure1Tree('\0'));
    serialize_tree(deserialize_tree("IIILaLbILeLfILcLd"));
    printTree(deserialize_tree("IIILaLbILeLfILcLd"), '\0');
    printTree(makeFigure1Tree('\0'), '\0');


}
