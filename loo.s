<<<<<<< HEAD
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
#.equ		BMPIDENTIFIER, 'BM'
bmpID:		.ascii "BM"
errorMsg:	.ascii "Error: Invalid file format\0"
license:	.ascii "loo  Copyright (C) 2016  suplementtipulma\nThis program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions; type `show c' for details.\n\n\0"
	
.equ		STARTADDROFFSET,    10	#4 bytes
.equ		BITMAPWIDTHOFFSET,  18	#4 bytes
.equ		BITMAPHEIGHTOFFSET, 22	#4 bytes
.equ		BITSPERPIXELOFFSET, 28  #2 bytes	
.equ		COMPRESSUSEDOFFSET, 30  #4 bytes	tulee olla BL_RGB eli 0				
.equ		IMAGESIZEOFFSET,    34	#4 bytes	
	
#.equ		FIRSTLOC, /*...*/
#.equ		OFFSETHOR, /*...*/
#.equ		OFFSETVER, /*...*/	
	
msg:		.ascii "\n>\0"
	
#dataRaw:	.ascii "FY10\0" "HI7\0" "PS7\0"
#		       "MU5\0" "BI6\0" "BI6\0" "ƒI83\0"
#		       "ƒI12\0" "ENA103\0" "RAA9+RA\0"
#		       "TE3\0" "UE31\0" "MAA142\0" "MU9\0"
#		       "KE3\0" "YH8\0" "ESB10\0" "MAA141\0" "SAA9+SA\0"
data:		   .fill 125
dataSize:	   .int 19
userInputSize:	   .int 0
userInputElements: .int 0	


	
readBuffer:	   .fill 10
	
#dataRaw:
#	.ascii "FY10\0"
#	.ascii "HI7\0"
#	.ascii "PS7\0"
#	.ascii "\0"
#	.ascii "MU5\0"
#	.ascii "BI6\0"
#	.ascii "BI6\0"
#	.ascii "AI83\0"
#	.ascii "\0"
#	.ascii "AI12\0"
#	.ascii "ENA103\0"
#	.ascii "RAA9+RA\0"
#	.ascii "\0"
#	.ascii "TE3\0"
#	.ascii "UE31\0"
#	.ascii "MAA142\0"
#	.ascii "MU9\0"
#	.ascii "\0"
#	.ascii "KE3\0"
#	.ascii "YH8\0"
#	.ascii "ESB10\0"
#	.ascii "MAA141\0"
#	.ascii "SAA9+SA\0"
#	#FY10 & HI7 & PS7 x  y	x  y 
#	.byte 0, 0, 3, 3, 5, 4, 0, 0
#	#MU5 & BI6 & BI6 & AI83
#	.byte 0, 1,
	
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

.section .bss
.lcomm userInput, 50
.lcomm userInputLengths, 20	
	
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
	
	#pushl fileHandle
	#call _fclose
	
	#addl $8, %esp
	
	jmp exit
	
readInput:	
	pushl %ebp
	movl %esp, %ebp
	jmp readInputLoop
	
readInputLoop:
	pushl $msg
	call _printf
	addl $4, %esp		

	
	call _getchar
	cmpb $NEWLINE, %al			
	je endCall

	#movl $0, %ebx
	movl $0, %ecx
	movl userInputSize, %edx
	#xorb %al, %bl 
	movb %al, userInput(%edx, %ecx, 1) 
	incl %ecx

	
	jmp innerLoop
	
innerLoop:	
	
	call _getchar
	cmpb $NEWLINE, %al			
	je endLine

	#xorb %al, %bl				
	#xorl %eax, %ebx			

	#movl userInputIndex, %edx
	#movl userInputSize, %edx		
	movb %al, userInput(%edx, %ecx, 1) 	
	incl %ecx

	jmp exit #######
	jmp innerLoop

endLine:
	#movl userInputIndex, %eax		
	#movb %bl, userInput(, %eax, 1)
	#movl userInput, %ecx
	#movb %bl, (%eax, %ecx)				
	#movl %ebx, (%eax, %ecx)		

	
	movb $NULLTERM, userInput(%edx, %ecx, 1) 		#crash

	addl %ecx, %edx
	movl %edx, userInputSize

	movl userInputElements, %ebx
	movl %ecx, userInputLengths(, %ebx, 1)
	incl userInputElements

	jmp exit
	jmp readInputLoop
	
endCall:
	movl %ebp, %esp
	popl %ebp
	ret
	
exit:
	movl $0, %eax
	pushl $0
	call _ExitProcess@4


	
calc:
	pushl %ebp
	movl %esp, %ebp
	
	#call hash
	#call compare
	

	jmp endCall

hash:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax
	movl $0, %ebx
	movl $0, %ecx
	
	jmp hashLoop

hashLoop:

	cmpl $NULLTERM, (%eax, %ecx)
	je endCall
	
	mull $191, %ebx
	addl (%eax, %ecx), %ebx
	incl %ecx 
	
	jne hashLoop
	
hashFind:	
	
	
disp:	



	

	



 
	


=======
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
#.equ		BMPIDENTIFIER, 'BM'
bmpID:		.ascii "BM"
errorMsg:	.ascii "Error: Invalid file format\0"
license:	.ascii "loo  Copyright (C) 2016  suplementtipulma\nThis program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions; type `show c' for details.\n\n\0"

.equ		STARTADDROFFSET,    10	#4 bytes
.equ		BITMAPWIDTHOFFSET,  18	#4 bytes
.equ		BITMAPHEIGHTOFFSET, 22	#4 bytes
.equ		BITSPERPIXELOFFSET, 28  #2 bytes	
.equ		COMPRESSUSEDOFFSET, 30  #4 bytes	tulee olla BL_RGB eli 0				
.equ		IMAGESIZEOFFSET,    34	#4 bytes	
	
#.equ		FIRSTLOC, /*...*/
#.equ		OFFSETHOR, /*...*/
#.equ		OFFSETVER, /*...*/	
	
msg:		.ascii "\n>\0"
	
#dataRaw:	.ascii "FY10\0" "HI7\0" "PS7\0"
#		       "MU5\0" "BI6\0" "BI6\0" "√ÑI83\0"
#		       "√ÑI12\0" "ENA103\0" "RAA9+RA\0"
#		       "TE3\0" "UE31\0" "MAA142\0" "MU9\0"
#		       "KE3\0" "YH8\0" "ESB10\0" "MAA141\0" "SAA9+SA\0"
data:		   .fill 125
dataSize:	   .int 19
userInputSize:	   .int 0
userInputElements: .int 0	


	
readBuffer:	   .fill 10
	
#dataRaw:
#	.ascii "FY10\0"
#	.ascii "HI7\0"
#	.ascii "PS7\0"
#	.ascii "\0"
#	.ascii "MU5\0"
#	.ascii "BI6\0"
#	.ascii "BI6\0"
#	.ascii "AI83\0"
#	.ascii "\0"
#	.ascii "AI12\0"
#	.ascii "ENA103\0"
#	.ascii "RAA9+RA\0"
#	.ascii "\0"
#	.ascii "TE3\0"
#	.ascii "UE31\0"
#	.ascii "MAA142\0"
#	.ascii "MU9\0"
#	.ascii "\0"
#	.ascii "KE3\0"
#	.ascii "YH8\0"
#	.ascii "ESB10\0"
#	.ascii "MAA141\0"
#	.ascii "SAA9+SA\0"
#	#FY10 & HI7 & PS7 x  y	x  y 
#	.byte 0, 0, 3, 3, 5, 4, 0, 0
#	#MU5 & BI6 & BI6 & AI83
#	.byte 0, 1,
	
dataRaw:	
	#tilaa 100 eri aineelle, joissa enint. 8 kirjainta
	
	.rept 100
	.ascii "\0\0\0\0\0\0\0\0\0"				#Ensimm√§inen tavu kertoo kyseisen aineen sijaintikolmikon sijainnin taulukossa
	.endr
	
	#8 erilaista laatikkoa -> 8*3 sijaintia			sijainnit kolmen ryhmiss√§ eli 8 eri ryhm√§√§
	
	.rept 24
	.byte 0
	.endr
	
	
#hashedUserInput:
#	.rept 10
#	.int 0
#	.endr

.section .bss
.lcomm userInput, 50
.lcomm userInputLengths, 20	
	
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
	
	#pushl fileHandle
	#call _fclose
	
	#addl $8, %esp
	
	jmp exit
	
readInput:	
	pushl %ebp
	movl %esp, %ebp
	jmp readInputLoop
	
readInputLoop:
	pushl $msg
	call _printf
	addl $4, %esp		

	
	call _getchar
	cmpb $NEWLINE, %al			
	je endCall

	#movl $0, %ebx
	movl $0, %ecx
	movl userInputSize, %edx
	#xorb %al, %bl 
	movb %al, userInput(%edx, %ecx, 1) 
	incl %ecx
	
	jmp innerLoop
	
innerLoop:	
	
	call _getchar
	cmpb $NEWLINE, %al			
	je endLine

	#xorb %al, %bl				
	#xorl %eax, %ebx			

	#movl userInputIndex, %edx
	#movl userInputSize, %edx		
	movb %al, userInput(%edx, %ecx, 1) 	
	incl %ecx

	jmp exit #######
	jmp innerLoop

endLine:
	#movl userInputIndex, %eax		
	#movb %bl, userInput(, %eax, 1)
	#movl userInput, %ecx
	#movb %bl, (%eax, %ecx)				
	#movl %ebx, (%eax, %ecx)		

	
	movb $NULLTERM, userInput(%edx, %ecx, 1) 		#crash

	addl %ecx, %edx
	movl %edx, userInputSize

	movl userInputElements, %ebx
	movl %ecx, userInputLengths(, %ebx, 1)
	incl userInputElements

	jmp exit
	jmp readInputLoop
	
endCall:
	movl %ebp, %esp
	popl %ebp
	ret
	
exit:
	movl $0, %eax
	pushl $0
	call _ExitProcess@4


	
calc:
	pushl %ebp
	movl %esp, %ebp
	
	#call hash
	#call compare
	

	jmp endCall

	
hashFind:	
	
	
disp:	



	

	



 
	


>>>>>>> 89402cd0eba2183f1d61fc55506adc99dab2b0dd
