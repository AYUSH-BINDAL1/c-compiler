	.text
.globl printArray
printArray:
	# Save Frame pointer
	pushq %rbp
	movq %rsp,%rbp
	subq $256, %rsp
	# Save registers. 
	# Push one extra to align stack to 16bytes
	pushq %rbx
	pushq %rbx
	pushq %r10
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq %rdx, -24(%rbp)
	movq -16(%rbp), %rbx
	movq %rbx, -32(%rbp)
start_loop_0:
	movq -32(%rbp), %rbx
	movq -24(%rbp), %r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovle %r13, %rbx
	cmovg %r14, %rbx
	cmpq $0, %rbx
	je end_loop_0
	jne end_increment_loop_0
start_increment_loop_0:
continue_loop_0:
	movq -32(%rbp), %rbx

	# push 1
	movq $1,%r10

	# +
	addq %r10,%rbx
	movq %rbx, -32(%rbp)
	jmp start_loop_0
end_increment_loop_0:
	#top=0

	# push string "%d\n" top=0
	movq $string0, %rbx
	movq -32(%rbp), %r10
	movq -8(%rbp), %r13
	imulq $8, %r10
	addq %r13, %r10
	movq (%r10), %r10
     	# func=printf nargs=2
     	# Move values from reg stack to reg args
	movq %r10, %rsi
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	jmp start_increment_loop_0
end_loop_0:
	# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
	.text
.globl print
print:
	# Save Frame pointer
	pushq %rbp
	movq %rsp,%rbp
	subq $256, %rsp
	# Save registers. 
	# Push one extra to align stack to 16bytes
	pushq %rbx
	pushq %rbx
	pushq %r10
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, -8(%rbp)
	#top=0

	# push string "==%s==\n" top=0
	movq $string1, %rbx
	movq -8(%rbp), %r10
     	# func=printf nargs=2
     	# Move values from reg stack to reg args
	movq %r10, %rsi
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
	.text
.globl quicksortsubrange
quicksortsubrange:
	# Save Frame pointer
	pushq %rbp
	movq %rsp,%rbp
	subq $256, %rsp
	# Save registers. 
	# Push one extra to align stack to 16bytes
	pushq %rbx
	pushq %rbx
	pushq %r10
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq %rdx, -24(%rbp)
	movq -24(%rbp), %rbx
	movq -16(%rbp), %r10
	subq %r10, %rbx

	# push 1
	movq $1,%r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovle %r13, %rbx
	cmovg %r14, %rbx
if_1:
	cmpq $0, %rbx
	je end_if_1

	# push 0
	movq $0,%rbx
	movq %rbx, %rax
# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
	jmp final_end_if_1
end_if_1:
final_end_if_1:
	movq -24(%rbp), %rbx
	movq -8(%rbp), %r10
	imulq $8, %rbx
	addq %r10, %rbx
	movq (%rbx), %rbx
	movq %rbx, -32(%rbp)
	movq -16(%rbp), %rbx
	movq %rbx, -40(%rbp)
	movq -24(%rbp), %rbx

	# push 1
	movq $1,%r10
	subq %r10, %rbx
	movq %rbx, -48(%rbp)
start_loop_1:
continue_loop_1:
	movq -40(%rbp), %rbx
	movq -48(%rbp), %r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovl %r13, %rbx
	cmovge %r14, %rbx
	cmpq $0, %rbx
	je end_loop_1
start_loop_2:
continue_loop_2:
	movq -40(%rbp), %rbx
	movq -48(%rbp), %r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovl %r13, %rbx
	cmovge %r14, %rbx
	cmpq $0, %rbx
	je end_short_circuit_3
	movq -40(%rbp), %r10
	movq -8(%rbp), %r13
	imulq $8, %r10
	addq %r13, %r10
	movq (%r10), %r10
	movq -32(%rbp), %r13
	cmpq %r13, %r10
	movq $1, %r14
	movq $0, %r15
	cmovl %r14, %r10
	cmovge %r15, %r10
	andq %r10, %rbx
end_short_circuit_3:
	cmpq $0, %rbx
	je end_loop_2
	movq -40(%rbp), %rbx

	# push 1
	movq $1,%r10

	# +
	addq %r10,%rbx
	movq %rbx, -40(%rbp)
	jmp start_loop_2
end_loop_2:
start_loop_4:
continue_loop_4:
	movq -40(%rbp), %rbx
	movq -48(%rbp), %r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovl %r13, %rbx
	cmovge %r14, %rbx
	cmpq $0, %rbx
	je end_short_circuit_5
	movq -48(%rbp), %r10
	movq -8(%rbp), %r13
	imulq $8, %r10
	addq %r13, %r10
	movq (%r10), %r10
	movq -32(%rbp), %r13
	cmpq %r13, %r10
	movq $1, %r14
	movq $0, %r15
	cmovg %r14, %r10
	cmovle %r15, %r10
	andq %r10, %rbx
end_short_circuit_5:
	cmpq $0, %rbx
	je end_loop_4
	movq -48(%rbp), %rbx

	# push 1
	movq $1,%r10
	subq %r10, %rbx
	movq %rbx, -48(%rbp)
	jmp start_loop_4
end_loop_4:
	movq -40(%rbp), %rbx
	movq -48(%rbp), %r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmovl %r13, %rbx
	cmovge %r14, %rbx
if_2:
	cmpq $0, %rbx
	je end_if_2
	movq -40(%rbp), %rbx
	movq -8(%rbp), %r10
	imulq $8, %rbx
	addq %r10, %rbx
	movq (%rbx), %rbx
	movq %rbx, -56(%rbp)
	movq -40(%rbp), %rbx
	imulq $8, %rbx
	addq -8(%rbp), %rbx
	movq -48(%rbp), %r10
	movq -8(%rbp), %r13
	imulq $8, %r10
	addq %r13, %r10
	movq (%r10), %r10
	movq %r10, (%rbx)
	movq -48(%rbp), %rbx
	imulq $8, %rbx
	addq -8(%rbp), %rbx
	movq -56(%rbp), %r10
	movq %r10, (%rbx)
	jmp final_end_if_2
end_if_2:
final_end_if_2:
	jmp start_loop_1
end_loop_1:
	movq -24(%rbp), %rbx
	imulq $8, %rbx
	addq -8(%rbp), %rbx
	movq -40(%rbp), %r10
	movq -8(%rbp), %r13
	imulq $8, %r10
	addq %r13, %r10
	movq (%r10), %r10
	movq %r10, (%rbx)
	movq -40(%rbp), %rbx
	imulq $8, %rbx
	addq -8(%rbp), %rbx
	movq -32(%rbp), %r10
	movq %r10, (%rbx)
	movq -8(%rbp), %rbx
	movq -16(%rbp), %r10
	movq -40(%rbp), %r13

	# push 1
	movq $1,%r14
	subq %r14, %r13
     	# func=quicksortsubrange nargs=3
     	# Move values from reg stack to reg args
	movq %r13, %rdx
	movq %r10, %rsi
	movq %rbx, %rdi
	call quicksortsubrange
	movq %rax, %rbx
	movq -8(%rbp), %rbx
	movq -48(%rbp), %r10

	# push 1
	movq $1,%r13

	# +
	addq %r13,%r10
	movq -24(%rbp), %r13
     	# func=quicksortsubrange nargs=3
     	# Move values from reg stack to reg args
	movq %r13, %rdx
	movq %r10, %rsi
	movq %rbx, %rdi
	call quicksortsubrange
	movq %rax, %rbx
	# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
	.text
.globl quicksort
quicksort:
	# Save Frame pointer
	pushq %rbp
	movq %rsp,%rbp
	subq $256, %rsp
	# Save registers. 
	# Push one extra to align stack to 16bytes
	pushq %rbx
	pushq %rbx
	pushq %r10
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq -8(%rbp), %rbx

	# push 0
	movq $0,%r10
	movq -16(%rbp), %r13

	# push 1
	movq $1,%r14
	subq %r14, %r13
     	# func=quicksortsubrange nargs=3
     	# Move values from reg stack to reg args
	movq %r13, %rdx
	movq %r10, %rsi
	movq %rbx, %rdi
	call quicksortsubrange
	movq %rax, %rbx
	# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
	.text
.globl main
main:
	# Save Frame pointer
	pushq %rbp
	movq %rsp,%rbp
	subq $256, %rsp
	# Save registers. 
	# Push one extra to align stack to 16bytes
	pushq %rbx
	pushq %rbx
	pushq %r10
	pushq %r13
	pushq %r14
	pushq %r15
	#top=0

	# push string "Hello" top=0
	movq $string2, %rbx
     	# func=print nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	call print
	movq %rax, %rbx

	# push 10
	movq $10,%rbx
	movq %rbx, -8(%rbp)
	movq -8(%rbp), %rbx

	# push 8
	movq $8,%r10

	# *
	imulq %r10,%rbx
     	# func=malloc nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	call malloc
	movq %rax, %rbx
	movq %rbx, -16(%rbp)

	# push 0
	movq $0,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 8
	movq $8,%r10
	movq %r10, (%rbx)

	# push 1
	movq $1,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 7
	movq $7,%r10
	movq %r10, (%rbx)

	# push 2
	movq $2,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 1
	movq $1,%r10
	movq %r10, (%rbx)

	# push 3
	movq $3,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 9
	movq $9,%r10
	movq %r10, (%rbx)

	# push 4
	movq $4,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 11
	movq $11,%r10
	movq %r10, (%rbx)

	# push 5
	movq $5,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 83
	movq $83,%r10
	movq %r10, (%rbx)

	# push 6
	movq $6,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 7
	movq $7,%r10
	movq %r10, (%rbx)

	# push 7
	movq $7,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 13
	movq $13,%r10
	movq %r10, (%rbx)

	# push 8
	movq $8,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 94
	movq $94,%r10
	movq %r10, (%rbx)

	# push 9
	movq $9,%rbx
	imulq $8, %rbx
	addq -16(%rbp), %rbx

	# push 1
	movq $1,%r10
	movq %r10, (%rbx)
	#top=0

	# push string "-------- Before -------\n" top=0
	movq $string3, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	movq -16(%rbp), %rbx

	# push 0
	movq $0,%r10
	movq -8(%rbp), %r13

	# push 1
	movq $1,%r14
	subq %r14, %r13
     	# func=printArray nargs=3
     	# Move values from reg stack to reg args
	movq %r13, %rdx
	movq %r10, %rsi
	movq %rbx, %rdi
	call printArray
	movq %rax, %rbx
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r10
     	# func=quicksort nargs=2
     	# Move values from reg stack to reg args
	movq %r10, %rsi
	movq %rbx, %rdi
	call quicksort
	movq %rax, %rbx
	#top=0

	# push string "-------- After -------\n" top=0
	movq $string4, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	movq -16(%rbp), %rbx

	# push 0
	movq $0,%r10
	movq -8(%rbp), %r13

	# push 1
	movq $1,%r14
	subq %r14, %r13
     	# func=printArray nargs=3
     	# Move values from reg stack to reg args
	movq %r13, %rdx
	movq %r10, %rsi
	movq %rbx, %rdi
	call printArray
	movq %rax, %rbx
	# Restore registers
	popq %r15
	popq %r14
	popq %r13
	popq %r10
	popq %rbx
	popq %rbx
	leave
	ret
string0:
	.string "%d\n"

string1:
	.string "==%s==\n"

string2:
	.string "Hello"

string3:
	.string "-------- Before -------\n"

string4:
	.string "-------- After -------\n"

