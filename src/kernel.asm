	BITS 16

os_init:
	; idk what any of this does but it makes it work so...
	cli
	mov ax, 0
	mov ss, ax
	mov sp, 0FFFFh
	sti

	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

os_start:
	mov si, any_key
	call print_string

	call wait_for_key

	call clear_screen

	; set background color to blue
	mov ah, 0x0B
	mov bh, 0x00
	mov bl, 0x01 ; BIOS code for blue
	int 0x10

	mov si, welcome
	call print_string

os_mainloop:
	mov si, prompt
	call print_string

	mov di, buffer
	call get_string

	mov si, buffer
	cmp byte [si], 0 ; blank line?
	je os_mainloop	 ; yes, ignore it

; ---Command Interpreter---
	
	; --about--
	mov si, buffer
	mov di, cmd_about	; 'about' entered?
	call os_string_compare
	jc .about
	; --about--

	; --help-
	mov si, buffer
	mov di, cmd_help 	; 'help' entered?
	call os_string_compare
	jc .help
	; --help--

	; --restart--
	mov si, buffer
	mov di, cmd_restart 	; 'restart' entered?
	call os_string_compare
	jc .restart_confirm
	; --restart--

	; --cls--
	mov si, buffer
	mov di, cmd_cls		; 'cls' entered?
	call os_string_compare
	jc .cls
	; --cls--

	; --willthisosdoanythinguseful--
	mov si, buffer
	mov di, cmd_willthisosdoanythinguseful	; 'willthisosdoanythinguseful' entered?
	call os_string_compare
	jc .willthisosdoanythinguseful
	; --willthisosdoanythinguseful--

; ---Command Interpreter---

	mov si, bad_command
	call print_string
	jmp os_mainloop

.about:
	mov si, msg_about
	call print_string

	jmp os_mainloop

.help:
	mov si, msg_help
	call print_string

	jmp os_mainloop

.cls:
	call clear_screen
	jmp os_mainloop

.willthisosdoanythinguseful:
	mov si, msg_willthisosdoanythinguseful
	call print_string

	jmp os_mainloop

.restart_confirm:
	mov si, msg_restart
	call print_string

	mov ah, 0
	int 0x16

	cmp al, 0x79
	je .restart	

	call new_line
	
	jmp os_mainloop

.restart:
	db 0x0ea
	dw 0x0000
	dw 0xffff

; Strings
any_key  db "Press any key to continue...", 0
welcome db "<< Welcome To POtOS! >>", 0x0D, 0x0A, 0
bad_command db "Command not found.", 0x0D, 0x0A, 0
prompt db '>', 0

; --commands--
cmd_about   			db "about", 0
cmd_help    			db "help", 0
cmd_restart 			db "restart", 0
cmd_cls     			db "cls", 0
cmd_willthisosdoanythinguseful 	db "willthisosdoanythinguseful", 0
; --commands--

msg_about db "POtOS 0.01: Developed by Kyle Kailihiwa", 0x0D, 0x0A, 0
msg_restart db "Are you sure? ", 0
msg_help db "Commands: help, about, restart, cls, willthisosdoanythinguseful", 0x0D, 0x0A, 0
msg_willthisosdoanythinguseful db "No", 0x0D, 0x0A, 0

new_line_escape db 0x0D, 0x0A, 0

buffer times 64 db 0

new_line:
	mov si, new_line_escape
	call print_string

	ret

clear_screen:
	pusha

	mov ax, 0700h
	mov bh, 07h
	mov cx, 0000h
	mov dx, 184fh
	int 10h

	popa
	
	; sets cursor position to top left corner
        mov ah, 02h
        mov bh, 00h
        mov dh, 00h
        mov dl, 00h
        int 10h
		
	ret

print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh		; int 10h 'print char' function

.repeat:
	lodsb			; Get character from string
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .repeat

.done:
	ret

os_pause:
	pusha
	cmp ax, 0
	je .time_up			; If delay = 0 then bail out

	mov cx, 0
	mov [.counter_var], cx		; Zero the counter variable

	mov bx, ax
	mov ax, 0
	mov al, 2			; 2 * 55ms = 110mS
	mul bx				; Multiply by number of 110ms chunks required 
	mov [.orig_req_delay], ax	; Save it

	mov ah, 0
	int 1Ah				; Get tick count	

	mov [.prev_tick_count], dx	; Save it for later comparison

.checkloop:
	mov ah,0
	int 1Ah				; Get tick count again

	cmp [.prev_tick_count], dx	; Compare with previous tick count

	jne .up_date			; If it's changed check it
	jmp .checkloop			; Otherwise wait some more

.time_up:
	popa
	ret

.up_date:
	mov ax, [.counter_var]		; Inc counter_var
	inc ax
	mov [.counter_var], ax

	cmp ax, [.orig_req_delay]	; Is counter_var = required delay?
	jge .time_up			; Yes, so bail out

	mov [.prev_tick_count], dx	; No, so update .prev_tick_count 

	jmp .checkloop			; And go wait some more


	.orig_req_delay		dw	0
	.counter_var		dw	0
	.prev_tick_count	dw	0

; FEATURES

	%INCLUDE "keyboard.asm"
	%INCLUDE "string.asm"

; ==END==	
