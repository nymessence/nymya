#!/bin/bash

# NymyaLang Syntax Highlighter Installation Script
# Installs syntax highlighting for various editors

set -e  # Exit on error

echo "Installing NymyaLang syntax highlighting..."

# Create backup directory
BACKUP_DIR="$HOME/.nym_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Install for Gedit/Pluma (GTKSourceView)
install_gedit_syntax() {
    echo "Installing Gedit/Pluma syntax highlighting..."
    
    # User-specific installation
    USER_LANG_DIR="$HOME/.local/share/gtksourceview-4/language-specs"
    USER_THEME_DIR="$HOME/.local/share/gtksourceview-4/styles"
    
    # System-wide installation (requires sudo)
    SYSTEM_LANG_DIR="/usr/share/gtksourceview-4/language-specs"
    SYSTEM_THEME_DIR="/usr/share/gtksourceview-4/styles"
    
    # Create directories if they don't exist
    mkdir -p "$USER_LANG_DIR" "$USER_THEME_DIR"
    
    # Copy language definition
    if [ -f "nymya.lang" ]; then
        cp "nymya.lang" "$USER_LANG_DIR/"
        echo "  Copied nymya.lang to $USER_LANG_DIR"
    else
        echo "  Warning: nymya.lang not found in current directory"
    fi
    
    # Copy theme
    if [ -f "nymya.xml" ]; then
        cp "nymya.xml" "$USER_THEME_DIR/"
        echo "  Copied nymya.xml to $USER_THEME_DIR"
    else
        echo "  Warning: nymya.xml not found in current directory"
    fi
    
    # Try system-wide installation if user has sudo privileges
    if command -v sudo >/dev/null 2>&1; then
        if [ -w "$SYSTEM_LANG_DIR" ] || sudo -v; then
            echo "  Attempting system-wide installation..."
            if [ -f "nymya.lang" ]; then
                sudo cp "nymya.lang" "$SYSTEM_LANG_DIR/" 2>/dev/null || echo "  System-wide language installation failed (permission denied)"
            fi
            if [ -f "nymya.xml" ]; then
                sudo cp "nymya.xml" "$SYSTEM_THEME_DIR/" 2>/dev/null || echo "  System-wide theme installation failed (permission denied)"
            fi
        fi
    fi
}

# Install for Nano
install_nano_syntax() {
    echo "Installing Nano syntax highlighting..."
    
    # User-specific installation
    if [ -f "nym.nanorc" ]; then
        NANO_CONFIG_FILE="$HOME/.nanorc"
        if [ -f "$NANO_CONFIG_FILE" ]; then
            # Backup existing config
            cp "$NANO_CONFIG_FILE" "$BACKUP_DIR/nanorc.backup" 2>/dev/null || true
            echo "  Backed up existing .nanorc to $BACKUP_DIR/nanorc.backup"
        fi
        
        # Append to existing config or create new one
        if grep -q "nym.nanorc" "$NANO_CONFIG_FILE" 2>/dev/null; then
            echo "  NymyaLang syntax already referenced in .nanorc"
        else
            echo "include ~/.config/nano/nym.nanorc" >> "$NANO_CONFIG_FILE"
            echo "  Added include directive to .nanorc"
        fi
        
        # Create nano configs directory and copy syntax file
        NANO_CONFIG_DIR="$HOME/.config/nano"
        mkdir -p "$NANO_CONFIG_DIR"
        cp "nym.nanorc" "$NANO_CONFIG_DIR/"
        echo "  Copied nym.nanorc to $NANO_CONFIG_DIR"
    else
        echo "  Warning: nym.nanorc not found in current directory"
    fi
}

# Install for Vim
install_vim_syntax() {
    echo "Installing Vim syntax highlighting..."
    
    VIM_SYNTAX_DIR="$HOME/.vim/syntax"
    VIM_FTDETECT_DIR="$HOME/.vim/ftdetect"
    
    # Create directories
    mkdir -p "$VIM_SYNTAX_DIR" "$VIM_FTDETECT_DIR"
    
    # Copy syntax file
    if [ -f "nym.vim" ]; then
        cp "nym.vim" "$VIM_SYNTAX_DIR/"
        echo "  Copied nym.vim to $VIM_SYNTAX_DIR"
        
        # Create filetype detection
        echo 'au BufNewFile,BufRead *.nym set filetype=nym' > "$VIM_FTDETECT_DIR/nym.vim"
        echo "  Created filetype detection for .nym files"
    else
        echo "  Warning: nym.vim not found in current directory"
    fi
    
    # Also install for Neovim
    NVIM_SYNTAX_DIR="$HOME/.config/nvim/syntax"
    NVIM_FTDETECT_DIR="$HOME/.config/nvim/ftdetect"
    
    mkdir -p "$NVIM_SYNTAX_DIR" "$NVIM_FTDETECT_DIR"
    
    if [ -f "nym.vim" ]; then
        cp "nym.vim" "$NVIM_SYNTAX_DIR/"
        echo "  Copied nym.vim to $NVIM_SYNTAX_DIR"
        echo 'au BufNewFile,BufRead *.nym set filetype=nym' > "$NVIM_FTDETECT_DIR/nym.vim"
        echo "  Created Neovim filetype detection for .nym files"
    fi
}

# Install for VS Code (if available)
install_vscode_syntax() {
    if command -v code >/dev/null 2>&1; then
        echo "Installing VS Code syntax highlighting..."
        
        # Create extension directory
        EXT_DIR="$HOME/.vscode/extensions/nymya-lang-0.1.0"
        mkdir -p "$EXT_DIR/syntaxes"
        
        # Convert language file to VS Code format
        cat > "$EXT_DIR/package.json" << 'EOF'
{
    "name": "nymya-lang",
    "displayName": "NymyaLang Support",
    "description": "Syntax highlighting for NymyaLang (.nym) files",
    "version": "0.1.0",
    "engines": {
        "vscode": "^1.0.0"
    },
    "categories": ["Programming Languages"],
    "contributes": {
        "languages": [{
            "id": "nymya",
            "aliases": ["NymyaLang", "nymya"],
            "extensions": [".nym"],
            "configuration": "./language-configuration.json"
        }],
        "grammars": [{
            "language": "nymya",
            "scopeName": "source.nymya",
            "path": "./syntaxes/nymya.json"
        }]
    }
}
EOF
        
        # Create language configuration
        cat > "$EXT_DIR/language-configuration.json" << 'EOF'
{
    "comments": {
        "lineComment": "#"
    },
    "brackets": [
        ["{", "}"],
        ["[", "]"],
        ["(", ")"]
    ],
    "autoClosingPairs": [
        ["{", "}"],
        ["[", "]"],
        ["(", ")"],
        ["\"", "\""],
        ["'", "'"]
    ],
    "surroundingPairs": [
        ["{", "}"],
        ["[", "]"],
        ["(", ")"],
        ["\"", "\""],
        ["'", "'"]
    ]
}
EOF
        
        # Create basic TM syntax (simple version)
        cat > "$EXT_DIR/syntaxes/nymya.json" << 'EOF'
{
  "fileTypes": ["nym"],
  "name": "nymya",
  "patterns": [
    {
      "include": "#comments"
    },
    {
      "include": "#keywords"
    },
    {
      "include": "#strings"
    },
    {
      "include": "#numbers"
    },
    {
      "include": "#operators"
    }
  ],
  "repository": {
    "comments": {
      "patterns": [{
        "begin": "#",
        "end": "$",
        "name": "comment.line.number-sign.nymya"
      }]
    },
    "keywords": {
      "patterns": [{
        "match": "\\b(import|func|init|class|struct|namespace|var|val|static|export|extern|macro|if|else|elif|while|for|range|return|break|continue|this|true|false|Void|Any|Int|Float|String|Char|Bool|List|Type)\\b",
        "name": "keyword.control.nymya"
      }]
    },
    "strings": {
      "patterns": [{
        "begin": "\"",
        "end": "\"",
        "name": "string.quoted.double.nymya"
      }]
    },
    "numbers": {
      "patterns": [{
        "match": "\\b[0-9]+(\\.[0-9]+)?\\b",
        "name": "constant.numeric.nymya"
      }]
    },
    "operators": {
      "patterns": [{
        "match": "(\\+|\\-|\\*|\\/|%|=|==|!=|<|>|<=|>=|&&|\\|\\||!|&|\\||\\^|~|<<|>>|\\+=|\\-=|\\*=|\\/=|%=)",
        "name": "keyword.operator.nymya"
      }]
    }
  },
  "scopeName": "source.nymya"
}
EOF
        
        echo "  Created VS Code extension in $EXT_DIR"
        echo "  To install: code --install-extension $EXT_DIR (manually)"
    else
        echo "VS Code not found, skipping VS Code extension installation"
    fi
}

# Main installation logic
install_gedit_syntax
install_nano_syntax
install_vim_syntax
install_vscode_syntax

echo
echo "Installation complete!"
echo
echo "Files backed up to: $BACKUP_DIR"
echo
echo "To use the syntax highlighting:"
echo "- For Gedit/Pluma: Restart the editor and select NymyaLang as language"
echo "- For Nano: Restart nano or check that ~/.nanorc includes the nym.nanorc file"
echo "- For Vim: Open a .nym file and syntax highlighting should be automatic"
echo
echo "You may need to restart your editors for changes to take effect."