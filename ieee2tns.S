		;		ARM Programming Assignment #3: IEEE 754 to TNS bit-level marshaller
		;
		;		Write a program to convert a 32-bit single-precision IEEE 754 floating-point
		;		number to the Tandem Non-stop Series (TNS) format. Refer to the README for a
		;		description of the format. Convert the numbers in `floats` and write the TNS
		;		equivalents into the `tns` area, one after the other.
		;
		;		Bonus:
		;		1. (30 extra points) Implement the reverse conversion, from TNS to IEEE.
		;		2. (50 extra points) Organize the code into two subroutines, with stack
		;		support.
		;		3. (10 extra points) In the main program, implement a round-trip conversion
		;		and prove the results match the initial values in 'floats'.  Define a
		;		`FILL` region to hold the IEEE 754 results.
		;
		
		;		Your code here
		
floats	DCD		0xa0bcff0d, 0x13c0adea
tns		FILL		8
ieee		FILL		8
		
		adr		r8, floats
		adr		r9, tns
		
		ldr		r0, [r8], #4	;loads first number into r0
		bl		toTNS
		str		r0, [r9], #4	;stores converted first number at tns
		
		ldr		r0, [r8]		;loads second number
		bl		toTNS
		str		r0, [r9], #4	;stores converted second number
		
		adr		r8, floats
		adr		r9, ieee
		
		ldr		r0, [r8], #4	;loads tns converted first number
		bl		toIEEE
		str		r0, [r9], #4	;stores first number converted back to IEEE
		
		ldr		r0, [r8]		;loads tns converted second number
		bl		toIEEE
		str		r0, [r9]		;stores second number converted back to IEEE
		
		end
		
		
		;arguments	passed and returned through r0. NOTE: Precision may be lost
toTNS	lsr		r1, r0, #1	;shaves off one digit of the mantissa
		lsl		r1, r1, #10	;clears sign and exponent
		lsr		r1, r1, #1	;lines up mantissa
		
		lsl		r2, r0, #1	;clears sign bit
		lsr		r2, r2, #24	;lines up exponent
		
		lsr		r3, r0, #31	;clears exponent and mantissa
		lsl		r3, r3, #31	;lines up sign bit
		
		add		r0, r1, r2	;adds exponent and mantissa
		add		r0, r0, r3	;adds exponent/mantissa with sign bit
		mov		pc, lr		;returns
		
		;arguments	passed and returned through r0. NOTE: Doesn not handle numbers that are too big to represent, convertion may be innaccurate in those cases
toIEEE	lsl		r1, r0, #1	;clears sign bit
		lsr		r1, r1, #9	;clears exponent and lines up mantisa
		
		lsl		r2, r0, #24	;clears sign bit and mantissa
		lsr		r2, r2, #1	;lines up exponent
		
		lsr		r3, r0, #31	;clears exponent and mantissa
		lsl		r3, r3, #31	;lines up sign bit
		
		add		r0, r1, r2	;adds mantissa and exponent
		add		r0, r0, r3	;adds exponent/mantissa and sign bit
		mov		pc, lr
