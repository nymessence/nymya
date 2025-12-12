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
    MethodCall { object: Box<Expression>, method: String, args: Vec<String> },  // For general method calls like var.method()
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
            '@' => {
                // Handle @-tags like @shira, @sela, @nora, etc.
                if !current_token.trim().is_empty() {
                    tokens.push(current_token.clone());
                    current_token.clear();
                }

                // Collect the entire @tag
                current_token.push(c); // Add the '@'

                // Collect alphanumeric characters and underscores after @
                while let Some(&next_char) = chars.peek() {
                    if next_char.is_alphanumeric() || next_char == '_' {
                        current_token.push(chars.next().unwrap());
                    } else {
                        break;
                    }
                }

                // Push the complete @tag as a single token
                tokens.push(current_token.clone());
                current_token.clear();
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
        // Skip any @-tags that appear (they are treated as metadata/comments for now)
        while i < tokens.len() && tokens[i].starts_with('@') {
            i += 1;  // Skip the tag token
        }

        if i >= tokens.len() {
            break;
        }

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
            // Look ahead to see if we have a nested namespace pattern like: graphics.stl_basic.function()
            let mut is_nested_namespace = false;
            let mut module_name = "".to_string();
            let mut function_name = "".to_string();
            let mut advance_amount = 0;

            // Check for 3-token pattern: module . submodule . function
            if i + 4 < tokens.len() && &tokens[i + 1] == "." && &tokens[i + 3] == "." {
                // Potential nested namespace: check if first part is a known module
                let potential_module = format!("{}.{}", tokens[i], tokens[i + 2]);
                let known_modules = ["crystal", "math", "quantum", "symbolic", "networking", "system", "image", "graphics", "physics", "datetime", "lowlevel", "ml", "gui"];

                if known_modules.contains(&tokens[i].as_str()) {
                    // This looks like a nested namespace call: module.submodule.function()
                    module_name = potential_module;
                    function_name = tokens[i + 4].clone();
                    advance_amount = 5; // module . submodule . function
                    is_nested_namespace = true;
                }
            }

            if is_nested_namespace {
                // Handle nested namespace call: module.submodule.function(args)
                let mut args = Vec::new();
                if i + advance_amount < tokens.len() && tokens[i + advance_amount] == "(" {
                    let mut arg_i = i + advance_amount + 1; // Skip '('
                    while arg_i < tokens.len() && tokens[arg_i] != ")" {
                        if tokens[arg_i] != "," {
                            args.push(tokens[arg_i].clone());
                        }
                        arg_i += 1;
                    }

                    if arg_i < tokens.len() && tokens[arg_i] == ")" {
                        arg_i += 1;
                    }
                }

                // Check if this is a known array method call
                if module_name.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
                   (function_name == "append" || function_name == "length" || function_name == "size" ||
                    function_name == "get" || function_name == "at" || function_name == "set") {
                    statements.push(Statement::ArrayMethodCall {
                        array_var: module_name,
                        method: function_name,
                        args
                    });
                } else {
                    // This is a nested namespace function call
                    statements.push(Statement::FunctionCall {
                        module: module_name,
                        function: function_name,
                        args
                    });
                }

                i += advance_amount;
                if i < tokens.len() && tokens[i] == "(" {
                    // We already handled the arguments above, so advance past them
                    while i < tokens.len() && tokens[i] != ")" {
                        if tokens[i] == "(" {
                            // Handle nested function calls by counting parenthesis
                            let mut paren_count = 1;
                            i += 1;
                            while i < tokens.len() && paren_count > 0 {
                                if tokens[i] == "(" {
                                    paren_count += 1;
                                } else if tokens[i] == ")" {
                                    paren_count -= 1;
                                }
                                if paren_count > 0 {
                                    i += 1;
                                }
                            }
                        } else {
                            i += 1;
                        }
                    }
                    if i < tokens.len() && tokens[i] == ")" {
                        i += 1;
                    }
                }
            } else {
                // Handle regular module.function() or variable.method() call
                let object = tokens[i].clone();
                let function = tokens[i + 2].clone();
                i += 3; // Skip module.function

                // Parse arguments
                let mut args = Vec::new();
                if i < tokens.len() && tokens[i] == "(" {
                    i += 1; // Skip '('

                    // Collect arguments until closing parenthesis
                    while i < tokens.len() && tokens[i] != ")" {
                        if tokens[i] != "," {
                            args.push(tokens[i].clone());
                        }
                        i += 1;
                    }

                    if i < tokens.len() && tokens[i] == ")" {
                        i += 1; // Skip ')'
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
                } else if object.chars().next().map_or(false, |c| c.is_ascii_lowercase()) {
                    // Check if this is a known module name (starts with lowercase but is a module, not a variable)
                    // Known modules: crystal, math, quantum, symbolic, networking, physics, etc.
                    let known_modules = ["crystal", "math", "quantum", "symbolic", "networking", "physics", "datetime", "lowlevel", "ml", "gui"];
                    let is_known_module = known_modules.contains(&object.as_str());

                    if is_known_module {
                        // This is a module.function() call, not a variable method call
                        statements.push(Statement::FunctionCall {
                            module: object,
                            function,
                            args
                        });
                    } else if function == "append" || function == "length" || function == "size" ||
                              function == "get" || function == "at" || function == "set" {
                        // This is an array method call on a variable (like list.length or list.append(value))
                        statements.push(Statement::ArrayMethodCall {
                            array_var: object,
                            method: function,
                            args
                        });
                    } else {
                        // This is a general method call on a variable (not a module.function)
                        // Create an expression statement for the method call
                        let method_call_expr = Expression::MethodCall {
                            object: Box::new(Expression::Variable(object)),
                            method: function,
                            args
                        };
                        statements.push(Statement::ExpressionStmt {
                            expression: method_call_expr
                        });
                    }
                } else {
                    // This is a regular module.function() call (object starts with uppercase or non-lowercase)
                    statements.push(Statement::FunctionCall {
                        module: object,
                        function,
                        args
                    });
                }
            }
        }

        i += 1;
    }

    statements
}

// Helper function to parse expressions with precedence and method chaining support
fn parse_expression(tokens: &[String], i: &mut usize) -> Expression {
    if *i >= tokens.len() {
        return Expression::StringLiteral("".to_string());
    }

    // Parse left-hand side of expression (primary expression)
    let mut expr = parse_primary_expr(tokens, i);

    // Handle postfix operators like method calls (obj.method() or array[index].method())
    loop {
        if *i < tokens.len() && &tokens[*i] == "." {
            *i += 1; // Skip '.'

            if *i >= tokens.len() {
                break; // No more tokens after '.'
            }

            let method_name = tokens[*i].clone();
            *i += 1;

            if *i < tokens.len() && &tokens[*i] == "(" {
                // This is a method call: obj.method(args) or array[index].method(args)
                *i += 1; // Skip '('

                let mut args = Vec::new();
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
                if method_name == "append" || method_name == "length" || method_name == "size" ||
                   method_name == "get" || method_name == "at" || method_name == "set" {
                    // Check if expression is a variable that looks like an array (starts with lowercase)
                    if let Expression::Variable(var_name) = &expr {
                        if var_name.chars().next().map_or(false, |c| c.is_ascii_lowercase()) {
                            expr = Expression::ArrayMethodCall {
                                array: Box::new(expr),
                                method: method_name.clone(),  // Use clone() to avoid move issues
                                args
                            };
                            continue;
                        }
                    }
                }

                // General method call
                expr = Expression::MethodCall {
                    object: Box::new(expr),
                    method: method_name,
                    args
                };
            } else {
                // This is property access without arguments (e.g., obj.length, obj.size)
                // Check if this is an array property method
                if method_name == "append" || method_name == "length" || method_name == "size" ||
                   method_name == "get" || method_name == "at" || method_name == "set" {
                    // Check if expression is a variable that looks like an array (starts with lowercase)
                    if let Expression::Variable(var_name) = &expr {
                        if var_name.chars().next().map_or(false, |c| c.is_ascii_lowercase()) {
                            expr = Expression::ArrayMethodCall {
                                array: Box::new(expr),
                                method: method_name.clone(),
                                args: vec![]  // No arguments for property access
                            };
                            continue;
                        }
                    }
                    // If not an array variable, fall through to create a general MethodCall
                }

                // General method call without arguments (or non-array property)
                expr = Expression::MethodCall {
                    object: Box::new(expr),
                    method: method_name,
                    args: vec![]  // No arguments
                };
            }
        } else {
            break; // No more method calls or property access
        }
    }

    // Check for binary operators (currently just +)
    if *i < tokens.len() && &tokens[*i] == "+" {
        let op = tokens[*i].clone();
        *i += 1; // Skip operator
        let right = parse_expression(tokens, i);
        return Expression::BinaryOperation {
            left: Box::new(expr),
            operator: op,
            right: Box::new(right)
        };
    }

    expr
}

// Parse primary expressions (variables, literals, array access, function calls)
fn parse_primary_expr(tokens: &[String], i: &mut usize) -> Expression {
    if *i >= tokens.len() {
        return Expression::StringLiteral("".to_string());
    }

    let token = &tokens[*i];

    // String literals
    if (token.starts_with('"') && token.ends_with('"')) || (token.starts_with('\'') && token.ends_with('\'')) {
        *i += 1;
        return Expression::StringLiteral(token[1..token.len()-1].to_string());
    }

    // Number literals
    if let Ok(num) = token.parse::<f64>() {
        *i += 1;
        return Expression::Number(num);
    }

    // Array literals: []
    if token == "[" && *i + 1 < tokens.len() && &tokens[*i + 1] == "]" {
        *i += 2; // Skip '[' and ']'
        return Expression::ArrayLiteral(vec![]);
    }

    // Array access: array[index] - look ahead to see if we have [ after the variable
    if *i + 2 < tokens.len() && &tokens[*i + 1] == "[" {
        let array_name = tokens[*i].clone();
        *i += 1; // Skip array name
        *i += 1; // Skip '['

        let index_expr = parse_expression(tokens, i); // Parse the index (could be complex)

        if *i < tokens.len() && &tokens[*i] == "]" {
            *i += 1; // Skip ']'
            let array_var = Expression::Variable(array_name);
            return Expression::ArrayAccess {
                array: Box::new(array_var),
                index: Box::new(index_expr)
            };
        } else {
            // Malformed - no closing bracket, return variable for now
            return Expression::Variable(array_name);
        }
    }

    // Check for nested namespace pattern first: module.submodule.function()
    if *i + 4 < tokens.len() && &tokens[*i + 1] == "." && &tokens[*i + 3] == "." {
        // This is the pattern: module . submodule . function ( args )
        let potential_module = format!("{}.{}", tokens[*i], tokens[*i + 2]);
        let function = tokens[*i + 4].clone();
        let known_modules = ["crystal", "math", "quantum", "symbolic", "networking", "system", "image", "graphics", "physics", "datetime", "lowlevel", "ml", "gui"];

        if known_modules.contains(&tokens[*i].as_str()) {
            *i += 5; // Skip module.submodule.function

            // Check if this is followed by arguments
            if *i < tokens.len() && &tokens[*i] == "(" {
                *i += 1; // Skip '('

                let mut args = Vec::new();
                while *i < tokens.len() && &tokens[*i] != ")" {
                    if &tokens[*i] != "," {
                        args.push(tokens[*i].clone());
                    }
                    *i += 1;
                }

                if *i < tokens.len() && &tokens[*i] == ")" {
                    *i += 1; // Skip ')'
                }

                // Check if this is an array method call (when potential_module is a variable name starting with lowercase)
                if potential_module.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
                   (function == "append" || function == "length" || function == "size" ||
                    function == "get" || function == "at" || function == "set") {
                    let array_var = Expression::Variable(potential_module);
                    return Expression::ArrayMethodCall {
                        array: Box::new(array_var),
                        method: function,
                        args
                    };
                } else {
                    return Expression::FunctionCall { module: potential_module, function, args };
                }
            } else {
                // Just a module.submodule.function without arguments
                return Expression::FunctionCall { module: potential_module, function, args: vec![] };
            }
        }
    }

    // If next token is dot (.), this could be a module.function() pattern
    if *i + 2 < tokens.len() && &tokens[*i + 1] == "." {
        let module = tokens[*i].clone();
        let function = tokens[*i + 2].clone();
        *i += 3; // Skip module.function

        // Check if this is followed by arguments
        if *i < tokens.len() && &tokens[*i] == "(" {
            *i += 1; // Skip '('

            let mut args = Vec::new();
            while *i < tokens.len() && &tokens[*i] != ")" {
                if &tokens[*i] != "," {
                    args.push(tokens[*i].clone());
                }
                *i += 1;
            }

            if *i < tokens.len() && &tokens[*i] == ")" {
                *i += 1; // Skip ')'
            }

            // Check if this is an array method call (module is actually a variable name starting with lowercase)
            if module.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
               (function == "append" || function == "length" || function == "size" ||
                function == "get" || function == "at" || function == "set") {
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
            // Just a module.function without arguments
            return Expression::FunctionCall { module, function, args: vec![] };
        }
    }

    // Regular variable name
    let var_name = tokens[*i].clone();
    *i += 1;
    Expression::Variable(var_name)
}

// Parse primary expressions (variables, literals, array access)
fn parse_primary_expression_expr(tokens: &[String], i: &mut usize) -> Expression {
    if *i >= tokens.len() {
        return Expression::StringLiteral("".to_string());
    }

    let token = &tokens[*i];

    // String literals
    if (token.starts_with('"') && token.ends_with('"')) || (token.starts_with('\'') && token.ends_with('\'')) {
        *i += 1;
        return Expression::StringLiteral(token[1..token.len()-1].to_string());
    }

    // Numeric literals
    if let Ok(num) = token.parse::<f64>() {
        *i += 1;
        return Expression::Number(num);
    }

    // Array access: array[index]
    if *i + 2 < tokens.len() && &tokens[*i + 1] == "[" {
        let array_name = tokens[*i].clone();
        *i += 2; // Skip array name and '['

        let index_expr = parse_expression(tokens, i);

        if *i < tokens.len() && &tokens[*i] == "]" {
            *i += 1; // Skip ']'
            let array_var = Expression::Variable(array_name);
            return Expression::ArrayAccess {
                array: Box::new(array_var),
                index: Box::new(index_expr)
            };
        } else {
            // Malformed array access
            return Expression::Variable(array_name);
        }
    }

    // Function call: module.function(args) or object.method(args) - this is handled in the main loop but also here for completion
    if *i + 2 < tokens.len() && &tokens[*i + 1] == "." && &tokens[*i + 2] != "(" {
        // Handle: module.function() pattern
        let module = tokens[*i].clone();
        let function = tokens[*i + 2].clone();
        *i += 3; // Skip module.function

        if *i < tokens.len() && &tokens[*i] == "(" {
            *i += 1; // Skip '('

            let mut args = Vec::new();
            while *i < tokens.len() && &tokens[*i] != ")" {
                if &tokens[*i] != "," {
                    args.push(tokens[*i].clone());
                }
                *i += 1;
            }

            if *i < tokens.len() && &tokens[*i] == ")" {
                *i += 1; // Skip ')'
            }

            return Expression::FunctionCall {
                module,
                function,
                args
            };
        }
    }

    // Array literal: [] (handled as separate tokens)
    if token == "[" && *i + 1 < tokens.len() && &tokens[*i + 1] == "]" {
        *i += 2; // Skip '[' and ']'
        return Expression::ArrayLiteral(vec![]);
    }

    // Regular variable name
    let var_name = tokens[*i].clone();
    *i += 1;
    Expression::Variable(var_name)
}

// Parse binary operations
fn parse_binary_op(tokens: &[String], i: &mut usize, left: Expression, operator: String) -> Expression {
    if *i < tokens.len() && tokens[*i] == operator {
        *i += 1; // Skip operator

        let right = parse_expression(tokens, i);

        return Expression::BinaryOperation {
            left: Box::new(left),
            operator,
            right: Box::new(right)
        };
    }

    left
}

// Helper to parse simple expressions (non-binary)
fn parse_simple_expression(tokens: &[String], i: &mut usize) -> Expression {
    if *i < tokens.len() {
        // Handle array literal: []
        if *i + 1 < tokens.len() && &tokens[*i] == "[" && &tokens[*i + 1] == "]" {
            *i += 2; // Skip '[' and ']'
            // Return an actual ArrayLiteral expression
            return Expression::ArrayLiteral(vec![]); // Empty array literal
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
        // Handle function calls like: module.function() or variable.method() - this is handled in the main loop but also here for completion
        else if *i + 2 < tokens.len() && &tokens[*i + 1] == "." {
            // Look ahead to see if we have a nested namespace pattern like: graphics.stl_basic.function()
            let mut is_nested_namespace = false;
            let mut module_name = "".to_string();
            let mut function_name = "".to_string();
            let mut advance_amount = 0;

            // Check for 3-token pattern: module . submodule . function
            if *i + 4 < tokens.len() && &tokens[*i + 1] == "." && &tokens[*i + 3] == "." {
                // Potential nested namespace: check if first part is a known module
                let potential_module = format!("{}.{}", tokens[*i], tokens[*i + 2]);
                let known_modules = ["crystal", "math", "quantum", "symbolic", "networking", "system", "image", "graphics", "physics", "datetime", "lowlevel", "ml", "gui"];

                if known_modules.contains(&tokens[*i].as_str()) {
                    // This looks like a nested namespace call: module.submodule.function()
                    module_name = potential_module;
                    function_name = tokens[*i + 4].clone();
                    advance_amount = 5; // module . submodule . function
                    is_nested_namespace = true;
                }
            }

            if is_nested_namespace {
                *i += advance_amount; // Skip module.submodule.function

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

                    // Check if this is an array method call (when module is a variable name starting with lowercase)
                    if module_name.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
                       (function_name == "append" || function_name == "length" || function_name == "size" ||
                        function_name == "get" || function_name == "at" || function_name == "set") {
                        let array_var = Expression::Variable(module_name);
                        return Expression::ArrayMethodCall {
                            array: Box::new(array_var),
                            method: function_name,
                            args
                        };
                    } else {
                        return Expression::FunctionCall { module: module_name, function: function_name, args };
                    }
                } else {
                    // This is a nested namespace reference without parentheses
                    return Expression::Variable(module_name); // Treat as variable/namespace reference
                }
            } else {
                // Handle regular module.function() or variable.method() call
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

                    // Check if this is an array method call (when module is a variable name starting with lowercase)
                    if module.chars().next().map_or(false, |c| c.is_ascii_lowercase()) &&
                       (function == "append" || function == "length" || function == "size" ||
                        function == "get" || function == "at" || function == "set") {
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
                    return Expression::FunctionCall { module, function, args: vec![] };
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
                        // This is an array method call like list.length or list.get(index) that returns a value
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

                        // Map NymyaLang array methods to C++ equivalents - these methods return values for assignment
                        let method_call = match method.as_str() {
                            "append" => format!("{}.push_back({})", array_cpp, args_cpp.join(", ")), // Side-effect, returns void
                            "length" | "size" => format!("{}.size()", array_cpp), // Returns size value
                            "get" | "at" => format!("{}[{}]", array_cpp, args_cpp.join(", ")), // Returns element value
                            "set" => {
                                if args_cpp.len() >= 2 {
                                    format!("{}[{}] = {}", array_cpp, args_cpp[0], args_cpp[1]) // Assignment, returns void
                                } else {
                                    format!("{}[0] = {}", array_cpp, args_cpp.get(0).unwrap_or(&"0".to_string()))
                                }
                            },
                            _ => format!("{}->{}({})", array_cpp, method, args_cpp.join(", ")) // General method call
                        };

                        // For method calls that return values (length, get, at), generate assignment
                        // For side-effect calls (append, set), we might need special handling
                        if method == "append" || method == "set" {
                            // These are void-returning operations that modify the array
                            cpp_code.push_str(&format!("    {};\n", method_call));
                        } else {
                            // These return values for assignment
                            cpp_code.push_str(&format!("    auto {} = {};\n", var_name, method_call));
                        }
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
                    // Extract string content from the argument (remove quotes if simple string literal)
                    let arg = &args[0];

                    // Check if it's a simple string literal (surrounded by quotes)
                    if (arg.starts_with("\"") && arg.ends_with("\"")) || (arg.starts_with("\'") && arg.ends_with("\'")) {
                        let content = &arg[1..arg.len()-1]; // Remove surrounding quotes
                        cpp_code.push_str(&format!("    crystal::manifest(\"{}\");\n", content));
                    } else {
                        // For complex expressions like "text" + x.to_string(), output as-is
                        // These should be already in proper C++ expression format after parsing
                        cpp_code.push_str(&format!("    crystal::manifest({});\n", arg));
                    }
                } else {
                    // Generic function call generation
                    let args_cpp: Vec<String> = args.iter()
                        .map(|arg| {
                            // Handle different types of arguments
                            if (arg.starts_with("\"") && arg.ends_with("\"")) || (arg.starts_with("\'") && arg.ends_with("\'")) {
                                // String literals - convert single quotes to double quotes for C++
                                let content = &arg[1..arg.len()-1];
                                format!("\"{}\"", content)
                            } else {
                                // Variables or complex expressions - output as-is
                                arg.to_string()
                            }
                        })
                        .collect();

                    // Convert nested module names from dot notation to C++ namespace notation
                    let module_cpp = module.replace(".", "::");
                    cpp_code.push_str(&format!("    {}::{}({});\n", module_cpp, function, args_cpp.join(", ")));
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
            Statement::ExpressionStmt { expression } => {
                // Generate C++ code for expression statements (like obj.method() calls that are statements)
                let expr_cpp = generate_cpp_for_expression(expression);
                cpp_code.push_str(&format!("    {};\n", expr_cpp));
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
            // Convert nested module names from dot notation to C++ namespace notation
            let module_cpp = module.replace(".", "::");
            format!("{}::{}({})", module_cpp, function, args_cpp.join(", "))
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
        Expression::MethodCall { object, method, args } => {
            let object_cpp = generate_cpp_for_expression(object.as_ref());
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

            // Handle common NymyaLang methods that map to appropriate C++ equivalents
            match method.as_str() {
                "to_string" => format!("std::to_string({})", object_cpp),  // Convert primitives to string using std::to_string
                _ => format!("{}->{}({})", object_cpp, method, args_cpp.join(", ")) // General method call format using -> pointer syntax
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

            // Handle string concatenation specially since C++ doesn't allow direct concatenation
            // of string literals with other types
            if operator == "+" {
                // Only apply special handling when one side is an actual string literal
                if left_cpp.starts_with('"') || right_cpp.starts_with('"') {
                    let left_str = if left_cpp.starts_with('"') {
                        format!("std::string({})", left_cpp)
                    } else {
                        left_cpp
                    };
                    let right_str = if right_cpp.starts_with('"') {
                        format!("std::string({})", right_cpp)
                    } else {
                        right_cpp
                    };
                    return format!("{} + {}", left_str, right_str);
                }
            }

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
#include <fstream>

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

// Crystal utilities (console output and file operations)
namespace crystal {{
    void manifest(const std::string& msg) {{
        std::cout << msg << std::endl;
    }}

    void print(const std::string& msg) {{
        std::cout << msg;
    }}

    // File operations namespace (Taygetan-inspired names)
    namespace file {{
        // dalan_orin = home food (nourish home with content)
        bool dalan_orin(const std::string& path, const std::string& content) {{
            std::ofstream file(path);
            if (file.is_open()) {{
                file << content;
                file.close();
                return true;
            }}
            return false;
        }}

        // dalan_aya = home see (check if home exists)
        bool dalan_aya(const std::string& path) {{
            std::ifstream file(path);
            bool exists = file.good();
            if (exists) {{
                file.close();
            }}
            return exists;
        }}

        // dalan_karma = home work (read content from home)
        std::string dalan_karma(const std::string& path) {{
            std::ifstream file(path);
            if (file.is_open()) {{
                std::string content;
                std::string line;
                while (std::getline(file, line)) {{
                    content += line + "\\n";
                }}
                file.close();
                return content;
            }}
            return "";
        }}

        // dalan_lora = home exist (create output stream)
        std::ofstream dalan_lora(const std::string& path) {{
            return std::ofstream(path);
        }}

        // dalan_shira = home love (create input stream)
        std::ifstream dalan_shira(const std::string& path) {{
            return std::ifstream(path);
        }}
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