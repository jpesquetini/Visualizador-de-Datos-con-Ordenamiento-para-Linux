%include "linux64.inc"

section .data
	config_path db "config.ini",0
	inventario_path db "inventario.txt",0	
	hello db "Hello World!!", 0xa
	hello_len equ $ - hello
	reset_color db 0x1b, "[0m"

section .bss
        text resb 64
	bytes_read resq 1
	caracter_barra resb 3
	color_barra resb 3
	color_fondo resb 3
	format resb 32
	inventario resb 512
	bytes_inventario resq 1
	inventario_pointers resb 64
	msg resb 512
	barra resb 64

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
	jmp cargar_formato

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

cargar_formato:
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

lectura_inventario:
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
        mov  rsi, inventario
        mov  rdx, 512
        syscall
 
        mov [bytes_inventario], rax
 
        ; Close the file
        mov rax, SYS_CLOSE
        pop rdi
        syscall

llenar_inventario_pointers:
	mov r8, 1
	mov r9, inventario
	mov [inventario_pointers], r9
	mov r10, 0
	jmp buscar_inventario
	
guardar_primer_caracter:
	inc r8
	inc r9
	add r10, 4
	mov [inventario_pointers+r10], r9

buscar_inventario:
	inc r8
	inc r9
	cmp r8, [bytes_inventario]
	je bubble_sort
	mov bl, [r9]
	cmp bl, 10
	je guardar_primer_caracter
	jmp buscar_inventario 

bubble_sort:
	mov r8, 4	; i index
	mov r9, 0	; j index ambos para recorrer la lista de punteros
	mov r10, 4	; j + 1 va de 4 en 4 ya que se accesan punteros

bubble_compare:
	mov r11d, [inventario_pointers+r9]	; puntero en j
	mov r12d, [inventario_pointers+r10]	; puntero en j + 1
	cmp r12d, 0				; final de la lista de punteros
	je bubble_i
	mov al, [r11d]
	mov bl, [r12d]
	cmp al, bl
	jg bubble_swap
	jmp bubble_j

bubble_swap:
	mov [inventario_pointers+r9], r12d
	mov [inventario_pointers+r10], r11d

bubble_j:
	add r9, 4
	add r10, 4
	jmp bubble_compare

bubble_i:
	add r8, 4
	mov r9, 0
	mov r10, 4
	mov r12d, [inventario_pointers+r8]
	cmp r12d, 0
	mov r15, 0
	je imprimir_inventario
	jmp bubble_compare

imprimir_inventario:	
	; Imprimir nombre del inventario
	mov r8d, [inventario_pointers+r15]
	cmp r8d, 0
	je exit_script
	mov rsi, r8
	mov rdi, msg
	call copiar_nombre
	print msg
	mov r10, 0
	call limpiar_msg

	; Imprimir formato de colores
	print format
	
	; Imprimir barra
	mov rsi, r8
	mov rdi, barra
	call cargar_barra
	mov r13, [barra]
	call imprimir_barra

	; Devolver colores a lo normal
	print reset_color

	; Imprimir cantidad
	print barra

	add r15, 4
	jmp imprimir_inventario

copiar_nombre:
	mov al, [rsi]
	mov [rdi], al
	inc rsi
	inc rdi
	cmp al, 58
	jnz copiar_nombre
	ret

limpiar_msg:
	mov al, [msg+r10]
	cmp al, 0
	je terminar_limpieza
	mov al, 0
	mov [msg+r10], al
	inc r10
	jmp limpiar_msg

terminar_limpieza:
	ret

cargar_barra:
	mov al, [rsi]
	inc rsi
	cmp al, 58
	jnz cargar_barra

guardar_valor:
	mov al, [rsi]
	mov [rdi], al
	inc rsi
	inc rdi

guardar_otros_valores:
	mov al, [rsi]
	cmp al, 10
	je regreso_inventario
	jmp guardar_valor
			
regreso_inventario:
	mov [rdi], al
	ret
	
imprimir_barra:
	mov al, r13b
	sub al, 48

imprimir_caracter:
	print caracter_barra
	sub al, 1
	cmp al, 0
	jnz imprimir_caracter
	shr r13, 8
	cmp r13, 0
	je regreso_caracter
	jmp imprimir_barra

regreso_caracter:
	ret

end_bubble:
	mov r8d, [inventario_pointers+r9]
	cmp r8d, 0
	je exit_script
	mov rsi, r8
	mov rdi, msg
	call copiar_string
	print msg
	add r9, 4
	jmp end_bubble

copiar_string:
	mov al, [rsi]
	mov [rdi], al
	inc rsi
	inc rdi
	cmp al, 0
	jnz copiar_string
	ret
 
exit_script:
	print reset_color
	exit

