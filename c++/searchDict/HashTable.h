
/*
 * HashTable.h
 * Peter Ren (jren03)
 * 04/21/2024
 * 
 * CS 15 Project 4 Gerp
 *
 * This header file declares the hashTable class for hashing all unique
 * words in all files from the assigned directory and its all subdirectories.
 * We create a hash in hash table to store all words and their locations.
 * The key type for hashTable 'uniqueWords' is a string of the unique word,
 * all capital; the value type is another hash table, storing all sensitive
 * searches of this unqiue word. The key type for hashTable 'exactWords' is
 * string of exact words; the value type is a struct 'location', storing
 * the index of the file path in 'Vector <fileContent> content', and the line
 * number.
 */

#ifndef _HASH_TABLE_
#define _HASH_TABLE_

#include <string>
#include <vector>
#include <set>
#include <functional>
#include <cctype>
#include <utility>
#include <iostream>

using namespace std;


// change public to private before submission


class HashTable {
private:
    /* struct Location contains the vector of pair, which the first is the 
       index to a vector holding file contents, and second is a set of 
       line numbers where the word appears */
    struct Location {
        vector<pair<size_t, set<int>>> fileLines;

        Location();
        Location(size_t fileIndex, int lineNumber);
        void addLocation(size_t fileIndex, int lineNumber);
        void display() const;
    };

    /* struct BucketItem contains the unique word, all lowercase, used as 
       the key in the hash table and a vector that stores all variations 
       of this word and its associated location as value of the hash */
    struct BucketItem {
        string normalizedKey;
        vector<pair<string, Location>> variations;
    };

    vector<vector<BucketItem>> table;
    hash<string> hashFunction;
    size_t  numElements;
    size_t  numBuckets;
    size_t  getIndex(const string &key);
    void    resizeTable();
    void    rehashItem(const BucketItem &item, 
                       vector<vector<BucketItem>> &newTable, size_t newSize);
    string  normalizeKey(const string &word);
    void    updateVariation(BucketItem &item, const string &word, 
                            size_t fileIndex, const set<int> &newLines);
 
public:
    // above are all private
    HashTable(size_t numBuckets);
    void    addWord(const string &word, size_t fileIndex, int lineNumber);
    vector<Location*> getWordLocation(const string &word);
    Location *getSensitiveLocation(const string &word);
};

#endif
