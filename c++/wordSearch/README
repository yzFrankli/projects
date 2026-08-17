/*
 *  README
 *  Frank Li & Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project Gerp
 *
 *  explanation of the data structure used in the program
 *
 */


A The title of the homework and the author names (you and your partner)
-------
Project Gerp
Peter Ren and Frank Li

B The purpose of the program
-------
The purpose is to find a word in a directory given by the user and output the 
results of the search in a file.


C Acknowledgements for any help you received, including references to outside 
sources you consulted (though there is no need list C++ references like 
cplusplus.com).
-------
we received help from TA who helped us to plan out the structure 
of the program.


D The files that you provided and a short description of what each file is and 
its purpose
-------
    * HashTable.h/HashTable.cpp
    These files contains HashTable class and is divided into the header file 
    and the implementation of the functions respectively. HashTable class uses 
    hash data structure to store all words and their variations. The search
    functions then return the location and fileIndex of the words for other
    class to use.

    * File.h/File.cpp
    File class handles all tasks related to the directory and files user 
    provided to write on. File class first loops through the given 
    search directory to store the file paths and lines in a vector data
    structure. Then it adds all the unique words to HashTable class. Finally it
    uses the search function in the HashTable class to find the given word
    and output the result in the file provided.

    * Gerp.h/Gerp.cpp
    Gerp class directly interacts with main.cpp and its task is to handle all
    the commands from the user and output the results using the function from
    File class.

    * main.cpp
    main.cpp is used to get the command line from terminal so it can pass the 
    given file and directory to the Gerp class. It also uses Gerp to handle
    commands from user.

    * unit_test.h
    unit_test is a testing framework that is used to test the functions from 
    each class.

E How to compile and run your program
-------
    * use "make"
    * use "./Gerp [inputDirectory] [outputFile]"

F An “architectural overview,” i.e., a description of how your various program 
modules relate. For example, the FSTree implementation keeps a pointer to the 
root DirNode.
-------
There are two parts to this program: building a class that stores each 
individual words and reading the words from the given search directory. 
HashTable class deals with storing each words efficiently so they are easy to
find later on. It also provides search function for case sensitive and 
insensitive words that returns the file index and line number of the word.
File class handles reading from the files in the given search directory and 
push each word into hash. It pushes the word as well as its relevant 
information such as the file that it is on and the location of the word in the 
file (line number). Later, when the user inputs a command, it is passed to File
class which uses search function from HashTable class to find the location
of the word and output the file path and line number. Gerp class handles user
commands and create an instance of the File class so the commands can be passed
to File, which in turn relies on HashTable to get the location of the word. 

G An outline of the data structures and algorithms that you used. Given that 
this is a data structures class, you need to always discuss any data structures 
that you used and justify why you used them. For this assignment it is 
imperative that you explain your data structures and algorithms in detail, 
as it will help us understand your code since there is no single right way of 
completing this assignment.
-------
Hash Table:
    * Struct: 
    The class uses a struct named BucketItem to store the normalized
    key which is a lowercase version of the word and a vector named variations
    which stores pairs in each element. The pair has the original word and a 
    struct named Location containing information about the word. 
    Location struct holds all the essential information needed to find the line
    in which the word appears. It includes a vector fileLines that stores pairs 
    of fileIndex and a set of line numbers which the word appears in the file.
    Location struct also includes location functions that can initialize and 
    updates the location data of the word. 
    * Collision:
    Table is a 2 dimensional array that has an aray of BucketItem structs. 
    Each item on the row stores an unique word from the directory. BucketItem 
    acts as a key to the Hashfunction which assigns each bucket an index. When 
    multiple buckets are assigned to the same index, it uses the method of 
    separate chaining and pushes the bucket into the list of bucketItem struct
    (column on the table). 
    * Resizing:
    The hash table dynamically resizes itself when the load factor exceeds 
    a certain threshold (in this implementation, when the number of elements 
    exceeds the number of buckets). This is handled by the resizeTable 
    function, which doubles the size of the table and rehashes all 
    elements into the new table.
    * Insertion: 
    When adding a word to the hash table (addWord function), the key 
    (normalized word) is hashed to obtain its index. Then, the function checks 
    if there are any items in the bucket at that index. If there are no items, 
    the new key-value pair is simply inserted into the bucket. If there are 
    items present, the function iterates through each item in the bucket to 
    check if the key already exists. If the key exists, it updates the 
    corresponding location information. If the key does not exist, a 
    new BucketItem is added to the bucket.

File: 
    * Vector of fileContent:
    This vector stores information about each file, including its path 
    (string path) and a vector of lines (vector<string> lines). Each 
    fileContent struct represents a file and holds its path and content (lines).
    * Vector of wordInfo (temp):
    This vector temporarily stores information about words encountered 
    during file parsing. Each wordInfo struct contains information about a 
    word, including the word itself (string word), its line occurrence 
    (int lineOccurence), and the index of the file where it occurs (int 
    fileIndex).
    * FSTree and DirNode:
    These classes are used to traverse directory structures.
    FSTree represents the file system tree and provides methods for 
    navigating directories. DirNode represents a node in the directory tree 
    and contains information about files and subdirectories within that node.


H Details and an explanation of how you tested the various parts of your 
classes and the program as a whole. You may reference the testing files that 
you submitted to aid in your explanation.
-------
We used unit tests to test the functions in each file which are tested against
the reference outputs. main.cpp was used to test output of the functions. 
Finally, diff test was used to test the output of the results against the
provided reference solutions. Edge cases was tested such as invalid input, 
searching for case senstive word.  


I. Please let us know approximately how many hours you spent working on this 
project. This should include both weeks one and two.
------

30hrs
