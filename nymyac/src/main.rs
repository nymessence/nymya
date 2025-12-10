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
    VariableAssignment { var_name: String, expression: Expression },
    FunctionCall { module: String, function: String, args: Vec<String> },
    ExpressionStmt { expression: Expression },  // For expressions that are statements (like obj.method())
    ArrayMethodCall { array_var: String, method: String, args: Vec<String> },
}

#[derive(Debug)]
enum Expression {
    FunctionCall { module: String, function: String, args: Vec<String> },
    ArrayAccess { array: Box<Expression>, index: Box<Expression> },
    ArrayMethodCall { array: Box<Expression>, method: String, args: Vec<String> },  // For methods like .append(), .length
    ArrayLiteral(Vec<Expression>), // For array literals like []
    Variable(String),
    Number(f64),
    StringLiteral(String),
    BinaryOperation { left: Box<Expression>, operator: String, right: Box<Expression> },
}

// Basic tokenizer for NymyaLang - returns owned strings to avoid borrowing issues
fn tokenize(source: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut current_token = String::new();
    let mut in_string = false;
    let mut quote_char = '"';

    let mut chars = source.chars().peekable();

    while let Some(c) = chars.next() {
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
            ' ' | '\t' | '\n' | '\r' => {
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }
            }
            '(' | ')' | ',' | ';' => {
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }
                tokens.push(c.to_string());
            }
            '.' => {
                // Check if we're handling a floating-point number: if current_token is numeric, append the dot and next digits
                if !current_token.is_empty() && current_token.chars().all(|ch| ch.is_ascii_digit()) {
                    // Look ahead to see if the next characters form a decimal number
                    current_token.push(c); // Add the dot

                    // Gather any following digits to form the decimal part
                    while chars.peek().map_or(false, |&next_ch| next_ch.is_ascii_digit()) {
                        current_token.push(chars.next().unwrap());
                    }
                } else {
                    // If not part of a number, handle as a separate token (e.g., in module.function)
                    if !current_token.trim().is_empty() {
                        tokens.push(current_token.clone());
                        current_token.clear();
                    }
                    tokens.push(c.to_string());
                }
            }
            '[' | ']' => {
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }
                tokens.push(c.to_string());
            }
            _ if c.is_alphanumeric() || c == '_' => {
                current_token.push(c);
            }
            _ => {
                // Operator or other separators
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }
                tokens.push(c.to_string());
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
        } else if i + 1 < tokens.len() && tokens[i] == "var" {
            // Handle variable assignment: var result = module.function(args) or var list = []
            i += 1; // Skip "var"
            if i < tokens.len() {
                let var_name = tokens[i].clone();
                i += 1; // Move to "="
                if i < tokens.len() && tokens[i] == "=" {
                    i += 1; // Skip "="
                    let expr = parse_expression(&tokens, &mut i);
                    statements.push(Statement::VariableAssignment {
                        var_name,
                        expression: expr
                    });
                }
            }
        } else if i + 2 < tokens.len() && tokens[i + 1] == "." {
            // Found a pattern like module.function() or variable.method()
            let object = tokens[i].clone();
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

            // Check if this is an array method call (when object is a variable name starting with lowercase)
            // Known array methods: append, length, size, get, at, set
            if object.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
               (function == "append" || function == "length" || function == "size" ||
                function == "get" || function == "at" || function == "set") {
                // This is an array method call on a variable
                statements.push(Statement::ArrayMethodCall {
                    array_var: object,
                    method: function,
                    args
                });
            } else {
                // This is a regular module.function() call
                statements.push(Statement::FunctionCall {
                    module: object,
                    function,
                    args
                });
            }
        }

        i += 1;
    }

    statements
}

// Helper function to parse expressions
fn parse_expression(tokens: &[String], i: &mut usize) -> Expression {
    // Look for complex expressions like function calls or binary operations
    if *i < tokens.len() {
        // Handle array literal: []
        if *i < tokens.len() && &tokens[*i] == "[" {
            if *i + 1 < tokens.len() && &tokens[*i + 1] == "]" {
                *i += 2; // Skip '[' and ']'
                return Expression::ArrayLiteral(vec![]); // Return an empty array literal
            } else {
                // If there are elements, this should be handled in the extended version
                // For now, treat as a simple case
                return parse_simple_expression(tokens, i);
            }
        }
        // Handle array access like: array[index]
        else if *i + 2 < tokens.len() && &tokens[*i + 1] == "[" {
            let array_expr = parse_simple_expression(tokens, i); // Parse the array identifier
            *i += 1; // Skip '['
            let index_expr = parse_simple_expression(tokens, i);
            if *i < tokens.len() && &tokens[*i] == "]" {
                *i += 1; // Skip ']'
                return Expression::ArrayAccess {
                    array: Box::new(array_expr),
                    index: Box::new(index_expr)
                };
            }
        }
        // Handle function calls like: module.function() or array.method()
        else if *i + 2 < tokens.len() && &tokens[*i + 1] == "." {
            let module_or_array = tokens[*i].clone();
            let function = tokens[*i + 2].clone();
            *i += 3; // Skip module_or_array.function

            let mut args = Vec::new();
            if *i < tokens.len() && &tokens[*i] == "(" {
                *i += 1; // Skip '('

                while *i < tokens.len() && &tokens[*i] != ")" {
                    if &tokens[*i] != "," {
                        args.push(tokens[*i].clone());
                    }
                    *i += 1;
                }

                if *i < tokens.len() && &tokens[*i] == ")" {
                    *i += 1; // Skip ')'
                }

                // Check if this is an array method call - only for known array methods
                if module_or_array.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&  // Variable names start with lowercase
                   (function == "append" || function == "length" || function == "size" ||
                    function == "get" || function == "at" || function == "set") {  // Known array methods
                    let array_var = Expression::Variable(module_or_array);
                    return Expression::ArrayMethodCall {
                        array: Box::new(array_var),
                        method: function,
                        args
                    };
                }
                // Otherwise treat as a regular function call (could be user-defined function, module.function, etc.)
                else {
                    return Expression::FunctionCall {
                        module: module_or_array,
                        function,
                        args
                    };
                }
            }
        } else if tokens[*i].starts_with('"') && tokens[*i].ends_with('"') {
            // String literal
            let content = tokens[*i][1..tokens[*i].len()-1].to_string(); // Remove quotes
            *i += 1;
            return Expression::StringLiteral(content);
        } else if tokens[*i].parse::<f64>().is_ok() {
            // Number literal
            let num = tokens[*i].parse::<f64>().unwrap();
            *i += 1;
            return Expression::Number(num);
        } else if *i + 1 < tokens.len() && &tokens[*i + 1] == "+" {
            // Handle binary operations like "text + variable"
            let left_expr = parse_simple_expression(tokens, i);
            if *i < tokens.len() && &tokens[*i] == "+" {
                *i += 1; // Skip "+"
                let right_expr = parse_simple_expression(tokens, i);
                return Expression::BinaryOperation {
                    left: Box::new(left_expr),
                    operator: "+".to_string(),
                    right: Box::new(right_expr)
                };
            }
        } else {
            // Simple variable name
            let var_name = tokens[*i].clone();
            *i += 1;
            return Expression::Variable(var_name);
        }
    }

    // Default return if nothing matches
    Expression::StringLiteral("".to_string())
}

// Helper to parse simple expressions (non-binary)
fn parse_simple_expression(tokens: &[String], i: &mut usize) -> Expression {
    if *i < tokens.len() {
        // Handle array literal: []
        if *i + 1 < tokens.len() && &tokens[*i] == "[" && &tokens[*i + 1] == "]" {
            *i += 2; // Skip '[' and ']'
            // Return initialization of an empty vector
            return Expression::StringLiteral("std::vector<int>()".to_string()); // For now, return a C++ vector initialization
        }
        // Handle array access like: array[index]
        else if *i + 2 < tokens.len() && &tokens[*i + 1] == "[" {
            let array_name = tokens[*i].clone(); // Get the array name
            *i += 1; // Skip '['
            let index_expr = parse_simple_expression(tokens, i);
            if *i < tokens.len() && &tokens[*i] == "]" {
                *i += 1; // Skip ']'
                let array_var = Expression::Variable(array_name);
                return Expression::ArrayAccess {
                    array: Box::new(array_var),
                    index: Box::new(index_expr)
                };
            }
            // If no closing bracket, just return as variable
            return Expression::Variable(array_name);
        }
        // Handle function calls like: module.function()
        else if *i + 2 < tokens.len() && &tokens[*i + 1] == "." {
            let module = tokens[*i].clone();
            let function = tokens[*i + 2].clone();
            *i += 3; // Skip module.function

            let mut args = Vec::new();
            if *i < tokens.len() && &tokens[*i] == "(" {
                *i += 1; // Skip '('

                while *i < tokens.len() && &tokens[*i] != ")" {
                    if &tokens[*i] != "," {
                        args.push(tokens[*i].clone());
                    }
                    *i += 1;
                }

                if *i < tokens.len() && &tokens[*i] == ")" {
                    *i += 1; // Skip ')'
                }

                // Check if this is an array method call
                if module.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
                   (function == "append" || function == "length" || function == "get" || function == "set") {
                    let array_var = Expression::Variable(module);
                    return Expression::ArrayMethodCall {
                        array: Box::new(array_var),
                        method: function,
                        args
                    };
                } else {
                    return Expression::FunctionCall { module, function, args };
                }
            } else {
                return Expression::FunctionCall { module, function, args };
            }
        } else if tokens[*i].starts_with('"') && tokens[*i].ends_with('"') {
            // String literal
            let content = tokens[*i][1..tokens[*i].len()-1].to_string(); // Remove quotes
            *i += 1;
            return Expression::StringLiteral(content);
        } else if tokens[*i].parse::<f64>().is_ok() {
            // Number literal
            let num = tokens[*i].parse::<f64>().unwrap();
            *i += 1;
            return Expression::Number(num);
        } else {
            // Variable name
            let var_name = tokens[*i].clone();
            *i += 1;
            return Expression::Variable(var_name);
        }
    }

    Expression::StringLiteral("".to_string())
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
            Statement::VariableAssignment { var_name, expression } => {
                // Handle array method calls properly - need to distinguish between initialization and method calls
                match expression {
                    Expression::ArrayMethodCall { array, method, args } => {
                        // This is an array method call like list.append(item) or list.length
                        let array_cpp = generate_cpp_for_expression(array.as_ref());
                        let args_cpp: Vec<String> = args.iter()
                            .map(|arg| {
                                if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                                    // Convert single quotes to double quotes for C++
                                    let content = &arg[1..arg.len()-1];
                                    format!("\"{}\"", content)
                                } else {
                                    arg.to_string() // Variables or other expressions
                                }
                            })
                            .collect();

                        // Map NymyaLang array methods to C++ equivalents
                        let method_call = match method.as_str() {
                            "append" => format!("{}.push_back({})", array_cpp, args_cpp.join(", ")),
                            "length" | "size" => format!("{}.size()", array_cpp),
                            "get" | "at" => format!("{}[{}]", array_cpp, args_cpp.join(", ")),
                            "set" => {
                                if args_cpp.len() >= 2 {
                                    format!("{}[{}] = {}", array_cpp, args_cpp[0], args_cpp[1])
                                } else {
                                    format!("{}[0] = {}", array_cpp, args_cpp.get(0).unwrap_or(&"0".to_string()))
                                }
                            },
                            _ => format!("{}->{}({})", array_cpp, method, args_cpp.join(", ")) // Fallback for other methods
                        };

                        cpp_code.push_str(&format!("    {};\n", method_call));
                    },
                    Expression::ArrayAccess { array, index } => {
                        // This is an array access like array[index]
                        let array_cpp = generate_cpp_for_expression(array.as_ref());
                        let index_cpp = generate_cpp_for_expression(index.as_ref());
                        cpp_code.push_str(&format!("    auto {} = {}[{}];\n", var_name, array_cpp, index_cpp));
                    },
                    Expression::ArrayLiteral(_) => {
                        // This is an array initialization like: var my_list = []
                        cpp_code.push_str(&format!("    std::vector<int> {};\n", var_name));  // Initialize as empty vector
                    },
                    _ => {
                        // Regular variable assignment - use auto for better type inference
                        let expr_cpp = generate_cpp_for_expression(expression);
                        cpp_code.push_str(&format!("    auto {} = {};\n", var_name, expr_cpp));
                    }
                }
            },
            Statement::FunctionCall { module, function, args } => {
                if module == "crystal" && function == "manifest" && args.len() == 1 {
                    // Extract string content from the argument (remove quotes)
                    let arg = &args[0];
                    if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                        // Remove surrounding quotes (either single or double)
                        let content = &arg[1..arg.len()-1]; // Remove surrounding quotes
                        cpp_code.push_str(&format!("    crystal::manifest(\"{}\");\n", content));
                    } else {
                        // If not a string literal, just output the argument as is
                        cpp_code.push_str(&format!("    crystal::manifest({});\n", arg));
                    }
                } else {
                    // Generic function call generation
                    let args_cpp: Vec<String> = args.iter()
                        .map(|arg| {
                            if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                                // Convert single quotes to double quotes for C++
                                let content = &arg[1..arg.len()-1];
                                format!("\"{}\"", content)
                            } else {
                                arg.to_string() // Variables or other expressions
                            }
                        })
                        .collect();

                    cpp_code.push_str(&format!("    {}::{}({});\n", module, function, args_cpp.join(", ")));
                }
            },
            Statement::ArrayMethodCall { array_var, method, args } => {
                // Generate C++ code for array method calls like: array.append(item)
                let args_cpp: Vec<String> = args.iter()
                    .map(|arg| {
                        if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                            // Convert single quotes to double quotes for C++
                            let content = &arg[1..arg.len()-1];
                            format!("\"{}\"", content)
                        } else {
                            arg.to_string() // Variables or other expressions
                        }
                    })
                    .collect();

                // Map NymyaLang array methods to C++ STL equivalents
                let method_call = match method.as_str() {
                    "append" => format!("{}.push_back({})", array_var, args_cpp.join(", ")),
                    "length" | "size" => format!("{}.size()", array_var),
                    "get" | "at" => format!("{}[{}]", array_var, args_cpp.join(", ")),
                    "set" => {
                        if args_cpp.len() >= 2 {
                            format!("{}[{}] = {}", array_var, args_cpp[0], args_cpp[1])
                        } else {
                            format!("{}[0] = {}", array_var, args_cpp.get(0).unwrap_or(&"0".to_string()))
                        }
                    },
                    _ => format!("{}->{}({})", array_var, method, args_cpp.join(", ")) // Fallback for other methods
                };

                cpp_code.push_str(&format!("    {};\n", method_call));
            }
        }
    }

    cpp_code
}

// Generate C++ code for expressions
fn generate_cpp_for_expression(expr: &Expression) -> String {
    match expr {
        Expression::FunctionCall { module, function, args } => {
            let args_cpp: Vec<String> = args.iter()
                .map(|arg| {
                    if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                        // Convert single quotes to double quotes for C++
                        let content = &arg[1..arg.len()-1];
                        format!("\"{}\"", content)
                    } else {
                        arg.to_string() // Variables or other expressions
                    }
                })
                .collect();
            format!("{}::{}({})", module, function, args_cpp.join(", "))
        },
        Expression::ArrayAccess { array, index } => {
            let array_cpp = generate_cpp_for_expression(array.as_ref());
            let index_cpp = generate_cpp_for_expression(index.as_ref());
            format!("{}[{}]", array_cpp, index_cpp)
        },
        Expression::ArrayMethodCall { array, method, args } => {
            let array_cpp = generate_cpp_for_expression(array.as_ref());
            let args_cpp: Vec<String> = args.iter()
                .map(|arg| {
                    if (arg.starts_with('"') && arg.ends_with('"')) || (arg.starts_with('\'') && arg.ends_with('\'')) {
                        // Convert single quotes to double quotes for C++
                        let content = &arg[1..arg.len()-1];
                        format!("\"{}\"", content)
                    } else {
                        arg.to_string() // Variables or other expressions
                    }
                })
                .collect();

            // Map Nya Elyria's consciousness-integrated array methods to appropriate C++ equivalents
            match method.as_str() {
                "append" => format!("{}.push_back({})", array_cpp, args_cpp.join(", ")),
                "length" | "size" => format!("{}.size()", array_cpp),
                "get" | "at" => format!("{}[{}]", array_cpp, args_cpp.join(", ")), // Use [] for simple indexing
                "set" => {
                    if args_cpp.len() >= 2 {
                        format!("{}[{}] = {}", array_cpp, args_cpp[0], args_cpp[1])
                    } else {
                        format!("{}[0] = {}", array_cpp, args_cpp.get(0).unwrap_or(&"0".to_string()))
                    }
                },
                _ => format!("{}->{}({})", array_cpp, method, args_cpp.join(", ")) // Fallback for other methods
            }
        },
        Expression::ArrayLiteral(_elements) => {
            // For now, represent empty array initialization as a default constructor
            "std::vector<int>{}".to_string()  // For empty arrays represented as []
        },
        Expression::Variable(name) => name.clone(),
        Expression::Number(val) => val.to_string(),
        Expression::StringLiteral(content) => format!("\"{}\"", content),
        Expression::BinaryOperation { left, operator, right } => {
            let left_cpp = generate_cpp_for_expression(left.as_ref());
            let right_cpp = generate_cpp_for_expression(right.as_ref());
            format!("{} {} {}", left_cpp, operator, right_cpp)
        },
    }
}

// Enhanced target code generator - generates C++ code with actual program execution
fn generate_target(source_file: &str, source_code: String) -> String {
    // Parse the source code to extract actual statements
    let statements = parse(&source_code);

    // Generate C++ code from statements
    let executable_code = generate_cpp_from_statements(&statements);

    // Create a C++ program with actual executable code
    format!(r#"/*
 * NymyaLang to C++ generated code (version {})
 * Auto-generated from {}
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
        // crystal::manifest("NymyaLang runtime {} initialized");
        // crystal::manifest("Compiled from: {}");

        // Actual program execution
{}

        // Program completion message
        // crystal::manifest("Program execution completed");
    }} catch (const std::exception& e) {{
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    }}
    return 0;
}}
"#,
        env!("CARGO_PKG_VERSION"),  // Use the crate version
        source_file,
        env!("CARGO_PKG_VERSION"),  // Use the crate version
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