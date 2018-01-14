	BITS 16

	mov ax, 07C0h		
	add ax, 288
	mov ss, ax
	mov sp, 4096
	
	mov ax, 07C0h
	mov ds, ax

	mov si, intro 
	call print	;print intro
	
start:
	call clear	;zero the registers

	mov si, newline
	call print
	mov si, textF
	call print
	mov si, textOne
	call print
	mov si, things
	call print
	inc bh

input:			   ;bh contains the length of the string of the numbers entered as factor
	mov ah, 0	   ;put zero in the ah register
	int 16h		   ;wait for user input
	cmp al, 13	   ;check if key pushed is 'Enter'
	je conts	   ;jump to conts label if it is
	call dispal	   ;display the characters entered
	sub al, 0x30       ;shift numbers entered in ascii to original numbers
	push ax		   ;push the number in the stack
	inc bh		   ;add 1 to the bh register
	jmp input	   ;go to input label

conts:
	mov si, newline
	call print	   ;print \n

cont:			;conversion from ascii input to actual number
	inc bl
	cmp bl, bh
	jge skip
	pop ax
	cmp bl, 1	  
	je jadd
	cmp bl, 2
	je tenadd
	cmp bl, 3
	je hunadd

skip:	
	cmp ch, 21
	je proceed 	  ;jump to proceed label if this is the second time here

	mov si, textF
	call print
	mov si, textTwo
	call print
	mov si, things
	call print
	mov dl, dh
	mov dh, 0
	push dx
	call clear
	mov bh, 1
	mov ch, 21	  ;set a flag to know that we have been here
	jmp input	  ;start again for the next factor

proceed:		  ;put factors in registers dh and dl and jump to label mult
	push dx
	call clear
	pop bx
	mov dh, bh
	pop bx
	mov dl, bl
	mov bx, 0
	mov si, ans
	call print
	jmp mult

;next five labels are part of the conversion from ascii to actual numbers

jadd:
	add dh, al
	jmp cont

tenadd:
	mov cl, 0 	;add 10 to dh for al times and go to cont

lewp:
	cmp cl, al
	jge cont
	add dh, 10
	inc cl
	jmp lewp

hunadd:
	mov cl, 0

hlewp:
	cmp cl, al
	jge cont
	add dh, 100     ;add 100 to dh for al times and go to cont
	inc cl
	jmp hlewp

mult:			;the multiplication of the factors dh and dl. bx will be the product
	cmp cl, dh      ;check if cl is equal to factor dh
	jge continue    ;if it is, then bx is the product, so continues

	push dx
	mov dh, 0
	add bx, dx	;add dx (which at this point is equal to dl) to bx
	pop dx
	inc cl	        ;increment cl
	jmp mult        ;keep looping untill dl is added to bx for dh times

continue:
	mov ah, 0
	mov cx, bx ;place product in cx to be converted back to string

	mov dx, 0
	mov bh, 1

	cmp cx, 10
	jge loop	;if cx is < 10
	mov al, cl 	;then jump to these statements
	add al, 0x30
	call dispal
	jmp stop

	;string bytes are defined here

	intro db '---Multiplication calculator---',10,13,'Can be buggy when factor > 127',0
	textF db 'Enter factor ',0
	textOne db 'One ',0
	textTwo db 'Two ',0
	things db '>> ',0
	ans db 'Product >> ',0
	newline db 10,13,0

print:			;this is called when printing strings
	mov ah, 0Eh

do:
	lodsb
	cmp al, 0
	je back
	int 10h
	jmp do

back:
	ret

loop:			;part of the conversion back from int to string
	inc dx
	sub cx, 10
	cmp cx, 10
	jge loop
	push cx
	cmp dx, 10
	jge again
	jmp end

end:
	mov bl, 0
	mov al, dl
	add al, 0x30
	call dispal

stack:
	inc bl
	pop ax
	add al, 0x30
	call dispal
	cmp bl, bh
	jge stop
	jmp stack

dispal:			;display the contents of register al
	mov ah, 0Eh
	int 10h
	ret

again:
	inc bh
	mov cx, dx
	mov dx, 0
	jmp loop

clear:			;zeroes the registers
	mov eax, 0
	mov ebx, 0
	mov edx, 0
	mov ecx, 0
	ret

stop:			;go back to the beginning
	jmp start

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; boot signature
