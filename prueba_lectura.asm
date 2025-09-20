%include "linux64.inc"

section .data
	inventario_path db "inventario.txt",0

section .bss
	text resb 256

section .text
	global _start

_start:
	; Open the file
	mov rax, SYS_OPEN
	mov rdi, inventario_path
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall

	; Read from the file	
	push rax
	mov  rdi, rax
	mov  rax, SYS_READ
	mov  rsi, text
	mov  rdx, 256
  	syscall

	; Close the file
	mov rax, SYS_CLOSE
	pop rdi
	syscall

	print text
	syscall
