	.text
.globl fact
fact:
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
	movq -8(%rbp), %rbx

	# push 0
	movq $0,%r10
	cmpq %r10, %rbx
	movq $1, %r13
	movq $0, %r14
	cmove %r13, %rbx
	cmovne %r14, %rbx
if_1:
	cmpq $0, %rbx
	je end_if_1

	# push 1
	movq $1,%rbx
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
	movq -8(%rbp), %rbx
	movq -8(%rbp), %r10

	# push 1
	movq $1,%r13
	subq %r13, %r10
     	# func=fact nargs=1
     	# Move values from reg stack to reg args
	movq %r10, %rdi
	call fact
	movq %rax, %r10

	# *
	imulq %r10,%rbx
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

	# push string " Factorial of 5 = %d\n" top=0
	movq $string0, %rbx

	# push 5
	movq $5,%r10
     	# func=fact nargs=1
     	# Move values from reg stack to reg args
	movq %r10, %rdi
	call fact
	movq %rax, %r10
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
string0:
	.string " Factorial of 5 = %d\n"

