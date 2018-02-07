#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2017 University of Alberta
# Copyright 2017 Kristen Newbury
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------
# Lab- findLive
#
# Author: Kristen Newbury
# Date: June 9 2017
#
# Adapted from:
# Control Flow Lab - Student Testbed
# Author: Taylor Lloyd
# Date: July 19, 2012
#
#
#-------------------------------
.data
.align 2
binary:   #These absolutely MUST be the first two data defined, for jump correction
.space 2052
noFileStr:
.asciiz "Couldn't open specified file.\n"
format:
.asciiz "\n"
space:
.asciiz " "
liveMessage:
.asciiz "The live registers: "
zero:
.asciiz "$0  "
at:
.asciiz "$at "
v0:
.asciiz "$v0 "
v1:
.asciiz "$v1 "
a0:
.asciiz "$a0 "
a1:
.asciiz "$a1 "
a2:
.asciiz "$a2 "
a3:
.asciiz "$a3 "
t0:
.asciiz "$t0 "
t1:
.asciiz "$t1 "
t2:
.asciiz "$t2 "
t3:
.asciiz "$t3 "
t4:
.asciiz "$t4 "
t5:
.asciiz "$t5 "
t6:
.asciiz "$t6 "
t7:
.asciiz "$t7 "
s0:
.asciiz "$s0 "
s1:
.asciiz "$s1 "
s2:
.asciiz "$s2 "
s3:
.asciiz "$s3 "
s4:
.asciiz "$s4 "
s5:
.asciiz "$s5 "
s6:
.asciiz "$s6 "
s7:
.asciiz "$s7 "
t8:
.asciiz "$t8 "
t9:
.asciiz "$t9 "

.text
main:

lw      $a0 4($a1)  # Put the filename pointer into $a0
li      $a1 0       # Read Only
li      $a2 0       # No Mode Specified
li      $v0 13      # Open File

syscall
bltz    $v0 main_err    # Negative means open failed

move    $a0 $v0     # point at open file
la      $a1 binary  # write into my binary space
li      $a2 2048    # read a file of at max 2kb
li      $v0 14      # Read File Syscall
syscall
la      $t0 binary
add     $t0 $t0 $v0 # point to end of binary space

li      $t1 0xFFFFFFFF  # place ending sentinel
sw      $t1 0($t0)

# fix all jump instructions
la      $t0 binary  # point at start of instructions
move    $t1 $t0
main_jumpFixLoop:
    lw      $t2 0($t0)
    srl     $t3 $t2 26  # primary opCode
    li      $t4 2       # 2 is the jump opcode
    beq     $t3 $t4 main_jumpFix
    li      $t4 3       # 3 is the jal opcode
    beq     $t3 $t4 main_jumpFix
    j       main_jfIncrem
    main_jumpFix:
    #Replace upper 10 bits of jump with binary address
    li      $t3 0xFC000FFF  # bitmask
    and     $t2 $t2 $t3     # clear bits
    la      $t4 binary
    srl     $t4 $t4 2       # align to instruction
    not     $t3 $t3
    and     $t4 $t4 $t3     # only get bits in field
    or      $t2 $t2 $t4     # combine back on the binary address
    addi    $t2 $t2 -9      # adjust for the first 9 lines
                            # when spim loads a program
    sw      $t2 0($t0)      # place the modified instruction
    main_jfIncrem:
    addi    $t0 $t0 4
    li      $t4 -1
    bne     $t2 $t4 main_jumpFixLoop

la      $a0 binary  #prepare pointers for assignment
jal     findLive
move    $a0 $v0 
jal     writeArray

j       main_done

main_err:
la      $a0 noFileStr
li      $v0 4
syscall
main_done:

li      $v0 10
syscall


#-----------------------------------------------------------
# writeArray writes out the live registers
# that have been gathered in a nice format
#
# input:
# $a0: the array to write out
#-----------------------------------------------------------

writeArray:

addi    $sp $sp -24
sw      $ra 0($sp)
sw      $s0 4($sp)
sw      $s1 8($sp)
sw      $s2 12($sp)
sw      $s3 16($sp)
sw      $s4 20($sp)

move    $s0 $a0
li      $s1 0xFFFFFFFF      # sentinel to look for, for end of array

writeArrayLoop:
    lw      $s2 0($s0)
    beq     $s2 $s1 writeArrayDone  # if array entry == -1 : done
    addi    $s0 $s0 4
    la      $a0 liveMessage     # print the generic live message
                                # for each entry in the array
    li      $v0 4
    syscall

    # Print the contents of the vector lists

    #iterate over each bit and print as needed
    li      $t2, 0                  # shamt = 0
    li      $t3, 32
    vLPbits:                        # while True
        beq     $t2, $t3, vLPbend   # if shamt = 32: break
        srlv    $t4, $s2, $t2       # bit = (word >> shamt) AND 0x1
        andi    $t4, $t4, 0x1
        beq     $t4, $zero, vLPbcont # if bit == 1
        la      $t4, zero
        addi    $t5, $zero, 5
        mult    $t5, $t2
        mflo    $t5
        add     $a0, $t4, $t5
        li      $v0, 4
        syscall
        la      $a0 space
        li      $v0 4
        syscall
        vLPbcont:
        addi    $t2, $t2, 1         # shamt = shamt + 1
        j       vLPbits
    vLPbend:
    la      $a0 format      #newline
    li      $v0 4
    syscall
    j       writeArrayLoop
writeArrayDone:
lw      $ra 0($sp)
lw      $s0 4($sp)
lw      $s1 8($sp)
lw      $s2 12($sp)
lw      $s3 16($sp)
lw      $s4 20($sp)
addi    $sp $sp 24
jr      $ra

#####---------  end of common file  ---------#####


.data
    visited: .align 4
            .space 1000         #number of instruction*number of functions*word 
    allLiveRegs: .align 4
                .space 100      #number of functions*word (Each word has an jal code block)
    liveRegs: .align 4
                .space 4             #word
    DeadStack: .align 4
                .space 4000         #like visited(each instruction is branch)
    beginningAddressArg: .align 4
                        .space 4

.text
findLive:
    addi $sp, $sp, -36     #storing registers
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)

    la $s0, beginningAddressArg
    sw $a0, 0($s0)               # $s0 -> beginningAddressArg - $a0

    li $s1, 0                    # ResultIndex = 0

    la $s4, allLiveRegs
    la $s5, liveRegs
    la $s6, DeadStack

    #getting all the jal instructions
    Loop:
        #$s0 - instruction position
        lw $t0, 0($s0)              #has the address of instruction
        lw $t1, 0($t0)               #has instruction

        beq $t1, 0xFFFFFFFF, END     #Reaching end of program (no more JAL)
        srl $t2, $t1, 26             #getting the opcode
        bne $t2, 0x0003, NextIntr     #if not jal dont go through

        addi $s3, $zero, 0             #deadStackIndex = 0
        move $a1, $s3                   #sending argument to gatherlive
        addi $a2, $t0, 4            #address value after the jump
        jal gatherLiveRegs             

        sll $s1, $s1, 2             #resultindex*4
        add $s4, $s4, $s1             #allLiveRegs + resultIndex - allLiveRegs[resultIndex]
        sw $s5, 0($s4)                 #allLiveRegs[resultIndex] = liveRegs 

        addi $s1, $s1, 1             #resultIndex ++

        li $s6, 0
        sw $s6, 0($s5)

        add $s5, $zero, $zero

    NextIntr:
        addi $s0, $s0, 4             #next instruction
        j Loop

END:
    sll $t1, $t1, 2             #resultindex*4
    add $t4, $t4, $t1             #allLiveRegs + resultIndex = allLiveRegs[resultIndex]
    li $t6, 0
    sw $t6, 0($t4)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    addi $sp, $sp, 36

    jr $ra

gatherLiveRegs:
#a1, has deadStackIndex
#$a2, current instruction(after jal)

    move $t0, $a2         #address of the current position instruction
                          #after the jal

    lw $t3, 0($a2)        #instruction of the current instruction

    andi $s0, $t3, 0x001FFFFF
    bne $s0, 0x0008, END    #checking if we reached jr $ra(End of code block)

    move $t1, $a1         #deadStackIndex

    # la $s3, liveRegs        #LiveRegs will have all the registers that are live
    # la $s2, DeadStack       #DeadStack 

    sub $t2, $t0, $a0     #index = address-beginningAddress
    lw $t3, 0($t0)         #instruction = load instruction from address

    la $t4, visited     #Visited
    add $t4, $t4, $t2     #visited[index]

    li $t5, 1              #~~~~~~
    beq $t4, $t5, Term     #visited[index] == 1
    srl $t5, $t3, 26        
    beq $t5, 0x0000, Term     #instruction == jr $ra

    li $t5, 1
    sw $t5, 0($t4)             #visited[index] = 1

    # move $a1, $t0#contains the instruction address
    # move $a2, # contains the deadstackIndex

    jal updateLiveRegs

Targets:

    srl $t9, $t3, 26    #OpCode current instruction

    #if( instruction == jump )
    #elif( instruction == branch )

    beq $t9, 0x0001, calcTarget
    beq $t9, 0x0004, calcTarget
    beq $t9, 0x0005, calcTarget
    beq $t9, 0x0006, calcTarget
    beq $t9, 0x0008, calcTarget
    beq $t9, 0x0002, jumpCalcTarget

jumpCalcTarget:

    andi $t7, $t3, 0x03FFFFFF   #26 bits of jump
    addi $s0, $t3, 4            #PC+4
    sll $t7, $t7, 2             # shift by 2

    andi $t7, $t7, 0xF0000000   #get the 4 MSB
    and $t3, $t7, $s0           #concatenate the 4 MSB with PC+4

    move $a1, $t3
    move $a2, $t1
    
    jal gatherLiveRegs

    li $t5, 0
    sw $t5, 0($t4)

    jr $ra


calcTarget:
    li $s5, 1
    sll $t7, $t3, 16    #has the lower 16 bit of branch
    sra $t7, $t7, 16

    sll $t7, $t7, 2

    addi $s0, $t3, 4    #PC+4

    add $t6, $s0, $t7   #PC+4 + signExtended

    addi $t1, $t1, 1

    #cloneTopOfStack
    lw $t5, 0($s7) 
    addi $s7, $s7, 4
    sw $t5, 0($s7)

    move $a1, $t3
    move $a2, $t1

    jal gatherLiveRegs

    addi $t1, $t1, -1

END:
    addi $t3, $t3, 4
    move $a1, $t3
    move $a2, $t1

    jal gatherLiveRegs

    li $t5, 0
    sw $t5, 0($t4)

    jr $ra


Term:
    li $t5, 0             #visited[index] = 0    
    sw  $t5, 0($t4)
    jr $ra

updateLiveRegs:
    lw $t6, 0($a2)      #current word
    move $t0, $a1       #deadStackIndex

    la $s2, DeadStack
    sll $t0, $t0, 2     #deadStackIndex*4
    add $s2, $s2, $t0   #DeadStack[deadStackIndex]

    srl $t7, $t6, 26    #OpCode current instruction

    beq $t7, 0x0001, branch         #bgez/bltz
    beq $t7, 0x0004, branch         #beq
    beq $t7, 0x0005, branch         #bne
    beq $t7, 0x0006, branch         #blez
    beq $t7, 0x0007, branch         #bgtz

    beq $t7, 0x0000, RTYPE          #RTYPE
    
    bne $t7, 0x0000, ITYPE    #ITYPE


RTYPE:
    sll $t5, $t6, 6     #rs
    srl $t5, $t5, 26    #rs
    
    sll $t8, $t6, 11    #rt
    srl $t8, $t8, 26    #rt

    
    #li $s6, 1           #RTYPE only one have two live registers: boolean
    
    sll $t9, $t6, 16    #rd (Dead)
    srl $t9, $t9, 26    #rd

    #liveness
    li $t4, 1

    #checking if dead rs
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t5   #shift the 1 to the rs position
    and $t4, $s7, $t4   #if return 1 then it is been marked dead
    srl $t4, $t4, $t5   #put it back to position 0 so that can compare
    bne $t4, 1, makeLive1
    j back

makeLive1:
    li $t4, 1
    la $s6, liveRegs    #loading address of liveRegs

    lw $s5, 0($s6)      #store the liveRegs in s5
    sll $t4, $t4, $t5   #shift the t4 by the position you want to make 1
    or $s5, $s5, $t4    #or it to the s5 liveRegs word
    sw $s5, 0($s6)      #store it back to the s5
    j back

back:

    li $t4, 1
    #checking if dead rt
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t8   #shift the 1 to the rs position
    and $t4, $s7, $t4   #if return 1 then it is been marked dead
    srl $t4, $t4, $t8   #put it back to position 0 so that can compare
    bne $t4, 1, makeLive2 
    j back2

makeLive2:
    li $t4, 1
    la $s6, liveRegs    #loading address of liveRegs

    lw $s5, 0($s6)      #store the liveRegs in s5
    sll $t4, $t4, $t8   #shift the t4 by the position you want to make 1
    or $s5, $s5, $t4    #or it to the s5 liveRegs word
    sw $s5, 0($s6)      #store it back to the s5
    j back2

back2:

    li $t4, 1
    #Making it dead rd
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t9   #shift 1 to the position you want it to be 1
    or $s7, $s7, $t4    #or it with the deadStack load word
    sw $s7, 0($s2)      #store it in the deadStack

    j continue

ITYPE:
    
    sll $t5, $t6, 6     #rs (live)
    srl $t5, $t5, 26    #rs
    
    sll $t9, $t6, 11    #rt (Dead)
    srl $t9, $t9, 26    #rt
    #li $s6, 0           #for not having second register
    
    li $t4, 1
    #checking if dead rt
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t5   #shift the 1 to the rs position
    and $t4, $s7, $t4   #if return 1 then it is been marked dead
    srl $t4, $t4, $t5   #put it back to position 0 so that can compare
    bne $t4, 1, makeLive3 
    j back3

#making it alive
makeLive3:
    li $t4, 1
    la $s6, liveRegs    #loading address of liveRegs

    lw $s5, 0($s6)      #store the liveRegs in s5
    sll $t4, $t4, $t5   #shift the t4 by the position you want to make 1
    or $s5, $s5, $t4    #or it to the s5 liveRegs word
    sw $s5, 0($s6)      #store it back to the s5
    j back3

back3:
    li $t4, 1
    #Making it dead rd
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t9   #shift 1 to the position you want it to be 1
    or $s7, $s7, $t4    #or it with the deadStack load word
    sw $s7, 0($s2)      #store it in the deadStack

    j continue

branch:

    sll $t5, $t6, 6    #rs (live)
    srl $t5, $t5, 26

    sll $t8, $t6, 11
    srl $t8, $t8, 26   #rt (live)

    li $t4, 1
    #checking if dead rt
    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t6   #shift the 1 to the rs position
    and $t4, $s7, $t4   #if return 1 then it is been marked dead
    srl $t4, $t4, $t6   #put it back to position 0 so that can compare
    bne $t4, 1, makeLive4 
    j back4

#making it alive
makeLive4:
    li $t4, 1
    la $s6, liveRegs    #loading address of liveRegs

    lw $s5, 0($s6)      #store the liveRegs in s5
    sll $t4, $t4, $t5   #shift the t4 by the position you want to make 1
    or $s5, $s5, $t4    #or it to the s5 liveRegs word
    sw $s5, 0($s6)      #store it back to the s5
    j back4

back4:

    lw $s7, 0($s2)      #load the deadStack word
    sll $t4, $t4, $t6   #shift the 1 to the rs position
    and $t4, $s7, $t4   #if return 1 then it is been marked dead
    srl $t4, $t4, $t6   #put it back to position 0 so that can compare
    bne $t4, 1, makeLive3 
    j continue

#making it alive
makeLive3:
    li $t4, 1
    la $s6, liveRegs    #loading address of liveRegs

    lw $s5, 0($s6)      #store the liveRegs in s5
    sll $t4, $t4, $t5   #shift the t4 by the position you want to make 1
    or $s5, $s5, $t4    #or it to the s5 liveRegs word
    sw $s5, 0($s6)      #store it back to the s5

    j continue

continue:
    j Targets
