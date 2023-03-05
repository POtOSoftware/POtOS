os_string_compare:
.loop:
        mov al, [si]    ; grab a byte from SI
        mov bl, [di]    ; grab a byte from DI
        cmp al, bl      ; are they equal?
        jne .notequal   ; nope, we're done

        cmp al, 0       ; are both bytes (they were equal before) null?
        je .done        ; yes, we're done

        inc di  ; increment DI
        inc si  ; increment SI
        jmp .loop

.notequal:
        clc     ; not equal, clear the carry flag
        ret

.done:
        stc     ; equal, set the carry flag
        ret

; os_string_length: Return length of a string
; IN: AX = string location
; OUT: AX = length

os_string_length:
	pusha

	mov bx, ax			; Move location of string to BX

	mov cx, 0			; Counter

.more:
	cmp byte [bx], 0		; Zero (end of string) yet?
	je .done
	inc bx				; If not, keep adding
	inc cx
	jmp .more


.done:
	mov word [.tmp_counter], cx	; Store count before restoring other registers
	popa

	mov ax, [.tmp_counter]		; Put count back into AX before returning
	ret


	.tmp_counter	dw 0


; os_string_uppercase: Convert string to upper case
; IN/OUT: AX = string location
os_string_uppercase:
	pusha

	mov si, ax	; use SI to access string

.more:
	cmp byte [si],  0	; zero-termination of string?
	je .done		; if so, quit

	cmp byte [si], 'a'	; in the lower case A to Z range?
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 0x20 	; if so, convert input char to upper case

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret
