		;		ARM Programming Assignment #3: 32 bit IEEE 754 single-precision multiplier
		;
		;		Write a 32-bit floating point multiplier. The numbers will be represented
		;		in the single-precision IEEE 754 floating-point standard. The result should
		;		also be in IEEE 754 binary32. Assume you only have normalized numbers, i.e.
		;		the exponent is never 0b00000000.
		;		Write the result in the provided "fill" word.
		
		;		Your code here
		
floats	DCD		0xa0bcff0d, 0x13c0adea
result	FILL		8
link		FILL		4
		
		adr		r0, floats		;get pointer to numbers
		ldr		r6, [r0], #4		;load first number
		ldr		r7, [r0]			;load second number
		lsl		r6, r6, #9		;clears sign and exponent bits
		lsr		r3, r6, #1		;shifts back right 1 to make room for the understood bit
		add		r3, r3, #0x80000000	;adds in the understood bit
		lsl		r7, r7, #9		;clears sign and exponent bits
		lsr		r5, r7, #1		;shifts back right 1 to make room for the understood bit
		add		r5, r5, #0x80000000	;adds in the understood bit
		bl		mul32			;multiplies the fractions
		mov		r2, r3			;places top half in r1, and bottom half in r2
		lsl		r1, r1, #2		;gets rid of understood bits
		lsr		r1, r1, #2		;lines up r2 again
		mov		r3, #10			;initializes counter
		
shift	lsrs		r1, r1, #1		;this subrutine shifts bits from r1 into r2
		lsr		r2, r2, #1
		addcs	r2, r2, #0x80000000
		subs		r3, r3, #1
		bne		shift
		
		adr		r0, floats
		ldr		r6, [r0], #4
		ldr		r7, [r0]
		lsr		r6, r6, #23		;clears fraction
		lsr		r7, r7, #23		;clears fraction
		lsr		r4, r6, #8		;clears exponent
		lsr		r5, r7, #8		;clears exponent
		eors		r3, r4, r5		;subtracts sign bits
		addne	r1, r1, #0x80000000	;adds sign bit if only one operand was negative
		bic		r6, r6, #0x100		;clears sign bit
		bic		r7, r7, #0x100		;clears sign bit
		add		r6, r6, r7		;adds exponents
		sub		r6, r6, #0x7f		;subtracts 127 from exponents to acount for bias
		lsl		r6, r6, #20		;lines up exponents
		add		r1, r1, r6		;adds exponent to finish
		adr		r0, result
		str		r1, [r0], #4
		str		r2, [r0]
		
		end
		
mul32	;Multiply	uses	r3 for operand 1, r5 for operand 2, r1 for MSB, r3 for LSB
		ADR		r0, link
		STR		lr, [r0]
		
		;extract	top a and bottom a to r2 and r3 respectively
		MOV		r2, r3, LSR #16	;puts top half of r2 (a) in r1 | (top a)
		BIC		r3, r3, r2, LSL #16 ;puts bottom half of r2 (a) in r2 | (bottom a)
		;extract	top b and bottom b to r4 and r5 respective
		MOV		r4, r5, LSR #16	;puts top half of r4 (b) in r3 | (top b)
		BIC		r5, r5, r4, LSL #16	;puts bottom half of r4 (b) in r4 | (bottom b)
		
		;multiply	(top a) with (top b)
		MOV		r8, r2			;moves (top a) into r8
		MOV		r9, r4			;moves (top b) into r9
		BL		mul				;(top a) * (top b)
		MOV		r1, r10			;moves result (partial sum) to r1
		;multiply	(top a) with (bottom b)
		MOV		r8, r2			;moves (top a) into r8
		MOV		r9, r5			;moves (bottom b) into r9
		BL		mul				;(top a) * (bottom b)
		MOV		r2, r10			;moves result (partial sum) to r2
		;multiply	(bottom a) with (top b)
		MOV		r8, r3			;moves (bottom a) into r8
		MOV		r9, r4			;moves (top b) into r9
		BL		mul				;(bottom a) * (top b)
		MOV		r4, r10			;moves result (partial sum) to r4
		;multiply	(bottom a) with (bottom b)
		MOV		r8, r3			;moves (bottom a) into r8
		MOV		r9, r5			;moves (bottom b) into r9
		BL		mul				;(bottom a) * (bottom b)
		MOV		r3, r10			;moves result (partial sum) to r3
		
		ADDS		r2, r2, r4		;add middle parts
		ADDCS	r1, r1, #0x10000	;add in carry from above
		ADDS		r3, r3, r2, LSL #16	;LSB 32 bits
		ADC		r1, r1, r2, LSR #16	;MSB 32 bits
		ADR		r0, link
		LDR		lr, [r0]
		MOV		pc, lr
		
		;Multiply	uses	r8 for operand 1, r9 for operand 2, r10 for result
mul		MOV		r10, #0		;initialize result register
		
loop		MOVS		r9, r9, lsr #1	;shifts r9 (b) right 1, writes that back to r9, and sets the status flags
		ADDCS	r10, r10, r8	;if the carry bit is set, add r8 to r10
		MOV		r8, r8, lsl #1	;update r8 (a) by shifting it left 1
		CMP		r9, #1
		BGT		loop			;branch back to loop if r9 is not 0
		
		MOVS		r9, r9, lsr #1	;shifts r9 (b) right 1, writes that back to r9 (b), and sets the status flags for the last time
		ADDCS	r10, r10, r8	;if the carry bit is set, add r8 (a) to r10 for the last time
		MOV		pc, lr		;returns
