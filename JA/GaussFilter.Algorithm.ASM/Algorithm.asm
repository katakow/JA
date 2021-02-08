;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Temat projektu:						Filtr Laplace'a																					;
; Autor:								Katarzyna Kowalczewska																			;
; Przedmiot:							Języki Asemblerowe																				;
; Kierunek:								Informatyka																						;
; Semestr:								5																								;
; Grupa dziekańska:						1																								;
; Sekcja:								2																								;
; Data wykonania projektu:				08.02.2021																						;
; Krótki opis projektu:					Program nakłada na obraz wybrany przez użytkownika filtr Laplace'a.								;
;										Filtr ten jest wykorzystywany do wyostrzenia krawędzi obrazu.									;
;										Wczytany obraz, efekt końcowy oraz obliczony wcześniej histogram jest wyświetlony w programie.	;
;										Biblioteka jest w C# oraz w asemblerze.															;
;										Jest ona odpowiedzialna za algorytm wyostrzenia.												;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CHANGELOG																																;
;																																		;
; version 0.1																															;
; Short description of project, ideas about implemenation Laplace filter in Assembly.													;
;																																		;
; version 0.2																															;
; First code in Assembly, checking if arguments are correctly transferred to dll file, and loaded to C#.								;
;																																		;
; version 0.3																															;
; Implementation first part of Laplace algorithmm, short description of main loop in program.											;
;																																		;
; verion 0.4 																															;
; Implementation the rest of Laplace algorithm, small changes in previous code.															;
;																																		;
; verion 0.5																															;
; Errors during dividing into threads - no range, few comments.																			;
;																																		;
; version 0.6 																															;
; Much more comments, correct range of possible threads.																				;
; Errors when user chose 1 thread, errors during splitting and merging image - black strpis on filtered image.							;
;																																		;
; version 0.7																															;
; Program during filtration has no errors, algorithm works correctly according to assumptions.											;
; There are no black stripes on filred image. Filtred image is exactly the same on every amount of threads.								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data 

; amount of bytes in one pixel
BYTE_IN_PIXEL_Q qword 4
.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main procedure used for applying laplace filter on image row																			;
; ### PARAMETERS ###																													;
;	int startingSubpixelIndex		RCX => R10			[range must be more than 0, it is checked in the proceure]						;
;	int subpixelToFilter			RDX => R11			[range must be more than 0, it is checked in the proceure]						;	
;	byte* original,					R8					[byte array of original image]													;
;	byte* filtered,					R9					[byte array of filtered image]													;
;	int* mask,		    			STACK [rbp+48] 		[laplace mask table pointer]													;
;	int subpixelWidth    			STACK [rbp+56] 		[subpixelWidth, range must be more than 0, it is not checked in the proceure]	;
; ### USED REGISTERS ###																												;
; rax																																	;
; rbx - temp value for subpixel																											;
; rcx																																	;
; rdx																																	;
; r12 - loop counter																													;
; r13 - mask subpixel index																												;
; r14																																	;
; r15																																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

laplace proc

; prepare for stack deallocation
push rbp									; push register state onto stack
mov rbp, rsp								; move register rsp to rbp
push rax									; push register state onto stack
push rbx									; push register state onto stack
push rcx									; push register state onto stack
push rdx									; push register state onto stack
push r12									; push register state onto stack
push r13									; push register state onto stack
push r14									; push register state onto stack
push r15									; push register state onto stack

; Main code
; The program starts by loading the image into the byte array. 
; Then the first index in a row is passed to be processed. 
; Then the indexes of 8 adjacent values ​​of the corresponding pixel component (RGBA) are computed.
; The next step is to sum these values ​​after the previous multiplication by the appropriate masks. 
; Then it is checked if the value is less than zero. 
; If so, the sum is set to zero and the value for the counted pixel is stored in the array. 
; However, if not, it is checked if it is greater than 255 and if not, it is saved and if so, it is changed to 255 and also saved. 
; After saving, it is checked whether it is the last index to be converted in a row. 
; If not, the byte index is incremented and the algorithm returns to the beginning. 
; If so, it is checked to see if it is the last row. 
; If so, the filtering of the image is finished, otherwise the index of the beginning of the next line is counted and we go back to the beginning.

PREPAREVARIABLES:
mov r10, rcx 								; move startingSubpixelIndeX parameter to r10d	
mov r11, rdx								; move subpixelToFilter parameter to r11d

; run 'MAINLOOP' loop

xor r12, r12								; make registers equal to 0
MAINLOOP:
xor rbx, rbx								; make registers equal to 0
xor rcx, rcx								; make registers equal to 0
xor rdx, rdx								; make registers equal to 0

; Set subpixel
	
	; add 1st subpixels from mask
		xor r13, r13						; make registers equal to 0
		xor rcx, rcx						; make registers equal to 0
		mov ecx, dword ptr[rbp+56]			; get mask value
		sub r13, rcx						; subtract rcx from r13
		sub r13, BYTE_IN_PIXEL_Q			
		movd xmm8, r8d						; copy r8d to xmm8
		movd xmm9, r13d						; copy r13d to xmm9
		paddq xmm9, xmm8					; add original image starting index
		movd xmm8, r10d						; copy r10d to xmm8
		paddq xmm9, xmm8					; add starting subpixel index
		movd xmm8, r12d						; copy r12d to xmm8
		paddq xmm9, xmm8					; add loop index
		movd r13, xmm9						; copy xmm8 back to r13
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx] 			; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 2nd subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48]			; get mask value 
		imul eax, dword ptr[rcx+4]			; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 3rd subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+8] 			; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 4th subpixels from mask
		sub r13, BYTE_IN_PIXEL_Q			
		sub r13, BYTE_IN_PIXEL_Q			
		xor rcx, rcx						; make registers equal to 0
		mov ecx, dword ptr[rbp+56]			; get mask value 
		add r13, rcx						; add rcx to r13
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+12] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 5th subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+16] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 6th subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+20] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 7th subpixels from mask
		sub r13, BYTE_IN_PIXEL_Q		
		sub r13, BYTE_IN_PIXEL_Q
		xor rcx, rcx						; make registers equal to 0
		mov ecx, dword ptr[rbp+56]			; get mask value 
		add r13, rcx						; add rcx to r13
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+24] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 8th subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+28] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx
	
	; add 9th subpixels from mask
		add r13, BYTE_IN_PIXEL_Q
		xor eax, eax						; make registers equal to 0
		mov al, byte ptr[r13] 				; get corresponding image subpixel
		mov rcx, qword ptr[rbp+48] 			; get mask value 
		imul eax, dword ptr[rcx+32] 		; multiply by mask value
		movd xmm8, ebx						; copy ebx to xmm8
		movd xmm9, eax						; copy eax to xmm9
		paddq xmm8, xmm9					; add eax to ebx
		movd ebx, xmm8						; copy xmm8 back to ebx

; Check max/min for subpixels.
; It is checked if the value is less than zero. 
; If so, the sum is set to zero and the value for the counted pixel is stored in the array. 
; However, if not, it is checked if it is more than 255. 
; If not, it is saved and if so, it is changed to 255 and also saved. 

	cmp ebx, 255							; compare if it is more than 255
	jg SET_MAX								; jump to 'SET_MAX' loop, if it is grater than 255
	cmp ebx, 0								; compare if it is less than 0  
	jl SET_MIN								; jump to 'SET_MIN' loop, if it is less than 
	jmp SET									; jump to 'SET' loop 

; 'SET_MAX' loop if value is grater than 255
	SET_MAX:			
	mov ebx, 255							; the sum is set to 255
	jmp SET									; jump to 'SET' loop 

; 'SET_MIN' loop if value is less than 0
	SET_MIN:
	mov ebx, 0								; the sum is set to zero
	jmp SET									; jump to 'SET' loop 

	SET:
	mov rax, r9								; copy r9 to rax
	add rax, r12							; add r12 to rax
	add rax, r10							; add r10 to rax
	mov byte ptr[rax], bl		
	
; set subpixels
	inc r12 								; inrement loop counter
	cmp r12d, r11d							; check with subpixed width of image
	jz CLEARSTACK							; clear stack
	jmp MAINLOOP							; jump back to the 'MAINLOOP' loop

CLEARSTACK:

; clear stack
	pop r15									; restore the top of the stack into a register
	pop r14									; restore the top of the stack into a register
	pop r13									; restore the top of the stack into a register
	pop r12									; restore the top of the stack into a register
	pop rdx									; restore the top of the stack into a register
	pop rcx									; restore the top of the stack into a register
	pop rbx									; restore the top of the stack into a register
	pop rax									; restore the top of the stack into a register
	pop rbp									; restore the top of the stack into a register
	ret
laplace endp								; end procedure
end