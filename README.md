# C Compiler

A functional C compiler that translates C source code into x86 assembly, built using Lex and Yacc for lexical analysis and parsing. Supports core C language features including functions, variables, control flow, arrays, and complex expressions with proper operator precedence.

## Overview

This compiler implements a significant subset of the C programming language, generating executable x86 assembly code. The project demonstrates understanding of compiler design principles, formal language theory, and low-level code generation.

**Key Achievement:** Successfully compiles and executes complex programs including recursive algorithms, sorting implementations, and the classic N-Queens problem.

## Architecture

```
Source Code (.c) → Lexical Analysis → Parsing → Code Generation → Assembly (.s)
                     (Lex)            (Yacc)      (Custom)
```

### Core Components

- **Lexer (`simple.l`)** - Tokenizes C source code, handling keywords, operators, literals, and identifiers
- **Parser (`simple.y`)** - Implements C grammar rules and builds abstract syntax trees using Yacc
- **Code Generator** - Translates parsed constructs into x86 assembly with proper register allocation
- **Symbol Table** - Manages variable scoping, function definitions, and type information

## Supported Language Features

### Data Types & Variables
- `long` integers and `char` data types
- Global and local variable declarations
- Automatic variable initialization
- Array declarations and multi-dimensional arrays

### Functions & Control Flow
- Function definitions with multiple parameters
- Function calls with argument passing
- Return statements with value propagation
- Recursive function calls

### Operators & Expressions
- Arithmetic operators (`+`, `-`, `*`, `/`)
- Relational operators (`<`, `>`, `<=`, `>=`)
- Equality operators (`==`, `!=`)
- Logical operators (`&&`, `||`) with **short-circuit evaluation**
- Address-of operator (`&`)
- Proper operator precedence and associativity

### Control Structures
- `if` statements with conditional branching
- `while` and `do-while` loops
- `for` loops with initialization, condition, and increment
- `break` and `continue` statements
- Nested control structures

### Advanced Features
- **Short-circuit boolean evaluation** - Optimized logical operators that skip unnecessary evaluations
- **Multiple function arguments** - Handles complex function calls with 6+ parameters
- **Complex expressions** - Supports nested arithmetic and logical expressions
- **Array operations** - Multi-dimensional array access and manipulation

## Technical Challenges Solved

1. **Register Management** - Implemented systematic x86-64 register allocation using dedicated register sets for arguments and general computation
2. **Scope Resolution** - Built symbol table system managing global variables, local variables, and function parameters with proper scoping rules
3. **Code Generation** - Translated high-level C constructs into correct x86-64 assembly sequences with proper calling conventions
4. **Expression Parsing** - Handled complex nested expressions with correct operator precedence and associativity rules
5. **Control Flow** - Generated proper jump labels and branch instructions for loops, conditionals, and function calls

## Test Suite

The compiler includes a comprehensive test suite with 31+ test cases covering:

- **Basic Programs** - Hello world, variable assignments
- **Algorithms** - Bubble sort, quicksort, factorial computation
- **Data Structures** - Array manipulation, string operations
- **Advanced Logic** - N-Queens solver, complex mathematical expressions
- **Edge Cases** - Short-circuit evaluation, nested function calls

### Running Tests

```bash
make test
```

The test suite compares compiler output against GCC to ensure correctness, validating that generated assembly produces identical results to standard C compilation.

## Build & Usage

```bash
# Build the compiler
make

# Compile a C program
./scc program.c

# Assemble and run  
gcc -static -o program program.s
./program
```

## Example Programs

The compiler successfully handles complex programs like this recursive N-Queens solver:

```c
int board[8];
int solutions = 0;

int safe(int row, int col) {
    int i;
    for (i = 0; i < row; i++) {
        if (board[i] == col || 
            board[i] - i == col - row || 
            board[i] + i == col + row)
            return 0;
    }
    return 1;
}

void solve(int row) {
    if (row == 8) {
        solutions++;
        return;
    }
    int col;
    for (col = 0; col < 8; col++) {
        if (safe(row, col)) {
            board[row] = col;
            solve(row + 1);
        }
    }
}
```

## What I Learned

- **Compiler Theory** - Deep understanding of lexical analysis, parsing, and code generation phases
- **Assembly Programming** - Experience with x86 instruction set and low-level optimization
- **Language Design** - Insights into how high-level constructs map to machine operations  
- **Tool Mastery** - Proficient use of Lex/Yacc for building production parsers
- **Testing Methodologies** - Comprehensive validation against reference implementations

This project reinforced the connection between theoretical computer science concepts and practical systems programming, showing how abstract language rules translate into concrete machine instructions.