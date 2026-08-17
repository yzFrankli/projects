void HuffmanCoder::encode(const std::string &input_file, const std::string &output_file) {
    
    // count the frequencies of characters in the input file
    std::map<char, int> mymap;
    count_freqs(input_file);

    // build the Huffman tree


    // encode the given text in binary 

    // saving the serialized tree and encoded text in the output file
}

void HuffmanCoder::count_freqs(std::istream &text, std::map<char, int> mymap) {
    // get the input and store it in string var
    char curr_char;

    // insert frequencies in the map 
    while(text.get(curr_char)) {
        mymap[curr_char]+=1;
    }
}

void HuffmanCoder::build_tree(std::map<char, int> mymap);