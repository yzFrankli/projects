/*
 *  Gerp.cpp
 *  Frank Li & Peter Ren
 *  4/21/2024
 *
 *  CS 15 Project Gerp
 *
 *  implementation for Gerp.h, handles execution of commands
 *
 */

#include "Gerp.h"
#include "File.h"

/*
* run()
* purpose: to execute the use commands
* parameters: string directory and string output file name
* return: none
* effect: search directory and output results
*/
void Gerp::run(string Dir, string Output) {
    // intialize File 
    File ht;
    ht.traverseFile(Dir);
    ht.getLineNum();
    string command, str, newStr, fileName;
    cout << "Query? ";
    ofstream file;
    file.open(Output);
    // create a while command loop
    while (cin >> command) {
        // cout << command << endl;
        // case insensitive
        if (command == "@i" or command == "@insensitive") {
            cin >> str;
            // implementation of case insensitive search            
            ht.searchDir(stripNonAlphaNum(str), file);
        } else if (command == "@f") {
            cin >> fileName;
            // write to the new fileName file
            run(Dir, fileName);

        } else if (command == "@q" or command == "@quit") {
            return;
        } else {
            ht.searchSensitive(stripNonAlphaNum(command), file);
        }

        cout << "Query? ";
        
    }
}
