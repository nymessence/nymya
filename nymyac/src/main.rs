use std::fs;
use std::path::Path;
use clap::Parser;

/// NymyaLang Compiler - Compiles .nym files to executable code
#[derive(Parser)]
#[clap(author, version, about)]
struct Args {
    /// Input .nym file to compile
    #[clap(value_parser)]
    input: Option<String>,

    /// Output executable name
    #[clap(short, long, value_parser)]
    output: Option<String>,
}

// Enhanced target code generator - generates C++ code
fn generate_target(source_file: &str, source_code: String) -> String {
    // Create a C++ stub that represents the source code functionality
    format!(r#"/*
 * NymyaLang to C++ generated code (version 0.2.0-alpha~6)
 * Auto-generated from {0}
 */

#include <iostream>
#include <string>
#include <vector>
#include <cmath>

// Math utilities
namespace math {{
    double sqrt(double x) {{ return std::sqrt(x); }}
    double abs(double x) {{ return x < 0 ? -x : x; }}
    double min(double a, double b) {{ return a < b ? a : b; }}
    double max(double a, double b) {{ return a > b ? a : b; }}
    double pow(double base, double exp) {{ return std::pow(base, exp); }}
    double sin(double x) {{ return std::sin(x); }}
    double cos(double x) {{ return std::cos(x); }}
    double tan(double x) {{ return std::tan(x); }}
    
    const double PI = 3.141592653589793;
    
    // Integer math functions
    long long pow_int(long long base, long long exp) {{
        if (exp <= 0) return 1;
        long long result = 1;
        long long b = base;
        long long e = exp;
        while (e > 0) {{
            if (e % 2 == 1) result *= b;
            b *= b;
            e /= 2;
        }}
        return result;
    }}
    
    long long gcd(long long a, long long b) {{
        a = a < 0 ? -a : a;
        b = b < 0 ? -b : b;
        while (b != 0) {{
            long long temp = b;
            b = a % b;
            a = temp;
        }}
        return a;
    }}
}}

// Crystal utilities (console output)
namespace crystal {{
    void manifest(const std::string& msg) {{
        std::cout << msg << std::endl;
    }}
    
    void print(const std::string& msg) {{
        std::cout << msg;
    }}
}}

// Symbolic mathematics namespace
namespace symbolic {{
    namespace numerology {{
        struct Meaning {{
            std::string meaning;
            std::vector<std::string> traits;
        }};
        
        Meaning get_meaning(long long number) {{
            Meaning result;
            result.meaning = "Meaning for number " + std::to_string(number);
            result.traits = {{"trait1", "trait2", "trait3"}};
            return result;
        }}
    }}
}}

int main() {{
    try {{
        crystal::manifest("NymyaLang runtime v0.2.0-alpha~6 initialized");
        crystal::manifest("Compiled from: {0}");
        crystal::manifest("Source length: " + std::to_string({1}));
        
        // Placeholder for actual code execution
        // In a real compiler, this would contain translated code from the AST
        
        // Simulate processing based on source content
        if ({2}) {{
            crystal::manifest("Contains import statements - loading libraries...");
        }}
        
        if ({3}) {{
            crystal::manifest("Contains math operations - initializing math library...");
        }}
        
        if ({4}) {{
            crystal::manifest("Contains crystal operations - output system ready...");
        }}
        
        crystal::manifest("Program execution completed");
    }} catch (const std::exception& e) {{
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    }}
    return 0;
}}
"#,
        source_file,
        source_code.len(),
        if source_code.contains("import") { "true" } else { "false" },
        if source_code.contains("math") || source_code.contains("sqrt") || source_code.contains("pow") { "true" } else { "false" },
        if source_code.contains("crystal") || source_code.contains("manifest") { "true" } else { "false" }
    )
}

fn main() {
    let args = Args::parse();

    match &args.input {
        Some(input) => {
            if !input.ends_with(".nym") {
                eprintln!("Error: Input file must have .nym extension");
                std::process::exit(1);
            }

            if !Path::new(input).exists() {
                eprintln!("Error: Input file does not exist: {}", input);
                std::process::exit(1);
            }

            println!("Compiling {}...", input);
            
            // Read the source file
            let source_code = fs::read_to_string(input)
                .expect("Should have been able to read the file");
            
            // Generate target code
            let cpp_code = generate_target(input, source_code);
            
            // Determine output filename
            let output_filename = if let Some(name) = &args.output {
                name.clone()
            } else {
                // Default output: replace .nym with executable extension
                let base_name = input.trim_end_matches(".nym");
                if cfg!(windows) {
                    format!("{}.exe", base_name)
                } else {
                    base_name.to_string()
                }
            };

            // Write the generated C++ code to a temporary file first
            let temp_cpp_file = format!("{}.cpp", output_filename.trim_end_matches(".exe"));
            fs::write(&temp_cpp_file, &cpp_code)
                .expect("Should have been able to write the C++ source file");

            // Compile the C++ code to executable using g++
            use std::process::Command;
            let compile_result = Command::new("g++")
                .arg(&temp_cpp_file)
                .arg("-o")
                .arg(&output_filename)
                .arg("-std=c++17")
                .arg("-O2")
                .arg("-lm")  // Link math library
                .output();
            
            match compile_result {
                Ok(output) => {
                    if output.status.success() {
                        // Successful compilation - remove the temporary C++ file
                        std::fs::remove_file(&temp_cpp_file)
                            .expect("Should have been able to remove the temporary C++ file");
                            
                        println!("Compiled successfully to: {}", output_filename);
                    } else {
                        eprintln!("C++ compilation failed:");
                        eprintln!("{}", String::from_utf8_lossy(&output.stderr));

                        // Keep the C++ source file for debugging if compilation fails
                        println!("C++ source code saved to: {} for manual compilation", temp_cpp_file);

                        std::process::exit(1);
                    }
                },
                Err(e) => {
                    eprintln!("Failed to run g++: {}. Keeping C++ source file: {}", e, temp_cpp_file);
                    println!("To compile manually: g++ -std=c++17 {} -o {}", temp_cpp_file, output_filename);
                    std::process::exit(1);
                }
            }
        },
        None => {
            println!("NymyaLang Compiler v0.2.0-alpha~6");
            println!("Usage: nymyac <input.nym> [-o output]");
        }
    }
}