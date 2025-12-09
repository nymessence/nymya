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

#[derive(Debug)]
enum Statement {
    Import(String),
    FunctionCall { module: String, function: String, args: Vec<String> },
}

// Basic tokenizer for NymyaLang - returns owned strings to avoid borrowing issues
fn tokenize(source: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut current_token = String::new();
    let mut in_string = false;
    let mut quote_char = '"';

    for c in source.chars() {
        match c {
            '"' | '\'' => {
                if !in_string {
                    if !current_token.trim().is_empty() {
                        tokens.push(current_token.trim().to_string());
                        current_token.clear();
                    }
                    in_string = true;
                    quote_char = c;
                    current_token.push(c);
                } else if quote_char == c {
                    current_token.push(c);
                    tokens.push(current_token.clone());
                    current_token.clear();
                    in_string = false;
                } else {
                    current_token.push(c);
                }
            }
            _ if in_string => {
                current_token.push(c);
            }
            ' ' | '\t' | '\n' | '\r' | '(' | ')' | ',' | '.' | ';' => {
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }
                if ![' ', '\t', '\n', '\r'].contains(&c) {
                    tokens.push(c.to_string());
                }
            }
            _ => {
                current_token.push(c);
            }
        }
    }

    if !current_token.trim().is_empty() {
        tokens.push(current_token);
    }

    tokens
}

// Parse NymyaLang source code into AST
fn parse(source: &str) -> Vec<Statement> {
    let tokens: Vec<String> = tokenize(source);
    let mut statements = Vec::new();
    let mut i = 0;

    while i < tokens.len() {
        if tokens[i] == "import" {
            i += 1;
            if i < tokens.len() {
                statements.push(Statement::Import(tokens[i].clone()));
            }
        } else if i + 2 < tokens.len() && tokens[i + 1] == "." {
            // Found a module.function() pattern
            let module = tokens[i].clone();
            let function = tokens[i + 2].clone();

            // Parse arguments
            let mut args = Vec::new();
            i += 3; // Move to the opening parenthesis

            if i < tokens.len() && tokens[i] == "(" {
                i += 1; // Skip '('

                // Collect arguments until closing parenthesis
                while i < tokens.len() && tokens[i] != ")" {
                    if tokens[i] != "," {
                        args.push(tokens[i].clone());
                    }
                    i += 1;
                }
            }

            statements.push(Statement::FunctionCall {
                module,
                function,
                args
            });
        }

        i += 1;
    }

    statements
}

// Generate C++ code from parsed statements
fn generate_cpp_from_statements(statements: &[Statement]) -> String {
    let mut cpp_code = String::new();

    for stmt in statements {
        match stmt {
            Statement::Import(_module) => {
                // Import statements don't generate executable code, just ensure the namespace exists
                continue;
            },
            Statement::FunctionCall { module, function, args } => {
                if module == "crystal" && function == "manifest" && args.len() == 1 {
                    // Extract string content from the argument (remove quotes)
                    let arg = &args[0];
                    if arg.starts_with('"') && arg.ends_with('"') {
                        let content = &arg[1..arg.len()-1]; // Remove surrounding quotes
                        cpp_code.push_str(&format!("    crystal::manifest(\"{}\");\n", content));
                    } else {
                        // If not a string literal, just output the argument as is
                        cpp_code.push_str(&format!("    crystal::manifest({});\n", arg));
                    }
                }
                // Add more function call translations as needed
            }
        }
    }

    cpp_code
}

// Enhanced target code generator - generates C++ code with actual program execution
fn generate_target(source_file: &str, source_code: String) -> String {
    // Parse the source code to extract actual statements
    let statements = parse(&source_code);

    // Generate C++ code from statements
    let executable_code = generate_cpp_from_statements(&statements);

    // Create a C++ program with actual executable code
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
        // Runtime initialization message (optional)
        // crystal::manifest("NymyaLang runtime v0.2.0-alpha~6 initialized");
        // crystal::manifest("Compiled from: {0}");

        // Actual program execution
{1}

        // Program completion message
        // crystal::manifest("Program execution completed");
    }} catch (const std::exception& e) {{
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    }}
    return 0;
}}
"#,
        source_file,
        executable_code
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