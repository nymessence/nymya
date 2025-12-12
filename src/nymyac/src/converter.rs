// Helper function to convert AST statements to C++ code
fn convert_ast_statement_to_cpp(stmt: &Statement) -> String {
    match stmt {
        Statement::Expression(expr) => format!("{};", convert_expression_to_cpp(expr)),
        Statement::VariableDeclaration { name, value } => {
            format!("auto {} = {};", name, convert_expression_to_cpp(value))
        },
        Statement::Assignment { variable, value } => {
            format!("{} = {};", variable, convert_expression_to_cpp(value))
        },
        Statement::If { condition, then_branch, else_branch } => {
            let cond_cpp = convert_expression_to_cpp(condition);
            let mut then_cpp = String::new();
            for stmt in then_branch {
                let stmt_cpp = convert_ast_statement_to_cpp(stmt);
                if !stmt_cpp.is_empty() {
                    then_cpp.push_str(&format!("            {}\n", stmt_cpp));
                }
            }
            
            if let Some(else_stmts) = else_branch {
                let mut else_cpp = String::new();
                for stmt in else_stmts {
                    let stmt_cpp = convert_ast_statement_to_cpp(stmt);
                    if !stmt_cpp.is_empty() {
                        else_cpp.push_str(&format!("            {}\n", stmt_cpp));
                    }
                }
                format!(
                    "if ({}) {{\n{}        }} else {{\n{}        }}",
                    cond_cpp, then_cpp, else_cpp
                )
            } else {
                format!(
                    "if ({}) {{\n{}        }}",
                    cond_cpp, then_cpp
                )
            }
        },
        Statement::While { condition, body } => {
            let cond_cpp = convert_expression_to_cpp(condition);
            let mut body_cpp = String::new();
            for stmt in body {
                let stmt_cpp = convert_ast_statement_to_cpp(stmt);
                if !stmt_cpp.is_empty() {
                    body_cpp.push_str(&format!("            {}\n", stmt_cpp));
                }
            }
            format!(
                "while ({}) {{\n{}        }}",
                cond_cpp, body_cpp
            )
        },
        Statement::Import { path: _ } => {
            // Import statements are handled separately for includes
            String::new()  // Return empty string since imports don't generate executable code
        },
    }
}

// Helper function to convert expressions to C++ code
fn convert_expression_to_cpp(expr: &Expression) -> String {
    match expr {
        Expression::Integer(val) => val.to_string(),
        Expression::Float(val) => {
            if val.fract() == 0.0 {
                format!("{}.0", val)  // Ensure float representation
            } else {
                val.to_string()
            }
        },
        Expression::String(val) => format!("\"{}\"", val.escape_default()),
        Expression::Boolean(val) => if *val { "true".to_string() } else { "false".to_string() },
        Expression::Variable(name) => format!("nlr::{}", name),  // Assume in our namespace
        Expression::BinaryOp { left, operator, right } => {
            let left_cpp = convert_expression_to_cpp(left);
            let right_cpp = convert_expression_to_cpp(right);
            
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
            let args_cpp: Vec<String> = args.iter().map(|arg| convert_expression_to_cpp(arg)).collect();
            
            // Map some NymyaLang standard library functions to C++ equivalents
            match name.as_str() {
                "crystal.manifest" => {
                    if args_cpp.len() >= 1 {
                        format!("nlr::crystal::manifest({})", args_cpp[0])
                    } else {
                        "// Error: crystal.manifest requires at least one argument".to_string()
                    }
                },
                "crystal.print" => {
                    if args_cpp.len() >= 1 {
                        format!("nlr::crystal::print({})", args_cpp[0])
                    } else {
                        "// Error: crystal.print requires at least one argument".to_string()
                    }
                },
                "math.sqrt" => {
                    if args_cpp.len() >= 1 {
                        format!("nlr::math::sqrt({})", args_cpp[0])
                    } else {
                        "// Error: math.sqrt requires one argument".to_string()
                    }
                },
                "math.abs" => {
                    if args_cpp.len() >= 1 {
                        format!("nlr::math::abs({})", args_cpp[0])
                    } else {
                        "// Error: math.abs requires one argument".to_string()
                    }
                },
                "math.sin" => {
                    if args_cpp.len() >= 1 {
                        format!("nlr::math::sin({})", args_cpp[0])
                    } else {
                        "// Error: math.sin requires one argument".to_string()
                    }
                },
                "math.pow_int" => {
                    if args_cpp.len() >= 2 {
                        format!("nlr::math::pow_int({}, {})", args_cpp[0], args_cpp[1])
                    } else {
                        "// Error: math.pow_int requires two arguments".to_string()
                    }
                },
                "math.gcd" => {
                    if args_cpp.len() >= 2 {
                        format!("nlr::math::gcd({}, {})", args_cpp[0], args_cpp[1])
                    } else {
                        "// Error: math.gcd requires two arguments".to_string()
                    }
                },
                _ => {
                    // For other function calls, use the original name with args
                    format!("{}({})", name, args_cpp.join(", "))
                }
            }
        },
    }
}