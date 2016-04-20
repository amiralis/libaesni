[bits 64]
[CPU intelnop]

; Copyright (c) 2010, Intel Corporation
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without 
; modification, are permitted provided that the following conditions are met:
; 
;     * Redistributions of source code must retain the above copyright notice, 
;       this list of conditions and the following disclaimer.
;     * Redistributions in binary form must reproduce the above copyright notice, 
;       this list of conditions and the following disclaimer in the documentation 
;       and/or other materials provided with the distribution.
;     * Neither the name of Intel Corporation nor the names of its contributors 
;       may be used to endorse or promote products derived from this software 
;       without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
; IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
; INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
; OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%macro linux_setup 0
%ifdef __linux__
	mov rcx, rdi
	mov rdx, rsi
%endif
%endmacro

%macro inversekey 1
	movdqu  xmm1,%1
	aesimc	xmm0,xmm1
	movdqu	%1,xmm0
%endmacro

%macro aesdeclast1 1
	aesdeclast	xmm0,%1
%endmacro

%macro aesenclast1 1
	aesenclast	xmm0,%1
%endmacro

%macro aesdec1 1
	aesdec	xmm0,%1
%endmacro

%macro aesenc1 1
	aesenc	xmm0,%1
%endmacro


%macro aesdeclast1_u 1
	movdqu xmm4,%1
	aesdeclast	xmm0,xmm4
%endmacro

%macro aesenclast1_u 1
	movdqu xmm4,%1
	aesenclast	xmm0,xmm4
%endmacro

%macro aesdec1_u 1
	movdqu xmm4,%1
	aesdec	xmm0,xmm4
%endmacro

%macro aesenc1_u 1
	movdqu xmm4,%1
	aesenc	xmm0,xmm4
%endmacro
 
%macro aesdec4 1
	movdqa	xmm4,%1

	aesdec	xmm0,xmm4
	aesdec	xmm1,xmm4
	aesdec	xmm2,xmm4
	aesdec	xmm3,xmm4

%endmacro

%macro aesdeclast4 1
	movdqa	xmm4,%1

	aesdeclast	xmm0,xmm4
	aesdeclast	xmm1,xmm4
	aesdeclast	xmm2,xmm4
	aesdeclast	xmm3,xmm4

%endmacro


%macro aesenc4 1
	movdqa	xmm4,%1

	aesenc	xmm0,xmm4
	aesenc	xmm1,xmm4
	aesenc	xmm2,xmm4
	aesenc	xmm3,xmm4

%endmacro

%macro aesenclast4 1
	movdqa	xmm4,%1

	aesenclast	xmm0,xmm4
	aesenclast	xmm1,xmm4
	aesenclast	xmm2,xmm4
	aesenclast	xmm3,xmm4

%endmacro


%macro load_and_inc4 1
	movdqa	xmm4,%1
	movdqa	xmm0,xmm5
	pshufb	xmm0, xmm6 ; byte swap counter back
	movdqa  xmm1,xmm5
	paddd	xmm1,[counter_add_one wrt rip]
	pshufb	xmm1, xmm6 ; byte swap counter back
	movdqa  xmm2,xmm5
	paddd	xmm2,[counter_add_two wrt rip]
	pshufb	xmm2, xmm6 ; byte swap counter back
	movdqa  xmm3,xmm5
	paddd	xmm3,[counter_add_three wrt rip]
	pshufb	xmm3, xmm6 ; byte swap counter back
	pxor	xmm0,xmm4
	paddd	xmm5,[counter_add_four wrt rip]
	pxor	xmm1,xmm4
	pxor	xmm2,xmm4
	pxor	xmm3,xmm4
%endmacro

%macro xor_with_input4 1
	movdqu xmm4,[%1]
	pxor xmm0,xmm4
	movdqu xmm4,[%1+16]
	pxor xmm1,xmm4
	movdqu xmm4,[%1+32]
	pxor xmm2,xmm4
	movdqu xmm4,[%1+48]
	pxor xmm3,xmm4
%endmacro



%macro load_and_xor4 2
	movdqa	xmm4,%2
	movdqu	xmm0,[%1 + 0*16]
	pxor	xmm0,xmm4
	movdqu	xmm1,[%1 + 1*16]
	pxor	xmm1,xmm4
	movdqu	xmm2,[%1 + 2*16]
	pxor	xmm2,xmm4
	movdqu	xmm3,[%1 + 3*16]
	pxor	xmm3,xmm4
%endmacro

%macro store4 1
	movdqu [%1 + 0*16],xmm0
	movdqu [%1 + 1*16],xmm1
	movdqu [%1 + 2*16],xmm2
	movdqu [%1 + 3*16],xmm3
%endmacro

%macro copy_round_keys 3
	movdqu xmm4,[%2 + ((%3)*16)]
	movdqa [%1 + ((%3)*16)],xmm4
%endmacro


%macro key_expansion_1_192 1
		;; Assumes the xmm3 includes all zeros at this point. 
        pshufd xmm2, xmm2, 11111111b        
        shufps xmm3, xmm1, 00010000b        
        pxor xmm1, xmm3        
        shufps xmm3, xmm1, 10001100b
        pxor xmm1, xmm3        
		pxor xmm1, xmm2		
		movdqu [rdx+%1], xmm1			
%endmacro

; Calculate w10 and w11 using calculated w9 and known w4-w5
%macro key_expansion_2_192 1				
		movdqa xmm5, xmm4
		pslldq xmm5, 4
		shufps xmm6, xmm1, 11110000b
		pxor xmm6, xmm5
		pxor xmm4, xmm6
		pshufd xmm7, xmm4, 00001110b 
		movdqu [rdx+%1], xmm7
%endmacro
