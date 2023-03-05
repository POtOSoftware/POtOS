; wait_for_key: Waits for a keypress then returns

wait_for_key:
        mov ah, 11h
        int 16h

        jnz .key_pressed

        hlt
        jmp wait_for_key

.key_pressed:
        mov ah, 10h
        int 16h
        ret

; get_string: Gets keystrokes and prints them

get_string:
	xor cl, cl

.loop:
	mov ah, 0
	int 0x16	; wait for keypress

	cmp al, 0x08	; backspace pressed?
	je .backspace	; yes, handle it

	cmp al, 0x0D	; enter pressed?
	je .done	; yes, we're done

	cmp cl, 0x3F	; 63 chars inputted?
	je .loop	; yes, only let in backspace and enter

	mov ah, 0x0E
	int 0x10	; print out character

	stosb	; put character in buffer
	inc cl
	jmp .loop

.backspace:
	cmp cl, 0 	; beginning of string?
	je .loop	; yes, ignore the key

	dec di
	mov byte [di], 0 	; delete character
	dec cl			; decrement counter as well

	mov ah, 0x0E
	mov al, 0x08
	int 0x10	; backspace on the screen

	mov al, ' '
	int 0x10	; blank character out

	mov al, 0x08
	int 0x10	; backspace gain

	jmp .loop	; go to the main loop

.done:
	mov al, 0	; null terminator
	stosb

	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A
	int 0x10	; newline

	ret
