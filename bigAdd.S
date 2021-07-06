		GLOBAL	bigAdd
		AREA	||.text||, CODE, READONLY
		
bigAdd	push {r4-r12, r14}	;@ Safely store all registers
	ldr	r3, [r0,#0]	;@ Load the number of words in num1
	ldr	r4, [r1,#0]	;@ Load the number of words in num2
	
	cmp	r3, r2		;@ Compare number of words in num1 with maxN0Size
	bgt error		;@ If numWords is greater, branch to error
	cmp	r4, r2		;@ Do the same for r4
	bgt error
	
	mov	r10, #0		;@ Load 0 into r10 (used to determine memory location of current word)
	mov	r11, #0		;@ Load 0 into r11 (used to determine when to stop incrementing r10)
	bl check		;@ Ensure there are numbers to be added
	add	r10, r10, #4	;@ Increment word to the memory location of word 1
	add	r11, r11, #1	;@ Increment numWords to 1
	
	adds 	r0, r0, #0	;@ Clear the carry flag
	mrs	r8, APSR	;@ Store all flags
	
loop	bl addWord		;@ Add the r11th words of r0 and r1
	bl check		;@ Check whether there are more words to add
	add	r10, r10, #4	;@ Increment word to the memory location of the next word
	add	r11, r11, #1	;@ Increment numWords by 1
	b loop
	
check	cmp	r11, r2		;@ Check if maxN0Size has been reached
	beq done
	cmp	r3, r4		;@ Check whether r3 or r4 is larger
	bge num1		;@ Branch if r3 is greater than or equal to r4
num2	cmp	r11, r4		;@ Check if size of r4 has been reached
	beq done
	mov	pc, lr		;@ Return from subroutine
	
num1	cmp	r11, r3		;@ Check if size of r3 has been reached
	beq done
	mov	pc, lr		;@ Return from subroutine
	

addWord	ldr 	r5, [r0, r10]	;@ Load the r10 word of num1
	ldr 	r6, [r1, r10]	;@ Load the r10 word of num2
	
	cmp	r11, r3
	movgt	r5, #0
	cmp	r11, r4
	movgt	r6, #0
	
	msr	APSR, r8	;@ Restore all flags
	adcs 	r7, r5, r6	;@ Add words at r5 and r6 with carry, set status flags
	str 	r7, [r0, r10]	;@ Store the result in the r10 word of r0
	
	mrs	r8, APSR	;@ Store all flags
	mov	pc,  lr		;@ Return from subroutine
	
error	mov	r0, #-1		;@ If an error is detected, set r0 to -1
	pop {r4-r12, pc}	;@ Pop stack and return to main
	
done	str	r11, [r0, #0]	;@ Store number of words in 0th word of r0
	msr	APSR, r8	;@ Restore all flags
	bcs overfl		;@ If there is a carry, go to overflow
	
	mov	r0, #0		;@ If there is no carry, set r0 to 0
	pop {r4-r12, pc}	;@ Pop stack and return to main
	
overfl	cmp	r2, r11		;@ Check if maxN0Size has been reached
	beq over		;@ If it has been reached, skip to end
	
	add	r10, r10, #4	;@ If maxN0Size has not been reached,
	add	r11, r11, #1	;@ We can place the 'overflow' into the next word
	mov	r7, #1		;@ Set r7 to 1
	str	r7, [r0, r10]	;@ Store the 'overflow' into the next word
	
	adds 	r0, r0, #0	;@ Clear the carry flag
	mrs	r8, APSR	;@ Store all flags
	b done			;@ Branch back to done
	
over	mov	r0, #1		;@ If there is a carry, set r0 to 1
	pop {r4-r12, pc}	;@ Pop stack and return to main
	
	END