!************************************************************************************
!************************************************************************************
!*	Devon Guinane																   
!*																   
!* 	File: asn4.m
!*																						
!* 	Description:
!*    	This program reads 2 floats from the user, displays each one in float format
!*		and binary format, then adds them using the SPARC fadds function and displays
!*		the result in floating point format and binary format. Then the two float values
!*		are added together using my own function, myfadd, and the result is displayed
!*		in floating point format and then binary format.
!*    	
!*
!* 	Revision History:
!*    	11/17/2011 added addition of 2 positive floats
!*		11/17/2011 Re-wrote code to add 2 positive floats to fix some bugs
!*		11/18/2011 added addition of 1 positive float and 1 negative float 
!*    	11/18/2011 Implemented adding 2 negative floats
!*		11/18/2011 Re-wrote code to fix a bug from the day before that wasn't calculating
!*				   the carry out bits when two positive floats were added together
!*		11/18/2011 Reorganized all of the code to make it a bit cleaner
!*		11/19/2011 Found a few bugs when adding negative numbers
!*		11/20/2011 Fixed bug when adding -0.5 to 0.5
!*		11/21/2011 Let the main program get the result from myfadd.m and display it
!*		11/21/2011 Finished commenting the code
!*		  	
!*
!* 	Register Legend:
!*    	%float1_r		stores first float from user		%l0
!*    	%float2_r		stores second float from user		%l1

!************************************************************************************
!************************************************************************************
							
 	
						! 4 bytes for memory allocation of float

						! holds first float from user
						! holds 2nd float from user
			
	EOL = 10								! ASCII code for newline character
		
	.global main
main:
	save 	%sp,-96,%sp 					! main program starts here
	
	mov	 	'>', %o0       					! display prompt for user
	call 	writeChar
	nop
		
	call 	readFloat2						! get first float from user
	nop

	call 	writeBin						! display 1st float in ninary
	nop
	
	mov 	%o0, %l0					! store 1st float so it can be sent to FPU
	
	call 	readFloat2						! get 2nd float from user
	nop

	call 	writeBin						! display 2nd float in binary
	nop
	
	mov 	%o0, %l1					! store 2nd float so it can be sent to FPU
	
	st 		%l0, [%fp + 4]	! save 1st float into memory
	ld 		[%fp + 4], %f0			! load 1st float from memory into FPU
	
	st 		%l1, [%fp + 4]	! save 2nd float into memory
	ld 		[%fp + 4], %f1			! load 2nd float from memory into FPU
	
	fadds 	%f0, %f1, %f0					! add the 2 floating point values
	
	st 		%f0, [%fp + 4]			! store result in memory
	ld 		[%fp + 4], %o0			! load result into output register
	
	call 	writeFloat2						! display result in floating point format
	nop
	
	call 	writeBin						! display result in binary
	nop
	
	mov 	%l0, %o0					! pass floating values to myfadd function
	call 	myfadd
	mov 	%l1, %o1
	
	call	writeFloat2						! display result from myfadds
	nop
		
	call	writeBin						! display result from myfadds in binary
	nop
	
end:	
	mov	 EOL, %o0							! write a newline character, for spacing
			
	call writeChar
	nop
	ret
	restore
