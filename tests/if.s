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

	# push 1
	movq $1,%rbx
if_1:
	cmpq $0, %rbx
	je end_if_1
	#top=0

	# push string "OK1\n" top=0
	movq $string0, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	jmp final_end_if_1
end_if_1:
final_end_if_1:

	# push 0
	movq $0,%rbx
if_2:
	cmpq $0, %rbx
	je end_if_2
	#top=0

	# push string "OK2\n" top=0
	movq $string1, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	jmp final_end_if_2
end_if_2:
final_end_if_2:

	# push 1
	movq $1,%rbx
if_3:
	cmpq $0, %rbx
	je end_if_3
	#top=0

	# push string "OK3\n" top=0
	movq $string2, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	jmp final_end_if_3
end_if_3:
	#top=0

	# push string "OK4\n" top=0
	movq $string3, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
final_end_if_3:

	# push 0
	movq $0,%rbx
if_4:
	cmpq $0, %rbx
	je end_if_4
	#top=0

	# push string "OK5\n" top=0
	movq $string4, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
	jmp final_end_if_4
end_if_4:
	#top=0

	# push string "OK6\n" top=0
	movq $string5, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
	movq %rbx, %rdi
	movl    $0, %eax
	call printf
	movq %rax, %rbx
final_end_if_4:
	#top=0

	# push string "OK7\n" top=0
	movq $string6, %rbx
     	# func=printf nargs=1
     	# Move values from reg stack to reg args
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
	.string "OK1\n"

string1:
	.string "OK2\n"

string2:
	.string "OK3\n"

string3:
	.string "OK4\n"

string4:
	.string "OK5\n"

string5:
	.string "OK6\n"

string6:
	.string "OK7\n"

