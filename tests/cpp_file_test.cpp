#include <fstream>
#include <iostream>
#include <string>

int main() {
    std::cout << "Testing C++ file operations..." << std::endl;
    
    // Test basic file writing
    std::ofstream file("cpp_test_file.txt");
    if (file.is_open()) {
        file << "Hello from C++ file test!" << std::endl;
        file.close();
        std::cout << "File written successfully" << std::endl;
    } else {
        std::cout << "Failed to open file for writing" << std::endl;
    }
    
    // Check if file exists by trying to read it
    std::ifstream checkFile("cpp_test_file.txt");
    if (checkFile.good()) {
        std::cout << "File exists and is readable" << std::endl;
        checkFile.close();
        
        // Read and display content
        std::string line;
        std::ifstream readFile("cpp_test_file.txt");
        if (std::getline(readFile, line)) {
            std::cout << "File content: " << line << std::endl;
        }
        readFile.close();
    } else {
        std::cout << "File does not exist or is not readable" << std::endl;
    }
    
    std::cout << "C++ file test completed" << std::endl;
    return 0;
}