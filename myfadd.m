!************************************************************************************
!************************************************************************************
!*  'Devon Guinane'                                                                                                                           
!*  'File: myfadd.m'
!*                                                                                      
!*  'Description:'
!*      'This file contains a function which adds two floating point values.'
!*      'The result is placed in register %i0 so it can be displayed from the main'
!*      'program in register %o0.'
!*      
!*  'INPUT:'
!*      '2 float values'
!*      '%i0: positive or negative float value'
!*      '%i1: positive or negative float value'
!*
!*  'OUTPUT:'
!*      '1 float value(sum of the 2 input float values)'
!*      'stored in %i0 when done, can be used from main program with %o0'
!*
!*  'Revision History:'
!*      '11/17/2011 added addition of 2 positive floats'
!*      '11/17/2011 Re-wrote code to add 2 positive floats to fix some bugs'
!*      '11/18/2011 added addition of 1 positive float and 1 negative float '
!*      '11/18/2011 Implemented adding 2 negative floats'
!*      '11/18/2011 Re-wrote code to fix a bug from the day before that wasn\'t calculating'
!*                 'the carry out bits when two positive floats were added together'
!*      '11/18/2011 Reorganized all of the code to make it a bit cleaner'
!*      '11/19/2011 Found a few bugs when adding negative numbers'
!*      '11/20/2011 Fixed bug when adding -0.5 to 0.5'
!*      '11/21/2011 Let the main program get the result from myfadd.m and display it'
!*      '11/21/2011 Finished commenting the code'
!*          
!*
!*  'Register Legend:'
!*      '%masks_r       stores masks to extract bits        %l0'
!*      '%sbit1_r       holds first float\'s signed bit     %l1'
!*      '%sbit2_r       holds second float\'s signed bit    %l2'
!*      '%exp1_r        holds first float\'s exponent       %l3'
!*      '%exp2_r        holds second float\'s exponent      %l4'
!*      '%sig1_r        holds first float\'s significand    %l5'
!*      '%sig2_r        holds second float\'s significand   %l6'
!*      '%result_r      holds result of adding significands %l7'
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
!    'value with %i0 from within this function'
!  '- the second number to be added is passed in through %o1 from main program. Get'
!    'value with %i1 from within this function'
!
! 'Returns:'
!  '- the sum of the floats in %i0. Value can be retrieved from %o0 from main program'
!
! 'Registers used:'
!       '%masks_r       stores masks to extract bits        %l0'
!       '%sbit1_r       holds first float\'s signed bit     %l1'
!       '%sbit2_r       holds second float\'s signed bit    %l2'
!       '%exp1_r        holds first float\'s exponent       %l3'
!       '%exp2_r        holds second float\'s exponent      %l4'
!       '%sig1_r        holds first float\'s significand    %l5'
!       '%sig2_r        holds second float\'s significand   %l6'
!       '%result_r      holds result of adding significands %l7'
! 
!************************************************************************************

include(macro_defs.m)

define(SBIT_MASK, 0x80000000)               ! 'mask to extract signed bit'
define(EXP_MASK, 0x7F800000)                ! 'mask to extract exponent from float'
define(SIG_MASK, 0x007FFFFF)                ! 'mask to extract significand from float'
define(IMP_MASK, 0x00800000)                ! 'mask to add the implicit 1 back in to the significand'
define(REPACK_MASK, 0xFF7FFFFF)             ! 'mask to remove hidden bit when repacking'
define(CARRY_MASK, 0x01000000)              ! 'mask to check for carry bit when adding'
define(MV_SIGN, 31)                         ! 'used to move sign bit to the right 31 bits'
define(SHFT_ONE, 1)                         ! 'used for shifting one to the left or right'
define(SHFT_EXP, 23)                        ! 'used for shifting expionents left and right'

define(masks_r, l0)                         ! 'used to store the different masks'
define(sbit1_r, l1)                         ! 'stores 1st float\'s signed bit'
define(sbit2_r, l2)                         ! 'stores 2nd floats\' signed bit'
define(exp1_r, l3)                          ! 'stores 1st float\'s exponent'
define(exp2_r, l4)                          ! 'stores 2nd float\'s exponent'
define(sig1_r, l5)                          ! 'stores 1st float\'s significand'
define(sig2_r, l6)                          ! 'stores 2nd float\'s significand'
define(result_r, l7)                        ! 'stores result of adding significands 1 and 2'

begin_fn(myfadd)

!*************************************************************************************
!                                                                                    *
!   'Extract the signed bit, exponent, and significand from the 1st float value'     *
!                                                                                    *
!*************************************************************************************

unpack1:
    set     SBIT_MASK, %masks_r             ! 'extract 1st float\'s sign bit'
    and     %i0, %masks_r, %sbit1_r
    srl     %sbit1_r, MV_SIGN, %sbit1_r     ! 'move sign bit to rightmost bit for comparison'
    
    set     EXP_MASK, %masks_r              ! 'store mask value to use for exponent extraction'
    and     %i0, %masks_r, %exp1_r          ! 'extract 1st float\'s exponent'

    set     SIG_MASK, %masks_r              ! 'store mask value to use for significand extraction'
    and     %i0, %masks_r, %sig1_r          ! 'extract 1st float\'s significand'
    
    
!*************************************************************************************
!                                                                                    *
!   'Add back the hidden bit to 1st float\'s significand'                            *
!                                                                                    *
!*************************************************************************************

set1:
    set     IMP_MASK, %masks_r          ! 'store the mask to be used to add back implicit 1'
    or      %sig1_r, %masks_r, %sig1_r  ! 'put back implicit 1 in 1st floats significand'


!*************************************************************************************
!                                                                                    *
!   'Extract the signed bit, exponent, and significand from the 2nd float value'     *
!                                                                                    *
!*************************************************************************************
    
unpack2:
    set     SBIT_MASK, %masks_r             ! 'extract 2nd float\'s sign bit'
    and     %i1, %masks_r, %sbit2_r         ! 'extract 2nd float\'s sign bit'
    srl     %sbit2_r, MV_SIGN, %sbit2_r     ! 'move sign bit to rightmost bit for comparison'
    
    set     EXP_MASK, %masks_r              ! 'store mask value to use for exponent extraction'
    and     %i1, %masks_r, %exp2_r          ! 'extract 2nd float\'s exponent'

    set     SIG_MASK, %masks_r              ! 'store mask value to use for significand extraction'
    and     %i1, %masks_r, %sig2_r          ! 'extract 2nd float\'s significand'
    

!*************************************************************************************
!                                                                                    *
!   'Add back the hidden bit to 2nd float\'s significand'                            *
!                                                                                    *
!*************************************************************************************

set2:   
    set     IMP_MASK, %masks_r
    or      %sig2_r, %masks_r, %sig2_r      ! 'put back implicit 1 in 2nd float\'s significand'
    
    
!*************************************************************************************
!                                                                                    *
!   'Shift exponents to the right 23 bits to make it easier to get the difference'   *
!   'and use the difference as the number to add to the lower exponent'              *
!                                                                                    *
!*************************************************************************************

shiftExp:
    srl     %exp1_r, SHFT_EXP, %exp1_r      ! 'shift exponents right 23 bits for comparing'
    srl     %exp2_r, SHFT_EXP, %exp2_r
    

!*************************************************************************************
!                                                                                    *
!   'Compare exponents to see if they are equal or to see which one is greater'      *
!                                                                                    *
!*************************************************************************************  
    
cmpExp: 
    cmp     %exp1_r, %exp2_r                ! 'if exponents are equal, add significands'
    be      addSigs
    nop
    
    cmp     %exp1_r, %exp2_r                ! 'if exp 1 > exp 2, subtract exp 2 from exp 1'
    bg      expDif1
    nop
    
!*************************************************************************************
!                                                                                    *
!   'Get the difference between the 2 exponents to see how much to increase the'     *
!   'smaller exponent by and then increase the smaller exponent by the difference.'  *
!   'Shift the significand of the smaller exponent to the right by the difference '  *
!                                                                                    *
!*************************************************************************************

    sub     %exp2_r, %exp1_r, %o3           ! 'exp 2 is bigger, subtract exp 1 from exp 2'
    add     %exp1_r, %o3, %exp1_r           ! 'increase exp 1 by the difference'
    
    srl     %sig1_r, %o3, %sig1_r           ! 'shift significand 1 by the difference'
    
    ba      cmpSigns                        ! 'add significands'
    nop

expDif1:
    sub     %exp1_r, %exp2_r, %o3           ! 'exp 1 is bigger, subtract exp 2 from exp 1'
    add     %exp2_r, %o3, %exp2_r           ! 'increase exp 2 by the difference'
    
    srl     %sig2_r, %o3, %sig2_r           ! 'shift significand 2 by the difference'
    

!*************************************************************************************
!                                                                                    *
!   'Check to see if signs of floats are different'                                  *
!                                                                                    *
!*************************************************************************************
    
cmpSigns:
    cmp     %sbit1_r, %sbit2_r              ! 'check if signed bits are different'
    bne     handleNegation                  ! 'if one is pos and one neg, negate the neg'
    nop
    
    ba      addSigs
    nop
    
!*************************************************************************************
!                                                                                    *
!   'Compare the signed bits. If one is negative, negate it '                        *
!                                                                                    *
!*************************************************************************************
    
handleNegation: 
    cmp     %sig1_r, %sig2_r                ! 'at this point, if signs are same, result is zero'
    be      resultZero
    nop
    
    cmp     %sbit1_r, %sbit2_r
    bg      negate1                         ! 'if signed bit 1 is negative, negate its significand'
    nop
    
    cmp     %sbit1_r, %sbit2_r
    bl      negate2                         ! 'if signed bit 2 is negative, negate its significand'
    nop
    
    ba      addSigs2                        ! 'add the significands'
    nop
    
negate1:
    sub     %g0, %sig1_r, %sig1_r           ! 'negate the 1st significand'
    ba      addSigs2
    nop
    
negate2:
    sub     %g0, %sig2_r, %sig2_r           ! 'negate the 2nd significand'
    ba      addSigs2
    nop
    
    
!*************************************************************************************
!                                                                                    *
!   'Add Significands when they both have the same sign '                            *
!                                                                                    *
!*************************************************************************************
    
addSigs:
    cmp     %sbit1_r, %sbit2_r              ! 'if signs differ, negate the negative significand'
    bne     handleNegation
    nop
    
    add     %sig1_r, %sig2_r, %result_r     ! 'add significands'
    
    set     CARRY_MASK, %masks_r            ! 'check if there is a carry out bit'
    btst    %masks_r, %result_r             ! 'if there is, handle the carry bit'
    bne     posCarry
    nop
    
    ba      next
    nop
    
!*************************************************************************************
!                                                                                    *
!   'Add Significands when their signs differ'                                       *
!                                                                                    *
!*************************************************************************************
    
addSigs2:   
    add     %sig1_r, %sig2_r, %result_r     ! 'add significands if 1 is pos and one neg'
    
    cmp     %result_r, %g0                  ! 'if result is negative, negate the result'
    bl      negateResult
    nop
    
    cmp     %result_r, %g0                  ! 'if result is positive, normalize result'
    bg      next
    nop
    
    ba      next                            ! 'normalize'
    nop
    
    
!*************************************************************************************
!                                                                                    *
!   'Negate the result(absolute value) if the result is negative'                    *
!                                                                                    *
!*************************************************************************************
    
negateResult:
    sub     %g0, %result_r, %result_r       ! 'negate result'
    mov     SHFT_ONE, %sbit1_r              ! 'set sign bit to negative'
    
    
!*************************************************************************************
!                                                                                    *
!   'Check to see if the 24th bit is a 1. If it\'s not, shift the significand until' *
!   'it is.'                                                                         *
!                                                                                    *
!*************************************************************************************
    
checkResult:
    set     IMP_MASK, %masks_r
    btst    %masks_r, %result_r             ! 'check if 24th bit is a 1'
    be      shiftResult
    nop
    
    ba      repack                          ! 'start repacking the bits'
    nop
    
shiftResult:
    sll     %result_r, SHFT_ONE, %result_r  ! 'bit 24 is not 1, shift left'
    sub     %exp1_r, SHFT_ONE, %exp1_r      ! 'decrease exponent by 1'
    
    ba      checkResult                     ! 'loop to check 24th bit again'
    nop
    
    
!*************************************************************************************
!                                                                                    *
!   'If both floats are positive and there is a carry bit after adding, shift the'   *
!   'significand and add 1'                                                          *
!                                                                                    *
!*************************************************************************************
    
posCarry:
    srl     %result_r, SHFT_ONE, %result_r  ! 'shift significand and add 1 to exponent'
    add     %exp1_r, SHFT_ONE, %exp1_r
    ba      repack
    nop
    

!*************************************************************************************
!                                                                                    *
!   'Normalize Significand, if 24th bit is a 0, shift significand to the right.'     *
!   'Keep looping until there is a 1 in the 24th bit'                                *
!                                                                                    *
!*************************************************************************************  

next:
    set     IMP_MASK, %masks_r              ! 'set mask to check if 24th bit is a 1'
normalize:          
    btst    %masks_r, %result_r             ! 'check if 24th bit is a 1'
    be      shiftSigRight                   ! 'if there is a 0, shift sig right'
    nop
    
    ba      repack
    nop

shiftSigRight:
    srl     %result_r, SHFT_ONE, %result_r  ! 'shift sig right, then loop again to check if 24th bit is a 1'
    add     %exp1_r, SHFT_ONE, %exp1_r      ! 'add 1 to exponent since sig shifted right'
    ba      normalize
    nop
    
    
!*************************************************************************************
!                                                                                    *
!   'Repack result. Shift the exponent and signed bit back to the left again.'       *
!   'Add back in the signed bit and the exponent to teh significand to get result'   *
!                                                                                    *
!*************************************************************************************  
    
repack: 
    set     REPACK_MASK, %masks_r           ! 'mask to remove the extra bit in the significand'
    and     %result_r, %masks_r, %result_r  ! 'remove the extra bit'
    
    sll     %exp1_r, SHFT_EXP, %exp1_r      ! 'shift exponent back to left'
    sll     %sbit1_r, MV_SIGN, %sbit1_r     ! 'shift signed bit back to the left'
    
    or      %sbit1_r, %result_r, %result_r  ! 'put signed bit into the result'
    or      %exp1_r, %result_r, %result_r   ! 'put exponent into the result'
    
    ba      return
    nop
    
resultZero:                                 ! 'set result to zero'
    mov     %g0, %result_r
    
return:
    mov     %result_r, %i0                  ! 'put result in %i0 so it can be called from main'
    
    ret
    restore
