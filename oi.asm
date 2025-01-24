; vers�o de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle disponibilizados por Jefferson Moro em 10/2009
;
segment code
..start:
    		mov 		ax,data
    		mov 		ds,ax
    		mov 		ax,stack
    		mov 		ss,ax
    		mov 		sp,stacktop

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
            mov  		ah,0Fh
    		int  		10h
    		mov  		[modo_anterior],al   

; alterar modo de video para gr�fico 640x480 16 cores
    	mov     	al,12h
   		mov     	ah,0
    	int     	10h
		

;desenhar retas

print:
		mov		byte[cor],branco_intenso	;antenas
		;em x  == 0 e y em 400
		; ponto final de referencia do plot_xy
		mov		ax,300 ; seta a posicao inicial em x a esquerda da  reta branca de divisao
		push		ax
		
		; igual ao fixo so plot_xy, pode variar apara transformar em um solido usando uma funcao
		mov		ax,400 ; seta a posicao de y  a esquerda da reta
		push		ax
		
		;em x == 640   y em 400
		
		; a seguinte sera o bx da line
		mov		ax,100 ;  seta a posicao inicial em x a direita da  reta branca de divisao
		push		ax
		
		;sera o fixo do plot_xy e bx do line
		mov		ax,400 ; seta a posicao de y a direita da reta
		push		ax
		
		call		full_retangle
	
		
		
l41:
		call	cursor
    	mov     al,[bx+mens1] ; escreve a mensagem 
		call	caracter
    	inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
    	loop    l41
		
		mov     	cx,69			;n�mero de caracteres
    	mov     	bx,0
    	mov     	dh,2			;linha 0-29
    	mov     	dl,3			;coluna 0-79
		
		
l42:	
		call	cursor
    	mov     al,[bx+mens2] ; escreve a mensagem 
		call	caracter
    	inc     bx			;proximo caracter
		inc		dl			;avanca a coluna

		loop l42
		
		 mov ah, 00h     ; Função para ler a tecla pressionada
	    int 16h         ; Chama a interrupção para ler o teclado
	    cmp al, 's'     ; Compara o código da tecla (ASCII de 's' é 73h)
		
       ; Restaura o modo de vídeo
		
		je exit
		
		cmp al, 'S'
		je exit
		
		jmp print
		
	   
		


;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		
		mov     	ah,2
		mov     	bh,0
		int     	10h
		
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
exit:  
        mov ah, 0       ; Função para retornar ao modo anterior de vídeo
        mov al, [modo_anterior]
        int 10h          ; Restaura o modo de vídeo

        mov ax, 4C00h    ; Função de término do programa
        int 21h
	__________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
    		mov     	ah,9
    		mov     	bh,0
    		mov     	cx,1
   		mov     	bl,[cor]
    		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		
	    mov     	ah,0ch
	    mov     	al,[cor] ; adiciona a cor 
	    mov     	bh,0
		
	    mov     	dx,479 ;  maximo de altura da tela
		
		sub		dx,[bp+4] ; dx - x da esquerda
		
	    mov     	cx,[bp+6] ;  mover para cx o y da esquerda
		
	    int     	10h ;  interrupção de print
		
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
		
;retangulo		
full_retangle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]    ; 1  r
	mov		bx,[bp+6]    ;300  yc
	mov     cx, [bp+4]    ;300  xc
	
	mov ax, 0

plotar_ret_full:
	;comeca em x++ ate o fim, junto com a variacao de y
	
	; ax  = altura e constante
	; bx = raio varia
	
	; ax no 

	;quando for para line 
	; dx(primeiro push) e bx(terceiro push) sao iguais
	; cx (segundo push) e menor que ax(quato push)
	
	;referencia final do plot_xy para a variaavel
	mov		si,cx
	add     si, 10 ; largura
	push	si		;yc+altura
	
	mov		si,dx
	add     si, ax
	push    si		;xc
	
	; a seguinte sera o bx da line e o variavel do plot_xy
	mov		si,cx
	push	si		;yc
	
	;fixo do plot_xy e bx da line
	mov		si,dx
	add     si, ax
	push    si		;xc
	
	call	line
	
	inc     ax
	cmp     bx, ax
	
	jb		fim_full_retangle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		plotar_ret_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_retangle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
       ; a pilha esta desta forma: y direita, x direta, y esquerda, x esquerda
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		
		mov		ax,[bp+10]   ;400 - constante em line e plot_xy
		mov		bx,[bp+8]    ;100 - oque varia em line e em plot_xy
		mov		cx,[bp+6]    ;400 resgata os valores das coordenadas = y esquerda - constante no plot_xy
		mov     dx, [bp+4]   ;300
		; os dois do topo da pilha sao ip_high em 0 e ip_low e 2, por isso comeca em 4
		mov     di, cx
		cmp		ax,di ; compara y direita com  y diretia =  mesma altura?
		je		line2 ; se for igual
		jb		line1 ; se nao for igual
		
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0

		cmp		bx,dx  ;subtrai dx em bx ;qual a largura da reta ? nao pode ser negativa
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
		
line3:	; dx > bx

		push		ax
		push		bx
		
		call 		plot_xy ;  agora printar o da equerda ; faz push e pop logo nenhuma variavele  alterada
		
		cmp		bx,dx ;  compara o  bx para ver se ele chegou ao valor do x da direita, visto que ele mudor para armazernar o x da esquerda
		
		jne		line31
		
		jmp		fim_line
line31:		
        inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8

;*******************************************************************
segment data

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0	
mens1    	db  		'Exercicio de Programacao de Sistemas EmbarcadosI  2024/2  '
mens2       db           'Seu nome completo 00 x 00 Computador    Velocidade atual: (de 1 a 3) '
saida       db           'r'
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:


