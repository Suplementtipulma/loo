#loo 
#Copyright (C) 2016  Suplementtipulma

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.



#COMPILE 32-BIT gcc -m32 -o loo loo.s
	
.section .data
filePath:	.ascii "./esimluk.bmp\0"
readMode:	.ascii "r\0"
fileHandle:	.long 0
	
.equ		NEWLINE, '\n'
.equ		VARSIZE,  10
.equ		NULLTERM,'\0'
.equ 		TABLESIZE, 100	

.equ		STARTADDROFFSET,    10	#4 bytes
.equ		BITMAPWIDTHOFFSET,  18	#4 bytes
.equ		BITMAPHEIGHTOFFSET, 22	#4 bytes
.equ		BITSPERPIXELOFFSET, 28  #2 bytes	
.equ		COMPRESSUSEDOFFSET, 30  #4 bytes	tulee olla BL_RGB eli 0				
.equ		IMAGESIZEOFFSET,    34	#4 bytes

#.equ		FIRSTLOC, /*...*/
#.equ		OFFSETHOR, /*...*/
#.equ		OFFSETVER, /*...*/
	
bmpID:		.ascii "BM"
msg:		.ascii "\n>\0"
errorMsg:	.ascii "Error: Invalid file format\0"
license:	.ascii "loo  Copyright (C) 2016  Suplementtipulma\nThis program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions; type `show c' for details.\n\n\0"

primeConstant:	   .int 191
readBuffer:	   .fill 10
	
dataRaw:	
	#tilaa 100 eri aineelle, joissa enint. 8 kirjainta
	
	.rept 100
	.ascii "\0\0\0\0\0\0\0\0\0"				#Ensimm‰inen tavu kertoo kyseisen aineen sijaintikolmikon sijainnin taulukossa
	.endr
	
	#8 erilaista laatikkoa -> 8*3 sijaintia			sijainnit kolmen ryhmiss‰ eli 8 eri ryhm‰‰
	
	.rept 24
	.byte 0
	.endr
	
	
hashedUserInput:
	.rept 10
	.int 0
	.endr

userInputLength:	.int 0

	
.section .bss
	

	
.section .text

	
.globl _main	
_main:

	pushl $license
	call _printf
	addl $4, %esp
	
	call init
	call readInput
	
	#call calc
	jmp exit


init:
	pushl %ebp
	movl %esp, %ebp

	pushl $readMode
	pushl $filePath
	call _fopen
	movl %eax, fileHandle(,1)
	addl $8, %esp	

	pushl $1
	pushl $2
	call readFromStream 
	
	movw readBuffer, %dx
	cmpw bmpID, %dx  
	jne ffError

	pushl $STARTADDROFFSET
	call setOffset

	#pushl $1
	#pushl $4
	#call readFromStream
	
	#header - 2 + 4 + 2+ 2 + 4 bytes
	#https://en.wikipedia.org/wiki/BMP_file_format	

	
	pushl fileHandle
	call _fclose	
	addl $4, %esp

	jmp endCall

setOffset:
	pushl %ebp
	movl %esp, %ebp
	
	pushl $0
	pushl 8(%ebp)				#param 1
	pushl fileHandle
	call _fseek
	addl $12, %esp

	jmp endCall
	
readFromStream:	
	pushl %ebp
	movl %esp, %ebp

	pushl fileHandle
	pushl 8(%ebp)				#param1	count
	pushl 12(%ebp)				#param2 element size
	leal readBuffer, %ebx
	pushl %ebx
	call _fread
	addl $16, %esp
	
	jmp endCall
	
ffError:	
	pushl $errorMsg
	call _printf
	addl $4, %esp
	
	jmp exit
	
readInput:	
	pushl %ebp
	movl %esp, %ebp
	jmp readInputLoop
	
readInputLoop:
	pushl $msg
	call _printf
	addl $4, %esp		

	xorl %eax, %eax
	xorl %esi, %esi
	
	call _getchar
	cmpb $NEWLINE, %al			
	je endCall

	movl %eax, %esi
	
	jmp innerLoop
	
innerLoop:	
	call _getchar					
	cmpb $NEWLINE, %al			
	je endLine
		
	movl %eax, %ebx	
	movl %esi, %eax
	
	#mull primeConstant		#for full precision arithemtic	
	imull primeConstant, %eax
	
	movl %eax, %esi
	addl %ebx, %esi
	
	jmp innerLoop

endLine:	
	xorl %edx, %edx
	movl %esi, %eax
	movl $TABLESIZE, %ebx

	#cdq				#for full precision arithmetic
	#divl %ebx			#
	idivl %ebx, %eax
	
	movl userInputLength, %ebx
	movl %edx, hashedUserInput(, %ebx, 4)
	incl userInputLength	
	
	jmp readInputLoop
	
endCall:
	movl %ebp, %esp
	popl %ebp
	ret
	
exit:
	movl $0, %eax
	pushl $0
	call _ExitProcess@4

hash:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %ebx
	movl $0, %eax
	movl $0, %ecx

	
	jmp hashLoop

hashLoop:

	cmpl $NULLTERM, (%ebx, %ecx)
	je hashEnd

	mull primeConstant
	addl (%ebx, %ecx), %eax
	incl %ecx 
	
	jne hashLoop
	
hashEnd:
	movl $0, %edx
	
	movl $TABLESIZE, %ebx
	divl %ebx

	movl %edx, %eax
	
	jmp endCall
	
hashFind:	
	

calc:
	pushl %ebp
	movl %esp, %ebp
	
	#...

	jmp endCall
	
disp:	



	

	



 
	


