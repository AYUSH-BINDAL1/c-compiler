%token <string_val> WORD

%token NOTOKEN LPARENT RPARENT LBRACE RBRACE LCURLY RCURLY COMA SEMICOLON EQUAL STRING_CONST LONG LONGSTAR VOID CHARSTAR CHARSTARSTAR INTEGER_CONST AMPERSAND OROR ANDAND EQUALEQUAL NOTEQUAL LESS GREAT LESSEQUAL GREATEQUAL PLUS MINUS TIMES DIVIDE PERCENT IF ELSE WHILE DO FOR CONTINUE BREAK RETURN

%union {
  char *string_val;
  int nargs;
  int my_nlabel;
}



%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyerror(const char *s);

extern int line_number;
const char *input_file;
char *asm_file;
FILE *fasm;

#define MAX_ARGS 6
int nargs;
char *args_table[MAX_ARGS];

#define MAX_GLOBALS 100
int nglobals = 0;
char *global_vars_table[MAX_GLOBALS];
int global_vars_type[MAX_GLOBALS];

#define MAX_LOCALS 32
int nlocals = 0;
char *local_vars_table[MAX_LOCALS];
int local_vars_type[MAX_LOCALS];

#define MAX_STRINGS 100
int nstrings = 0;
char *string_table[MAX_STRINGS];

char *regStkByte[] = { "bl", "r10b", "r13b", "r14b", "r15b", "r11b"};
char *regStk[]={ "rbx", "r10", "r13", "r14", "r15", "r11"};
char nregStk = sizeof(regStk) / sizeof(char *);

char *regArgs[]={ "rdi", "rsi", "rdx", "rcx", "r8", "r9"};
char nregArgs = sizeof(regArgs) / sizeof(char *);

int top = 0;

int nargs = 0;

int nifs = 0;

int nloops = 0;

int loopTop = 0;

int currentType;

%}



%%
goal:
    program
    ;



program:
       function_or_var_list
       ;



function_or_var_list:
                    function_or_var_list function
                    | function_or_var_list global_var
                    | /*empty */
                    ;



function:
         var_type WORD {

            nlocals = 0;
            top = 0;

            fprintf(fasm, "\t.text\n");
            fprintf(fasm, ".globl %s\n", $2);
            fprintf(fasm, "%s:\n", $2);

            fprintf(fasm, "\t# Save Frame pointer\n");
            fprintf(fasm, "\tpushq %%rbp\n");
            fprintf(fasm, "\tmovq %%rsp,%%rbp\n");

            fprintf(fasm, "\tsubq $%d, %%rsp\n", 8 * MAX_LOCALS);
            fprintf(fasm, "\t# Save registers. \n");
            fprintf(fasm, "\t# Push one extra to align stack to 16bytes\n");
            fprintf(fasm, "\tpushq %%rbx\n");
            fprintf(fasm, "\tpushq %%rbx\n");
            fprintf(fasm, "\tpushq %%r10\n");
            fprintf(fasm, "\tpushq %%r13\n");
            fprintf(fasm, "\tpushq %%r14\n");
            fprintf(fasm, "\tpushq %%r15\n");

         }
         LPARENT arguments RPARENT {

            for (int i = 0; i < nlocals; i++) {
              fprintf(fasm, "\tmovq %%%s, -%d(%%rbp)\n", regArgs[i], 8 * (i + 1));
            }

         }
         compound_statement {

            fprintf(fasm, "\t# Restore registers\n");
            fprintf(fasm, "\tpopq %%r15\n");
            fprintf(fasm, "\tpopq %%r14\n");
            fprintf(fasm, "\tpopq %%r13\n");
            fprintf(fasm, "\tpopq %%r10\n");
            fprintf(fasm, "\tpopq %%rbx\n");
            fprintf(fasm, "\tpopq %%rbx\n");
            fprintf(fasm, "\tleave\n");
            fprintf(fasm, "\tret\n");

         }
         ;



arg_list:
         arg
         | arg_list COMA arg
         ;



arguments:
         arg_list
         | /*empty*/
         ;



arg:
   var_type WORD {

      local_vars_table[nlocals] = $2;
      local_vars_type[nlocals] = currentType;
      nlocals++;

   }
   ;



global_var:
          var_type global_var_list SEMICOLON
          ;



global_var_list:
               WORD {

                  if (nglobals == 0) {
                    fprintf(fasm, ".data\n");
                  }

                  fprintf(fasm,"\t# global id=%s\n", $1);
                  fprintf(fasm, ".comm %s, 8\n", $1);
                  fprintf(fasm, "\n");
                  global_vars_table[nglobals] = $1;
                  global_vars_type[nglobals] = currentType;
                  nglobals++;
               }

               | global_var_list COMA WORD {

                  fprintf(fasm,"\t# global id=%s\n", $3);
                  fprintf(fasm, ".comm %s, 8\n", $3);
                  fprintf(fasm, "\n");
                  global_vars_table[nglobals] = $3;
                  global_vars_type[nglobals] = currentType;
                  nglobals++;

               }
               ;



var_type:
        CHARSTAR {
          currentType = 1;
        } 

        | CHARSTARSTAR {
          currentType = 2;
        }

        | LONG {
          currentType = 3;
        }

        | LONGSTAR {
          currentType = 4;
        }

        | VOID {
          currentType = 5;
        }
        ;



assignment:
          WORD EQUAL expression {

            int localVariablePosition = -1;

            for (int i = 0; i < nlocals; i++) {
              if (strcmp(local_vars_table[i], $1) == 0) {
                localVariablePosition = i;
                break;
              }
            }

            if (localVariablePosition != -1) {
              //Local variable
              fprintf(fasm, "\tmovq %%rbx, -%d(%%rbp)\n", 8 * (localVariablePosition + 1));
            } else {
              //Global variable
              fprintf(fasm, "\tmovq %%rbx, %s\n", $1);
            }

            top--;

          }
          | WORD LBRACE expression RBRACE {

            int localVariablePosition = -1;

            for (int i = 0; i < nlocals; i++) {
                if (strcmp(local_vars_table[i], $1) == 0) {
                    localVariablePosition = i;
                    break;
                }
            }
    
            if (localVariablePosition != -1) {
              //Local variable
              if (local_vars_type[localVariablePosition] == 1) {
                fprintf(fasm, "\timulq $1, %%%s\n", regStk[top - 1]);
              } else {
                fprintf(fasm, "\timulq $8, %%%s\n", regStk[top - 1]);
              }

              fprintf(fasm, "\taddq -%d(%%rbp), %%%s\n", 8 * (localVariablePosition + 1), regStk[top - 1]);
            } else {
              //Global variable
              int globalVariablePosition = -1;

              for (int i = 0; i < nglobals; i++) {
                if (strcmp(global_vars_table[i], $1) == 0) {
                    globalVariablePosition = i;
                    break;
                }
              }

              if (global_vars_type[globalVariablePosition] == 1) {
                fprintf(fasm, "\timulq $1, %%%s\n", regStk[top - 1]);
              } else {
                fprintf(fasm, "\timulq $8, %%%s\n", regStk[top - 1]);
              }
              fprintf(fasm, "\tmovq %s(%%rip), %%%s\n", $1, regStk[top]);
              top++;
              fprintf(fasm, "\taddq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
              top--;
            }

          }
          EQUAL expression {
            int localVariablePosition = -1;

            for (int i = 0; i < nlocals; i++) {
                if (strcmp(local_vars_table[i], $1) == 0) {
                    localVariablePosition = i;
                    break;
                }
            }
            if (localVariablePosition != -1) {
              if (local_vars_type[localVariablePosition] == 1) {
                fprintf(fasm, "\tmovb %%%s, (%%%s)\n", regStkByte[top - 1], regStk[top - 2]);
              } else {
                fprintf(fasm, "\tmovq %%%s, (%%%s)\n", regStk[top - 1], regStk[top - 2]);
              }
            } else {
              int globalVariablePosition = -1;

              for (int i = 0; i < nglobals; i++) {
                if (strcmp(global_vars_table[i], $1) == 0) {
                    globalVariablePosition = i;
                    break;
                }
              }

              if(global_vars_type[globalVariablePosition] == 1) {
                fprintf(fasm, "\tmovb %%%s, (%%%s)\n", regStkByte[top - 1], regStk[top - 2]);
              } else {
                fprintf(fasm, "\tmovq %%%s, (%%%s)\n", regStk[top - 1], regStk[top - 2]);
              }
            }

            top -= 2;

          }
          ;



call:
    WORD LPARENT call_arguments RPARENT {

      char *funcName = $<string_val>1;
      int nargs = $<nargs>3;
      int i;

      fprintf(fasm,"     \t# func=%s nargs=%d\n", funcName, nargs);
      fprintf(fasm,"     \t# Move values from reg stack to reg args\n");

      for (i = nargs - 1; i >= 0; i--) {
        top--;
        fprintf(fasm, "\tmovq %%%s, %%%s\n", regStk[top], regArgs[i]);
      }

      if (!strcmp(funcName, "printf")) {
        // printf has a variable number of arguments and it need the following
        fprintf(fasm, "\tmovl    $0, %%eax\n");
      }

      fprintf(fasm, "\tcall %s\n", funcName);
      fprintf(fasm, "\tmovq %%rax, %%%s\n", regStk[top]);
      top++;

    }
    ;



call_arg_list:
             expression {
                $<nargs>$ = 1;
             }
             | call_arg_list COMA expression {
                $<nargs>$++;
             }
             ;



call_arguments:
              call_arg_list {
                $<nargs>$ = $<nargs>1;
              }
              | /*empty*/ {
                $<nargs>$ = 0;
              }
              ;



expression:
          logical_or_expr
          ;



logical_or_expr:
               logical_and_expr
               | logical_or_expr {
                  $<my_nlabel>1=nloops++;
                  fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
                  fprintf(fasm, "\tjne end_short_circuit_%d\n", $<my_nlabel>1);
               }
               OROR logical_and_expr {
                    fprintf(fasm, "\torq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                    fprintf(fasm, "end_short_circuit_%d:\n", $<my_nlabel>1);
                    top--;
               }
               ;



logical_and_expr:
                equality_expr
                | logical_and_expr {
                  $<my_nlabel>1=nloops++;
                  fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
                  fprintf(fasm, "\tje end_short_circuit_%d\n", $<my_nlabel>1);
                }
                ANDAND equality_expr {
                    fprintf(fasm, "\tandq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                    fprintf(fasm, "end_short_circuit_%d:\n", $<my_nlabel>1);
                    top--;
                }
                ;



equality_expr:
             relational_expr
             | equality_expr EQUALEQUAL relational_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmove %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmovne %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

             }
             | equality_expr NOTEQUAL relational_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmovne %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmove %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

             }
             ;



relational_expr:
               additive_expr
               | relational_expr LESS additive_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmovl %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmovge %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

               }
               | relational_expr GREAT additive_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmovg %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmovle %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

               }
               | relational_expr LESSEQUAL additive_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmovle %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmovg %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

               }
               | relational_expr GREATEQUAL additive_expr {

                fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                fprintf(fasm, "\tmovq $1, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tmovq $0, %%%s\n", regStk[top]);
                top++;
                fprintf(fasm, "\tcmovge %%%s, %%%s\n", regStk[top - 2], regStk[top - 4]);
                fprintf(fasm, "\tcmovl %%%s, %%%s\n", regStk[top - 1], regStk[top - 4]);
                top -= 3;

               }
               ;



additive_expr:
             multiplicative_expr
             | additive_expr PLUS multiplicative_expr {
                fprintf(fasm,"\n\t# +\n");
                if (top < nregStk) {
                    fprintf(fasm, "\taddq %%%s,%%%s\n", regStk[top-1], regStk[top-2]);
                    top--;
                } else {
                  fprintf(stderr, "1Ran out of registers\n");
                  exit(1);
                }

             }
             | additive_expr MINUS multiplicative_expr {
               if (top < nregStk) {
                  fprintf(fasm, "\tsubq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                  top--;
               } else {
                  fprintf(stderr, "2Ran out of registers\n");
                  exit(1);
               }

             }
             ;



multiplicative_expr:
                   primary_expr
                   | multiplicative_expr TIMES primary_expr {
                      fprintf(fasm,"\n\t# *\n");

                      if (top < nregStk) {
                        fprintf(fasm, "\timulq %%%s,%%%s\n", regStk[top-1], regStk[top-2]);
                        top--;
                      } else {
                        fprintf(stderr, "3Ran out of registers\n");
                        exit(1);
                      }

                   }
                    | multiplicative_expr DIVIDE primary_expr {
                      if (top < nregStk) {
                          fprintf(fasm, "\tmovq %%%s, %%rax\n", regStk[top-2]);
                          fprintf(fasm, "\tmovq $0, %%rdx\n");
                          fprintf(fasm, "\tcqto\n");
                          fprintf(fasm, "\tidivq %%%s\n", regStk[top-1]);
                          fprintf(fasm, "\tmovq %%rax, %%%s\n", regStk[top-2]);
                          top--;
                      } else {
                        fprintf(stderr, "4Ran out of registers\n");
                        exit(1);
                      }

                    }
                    | multiplicative_expr PERCENT primary_expr {
                      if (top < nregStk) {
                          fprintf(fasm, "\tmovq %%%s, %%rax\n", regStk[top-2]);
                          fprintf(fasm, "\tmovq $0, %%rdx\n");
                          fprintf(fasm, "\tcqto\n");
                          fprintf(fasm, "\tidivq %%%s\n", regStk[top-1]);
                          fprintf(fasm, "\tmovq %%rdx, %%%s\n", regStk[top-2]);
                          top--;
                      } else {
                        fprintf(stderr, "5Ran out of registers\n");
                        exit(1);
                      }

                    }
                    ;



primary_expr:
            STRING_CONST {
              // Add string to string table.
              // String table will be produced later.
              string_table[nstrings] = $<string_val>1;

              fprintf(fasm, "\t#top=%d\n", top);
              fprintf(fasm, "\n\t# push string %s top=%d\n", $<string_val>1, top);

              if (top < nregStk) {
                fprintf(fasm, "\tmovq $string%d, %%%s\n", nstrings, regStk[top]);
                //fprintf(fasm, "\tmovq $%s,%%%s\n", $<string_val>1, regStk[top]);
                top++;
              }
              nstrings++;

            }
            | call
            | WORD {
              int localVariablePosition = -1;

              for (int i = 0; i < nlocals; i++) {
                if (strcmp(local_vars_table[i], $1) == 0) {
                  localVariablePosition = i;
                  break;
                }
              }

              if (localVariablePosition != -1) {
                //Local variable
                fprintf(fasm, "\tmovq -%d(%%rbp), %%%s\n", 8 * (localVariablePosition + 1), regStk[top]);
              } else {
                //Global variable
                fprintf(fasm, "\tmovq %s,%%%s\n", $1, regStk[top]);
              }

              top++;

            }
            | WORD LBRACE expression RBRACE {

              int localVariablePosition = -1;

              for (int i = 0; i < nlocals; i++) {
                if (strcmp(local_vars_table[i], $1) == 0) {
                  localVariablePosition = i;
                  break;
                }
              }

              if (localVariablePosition != -1) {
                //Local variable
                fprintf(fasm, "\tmovq -%d(%%rbp), %%%s\n", 8 * (localVariablePosition + 1), regStk[top]);
                top++;

                if (local_vars_type[localVariablePosition] == 1) {
                  fprintf(fasm, "\timulq $1, %%%s\n", regStk[top - 2]);
                } else {
                  fprintf(fasm, "\timulq $8, %%%s\n", regStk[top - 2]);
                }

                fprintf(fasm, "\taddq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]);
                
                if (local_vars_type[localVariablePosition] == 1) {
                   fprintf(fasm, "\tmovq (%%%s), %%%s\n", regStk[top - 2], regStk[top - 2]);
                   fprintf(fasm, "\tmovzbq %%%s, %%%s\n", regStkByte[top - 2], regStk[top - 2]);
                } else {
                  fprintf(fasm, "\tmovq (%%%s), %%%s\n", regStk[top - 2], regStk[top - 2]);
                }
                top--;

              } else {
                //Global variable
                fprintf(fasm, "\tmovq %s(%%rip), %%%s\n", $1, regStk[top]);
                top++;

                int globalVariablePosition = -1;

                for (int i = 0; i < nglobals; i++) {
                  if (strcmp(global_vars_table[i], $1) == 0) {
                      globalVariablePosition = i;
                      break;
                  }
                }

                if (global_vars_type[globalVariablePosition] == 1) {
                  fprintf(fasm, "\timulq $1, %%%s\n", regStk[top - 2]);
                } else {
                  fprintf(fasm, "\timulq $8, %%%s\n", regStk[top - 2]);
                }

                fprintf(fasm, "\taddq %%%s, %%%s\n", regStk[top - 1], regStk[top - 2]); 
                fprintf(fasm, "\tmovq (%%%s), %%%s\n", regStk[top - 2], regStk[top - 2]);
                top--;
              }

            }
            | AMPERSAND WORD {

              int localVariablePosition = -1;

              for (int i = 0; i < nlocals; i++) {
                if (strcmp(local_vars_table[i], $2) == 0) {
                  localVariablePosition = i;
                  break;
                }
              }

              if (localVariablePosition != -1) {
                //Local variable
                fprintf(fasm, "\tleaq -%d(%%rbp), %%%s", 8 * (localVariablePosition + 1), regStk[top]);
                top++;
              } else {
                fprintf(fasm, "\tmovq $%s, %%%s", $2, regStk[top]);
                top++;
              } 

            }
            | INTEGER_CONST {
              fprintf(fasm, "\n\t# push %s\n", $<string_val>1);
              if (top < nregStk) {
                fprintf(fasm, "\tmovq $%s,%%%s\n", $<string_val>1, regStk[top]);
                top++;
              } else {
                fprintf(stderr, "Ran out of registers\n");
                exit(1);
              }

            }
            | LPARENT expression RPARENT
            ;



compound_statement:
                  LCURLY statement_list RCURLY
                  ;



statement_list:
              statement_list statement
              | /* empty */
              ;



local_var:
         var_type local_var_list SEMICOLON
         ;



local_var_list:
              WORD {
                //First local variable in list
                if (nlocals < MAX_LOCALS) {
                  local_vars_table[nlocals] = $1;
                  local_vars_type[nlocals] = currentType;
                  nlocals++;
                } else {
                  fprintf(stderr, "Too many local variables\n");
                  exit(1);
                }

              }
              | local_var_list COMA WORD {
                if (nlocals < MAX_LOCALS) {
                  local_vars_table[nlocals] = $3;
                  local_vars_type[nlocals] = currentType;
                  nlocals++;
                } else {
                  fprintf(stderr, "Too many local variables\n");
                  exit(1);
                }

              }
              ;



statement:
         assignment SEMICOLON
         | call SEMICOLON {
            top = 0; // Reset register stack
         }

         | local_var
         | compound_statement
         | IF LPARENT expression RPARENT {
            nifs++;
            $<my_nlabel>1 = nifs;
            fprintf(fasm, "if_%d:\n", $<my_nlabel>1);
            fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
            fprintf(fasm, "\tje end_if_%d\n", $<my_nlabel>1);
            top--;
         }
         statement {
            fprintf(fasm, "\tjmp final_end_if_%d\n", $<my_nlabel>1);
            fprintf(fasm, "end_if_%d:\n", $<my_nlabel>1);
         }
         else_optional {
           fprintf(fasm, "final_end_if_%d:\n", $<my_nlabel>1);
         }


         | WHILE LPARENT {
            loopTop = nloops;
            loopTop++;
            nloops++;
            $<my_nlabel>1 = nloops;
            fprintf(fasm, "start_loop_%d:\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "continue_loop_%d:\n", $<my_nlabel>1 - 1);
         }
         expression RPARENT {
            fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
            fprintf(fasm, "\tje end_loop_%d\n", $<my_nlabel>1 - 1);
            top--;
         }
         statement {
            fprintf(fasm, "\tjmp start_loop_%d\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "end_loop_%d:\n", $<my_nlabel>1 - 1);
            loopTop--;
         }


         | DO {
            loopTop = nloops;
            loopTop++;
            nloops++;
            $<my_nlabel>1 = nloops;
            fprintf(fasm, "start_loop_%d:\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "continue_loop_%d:\n", $<my_nlabel>1 - 1);
         }
         statement WHILE LPARENT expression RPARENT SEMICOLON {
           fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
           fprintf(fasm, "\tje end_loop_%d\n", $<my_nlabel>1 - 1);
           fprintf(fasm, "\tjne start_loop_%d\n", $<my_nlabel>1 - 1);
           fprintf(fasm, "end_loop_%d:\n", $<my_nlabel>1 - 1);
           loopTop--;
         }

         | FOR {

         }
         LPARENT assignment SEMICOLON {
            loopTop = nloops;
            loopTop++;
            nloops++;
            $<my_nlabel>1 = nloops;
            fprintf(fasm, "start_loop_%d:\n", $<my_nlabel>1 - 1);
         }
         expression SEMICOLON {
            fprintf(fasm, "\tcmpq $0, %%%s\n", regStk[top - 1]);
            fprintf(fasm, "\tje end_loop_%d\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "\tjne end_increment_loop_%d\n", $<my_nlabel>1 - 1);
            top--;
            fprintf(fasm, "start_increment_loop_%d:\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "continue_loop_%d:\n", $<my_nlabel>1 - 1);
         }
         assignment RPARENT {
            fprintf(fasm, "\tjmp start_loop_%d\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "end_increment_loop_%d:\n", $<my_nlabel>1 - 1);
         }
         statement {
            fprintf(fasm, "\tjmp start_increment_loop_%d\n", $<my_nlabel>1 - 1);
            fprintf(fasm, "end_loop_%d:\n", $<my_nlabel>1 - 1);
            loopTop--;
         }

         | jump_statement
         ;



else_optional:
             ELSE statement
             | /* empty */
             ;



jump_statement:
              CONTINUE SEMICOLON {
                fprintf(fasm, "\tjmp continue_loop_%d\n", loopTop - 1);
              }
              | BREAK SEMICOLON {
                fprintf(fasm, "\tjmp end_loop_%d\n", loopTop - 1);
              }

              | RETURN expression SEMICOLON {
                fprintf(fasm, "\tmovq %%rbx, %%rax\n");
                top = 0;

                fprintf(fasm, "# Restore registers\n");
                fprintf(fasm, "\tpopq %%r15\n");
                fprintf(fasm, "\tpopq %%r14\n");
                fprintf(fasm, "\tpopq %%r13\n");
                fprintf(fasm, "\tpopq %%r10\n");
                fprintf(fasm, "\tpopq %%rbx\n");
                fprintf(fasm, "\tpopq %%rbx\n");
                fprintf(fasm, "\tleave\n");
                fprintf(fasm, "\tret\n");
              }

              ;



%%



void yyset_in(FILE *in_str);


int yyerror(const char *s) {
    fprintf(stderr, "%s:%d: %s\n", input_file, line_number, s);
}


int main(int argc, char **argv) {

    // Make sure there are enough arguments
    if (argc < 2) {
        fprintf(stderr, "Usage: scc file\n");
        exit(1);
    }

    // Get file name
    input_file = strdup(argv[1]);
    int len = strlen(input_file);
    if (len < 2 || input_file[len - 2] != '.' || input_file[len - 1] != 'c') {
        fprintf(stderr, "Error: file extension is not .c\n");
        exit(1);
    }

    // Get assembly file name
    asm_file = strdup(input_file);
    asm_file[len - 1] = 's';

    // Open file to compile
    FILE *f = fopen(input_file, "r");
    if (f == NULL) {
        fprintf(stderr, "Cannot open file %s\n", input_file);
        perror("fopen");
        exit(1);
    }

    // Create assembly file
    fasm = fopen(asm_file, "w");
    if (fasm == NULL) {
        fprintf(stderr, "Cannot open file %s\n", asm_file);
        perror("fopen");
        exit(1);
    }

    // Uncomment for debugging
    // fasm = stderr;

    // Set input file for parsing
    yyset_in(f);
    yyparse();

    // Generate string table
    for (int i = 0; i < nstrings; i++) {
        fprintf(fasm, "string%d:\n", i);
        fprintf(fasm, "\t.string %s\n\n", string_table[i]);
    }

    // Close files
    fclose(f);
    fclose(fasm);

    return 0;
}
