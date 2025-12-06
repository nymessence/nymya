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
            compile_file(input, &args.output);
        },
        None => {
            println!("NymyaLang Compiler v0.1.0");
            println!("Usage: nymyac <input.nym> [-o output]");
        }
    }
}

fn compile_file(input_file: &str, output_name: &Option<String>) {
    // Read the source file
    let source_code = fs::read_to_string(input_file)
        .expect("Should have been able to read the file");

    // Parse the source code
    let ast = parse_nymya_code(&source_code);
    
    // Generate intermediate representation
    let ir = generate_ir(ast);
    
    // Generate target code
    let target_code = generate_target(ir);
    
    // Write output
    let output_filename_str;
    let output_filename = if let Some(name) = output_name {
        name.as_str()
    } else {
        // Default output: replace .nym with executable extension
        let base_name = input_file.trim_end_matches(".nym");
        output_filename_str = if cfg!(windows) {
            format!("{}.exe", base_name)
        } else {
            base_name.to_string()
        };
        output_filename_str.as_str()
    };

    fs::write(output_filename, target_code)
        .expect("Should have been able to write the output file");

    println!("Compiled successfully to: {}", output_filename);
}

// Placeholder parser - in a real implementation this would be a full parser
fn parse_nymya_code(source: &str) -> String {
    // For now, just return a simple AST representation
    format!("AST: {}", source)
}

// Placeholder IR generator
fn generate_ir(ast: String) -> String {
    // For now, just return the AST as IR
    format!("IR: {}", ast)
}

// Placeholder target code generator
fn generate_target(ir: String) -> String {
    // For now, return a simple C++ stub
    format!("#include <iostream>\n\nint main() {{\n    std::cout << \"Hello from NymyaLang!\" << std::endl;\n    return 0;\n}}\n\n// Generated from: {}", ir)
}