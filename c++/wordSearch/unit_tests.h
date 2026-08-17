/*
 *  unit_tests.h
 *  Peter Ren (jren03), Frank Li (yli57)
 *  04/15/2024
 *
 *  CS 15 Project 4 - Gerp
 *
 *  Use unit_test framework to test.
 */

#include "processing.h"
#include "HashTable.h"
// #include "File.h"
#include <iostream>
#include <sstream>
#include <cassert>
#include <set>


// /* PhaseOne testing */
// // test stripping a basic string
// void testStripBasic() {
//     std::string input = "@#hello world!!";
//     std::string expected = "hello world";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripBasic: Passed\n";
//     else
//         std::cout << "testStripBasic: Failed\n";
// }

// // test stripping a string without any AlphaNum
// void testStripNoAlphaNum() {
//     std::string input = "@##!!#!@!#";
//     std::string expected = "";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripNoAlphaNum: Passed\n";
//     else
//         std::cout << "testStripNoAlphaNum: Failed\n";
// }

// // test stripping an empty string
// void testStripEmpty() {
//     std::string input = "";
//     std::string expected = "";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripEmpty: Passed\n";
//     else
//         std::cout << "testStripEmpty: Failed\n";
// }

// // test stripping a string with only AlphaNum
// void testStripOnlyAlphaNum() {
//     std::string input = "HelloWorld123";
//     std::string expected = "HelloWorld123";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripOnlyAlphaNum: Passed\n";
//     else
//         std::cout << "testStripOnlyAlphaNum: Failed\n";
// }

// // test stripping a complex string
// void testStripComplex() {
//     std::string input = "!!!123Hello-World!!!";
//     std::string expected = "123Hello-World";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripComplex: Passed\n";
//     else
//         std::cout << "testStripComplex: Failed\n";
// }

// // test stripping a string with non-AlphaNum symbols in the middle of AlphaNum
// void testStripSymbolsMiddle() {
//     std::string input = "Hello$$$World";
//     std::string expected = "Hello$$$World";
//     std::string result = stripNonAlphaNum(input);
//     assert(result == expected);
//     if (result == expected)
//         std::cout << "testStripSymbolsMiddle: Passed\n";
//     else
//         std::cout << "testStripSymbolsMiddle: Failed\n";
// }

// test traversing a tiny directory
void diff_test_tinyData() {
    string directory = "proj-gerp-test-dirs/tinyData";
    traverseDirectory(directory);
}

// // test traversing smallGutenBerg
// void diff_test_smallGutenBerg() {
//     string directory = "proj-gerp-test-dirs/smallGutenberg";
//     traverseDirectory(directory);
// }

// // test traversing mediumGutenBerg
// void diff_test_midGutenBerg() {
//     string directory = "proj-gerp-test-dirs/mediumGutenberg";
//     traverseDirectory(directory);
// }

// // test traversing largeGutenBerg
// void diff_test_largeGutenBerg() {
//     string directory = "proj-gerp-test-dirs/largeGutenberg";
//     traverseDirectory(directory);
// }


/* PhaseTwo testing */
// test creating a Location object through default constructor
void testDefaultLocationConstructor() {
    HashTable::Location loc;
    assert(loc.fileLines.empty());
    std::cout << "testDefaultLocationConstructor: Passed\n";
}

// test creating a Location object through parameterized constructor
void testLocationConstructor() {
    HashTable::Location loc(1, 100);
    assert(loc.fileLines.size() == 1);
    assert(loc.fileLines[0].first == 1 
           && loc.fileLines[0].second.count(100) == 1);
    std::cout << "testLocationConstructor: Passed\n";
}

// test adding a Location of the word
void testAddSingleLocation() {
    HashTable::Location loc;
    loc.addLocation(1, 100);

    assert(loc.fileLines.size() == 1);
    assert(loc.fileLines[0].second.size() == 1);
    assert(loc.fileLines[0].second.count(100) == 1);
    std::cout << "testAddSingleLocation: Passed\n";
}

// test adding multiple line numbers within the same file
void testAddManyLines() {
    HashTable::Location loc;
    loc.addLocation(1, 100);
    loc.addLocation(1, 101);
    loc.addLocation(1, 102);

    assert(loc.fileLines.size() == 1);
    assert(loc.fileLines[0].second.size() == 3);
    assert(loc.fileLines[0].first == 1);
    assert(loc.fileLines[0].second.count(100) == 1
           && loc.fileLines[0].second.count(101) == 1
           && loc.fileLines[0].second.count(102) == 1);
    std::cout << "testAddManyLines: Passed\n";
}

// test adding repetitive line numbers within the same file
// the repetitive line numbers shoud not be added twice
void testAddRepetitiveLines() {
    HashTable::Location loc;
    loc.addLocation(1, 100);
    loc.addLocation(1, 101);
    loc.addLocation(1, 101);

    assert(loc.fileLines.size() == 1);
    assert(loc.fileLines[0].second.size() == 2);
    assert(loc.fileLines[0].second.count(100) == 1
           && loc.fileLines[0].second.count(101) == 1);
    std::cout << "testAddRepetitiveLines: Passed\n";
}

// test adding multiple Locations of the same word from multiple files
void testAddManyLocations() {
    HashTable::Location loc;
    loc.addLocation(1, 100);
    loc.addLocation(2, 100);

    assert(loc.fileLines.size() == 2);
    assert(loc.fileLines[0].second.size() == 1);
    assert(loc.fileLines[0].first == 1);
    assert(loc.fileLines[1].second.size() == 1);
    assert(loc.fileLines[1].first == 2);
    assert(loc.fileLines[0].second.count(100) == 1
           && loc.fileLines[1].second.count(100) == 1);
    std::cout << "testAddtestAddManyLocations: Passed\n";
}

// test converting all characters in a word to lower case
void testNormalizeKey() {
    HashTable ht(10);
    std::string normalized = ht.normalizeKey("HelloWorld");
    assert(normalized == "helloworld");
    std::cout << "testNormalizeKey: Passed\n";
}

// test normalizing an empty key
void testNormalizeEmptyKey() {
    HashTable ht(10);
    std::string normalized = ht.normalizeKey("");
    assert(normalized == "");
    std::cout << "testNormalizeEmptyKey: Passed\n";
}

// test the hash index is in the valid range of the hash table
void testGetIndex() {
    int tableSize = 10;
    HashTable ht(10);
    size_t index = ht.getIndex("testkey");

    assert(index >= 0 && index < tableSize);
    std::cout << "testGetIndex: Passed\n";
}

// manually trigger a resize to test rehashing
void testRehashItem() {
    HashTable ht(2);
    ht.addWord("rehash", 1, {1});
    size_t oldIndex = ht.getIndex("rehash");
    ht.resizeTable();

    size_t newIndex = ht.getIndex("rehash");
    assert(newIndex != oldIndex);
    assert(newIndex < ht.numBuckets * 2);
    std::cout << "testRehashItem: Passed\n";
}

// Test automatically resizing the hash table
void testResizeTable() {
    HashTable ht(1);
    ht.addWord("hello", 1, 1);
    ht.addWord("world", 2, 1);

    assert(ht.table.size() > 1);
    std::cout << "testResizeTable: Passed\n";
}

// test getWordLocation returns the correct information about the word
void testGetWordLocation() {
    HashTable ht(10);
    ht.addWord("location", 1, 1);
    HashTable::Location *loc = ht.getSensitiveLocation("location");

    assert(loc->getSize() == 1 && loc[0].fileLines.size() == 1);
    std::cout << "testGetWordLocation: Passed\n";
}

// test Adding a single word with one line number to the hash table
void testAddSingleWord() {
    HashTable ht(10);
    ht.addWord("hello", 1, 1);
    HashTable::Location *loc = ht.getSensitiveLocation("hello");

    assert(loc->getSize() == 1 && loc[0].fileLines.size() == 1);
    assert(loc[0].fileLines[0].second.size() == 1);
    std::cout << "testAddSingleWord: Passed\n";
}

// test Adding a single word with the same line multiple times to hash table
// the line number should not appear twice
void testAddSameLine() {
    HashTable ht(10);
    ht.addWord("hello", 1, 2);
    ht.addWord("hello", 1, 2);

    HashTable::Location* loc = ht.getSensitiveLocation("hello");
    assert(loc->getSize() == 1 && loc[0].fileLines.size() == 1);
    assert(loc[0].fileLines[0].second.size() == 1);
    std::cout << "testAddSameLine: Passed\n";
}

// test the strategy of handling collision when hashing different words
// in the same bucket
void testHandleCollision() {
    HashTable ht(1);
    ht.addWord("hello", 1, 1);
    ht.addWord("world", 1, 1);

    assert(ht.getSensitiveLocation("hello") != nullptr 
           && ht.getSensitiveLocation("world") != nullptr);
    std::vector<HashTable::Location*> locs = ht.getWordLocation("hello");
    assert(locs.size() == 1);
    std::cout << "testHandleCollision: Passed\n";
}

// test adding a variation of the word
void testAddWordVariation() {
    HashTable ht(10);
    ht.addWord("Test", 1, 1);
    ht.addWord("test", 1, 2);

    std::vector<HashTable::Location*> locs = ht.getWordLocation("test");
    assert(locs.size() == 2);
    std::cout << "testAddWordAndUpdateVariation: Passed\n";
}

// test resizing the hash table when exceeding its capacity
void testResizeOnAdd() {
    HashTable ht(2);
    ht.addWord("word1", 1, 1);
    ht.addWord("word2", 1, 1);
    ht.addWord("word3", 1, 1);

    assert(ht.getSensitiveLocation("word3") != nullptr);
    assert(ht.numElements == 3);
    std::cout << "testResizeOnAdd: Passed\n";
}

// test upadting the same word from multiple files
void testAddMultipleFiles() {
    HashTable ht(10);
    ht.addWord("reuse", 1, 1);
    ht.addWord("reuse", 2, 2);

    HashTable::Location* loc = ht.getSensitiveLocation("reuse");
    assert(loc->getSize() == 2);
    assert(ht.numElements == 1);
    assert(loc[0].fileLines[0].first == 1);
    assert(loc[0].fileLines[1].first == 2);
    std::cout << "testAddMultipleFiles: Passed\n";
}

// test finding a word not in the hash table, it should return a nullptr
void testWordNotFound() {
    HashTable ht(10);
    ht.addWord("exist", 1, {1});
    
    HashTable::Location* loc = ht.getSensitiveLocation("nonexist");
    assert(loc == nullptr);
    std::cout << "testWordNotFound: Passed\n";
}

// // test adding a file path to the vector
// void testAddFilePath() {
//     File fileManager;
//     std::string path = "test/path/file1.txt";
//     fileManager.addFilePath(path);
    
//     assert(fileManager.getSize() == 1);
//     assert(fileManager.getFilePath(0) == path);
//     std::cout << "testAddFilePath: Passed\n";
// }

// // test adding multiple file paths to the vector
// void testAddManyFilePaths() {
//     File fileManager;
//     fileManager.addFilePath("test/path/file1.txt");
//     fileManager.addFilePath("test/path/file2.txt");
//     fileManager.addFilePath("test/path/file3.txt");
//     fileManager.addFilePath("test/path/file4.txt");
//     fileManager.addFilePath("test/path/file5.txt");
//     fileManager.addFilePath("test/path/file6.txt");
//     fileManager.addFilePath("test/path/file7.txt");

//     assert(fileManager.getSize() == 7);
//     std::cout << "testAddManyFilePaths: Passed\n";
// }

// // test getting a valid file path from the vector
// void testGetFilePathValid() {
//     File fileManager;
//     std::string filePath = "test/path/file1.txt";
//     fileManager.addFilePath(filePath);
//     string path = fileManager.getFilePath(0);
//     assert(path == filePath);
//     std::cout << "testGetFilePathValid: Passed\n";
// }

// // test getting an invalid file path from the vector
// void testGetFilePathInvalid() {
//     File fileManager;
//     std::string filePath = "test/path/file1.txt";
//     fileManager.addFilePath(filePath);
//     string path = fileManager.getFilePath(1);
//     assert(path.empty());
//     std::cout << "testGetFilePathInvalid: Passed\n";
// }

// test loading files data from tinyData
// void testTraverseFileTiny() {
//     File fileManager;
//     fileManager.traverseFile("proj-gerp-test-dirs/tinyData");

//     assert(not fileManager.files.empty()); 
//     std::cout << "testTraverseFileTiny: Passed\n";
// }

// // test loading files data from smallGutenBexrg
// void testTraverseFileSmall() {
//     File fileManager;
//     fileManager.traverseFile("proj-gerp-test-dirs/smallGutenberg");

//     assert(not fileManager.files.empty()); 
//     std::cout << "testTraverseFileSmall: Passed\n";
// }

// // test loading files data from an invalid directory
// void testTraverseFileInvalid() {
//     File fileManager;
//     try{
//         fileManager.traverseFile("proj-gerp-test-dirs/test");
//     } catch (const std::runtime_error &e) {
//         string error = "Directory \"proj-gerp-test-dirs/test\"";
//         error += " not found: could not build tree";
//         assert (std::string(e.what()) == error);
//         std::cout << "testTraverseFileInvalid: Passed\n";
//     }    
// }

// // test loading files data from largeGutenBexrg
// void testTraverseFileLarge() {
//     File fileManager;
//     fileManager.traverseFile("proj-gerp-test-dirs/largeGutenberg");
    
//     assert(not fileManager.files.empty()); 
//     std::cout << "testTraverseFileLarge: Passed\n";
// }

// // test loading sentences to the vector
// void testGetLineNum() {
//     File fileManager;
//     fileManager.traverseFile("proj-gerp-test-dirs/tinyData");
//     fileManager.getLineNum(); 

//     assert(not fileManager.files.empty() 
//            && not fileManager.files[0].lines.empty());
//     std::cout << "testGetLineNum: Passed\n";
// }

// // test loading sentences to the vector
// void testGetLine() {
//     File fileManager;
//     fileManager.traverseFile("proj-gerp-test-dirs/tinyData");
//     fileManager.getLineNum(); 
//     assert(not fileManager.files.empty());
//     string content = "gerp hey you DO YOU KNOW WHO TAHT IS?";
//     std::cout <<  fileManager.files[0].lines[0] << std::endl;
//     std::cout <<  fileManager.files[0].lines[1] << std::endl;
//     std::cout <<  fileManager.files[0].lines[2] << std::endl;
//     std::cout <<  fileManager.files[0].lines[3] << std::endl;
//     //assert(fileManager.files[0].lines[0] == content);
//     std::cout << "testGetLineNum: Passed\n";
// }


// testing FILE class
// void diff_test_tinyData() {
//     string directory = "proj-gerp-test-dirs/tinyData";
//     traverseDirectory(directory);
// }

// void test_getLineNum() {
//     File test;
//     test.traverseFile("proj-gerp-test-dirs/tinyData");
//     test.getLineNum();

// }

// void test_searchDir() {
//     File newFile;
//     newFile.traverseFile("proj-gerp-test-dirs/largeGutenberg/");
//     newFile.getLineNum();
//     newFile.searchDir("you");
// }

