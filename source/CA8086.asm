;add text in video interrupt
.model tiny
.286
.code

jmp Start
 .data 
  counter dw 50
  cur_color db 1h
  positionX dw 160
  positionY dw 100
  directionX db 1
  directionY db 1

Circle:	
	mov bp,0 ;changes starting point pos from eachother
	mov si,bx ;radius to SI (??)
loop01:
	call _8pixels
	sub bx,bp ;Radius=Radius-bp 
	inc bp  ;X+1  this increases separation from last pixel
	sub bx,bp ;Radius=Radius-(2bp+1) 
	jg loop02 ;Y adds a curve
	add bx,si ;Radius=Radius+Y 
	dec si ;Y-1 the distance between last pixel vertically 
	add bx,si
loop02: 
	cmp si,bp
	jae loop01
	ret 
_8pixels:
	inc al
	call _4pixels 
_4pixels:
	xchg bp,si ;Swap x and y, makes one quadrant work
	call _2pixels ;2 pixels 
_2pixels:
	neg si ;topright quadrant
	push di 
	add di,si 
	imul di,320
	add di,dx 
	mov es:[di+bp],al 
	sub di,bp 
	stosb ;left quadrants
	pop di 
	ret 
	
setDown: ;a bunch of variables I used to set direction
	mov directionX, 2 ; because I couldn't figure out how to set
	jmp setY ;them in a stack appropriately, because circles already use it
setUp:
	mov directionX, 1
	jmp setY
setRight:
	mov directionY, 2
	jmp setXY
setLeft: 
	mov directionY, 1
	jmp setXY
 
moveLeft:
	dec dx
	jmp moveX
moveRight:
	inc dx
	jmp moveX
moveUp:
	dec di
	jmp moveY
moveDown:
	inc di
	jmp moveY	
	
Start:
	mov directionX, 1
	mov directionY , 1
	mov ax,13h 
	int 10h
	mov dx,160 ;xCenter
	mov di,100  ;yCenter
	mov al, 1h
	mov cur_color, al
reset:
	push 0a000h 
	pop es
	mov bx,50 ;Radius
	mov counter, bx ;Variable to decrease radius and fill up initial circle

Shape01: ;50 circles that form a filled up dot //compound
	inc cur_color
	mov cx, 1 ;delay of animation
	mov ah, 86h 
	int 15h

	mov ah, 01h ;checks if there is a key pressed
	int 16h
	jz continue
	
	mov ah, 00h ;get the keystroke
	int 16h
	cmp ah, 01h ;esc key
	je endprogram
	cmp ah, 39h
	je Shape02
	
	continue: ;set X
		cmp dx, 51
		je setDown
		cmp dx, 269
		je setUp
	setY: ;set Y
		cmp di, 51
		je setRight
		cmp di, 149
		je setLeft
	setXY: ;XY have been set and now move X
		cmp directionX, 1
		je moveLeft
		cmp directionX, 2
		je moveRight
	moveX: ;move Y
		cmp directionY, 1
		je moveUp
		cmp directionY, 2
		je moveDown
	moveY: ;XY have been moved

	returnPoint:
		mov ah, 00h
		mov al, 13h
		int 10h
		Loop1:
			mov al, cur_color
			call Circle ;Draw circle
			dec counter
			mov bx, counter
			cmp bx, 0
			jne Loop1
	call reset 
	jmp Shape01
 
 	
endprogram: 
	mov ah, 00h ;clear screen
	mov ax,3 
	int 10h 
	mov ah,4ch 
	int 21h  	

Shape01Reach01:
	jmp Shape01

Shape02: ;filled up rectangle/square // basic
	
	inc cur_color
	mov cx, 03h ;delay of animation
	mov ah, 86h 
	int 15h

	mov ah, 01h ;checks if there is a key pressed
	int 16h
	jz Shape02Start
	
	mov ah, 00
	int 16h	;key press
	
	cmp ah, 01h ;esc key
	je endprogram
	cmp ah, 39h
	je Shape03Start
	
	Shape02Start:
		mov ah, 00h
		mov al, 13h
		int 10h

		mov al, cur_color
		mov cx, 130  ;col
		mov dx, 70 ;row
		mov ah, 0ch ; put pixel

	colcount:
	inc cx
	int 10h
	cmp cx, 190
	jne colcount

	inc al
	mov cx, 130  ;reset to start of col
	inc dx      ;next row
	cmp dx, 130
	jne colcount
	jmp Shape02
	
	
Shape01Reach02:
	jmp Shape01Reach01
	
Shape03: ;triangle // basic
	inc cur_color
	mov cx, 01h ;delay of animation
	mov ah, 86h 
	int 15h

	mov ah, 01h ;checks if there is a key pressed
	int 16h
	jz Shape03Start

	mov ah, 00
	int 16h	;key press
	
	cmp ah, 01h ;esc key
	je endprogram2
	cmp ah, 39h
	je Shape04
	
	Shape03Start:	
		mov ah, 00h ; clear screen
		mov al, 13h 
		int 10h
		
		mov al, cur_color
		inc al
		mov ah, 0ch
		
		mov cx, 190 ;X
		mov dx, 130 ;Y
	
	GoBottomRight:
		inc al
		dec dx
		int 10h
		dec dx
		dec cx
		int 10h
		cmp dx, 70
		jne GoBottomRight
		
	mov cx, 160 ;X
	mov dx, 70 ;Y
	
	GoBottomLeft:
		inc al
		inc dx
		int 10h
		inc dx
		dec cx
		int 10h
		cmp dx, 130
		jne GoBottomLeft

	mov cx, 130 ;X
	mov dx, 130 ;Y
	
	BottomLine:
		inc al
		inc cx
		int 10h
		cmp cx, 190
		jne BottomLine
	
	jmp Shape03
	
Shape01Reach03:
	jmp Shape01Reach02
	
endprogram2:
	mov ah, 00h ;clear screen
	mov ax,3 
	int 10h 
	mov ah,4ch 
	int 21h  	

Shape04: ;pentagon // basic
	inc cur_color
	mov cx, 01h ;delay of animation
	mov ah, 86h 
	int 15h

	mov ah, 01h ;checks if there is a key pressed
	int 16h
	jz Shape04Start

	mov ah, 00
	int 16h
	
	cmp ah, 01h ;esc key
	je endprogram2
	cmp ah, 39h ;spacebar
	je Shape01Reach03
	
	Shape04Start:
		mov ah, 00h ;clear screen
		mov al, 13h 
		int 10h
		
		mov al, cur_color
		inc al
		mov ah, 0ch
		
		mov cx, 130 ;X
		mov dx, 85 ;Y
	
	Line1: ;top left
		inc al
		inc cx
		int 10h
		dec dx
		inc cx
		int 10h
		cmp dx, 70
		jne Line1	
		
	mov cx, 160 ;X	
	mov dx, 70 ;Y

	Line2: ;top right
		inc al
		inc cx
		int 10h
		inc dx
		inc cx
		int 10h
		cmp dx, 85
		jne Line2
		
	mov cx, 189 ;X	
	mov dx, 85 ;Y
	
	Line3: ;bottom right
		inc al
		inc dx
		int 10h
		inc dx
		int 10h
		inc dx
		dec cx
		int 10h
		cmp dx, 115
		jne Line3
	
	mov cx, 179 ;X	
	
	Line4: ;bottom middle
		inc al
		dec cx
		int 10h
		cmp cx, 142
		jne Line4
		
	dec cx
	
	Line5: ;bottom left
		inc al
		dec dx
		int 10h
		dec dx
		int 10h
		dec dx
		dec cx
		int 10h
		cmp dx, 85
		jne Line5
	
	jmp Shape04
	
	;this is a failsafe, in-case we somehow exit the cycles
	mov ah, 00h 
	mov ax,3 
	int 10h 
	mov ah,4ch 
	int 21h  	

END Start 