
	.data
	.align	4
floatin:	.asciz "%f"
floatout:	.asciz "%lf\n"
newline:	.asciz "\n"
binout:		.asciz "%s\n"
nlBin:		.byte 0



	.text
	.align 4
	
	
! writeFloat2 -- print a single-precision floating pa oint number,
! stored in IEEE 754-2008 format, to the stdout as decimal
! value
!
! inputs:
!		%o0 -- the float to print

	.global writeFloat2
writeFloat2:
	save	%sp, -(92 + 8) & -8, %sp

	! First things first... printf expects a _double_, not a float.
	! Why? Because variadic functions in C always promote floats
	! to doubles. Why? Because you need some kind of standard sizes
	! for things when you allow arbitrarlily many of them, and it 
	! makes more sense to standardize on higher precision, rather
	! than lower precision, types. Note, though, that this creates
	! a bit of a pain in the ass for us. We're going to be lazy
	! and use the SPARC's FPU to upconvert the float to a double
	! for us. But even that has a surprise in store...

	! ... in early SPARC machines, the FPU was actually on a separate
	! physical piece of silicon. This means we can't mov data from an
	! integer register to a floating-point register directly. We have
	! to go via memory. 
	
	st		%i0, [%fp - 4]
	ld		[%fp - 4], %f0	! %f0 is one of the special float registers

	fstod		%f0, %f0 ! promote our float to a double

	std		%f0,[%fp - 8] ! save double back to memory
	
	set 		floatout, %o0	! format string for printf
	ld		[%fp - 8], %o1	! stuff double into registers for printf
	ld		[%fp - 4], %o2
	
	! Hey! Why two loads? Why not just one 'ldd'? If you answered
	! 'Alignment'... you're right.

	call printf
	nop
	
	ret
	restore
	

! readFloat2 -- read a decimal real value from stdin and store
! the result in IEEE 754-2008 single-precision floating point format
! in register %o0.
!
! inputs: none
!
! outputs:
!		%o0 -- single precision float read from user

	.global readFloat2
readFloat2:
	save	%sp, -(92 + 4) & -8, %sp
	
	set		floatin, %o0
	add		%fp,-4,%o1
	set 	nlBin, %o2

	call	scanf
	nop

	ld	[%fp - 4], %i0
	
	ret
	restore


! writeBin - Writes the contents of register %o0 to stdout as a raw
!            bit pattern. Assumes 32-bit architecture (SPARC V7)
!
! inputs:
!	%o0 - the bit pattern to print
!
! Interesting note: this function serves as an example of why it is
! so important to comment assembly language code. What it does is very, very
! simple and it does so in the most straightforward of ways. Nevertheless,
! it isn't trivial to figure out exactly what's going on at first glance, is
! it? Also: if you've made it this far through the file, good on ya. This
! isn't required reading... you're doing it because you want to learn.
! That makes me happy. For a bonus mark, add the word 'NARWHAL' to the top
! of your assignment 4 source code (in a comment, of course).
!	%l0 - working number
!	%l1 - counter
!	%l2 - string pointer

	.global writeBin
writeBin:
	save	%sp, -(92+32+8+1) & -8, %sp

	mov	0x20, %l1
	mov	%i0, %l0
	add	%fp,-2,%l2

	mov	0, %l3
	stb	%l3, [%fp - 1]

	tst	%l1
binloop:
	be	binDone
	nop

	and	%l1, 0x00000003, %l3
	tst	%l3
	bne	nospace
	nop

	mov	0x20, %l3	
	stb	%l3, [%l2]
	dec	%l2
	
nospace:
	and	%l0,0x00000001,%o1
	add	%o1, 48, %o1
	stb	%o1, [%l2]
	dec	%l2

	srl	%l0,1,%l0

	ba	binloop
	deccc	%l1


binDone:
	mov	10, %l1
	stb	%l1, [%l2]

	set	binout, %o0
	add	%fp,-41, %o1
	call 	printf
	nop

	ret
	restore	
