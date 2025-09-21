%include "linux64.inc"

section .data
	config_path db "config.ini",0	
	hello db "Hello World!!", 0xa
	hello_len equ $ - hello

section .bss
        text resb 64
	bytes_read resq 1
	caracter_barra resb 3
	color_barra resb 3
	color_fondo resb 3
	format resb 8

section .text
        global _start
	
_start:
        ; Open the file
        mov rax, SYS_OPEN
        mov rdi, config_path
        mov rsi, O_RDONLY
        mov rdx, 0
        syscall

        ; Read from the file
        push rax
        mov  rdi, rax
        mov  rax, SYS_READ
        mov  rsi, text
        mov  rdx, 64
        syscall
	
	mov [bytes_read], rax
 
        ; Close the file
        mov rax, SYS_CLOSE
        pop rdi
        syscall
	
	;print text
	;exit
	
obtener_config:
	mov r8, 0
	mov r9, text

buscar_caracter_barra:
	mov cl, [r9]
	cmp cl, 58
	je guardar_caracter_barra
	inc r8
	inc r9
	cmp r8, bytes_read
	je exit_script
	jmp buscar_caracter_barra

guardar_caracter_barra:
	inc r8
	inc r9
	mov r10, r8
	mov r11, r9
	
cmp_caracter_barra:
	inc r10
	inc r11
	mov bl, [r11]
	cmp bl, 10
	jne cmp_caracter_barra
	sub r10, r8
	mov r12, 0xff
	push r10
	push r12
	call mascara
	mov rax, [r9]
	and rax, r12
	mov [caracter_barra], rax
	;print caracter_barra

buscar_color_barra:
	mov cl, [r9]
	cmp cl, 58
	je guardar_color_barra
	inc r8
	inc r9
	jmp buscar_color_barra

guardar_color_barra:
	inc r8
	inc r9
	mov r10, r8
	mov r11, r9

cmp_color_barra:
	inc r10
	inc r11
	mov bl, [r11]
	cmp bl, 10
	jne cmp_color_barra
	sub r10, r8
	mov r12, 0xff
	push r10
	push r12
	call mascara
	mov rax, [r9]
	and rax, r12
	mov [color_barra], rax
	;print color_barra

buscar_color_fondo:
	mov cl, [r9]
	cmp cl, 58
	je guardar_color_fondo
	inc r8
	inc r9
	jmp buscar_color_fondo

guardar_color_fondo:
	inc r8
	inc r9
	mov r10, r8
	mov r11, r9

cmp_color_fondo:
	inc r10
	inc r11
	mov bl, [r11]
	cmp bl, 10
	jne cmp_color_fondo
	sub r10, r8
	mov r12, 0xff
	push r10
	push r12
	call mascara
	mov rax, [r9]
	and rax, r12
	mov [color_fondo], rax
	;print color_fondo
	jmp print_hello

mascara:
	push rbp
	mov rbp, rsp
	mov r12, [rbp+16]
	mov r10, [rbp+24]

cmp_mascara:
	sub r10, 1
	cmp r10, 0
	je end_mascara
	shl r12, 8
	add r12, 0xFF
	jmp cmp_mascara

end_mascara:
	pop rbp
	ret

print_hello:
	mov bl, 27
	mov [format], bl
	mov bl, 91
	mov [format+1], bl
	mov bx, [color_barra]
	mov [format+2], bx
	mov bl, 59
	mov [format+4], bl
	mov bx, [color_fondo]
	mov [format+5], bx
	mov bl, 109
	mov [format+7], bl
	print format
	print hello

exit_script:
	exit

