
/*
 * HashTable.cpp
 * Peter Ren (jren03)
 * 04/21/2024
 * 
 * CS 15 Project 4 Gerp
 *
 * Function definitions for HashTable.
 */

#include "HashTable.h"

/*
 * name:      Location (default constructor)
 * purpose:   Initializes a Location instance, setting the file index to 0.
 * arguments: none
 * returns:   none
 * effects:   Sets the 'file' member of the Location object to 0 
 *            and initializes an empty set of line numbers.
 */
HashTable::Location::Location() {

}

/*
 * name:      Location (parameterized constructor)
 * purpose:   Constructs a Location with a specified file index and 
 *            a set of line numbers.
 * arguments: size_t fileIndex - the index of the file.
 *            const set<int> &lineNumbers - a set of integers 
 *            representing line numbers.
 * returns:   none
 * effects:   Sets the 'file' member to the specified file index and 
 *            'lines' to the given set of line numbers.
 */
HashTable::Location::Location(size_t fileIndex, int lineNumber) {
    fileLines.emplace_back(fileIndex, set<int>{lineNumber});
}

/*
 * name:      addLineNumber
 * purpose:   Adds a line number to the Location's set of line numbers.
 * arguments: int lineNumber - the line number to add.
 * returns:   none
 * effects:   Inserts the specified line number into the 'lines' set. Does 
 *            not insert duplicates due to set properties.
 */
void HashTable::Location::addLocation(size_t fileIndex, int lineNumber) {
    // Check if the file index already exists
    for (auto &line : fileLines) {
        if (line.first == fileIndex) {
            line.second.insert(lineNumber);
            return;
        }
    }

    fileLines.emplace_back(fileIndex, set<int>{lineNumber});
}

/*
 * name:      display
 * purpose:   Outputs the contents of the Location object to standard output
 *            for testing, including file index and line numbers.
 * arguments: none
 * returns:   none
 * effects:   Prints the file index and all line numbers stored in the 
 *            Location to standard output.
 */
void HashTable::Location::display() const {
    for (const auto &pair : fileLines) {
        cout << "File Index: " << pair.first << "\nLine Numbers: ";
        for (int line : pair.second) {
            cout << line << " ";
        }
        cout << endl;
    }
}

/*
 * name:      getIndex
 * purpose:   Computes the hash table index for a given key based on 
 *            the hash function and current table size.
 * arguments: const string &key - the key to hash.
 * returns:   size_t - the index in the table where the key should be located.
 * effects:   Utilizes the hash function and mod operation by number of 
 *            buckets to calculate the index.
 */
size_t HashTable::getIndex(const string &key) {
    return hashFunction(normalizeKey(key)) % numBuckets;
}

/*
 * name:      resizeTable
 * purpose:   Doubles the size of the hash table and 
 *            rehashes all elements to the new table.
 * arguments: none
 * returns:   none
 * effects:   Increases the table size and redistributes all existing items.
 */
void HashTable::resizeTable() {
    size_t newSize = numBuckets * 2;
    vector<vector<BucketItem>> newTable(newSize);

    for (auto &bucket : table) {
        for (auto &item : bucket) {
            rehashItem(item, newTable, newSize);
        }
    }

    table = newTable;
    numBuckets = newSize;
}

/*
 * name:      rehashItem
 * purpose:   Rehashes a single item into the new table during table resizing.
 * arguments: const BucketItem &item - the item to rehash.
 *            vector<vector<BucketItem>> &newTable - reference to 
 *            the new hash table.
 *            size_t newSize - the new size of the hash table.
 * returns:   none
 * effects:   Calculates the new index for the item and inserts it into the 
 *            appropriate bucket in the new table.
 */
void HashTable::rehashItem(const BucketItem &item, 
                           vector<vector<BucketItem>> &newTable, 
                           size_t newSize) {
    size_t newIndex = hashFunction(item.normalizedKey) % newSize;
    newTable[newIndex].push_back(item);
}

/*
 * name:      normalizeKey
 * purpose:   Converts a string to lowercase for consistent key 
 *            handling in the hash table.
 * arguments: const string &word - The string to normalize.
 * returns:   string - The lowercase version of the input string.
 * effects:   Allocates memory for the lowercased string and converts each 
 *            character to lowercase, optimizing with memory reservation to 
 *            minimize reallocations.
 */
string HashTable::normalizeKey(const string &word) {
    string lower;
    lower.reserve(word.size());  // Reserve memory to avoid multiple allocations

    for (char c : word) {
        lower += tolower(c);
    }

    return lower;
}

/*
 * name:      HashTable (constructor)
 * purpose:   Initializes a hash table with a specified number of buckets.
 * arguments: size_t numBuckets - the initial number of buckets.
 * returns:   none
 * effects:   Sets the initial number of buckets and elements and resizes the 
 *            internal vector to match the number of buckets.
 */
HashTable::HashTable(size_t newBuckets) {
    table.resize(newBuckets);
    numBuckets = newBuckets;
    numElements = 0;
}

/*
 * name:      addWord
 * purpose:   Adds a word and its location to the hash table or 
 *            updates the location if the word already exists.
 * arguments: const string &word - The word to add or update.
 *            size_t fileIndex - The index of the file where the word is found.
 *            const set<int> &newLines - The set of new line numbers 
 *            where the word occurs.
 * returns:   none
 * effects:   Normalizes the word, checks for existence, updates or adds the 
 *            word to the hash table, and resizes the table if the load factor 
 *            exceeds the threshold.
 */
void HashTable::addWord(const string &word, size_t fileIndex, int lineNumber) {
    string normalizedWord = normalizeKey(word);
    size_t index = getIndex(normalizedWord);
    auto &bucket = table[index];
    for (auto &item : bucket) {
        if (item.normalizedKey == normalizedWord) {
            updateVariation(item, word, fileIndex, set<int>{lineNumber});
            return;
        }
    }

   // If the normalized word was not found, add a new BucketItem
    bucket.emplace_back(BucketItem{normalizedWord, {{word, Location()}}});
    bucket.back().variations.back().second.addLocation(fileIndex, lineNumber);
    numElements++;
    if (numElements > numBuckets) {
        resizeTable();
    }
}

/*
 * name:      updateVariation
 * purpose:   Updates the location information of a word variation 
 *            within a bucket or adds a new variation.
 * arguments: BucketItem &item - The bucket item being updated.
 *            const string &word - The specific variation of the word to update
 *            size_t fileIndex - The index of the file where the word is found.
 *            const set<int> &newLines - The set of new line numbers.
 * returns:   none
 * effects:   Modifies the 'Location' object associated with the word variation
 */
void HashTable::updateVariation(BucketItem &item, const string &word, 
                                size_t fileIndex, const set<int> &newLines) {
    // Update existing location with new file index and line numbers
    for (auto &var : item.variations) {
        if (var.first == word) {
            // Update existing location with each new line number
            for (int lineNumber : newLines) {
                var.second.addLocation(fileIndex, lineNumber);
            }
            return;
        }
    }

    // If the variation does not exist, add it
    Location newLocation;
    for (int lineNumber : newLines) {
        newLocation.addLocation(fileIndex, lineNumber);
    }
    item.variations.emplace_back(word, newLocation);
}

/*
 * name:      getWordLocation
 * purpose:   Retrieves all location objects associated with 
 *            variations of a word.
 * arguments: const string &word - The word whose locations are sought.
 * returns:   vector<Location*> - A vector of pointers to location 
 *            objects for each word variation.
 * effects:   Searches the hash table for the normalized key and 
 *            collects all corresponding location pointers.
 */
vector<HashTable::Location*> HashTable::getWordLocation(const string &word) {
    vector<Location*> locations;
    string normalizedWord = normalizeKey(word);
    size_t index = getIndex(normalizedWord);

    for (auto &item : table[index]) {
        if (item.normalizedKey == normalizedWord) {
            for (auto &var : item.variations) {
                locations.push_back(&var.second);
            }
            return locations;
        }
    }
    return locations;
}

/*
 * name:      getSensitiveLocation
 * purpose:   Retrieves the exact location object for a case-sensitive word.
 * arguments: const string &word - The case-sensitive word.
 * returns:   Location* - A pointer to the location object for the word.
 * effects:   Searches the hash table for the normalized key and 
 *            returns the location for the exact word match.
 */
HashTable::Location *HashTable::getSensitiveLocation(const string &word) {
    string normalizedWord = normalizeKey(word);
    size_t index = getIndex(normalizedWord);

    for (auto &item : table[index]) {
        if (item.normalizedKey == normalizedWord) {
            for (auto &var : item.variations) {
                if (var.first == word) {
                    return &var.second;
                }
            }
        }
    }
    return nullptr;
}
