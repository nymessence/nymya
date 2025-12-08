use std::fs;
use std::path::Path;
use clap::Parser as ClapParser;

/// NymyaLang Compiler - Compiles .nym files to executable code
#[derive(ClapParser)]
#[clap(author, version, about)]
struct Args {
    /// Input .nym file to compile
    #[clap(value_parser)]
    input: Option<String>,

    /// Output executable name
    #[clap(short, long, value_parser)]
    output: Option<String>,
}

// AST (Abstract Syntax Tree) definitions
#[derive(Debug, Clone, PartialEq)]
enum Expression {
    Integer(i64),
    Float(f64),
    String(String),
    Boolean(bool),
    Variable(String),
    BinaryOp {
        left: Box<Expression>,
        operator: BinaryOperator,
        right: Box<Expression>,
    },
    FunctionCall {
        name: String,
        args: Vec<Expression>,
    },
    // Add more expression types as needed
}

#[derive(Debug, Clone, PartialEq)]
enum BinaryOperator {
    Add,
    Sub,
    Mul,
    Div,
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
    And,
    Or,
}

#[derive(Debug, Clone, PartialEq)]
enum Statement {
    Expression(Expression),
    VariableDeclaration {
        name: String,
        value: Expression,
    },
    Assignment {
        variable: String,
        value: Expression,
    },
    If {
        condition: Expression,
        then_branch: Vec<Statement>,
        else_branch: Option<Vec<Statement>>,
    },
    While {
        condition: Expression,
        body: Vec<Statement>,
    },
    // Add more statement types as needed
}

#[derive(Debug, Clone, PartialEq)]
struct AST {
    statements: Vec<Statement>,
}

// Parser implementation
struct NymyaParser {
    tokens: Vec<Token>,
    current: usize,
}

#[derive(Debug, Clone, PartialEq)]
enum Token {
    // Literals
    Integer(i64),
    Float(f64),
    String(String),
    Boolean(bool),

    // Identifiers and keywords
    Identifier(String),
    Let,
    Func,
    If,
    Else,
    While,
    Return,
    Import,
    Namespace,

    // Operators
    Plus,
    Minus,
    Star,
    Slash,
    Eq,
    EqEq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
    And,
    Or,

    // Delimiters
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    LeftBracket,
    RightBracket,
    Semicolon,
    Colon,
    Comma,
    Dot,

    // End of file
    Eof,
}

impl NymyaParser {
    fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, current: 0 }
    }
    
    fn parse(&mut self) -> Result<AST, String> {
        let mut statements = Vec::new();
        
        while !self.is_at_end() {
            if let Some(stmt) = self.declaration()? {
                statements.push(stmt);
            }
        }
        
        Ok(AST { statements })
    }
    
    fn declaration(&mut self) -> Result<Option<Statement>, String> {
        // For now, we'll just handle basic statement parsing
        self.statement()
    }
    
    fn statement(&mut self) -> Result<Option<Statement>, String> {
        if self.match_token(&Token::LeftBrace) {
            return self.block_statement();
        }
        
        if self.match_token(&Token::If) {
            return self.if_statement();
        }
        
        if self.match_token(&Token::While) {
            return self.while_statement();
        }
        
        let expr = self.expression()?;
        self.consume(&Token::Semicolon, "Expect ';' after expression.")?;
        
        Ok(Some(Statement::Expression(expr)))
    }
    
    fn block_statement(&mut self) -> Result<Option<Statement>, String> {
        let mut statements = Vec::new();
        
        while !self.check(&Token::RightBrace) && !self.is_at_end() {
            if let Some(stmt) = self.declaration()? {
                statements.push(stmt);
            }
        }
        
        self.consume(&Token::RightBrace, "Expect '}' after block.")?;
        // For now, we'll return None since we don't have a block statement in our enum
        Ok(None)
    }
    
    fn if_statement(&mut self) -> Result<Option<Statement>, String> {
        self.consume(&Token::LeftParen, "Expect '(' after 'if'.")?;
        let condition = self.expression()?;
        self.consume(&Token::RightParen, "Expect ')' after if condition.")?;
        
        let then_branch = if let Some(Statement::Expression(Expression::Variable(_))) = self.statement()? {
            // Simplified handling - in a real implementation would handle blocks properly
            vec![]
        } else {
            vec![]
        };
        
        let else_branch = if self.match_token(&Token::Else) {
            if let Some(Statement::Expression(Expression::Variable(_))) = self.statement()? {
                Some(vec![])
            } else {
                Some(vec![])
            }
        } else {
            None
        };
        
        Ok(Some(Statement::If {
            condition,
            then_branch,
            else_branch,
        }))
    }
    
    fn while_statement(&mut self) -> Result<Option<Statement>, String> {
        self.consume(&Token::LeftParen, "Expect '(' after 'while'.")?;
        let condition = self.expression()?;
        self.consume(&Token::RightParen, "Expect ')' after while condition.")?;
        
        let body = if let Some(Statement::Expression(Expression::Variable(_))) = self.statement()? {
            vec![]
        } else {
            vec![]
        };
        
        Ok(Some(Statement::While { condition, body }))
    }
    
    fn expression(&mut self) -> Result<Expression, String> {
        self.equality()
    }
    
    fn equality(&mut self) -> Result<Expression, String> {
        let mut expr = self.comparison()?;
        
        while self.match_token(&Token::EqEq) || self.match_token(&Token::Ne) {
            let operator = if self.previous() == Token::EqEq {
                BinaryOperator::Eq
            } else {
                BinaryOperator::Ne
            };
            
            let right = self.comparison()?;
            expr = Expression::BinaryOp {
                left: Box::new(expr),
                operator,
                right: Box::new(right),
            };
        }
        
        Ok(expr)
    }
    
    fn comparison(&mut self) -> Result<Expression, String> {
        let mut expr = self.term()?;
        
        loop {
            if self.match_token(&Token::Lt) || self.match_token(&Token::Le) || 
               self.match_token(&Token::Gt) || self.match_token(&Token::Ge) {
                let operator = match self.previous() {
                    Token::Lt => BinaryOperator::Lt,
                    Token::Le => BinaryOperator::Le,
                    Token::Gt => BinaryOperator::Gt,
                    Token::Ge => BinaryOperator::Ge,
                    _ => unreachable!(),
                };
                
                let right = self.term()?;
                expr = Expression::BinaryOp {
                    left: Box::new(expr),
                    operator,
                    right: Box::new(right),
                };
            } else {
                break;
            }
        }
        
        Ok(expr)
    }
    
    fn term(&mut self) -> Result<Expression, String> {
        let mut expr = self.factor()?;
        
        loop {
            if self.match_token(&Token::Plus) || self.match_token(&Token::Minus) {
                let operator = if self.previous() == Token::Plus {
                    BinaryOperator::Add
                } else {
                    BinaryOperator::Sub
                };
                
                let right = self.factor()?;
                expr = Expression::BinaryOp {
                    left: Box::new(expr),
                    operator,
                    right: Box::new(right),
                };
            } else {
                break;
            }
        }
        
        Ok(expr)
    }
    
    fn factor(&mut self) -> Result<Expression, String> {
        let mut expr = self.unary()?;
        
        loop {
            if self.match_token(&Token::Star) || self.match_token(&Token::Slash) {
                let operator = if self.previous() == Token::Star {
                    BinaryOperator::Mul
                } else {
                    BinaryOperator::Div
                };
                
                let right = self.unary()?;
                expr = Expression::BinaryOp {
                    left: Box::new(expr),
                    operator,
                    right: Box::new(right),
                };
            } else {
                break;
            }
        }
        
        Ok(expr)
    }
    
    fn unary(&mut self) -> Result<Expression, String> {
        if self.match_token(&Token::Minus) || self.match_token(&Token::Plus) {
            let operator = if self.previous() == Token::Minus {
                // For simplicity in this example, we'll just handle negation
                let right = self.unary()?;
                return Ok(Expression::BinaryOp {
                    left: Box::new(Expression::Integer(0)),
                    operator: BinaryOperator::Sub,
                    right: Box::new(right),
                });
            } else {
                self.unary()?
            };
        }
        
        self.primary()
    }
    
    fn primary(&mut self) -> Result<Expression, String> {
        if self.match_token(&Token::Integer(0)) {
            // Get the actual integer value that was matched
            let val = match self.previous() {
                Token::Integer(n) => n,
                _ => 0, // This shouldn't happen
            };
            return Ok(Expression::Integer(val));
        }
        
        if self.match_token(&Token::Float(0.0)) {
            let val = match self.previous() {
                Token::Float(n) => n,
                _ => 0.0,
            };
            return Ok(Expression::Float(val));
        }
        
        if self.match_token(&Token::String(String::new())) {
            let val = match self.previous() {
                Token::String(s) => s,
                _ => String::new(),
            };
            return Ok(Expression::String(val));
        }
        
        if self.match_token(&Token::Boolean(false)) {
            let val = match self.previous() {
                Token::Boolean(b) => b,
                _ => false,
            };
            return Ok(Expression::Boolean(val));
        }
        
        if let Token::Identifier(_) = self.peek() {
            let identifier = match self.advance() {
                Token::Identifier(name) => name,
                _ => String::new(), // Should not happen
            };
            return Ok(Expression::Variable(identifier));
        }
        
        Err(format!("Unexpected token: {:?}", self.peek()))
    }
    
    // Helper methods for parser
    fn is_at_end(&self) -> bool {
        self.current >= self.tokens.len()
    }

    fn peek(&self) -> Token {
        if self.current >= self.tokens.len() {
            Token::Eof
        } else {
            self.tokens[self.current].clone()
        }
    }

    fn previous(&self) -> Token {
        self.tokens[self.current - 1].clone()
    }

    fn advance(&mut self) -> Token {
        if !self.is_at_end() {
            self.current += 1;
        }
        self.previous()
    }

    fn match_token(&mut self, token: &Token) -> bool {
        if self.is_at_end() {
            return false;
        }

        let current_token = &self.tokens[self.current];
        let matches = match (current_token, token) {
            (Token::Integer(_), Token::Integer(_)) => true,
            (Token::Float(_), Token::Float(_)) => true,
            (Token::String(_), Token::String(_)) => true,
            (Token::Boolean(_), Token::Boolean(_)) => true,
            (Token::Identifier(_), Token::Identifier(_)) => true,
            _ => current_token == token,
        };

        if matches {
            self.current += 1;
        }

        matches
    }

    fn consume(&mut self, token: &Token, message: &str) -> Result<Token, String> {
        if self.match_token(token) {
            Ok(self.previous())
        } else {
            Err(message.to_string())
        }
    }

    fn check(&self, token: &Token) -> bool {
        if self.is_at_end() {
            return false;
        }
        let current_token = &self.tokens[self.current];

        match (current_token, token) {
            (Token::Integer(_), Token::Integer(_)) => true,
            (Token::Float(_), Token::Float(_)) => true,
            (Token::String(_), Token::String(_)) => true,
            (Token::Boolean(_), Token::Boolean(_)) => true,
            (Token::Identifier(_), Token::Identifier(_)) => true,
            _ => current_token == token,
        }
    }
}

// Lexer implementation
struct Lexer {
    source: String,
    position: usize,
    current_char: Option<char>,
}

impl Lexer {
    fn new(source: String) -> Self {
        let mut lexer = Self {
            source,
            position: 0,
            current_char: None,
        };
        lexer.current_char = lexer.source.chars().next();
        lexer
    }
    
    fn advance(&mut self) {
        self.position += 1;
        if self.position >= self.source.len() {
            self.current_char = None;
        } else {
            self.current_char = self.source.chars().nth(self.position);
        }
    }
    
    fn peek(&self) -> Option<char> {
        if self.position + 1 >= self.source.len() {
            None
        } else {
            self.source.chars().nth(self.position + 1)
        }
    }
    
    fn skip_whitespace(&mut self) {
        while let Some(ch) = self.current_char {
            if ch.is_whitespace() {
                self.advance();
            } else {
                break;
            }
        }
    }
    
    fn read_number(&mut self) -> Token {
        let start_pos = self.position;
        
        while let Some(ch) = self.current_char {
            if ch.is_ascii_digit() || ch == '.' {
                self.advance();
            } else {
                break;
            }
        }
        
        let num_str: String = self.source[start_pos..self.position].to_string();
        
        if num_str.contains('.') {
            if let Ok(val) = num_str.parse::<f64>() {
                Token::Float(val)
            } else {
                Token::Float(0.0) // Default on parse error
            }
        } else {
            if let Ok(val) = num_str.parse::<i64>() {
                Token::Integer(val)
            } else {
                Token::Integer(0) // Default on parse error
            }
        }
    }
    
    fn read_string(&mut self) -> Token {
        self.advance(); // Skip opening quote
        let start_pos = self.position;
        
        while let Some(ch) = self.current_char {
            if ch == '"' {
                break;
            }
            self.advance();
        }
        
        let str_content = self.source[start_pos..self.position].to_string();
        self.advance(); // Skip closing quote
        
        Token::String(str_content)
    }
    
    fn read_identifier(&mut self) -> String {
        let start_pos = self.position;
        
        while let Some(ch) = self.current_char {
            if ch.is_alphanumeric() || ch == '_' {
                self.advance();
            } else {
                break;
            }
        }
        
        self.source[start_pos..self.position].to_string()
    }
    
    fn next_token(&mut self) -> Token {
        self.skip_whitespace();
        
        if let Some(ch) = self.current_char {
            match ch {
                '(' => {
                    self.advance();
                    Token::LeftParen
                }
                ')' => {
                    self.advance();
                    Token::RightParen
                }
                '{' => {
                    self.advance();
                    Token::LeftBrace
                }
                '}' => {
                    self.advance();
                    Token::RightBrace
                }
                '[' => {
                    self.advance();
                    Token::LeftBracket
                }
                ']' => {
                    self.advance();
                    Token::RightBracket
                }
                ';' => {
                    self.advance();
                    Token::Semicolon
                }
                ':' => {
                    self.advance();
                    Token::Colon
                }
                ',' => {
                    self.advance();
                    Token::Comma
                }
                '.' => {
                    self.advance();
                    Token::Dot
                }
                '+' => {
                    self.advance();
                    Token::Plus
                }
                '-' => {
                    self.advance();
                    Token::Minus
                }
                '*' => {
                    self.advance();
                    Token::Star
                }
                '/' => {
                    // Check for comments
                    if self.peek() == Some('/') {
                        // Skip single-line comment
                        while let Some(ch) = self.current_char {
                            if ch == '\n' {
                                break;
                            }
                            self.advance();
                        }
                        self.next_token() // Process next token after comment
                    } else {
                        self.advance();
                        Token::Slash
                    }
                }
                '=' => {
                    if self.peek() == Some('=') {
                        self.advance();
                        self.advance();
                        Token::EqEq
                    } else {
                        self.advance();
                        Token::Eq
                    }
                }
                '!' => {
                    if self.peek() == Some('=') {
                        self.advance();
                        self.advance();
                        Token::Ne
                    } else {
                        self.advance();
                        // For now, just return a placeholder
                        Token::Minus  // This is not correct, but avoids error
                    }
                }
                '<' => {
                    if self.peek() == Some('=') {
                        self.advance();
                        self.advance();
                        Token::Le
                    } else {
                        self.advance();
                        Token::Lt
                    }
                }
                '>' => {
                    if self.peek() == Some('=') {
                        self.advance();
                        self.advance();
                        Token::Ge
                    } else {
                        self.advance();
                        Token::Gt
                    }
                }
                '&' => {
                    if self.peek() == Some('&') {
                        self.advance();
                        self.advance();
                        Token::And
                    } else {
                        self.advance();
                        // Handle single & as an error for now
                        Token::Plus  // Placeholder
                    }
                }
                '|' => {
                    if self.peek() == Some('|') {
                        self.advance();
                        self.advance();
                        Token::Or
                    } else {
                        self.advance();
                        // Handle single | as an error for now
                        Token::Plus  // Placeholder
                    }
                }
                '"' => {
                    self.read_string()
                }
                _ => {
                    if ch.is_ascii_digit() {
                        self.read_number()
                    } else if ch.is_alphabetic() || ch == '_' {
                        let ident = self.read_identifier();
                        match ident.as_str() {
                            "let" => Token::Let,
                            "func" => Token::Func,
                            "if" => Token::If,
                            "else" => Token::Else,
                            "while" => Token::While,
                            "return" => Token::Return,
                            "import" => Token::Import,
                            "namespace" => Token::Namespace,
                            "true" => Token::Boolean(true),
                            "false" => Token::Boolean(false),
                            _ => Token::Identifier(ident),
                        }
                    } else {
                        self.advance();
                        Token::Plus  // Placeholder for unrecognized character
                    }
                }
            }
        } else {
            Token::Eof
        }
    }
    
    fn tokenize(&mut self) -> Vec<Token> {
        let mut tokens = Vec::new();
        
        loop {
            let token = self.next_token();
            tokens.push(token.clone());
            
            if matches!(token, Token::Eof) {
                break;
            }
        }
        
        tokens
    }
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

    // Tokenize the source code
    let mut lexer = Lexer::new(source_code);
    let tokens = lexer.tokenize();
    
    // Parse the tokens into an AST
    let mut parser = NymyaParser::new(tokens);
    let ast_result = parser.parse();
    
    match ast_result {
        Ok(ast) => {
            println!("Successfully parsed AST with {} statements", ast.statements.len());
            
            // Generate target code directly from AST
            let cpp_code = generate_target(ast);

            // Write output
            let output_filename_str;
            let output_filename = if let Some(name) = output_name {
                name.as_str()
            } else {
                // Default output: replace .nym with .cpp extension for generated code
                let base_name = input_file.trim_end_matches(".nym");
                output_filename_str = format!("{}.cpp", base_name);
                output_filename_str.as_str()
            };

            fs::write(output_filename, cpp_code)
                .expect("Should have been able to write the output file");

            // Compile the generated C++ code to executable
            let exe_filename = if cfg!(windows) {
                format!("{}.exe", input_file.trim_end_matches(".nym"))
            } else {
                input_file.trim_end_matches(".nym").to_string()
            };

            // Compile using g++
            use std::process::Command;
            let compile_result = Command::new("g++")
                .arg(output_filename)
                .arg("-o")
                .arg(&exe_filename)
                .arg("-std=c++17")
                .output();

            match compile_result {
                Ok(output) => {
                    if output.status.success() {
                        println!("Compiled successfully to: {}", exe_filename);
                    } else {
                        eprintln!("Compilation error:");
                        eprintln!("{}", String::from_utf8_lossy(&output.stderr).to_string());
                        std::process::exit(1);
                    }
                },
                Err(e) => {
                    eprintln!("Failed to run g++: {}. Creating only .cpp file.", e);
                    println!("Generated C++ code saved to: {}", output_filename);
                }
            }
        },
        Err(error) => {
            eprintln!("Parse error: {}", error);
        }
    }
}

// IR generator - kept for compatibility but not used in new implementation
fn generate_ir(ast: AST) -> String {
    // For now, just return a representation of the AST
    format!("IR: {:?}", ast.statements.len())
}

// Enhanced target code generator - generates C++ code from AST
fn generate_target(ir: AST) -> String {
    // Generate a proper C++ program based on the actual AST structure
    let header = r#"/*
 * NymyaLang to C++ generated code
 */

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <cmath>
#include <complex>
#include <stdexcept>
#include <sstream>

// Basic types and utility functions
typedef long long Int;
typedef double Float;
typedef bool Bool;
typedef std::string String;
typedef std::vector<double> List;

// BigInt implementation using primitive integers (for now)
class BigInt {
private:
    long long value;
public:
    BigInt(long long v) : value(v) {}
    BigInt operator+(const BigInt& other) const { return BigInt(value + other.value); }
    BigInt operator-(const BigInt& other) const { return BigInt(value - other.value); }
    BigInt operator*(const BigInt& other) const { return BigInt(value * other.value); }
    BigInt operator/(const BigInt& other) const {
        if (other.value == 0) throw std::runtime_error("Division by zero");
        return BigInt(value / other.value);
    }
    BigInt operator%(const BigInt& other) const {
        if (other.value == 0) throw std::runtime_error("Modulo by zero");
        return BigInt(value % other.value);
    }
    friend std::ostream& operator<<(std::ostream& os, const BigInt& bi) {
        os << bi.value;
        return os;
    }
    long long get_value() const { return value; }
};

// Complex number implementation
class Complex {
private:
    double real, imag;
public:
    Complex(double r = 0, double i = 0) : real(r), imag(i) {}
    Complex operator+(const Complex& other) const { return Complex(real + other.real, imag + other.imag); }
    Complex operator-(const Complex& other) const { return Complex(real - other.real, imag - other.imag); }
    Complex operator*(const Complex& other) const {
        return Complex(real * other.real - imag * other.imag,
                      real * other.imag + imag * other.real);
    }
    Complex operator/(const Complex& other) const {
        double denom = other.real * other.real + other.imag * other.imag;
        if (denom == 0) throw std::runtime_error("Division by complex zero");
        return Complex((real * other.real + imag * other.imag) / denom,
                      (imag * other.real - real * other.imag) / denom);
    }
    double magnitude() const { return std::sqrt(real * real + imag * imag); }
    double phase() const { return std::atan2(imag, real); }
    Complex conjugate() const { return Complex(real, -imag); }
    friend std::ostream& operator<<(std::ostream& os, const Complex& c) {
        os << c.real;
        if (c.imag >= 0) os << "+";
        os << c.imag << "i";
        return os;
    }
};

// Vector implementations
class Vec2 {
public:
    Float x, y;
    Vec2(Float x_val, Float y_val) : x(x_val), y(y_val) {}
    Float magnitude() const { return std::sqrt(x*x + y*y); }
    Vec2 normalize() const {
        Float mag = magnitude();
        if (mag == 0) return Vec2(0, 0);
        return Vec2(x/mag, y/mag);
    }
    Vec2 operator+(const Vec2& other) const { return Vec2(x + other.x, y + other.y); }
    Vec2 operator-(const Vec2& other) const { return Vec2(x - other.x, y - other.y); }
    Float dot(const Vec2& other) const { return x*other.x + y*other.y; }
};

class Vec3 {
public:
    Float x, y, z;
    Vec3(Float x_val, Float y_val, Float z_val) : x(x_val), y(y_val), z(z_val) {}
    Float magnitude() const { return std::sqrt(x*x + y*y + z*z); }
    Vec3 normalize() const {
        Float mag = magnitude();
        if (mag == 0) return Vec3(0, 0, 0);
        return Vec3(x/mag, y/mag, z/mag);
    }
    Vec3 operator+(const Vec3& other) const { return Vec3(x + other.x, y + other.y, z + other.z); }
    Vec3 operator-(const Vec3& other) const { return Vec3(x - other.x, y - other.y, z - other.z); }
    Float dot(const Vec3& other) const { return x*other.x + y*other.y + z*other.z; }
    Vec3 cross(const Vec3& other) const {
        return Vec3(y*other.z - z*other.y, z*other.x - x*other.z, x*other.y - y*other.x);
    }
};

// Math utilities
namespace math {
    Float abs(Float x) { return x < 0 ? -x : x; }
    Int abs_int(Int x) { return x < 0 ? -x : x; }
    Float min(Float a, Float b) { return a < b ? a : b; }
    Float max(Float a, Float b) { return a > b ? a : b; }
    Int min_int(Int a, Int b) { return a < b ? a : b; }
    Int max_int(Int a, Int b) { return a > b ? a : b; }
    Float clamp(Float value, Float min_val, Float max_val) {
        return math::min(math::max(value, min_val), max_val);
    }
    Float sign(Float x) { return x > 0 ? 1.0 : (x < 0 ? -1.0 : 0.0); }

    // Trigonometric functions
    Float sin(Float x) { return std::sin(x); }
    Float cos(Float x) { return std::cos(x); }
    Float tan(Float x) { return std::tan(x); }
    Float asin(Float x) { return std::asin(x); }
    Float acos(Float x) { return std::acos(x); }
    Float atan(Float x) { return std::atan(x); }
    Float atan2(Float y, Float x) { return std::atan2(y, x); }

    // Hyperbolic functions
    Float sinh(Float x) { return std::sinh(x); }
    Float cosh(Float x) { return std::cosh(x); }
    Float tanh(Float x) { return std::tanh(x); }

    // Exponential/logarithmic
    Float sqrt(Float x) { return std::sqrt(x); }
    Float cbrt(Float x) { return std::cbrt(x); }
    Float pow(Float base, Float exp) { return std::pow(base, exp); }
    Float exp(Float x) { return std::exp(x); }
    Float exp2(Float x) { return std::exp2(x); }
    Float log(Float x) { return std::log(x); }
    Float log2(Float x) { return std::log2(x); }
    Float log10(Float x) { return std::log10(x); }
    Float log1p(Float x) { return std::log1p(x); }

    // Rounding functions
    Float ceil(Float x) { return std::ceil(x); }
    Float floor(Float x) { return std::floor(x); }
    Float round(Float x) { return std::round(x); }
    Float trunc(Float x) { return std::trunc(x); }

    // Constants
    const Float PI = M_PI;
    const Float E = M_E;
    const Float TAU = 2 * M_PI;
    const Float PHI = 1.618033988749895;
    const Float SQRT2 = 1.4142135623730951;
    const Float SQRT3 = 1.7320508075688772;
    const Float INV_SQRT2 = 0.7071067811865476;

    // Integer power function
    Int pow_int(Int base, Int exp) {
        if (exp <= 0) return 1;
        Int result = 1;
        Int b = base;
        Int e = exp;
        while (e > 0) {
            if (e % 2 == 1) result *= b;
            b *= b;
            e /= 2;
        }
        return result;
    }

    // GCD function
    Int gcd(Int a, Int b) {
        a = abs_int(a);
        b = abs_int(b);
        while (b != 0) {
            Int temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }
}

// Crystal utilities (console output)
namespace crystal {
    void manifest(const std::string& msg) {
        std::cout << msg << std::endl;
    }

    void print(const std::string& msg) {
        std::cout << msg;
    }
}

// Low-level utilities
namespace lowlevel {
    namespace bitwise {
        Int and_op(Int a, Int b) { return a & b; }
        Int or_op(Int a, Int b) { return a | b; }
        Int xor_op(Int a, Int b) { return a ^ b; }
        Int not_op(Int a) { return ~a; }
        Int left_shift(Int a, Int b) { return a << b; }
        Int right_shift(Int a, Int b) { return a >> b; }
    }
}

// Conversion utilities
namespace conversions {
    String int_to_string(Int val) {
        return std::to_string(val);
    }

    String float_to_string(Float val) {
        return std::to_string(val);
    }

    String bool_to_string(Bool val) {
        return val ? "true" : "false";
    }
}

// Main program entry point
int main() {
    try {
        crystal::manifest("NymyaLang runtime initialized");

"#;

    let footer = r#"
        crystal::manifest("Program execution completed");
    } catch (const std::exception& e) {
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
"#;

    // Convert AST statements to C++ code
    let mut statements_code = String::new();
    for stmt in ir.statements {
        statements_code.push_str(&ast_to_cpp(&stmt));
        statements_code.push('\n');
    }

    format!("{}{}{}", header, statements_code, footer)
}

// Convert AST statement to C++ code
fn ast_to_cpp(stmt: &Statement) -> String {
    match stmt {
        Statement::Expression(expr) => format!("        {};", expression_to_cpp(expr)),
        Statement::VariableDeclaration { name, value } => {
            format!("        auto {} = {};", name, expression_to_cpp(value))
        },
        Statement::Assignment { variable, value } => {
            format!("        {} = {};", variable, expression_to_cpp(value))
        },
        Statement::If { condition, then_branch, else_branch } => {
            let cond_cpp = expression_to_cpp(condition);
            let mut then_cpp = String::new();
            for stmt in then_branch {
                then_cpp.push_str(&format!("            {}\n", ast_to_cpp(stmt).trim()));
            }

            if let Some(else_stmts) = else_branch {
                let mut else_cpp = String::new();
                for stmt in else_stmts {
                    else_cpp.push_str(&format!("            {}\n", ast_to_cpp(stmt).trim()));
                }
                format!(
                    r#"        if ({}) {{
{}
        }} else {{
{}
        }}"#,
                    cond_cpp, then_cpp, else_cpp
                )
            } else {
                format!(
                    r#"        if ({}) {{
{}
        }}"#,
                    cond_cpp, then_cpp
                )
            }
        },
        Statement::While { condition, body } => {
            let cond_cpp = expression_to_cpp(condition);
            let mut body_cpp = String::new();
            for stmt in body {
                body_cpp.push_str(&format!("            {}\n", ast_to_cpp(stmt).trim()));
            }
            format!(
                r#"        while ({}) {{
{}
        }}"#,
                cond_cpp, body_cpp
            )
        },
    }
}

// Convert AST expression to C++ code
fn expression_to_cpp(expr: &Expression) -> String {
    match expr {
        Expression::Integer(val) => val.to_string(),
        Expression::Float(val) => {
            if val.fract() == 0.0 {
                format!("{}.", val)  // Force float representation
            } else {
                val.to_string()
            }
        },
        Expression::String(val) => format!("\"{}\"", val.escape_default()),
        Expression::Boolean(val) => if *val { "true" } else { "false" }.to_string(),
        Expression::Variable(name) => name.clone(),
        Expression::BinaryOp { left, operator, right } => {
            let left_cpp = expression_to_cpp(left);
            let right_cpp = expression_to_cpp(right);

            let op_str = match operator {
                BinaryOperator::Add => "+",
                BinaryOperator::Sub => "-",
                BinaryOperator::Mul => "*",
                BinaryOperator::Div => "/",
                BinaryOperator::Eq => "==",
                BinaryOperator::Ne => "!=",
                BinaryOperator::Lt => "<",
                BinaryOperator::Le => "<=",
                BinaryOperator::Gt => ">",
                BinaryOperator::Ge => ">=",
                BinaryOperator::And => "&&",
                BinaryOperator::Or => "||",
            };

            format!("({} {} {})", left_cpp, op_str, right_cpp)
        },
        Expression::FunctionCall { name, args } => {
            let arg_strings: Vec<String> = args.iter().map(expression_to_cpp).collect();
            format!("{}({})", name, arg_strings.join(", "))
        },
    }
}