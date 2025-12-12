#include <fstream>
#include <iostream>
#include <string>

int main() {
    std::cout << "Testing C++ file operations similar to NymyaLang pattern..." << std::endl;
    
    // This mimics the pattern from crystal.nym: dalan_orin function
    std::string path = "cpp_taygetan_test.txt";
    std::string content = "Hello from Taygetan-style C++ test (dalan_orin equivalent)!";
    
    // Create ofstream (like dalan_lora in NymyaLang)
    std::ofstream file(path.c_str());
    
    // Check if not fail() like in NymyaLang
    if (!file.fail()) {
        file << content;
        file.close();
        std::cout << "File written with dalan_orin pattern: SUCCESS" << std::endl;
    } else {
        std::cout << "File written with dalan_orin pattern: FAILED" << std::endl;
    }
    
    // Check if file exists (like dalan_aya in NymyaLang)
    std::ifstream checkFile(path.c_str());
    if (!checkFile.fail()) {
        std::cout << "File exists check (dalan_aya pattern): EXISTS" << std::endl;
        checkFile.close();
        
        // Read content (like dalan_karma in NymyaLang)
        std::string readContent;
        std::ifstream readFile(path.c_str());
        std::getline(readFile, readContent);
        std::cout << "File content (dalan_karma pattern): " << readContent << std::endl;
        readFile.close();
    } else {
        std::cout << "File exists check (dalan_aya pattern): DOES NOT EXIST" << std::endl;
    }
    
    // Also test the is_open() version like in crystal/io.nym
    std::cout << "\nTesting is_open() version (like crystal/io.nym):" << std::endl;
    std::ofstream ioFile("cpp_io_test.txt");
    if (ioFile.is_open()) {
        ioFile << "Hello from is_open() test!";
        ioFile.close();
        std::cout << "is_open() write: SUCCESS" << std::endl;
    } else {
        std::cout << "is_open() write: FAILED" << std::endl;
    }
    
    std::ifstream ioCheck("cpp_io_test.txt");
    if (ioCheck.is_open()) {
        std::string ioContent;
        std::getline(ioCheck, ioContent);
        std::cout << "is_open() read: " << ioContent << std::endl;
        ioCheck.close();
    } else {
        std::cout << "is_open() read: FILE NOT FOUND" << std::endl;
    }
    
    std::cout << "Taygetan-style file test completed" << std::endl;
    return 0;
}