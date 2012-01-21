!************************************************************************************
!************************************************************************************
!*	'Devon Guinane'															   
!*	'Assignment #4'																   
!* 	'File: myfadd.m'
!*																						
!* 	'Description:'
!*    	'This file contains a function which adds two floating point values.'
!*    	'The result is placed in register %i0 so it can be displayed from the main'
!*    	'program in register %o0.'
!*    	
!*	'INPUT:'
!*		'2 float values'
!*		'%i0: positive or negative float value'
!*		'%i1: positive or negative float value'
!*
!*	'OUTPUT:'
!*		'1 float value(sum of the 2 input float values)'
!*		'stored in %i0 when done, can be used from main program with %o0'
!*
!* 	'Revision History:'
!*    	'11/17/2011 added addition of 2 positive floats'
!*		'11/17/2011 Re-wrote code to add 2 positive floats to fix some bugs'
!*		'11/18/2011 added addition of 1 positive float and 1 negative float '
!*    	'11/18/2011 Implemented adding 2 negative floats'
!*		'11/18/2011 Re-wrote code to fix a bug from the day before that wasn\'t calculating'
!*				   'the carry out bits when two positive floats were added together'
!*		'11/18/2011 Reorganized all of the code to make it a bit cleaner'
!*		'11/19/2011 Found a few bugs when adding negative numbers'
!*		'11/19/2011 Couldn\'t find a bug so I re-wrote all code after the adding positive'
!*				   'floats code'
!*		'11/20/2011 Fixed bug when adding -0.5 to 0.5'
!*		'11/21/2011 Let the main program get the result from myfadd.m and display it'
!*		'11/21/2011 Finished commenting the code'
!*		  	
!*
!* 	'Register Legend:'
!*    	'%masks_r		stores masks to extract bits		%l0'
!*    	'%sbit1_r		holds first float\'s signed bit		%l1'
!*    	'%sbit2_r		holds second float\'s signed bit	%l2'
!*    	'%exp1_r		holds first float\'s exponent		%l3'
!*    	'%exp2_r		holds second float\'s exponent		%l4'
!*    	'%sig1_r		holds first float\'s significand	%l5'
!*    	'%sig2_r		holds second float\'s significand	%l6'
!*    	'%result_r		holds result of adding significands	%l7'
!************************************************************************************
!************************************************************************************

!************************************************************************************
! 
! 'myfadd - A function which adds two floats and returns'
!          'the result. The numbers are assumed to be'
!          'valid (no overflow checking is done).'
!
! 'Calling sequence:'
!  '- the first number to be added is passed in through %o0 from main program. Get'
!	 'value with %i0 from within this function'
!  '- the second number to be added is passed in through %o1 from main program. Get'
!	 'value with %i1 from within this function'
!
! 'Returns:'
!  '- the sum of the floats in %i0. Value can be retrieved from %o0 from main program'
!
! 'Registers used:'
!  		'%masks_r		stores masks to extract bits		%l0'
!    	'%sbit1_r		holds first float\'s signed bit		%l1'
!    	'%sbit2_r		holds second float\'s signed bit	%l2'
!    	'%exp1_r		holds first float\'s exponent		%l3'
!    	'%exp2_r		holds second float\'s exponent		%l4'
!    	'%sig1_r		holds first float\'s significand	%l5'
!    	'%sig2_r		holds second float\'s significand	%l6'
!    	'%result_r		holds result of adding significands	%l7'
! 
!************************************************************************************

 

				! 'mask to extract signed bit'
				! 'mask to extract exponent from float'
				! 'mask to extract significand from float'
				! 'mask to add the implicit 1 back in to the significand'
				! 'mask to remove hidden bit when repacking'
				! 'mask to check for carry bit when adding'
							! 'used to move sign bit to the right 31 bits'
							! 'used for shifting one to the left or right'
						! 'used for shifting expionents left and right'

							! 'used to store the different masks'
							! 'stores 1st float\'s signed bit'
							! 'stores 2nd floats\' signed bit'
							! 'stores 1st float\'s exponent'
							! 'stores 2nd float\'s exponent'
							! 'stores 1st float\'s significand'
							! 'stores 2nd float\'s significand'
						! 'stores result of adding significands 1 and 2'

.global	myfadd
myfadd:	save	%sp, -96, %sp


!*************************************************************************************
!																					 *
!	'Extract the signed bit, exponent, and significand from the 1st float value'     *
!																					 *
!*************************************************************************************

unpack1:
	set		0x80000000, %l0				! 'extract 1st float\'s sign bit'
	and		%i0, %l0, %l1
	srl		%l1, 31, %l1		! 'move sign bit to rightmost bit for comparison'
	
	set		0x7F800000, %l0				! 'store mask value to use for exponent extraction'
	and		%i0, %l0, %l3			! 'extract 1st float\'s exponent'

	set		0x007FFFFF, %l0				! 'store mask value to use for significand extraction'
	and		%i0, %l0, %l5			! 'extract 1st float\'s significand'
	
	
!*************************************************************************************
!																					 *
!	'Add back the hidden bit to 1st float\'s significand'                            *
!																					 *
!*************************************************************************************

set1:
	set		0x00800000, %l0			! 'store the mask to be used to add back implicit 1'
	or		%l5, %l0, %l5	! 'put back implicit 1 in 1st floats significand'


!*************************************************************************************
!																					 *
!	'Extract the signed bit, exponent, and significand from the 2nd float value'     *
!																					 *
!*************************************************************************************
	
unpack2:
	set		0x80000000, %l0				! 'extract 2nd float\'s sign bit'
	and		%i1, %l0, %l2			! 'extract 2nd float\'s sign bit'
	srl		%l2, 31, %l2		! 'move sign bit to rightmost bit for comparison'
	
	set		0x7F800000, %l0				! 'store mask value to use for exponent extraction'
	and		%i1, %l0, %l4			! 'extract 2nd float\'s exponent'

	set		0x007FFFFF, %l0				! 'store mask value to use for significand extraction'
	and		%i1, %l0, %l6			! 'extract 2nd float\'s significand'
	

!*************************************************************************************
!																					 *
!	'Add back the hidden bit to 2nd float\'s significand'                            *
!																					 *
!*************************************************************************************

set2:	
	set		0x00800000, %l0
	or		%l6, %l0, %l6		! 'put back implicit 1 in 2nd float\'s significand'
	
	
!*************************************************************************************
!																					 *
!	'Shift exponents to the right 23 bits to make it easier to get the difference'   *
!	'and use the difference as the number to add to the lower exponent'				 *
!																					 *
!*************************************************************************************

shiftExp:
	srl		%l3, 23, %l3		! 'shift exponents right 23 bits for comparing'
	srl		%l4, 23, %l4
	

!*************************************************************************************
!																					 *
!	'Compare exponents to see if they are equal or to see which one is greater'      *
!																					 *
!*************************************************************************************	
	
cmpExp:	
	cmp		%l3, %l4				! 'if exponents are equal, add significands'
	be		addSigs
	nop
	
	cmp		%l3, %l4				! 'if exp 1 > exp 2, subtract exp 2 from exp 1'
	bg		expDif1
	nop
	
!*************************************************************************************
!																					 *
!	'Get the difference between the 2 exponents to see how much to increase the'     *
!   'smaller exponent by and then increase the smaller exponent by the difference.'  *
!   'Shift the significand of the smaller exponent to the right by the difference '  *
!																					 *
!*************************************************************************************

	sub		%l4, %l3, %o3			! 'exp 2 is bigger, subtract exp 1 from exp 2'
	add		%l3, %o3, %l3			! 'increase exp 1 by the difference'
	
	srl		%l5, %o3, %l5			! 'shift significand 1 by the difference'
	
	ba		cmpSigns						! 'add significands'
	nop

expDif1:
	sub		%l3, %l4, %o3			! 'exp 1 is bigger, subtract exp 2 from exp 1'
	add		%l4, %o3, %l4			! 'increase exp 2 by the difference'
	
	srl		%l6, %o3, %l6			! 'shift significand 2 by the difference'
	

!*************************************************************************************
!																					 *
!	'Check to see if signs of floats are different'									 *
!																					 *
!*************************************************************************************
	
cmpSigns:
	cmp		%l1, %l2				! 'check if signed bits are different'
	bne		handleNegation					! 'if one is pos and one neg, negate the neg'
	nop
	
	ba		addSigs
	nop
	
!*************************************************************************************
!																					 *
!	'Compare the signed bits. If one is negative, negate it	'						 *
!																					 *
!*************************************************************************************
	
handleNegation:	
	cmp		%l5, %l6				! 'at this point, if signs are same, result is zero'
	be		resultZero
	nop
	
	cmp		%l1, %l2
	bg		negate1							! 'if signed bit 1 is negative, negate its significand'
	nop
	
	cmp		%l1, %l2
	bl		negate2							! 'if signed bit 2 is negative, negate its significand'
	nop
	
	ba		addSigs2						! 'add the significands'
	nop
	
negate1:
	sub		%g0, %l5, %l5			! 'negate the 1st significand'
	ba		addSigs2
	nop
	
negate2:
	sub		%g0, %l6, %l6			! 'negate the 2nd significand'
	ba		addSigs2
	nop
	
	
!*************************************************************************************
!																					 *
!	'Add Significands when they both have the same sign	'							 *
!																					 *
!*************************************************************************************
	
addSigs:
	cmp		%l1, %l2				! 'if signs differ, negate the negative significand'
	bne		handleNegation
	nop
	
	add  	%l5, %l6, %l7		! 'add significands'
	
	set		0x01000000, %l0			! 'check if there is a carry out bit'
	btst	%l0, %l7				! 'if there is, handle the carry bit'
	bne		posCarry
	nop
	
	ba		next
	nop
	
!*************************************************************************************
!																					 *
!	'Add Significands when their signs differ'										 *
!																					 *
!*************************************************************************************
	
addSigs2:	
	add  	%l5, %l6, %l7		! 'add significands if 1 is pos and one neg'
	
	cmp		%l7, %g0					! 'if result is negative, negate the result'
	bl		negateResult
	nop
	
	cmp		%l7, %g0					! 'if result is positive, normalize result'
	bg		next
	nop
	
	ba		next							! 'normalize'
	nop
	
	
!*************************************************************************************
!																					 *
!	'Negate the result(absolute value) if the result is negative'   				 *
!																					 *
!*************************************************************************************
	
negateResult:
	sub		%g0, %l7, %l7		! 'negate result'
	mov		1, %l1				! 'set sign bit to negative'
	
	
!*************************************************************************************
!																					 *
!	'Check to see if the 24th bit is a 1. If it\'s not, shift the significand until' *
!	'it is.'																	     *
!																					 *
!*************************************************************************************
	
checkResult:
	set		0x00800000, %l0
	btst	%l0, %l7				! 'check if 24th bit is a 1'
	be		shiftResult
	nop
	
	ba		repack							! 'start repacking the bits'
	nop
	
shiftResult:
	sll		%l7, 1, %l7	! 'bit 24 is not 1, shift left'
	sub		%l3, 1, %l3		! 'decrease exponent by 1'
	
	ba		checkResult						! 'loop to check 24th bit again'
	nop
	
	
!*************************************************************************************
!																					 *
!	'If both floats are positive and there is a carry bit after adding, shift the'   *
!	'significand and add 1'														     *
!																					 *
!*************************************************************************************
	
posCarry:
	srl		%l7, 1, %l7	! 'shift significand and add 1 to exponent'
	add		%l3, 1, %l3
	ba		repack
	nop
	

!*************************************************************************************
!																					 *
!	'Normalize Significand, if 24th bit is a 0, shift significand to the right.'	 *
!	'Keep looping until there is a 1 in the 24th bit'								 *
!																					 *
!*************************************************************************************	

next:
	set		0x00800000, %l0				! 'set mask to check if 24th bit is a 1'
normalize:			
	btst	%l0, %l7				! 'check if 24th bit is a 1'
	be		shiftSigRight					! 'if there is a 0, shift sig right'
	nop
	
	ba		repack
	nop

shiftSigRight:
	srl		%l7, 1, %l7	! 'shift sig right, then loop again to check if 24th bit is a 1'
	add		%l3, 1, %l3		! 'add 1 to exponent since sig shifted right'
	ba		normalize
	nop
	
	
!*************************************************************************************
!																					 *
!	'Repack result. Shift the exponent and signed bit back to the left again.' 		 *
!   'Add back in the signed bit and the exponent to teh significand to get result'	 *
!																					 *
!*************************************************************************************	
	
repack:	
	set		0xFF7FFFFF, %l0			! 'mask to remove the extra bit in the significand'
	and		%l7, %l0, %l7	! 'remove the extra bit'
	
	sll		%l3, 23, %l3		! 'shift exponent back to left'
	sll		%l1, 31, %l1		! 'shift signed bit back to the left'
	
	or		%l1, %l7, %l7	! 'put signed bit into the result'
	or		%l3, %l7, %l7	! 'put exponent into the result'
	
	ba		return
	nop
	
resultZero:									! 'set result to zero'
	mov		%g0, %l7
	
return:
	mov		%l7, %i0					! 'put result in %i0 so it can be called from main'
	
	ret
	restore