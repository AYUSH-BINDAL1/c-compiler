all: scc

scc: simple.l simple.y
	lex simple.l
	yacc -d simple.y
	gcc -g -o scc lex.yy.c y.tab.c
	@echo "Compiler built successfully! Usage: ./scc input.c (produces input.s)"

test: scc
	@echo "Running compiler tests..."
	@cd tests && ./testall

clean:
	rm -f scc lex.yy.c y.tab.c y.tab.h
	rm -f tests/*.s tests/*.out* tests/*.scc tests/*.gcc
	rm -f tests/args2 tests/shortcircuit tests/total.txt

.PHONY: all test clean
