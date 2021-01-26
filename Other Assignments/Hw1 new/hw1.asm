# Homework 1
# Name: DHRUBA ROY
# Net ID: DHROY
# SBU ID: 111094686

.data
# include the file with the test case information
.include "Struct1.asm"  # change this line to test with other inputs

.align 2  # word alignment 

numargs: .word 0
AddressOfNetId: .word 0
AddressOfId: .word 0
AddressOfGrade: .word 0
AddressOfRecitation: .word 0
AddressOfFavTopics: .word 0
AddressOfPercentile: .word 0

err_string: .asciiz "ERROR\n"

newline: .asciiz "\n"

float0: .float 0.0
float100: .float 100.0

plusstring: .asciiz "+"
minusstring: .asciiz "-"

updated_NetId: .asciiz "Updated NetId\n"
updated_Id: .asciiz "Updated Id\n"
updated_Grade: .asciiz "Updated Grade\n"
updated_Recitation: .asciiz "Updated Recitation\n"
updated_FavTopics: .asciiz "Updated FavTopics\n"
updated_Percentile: .asciiz "Updated Percentile\n"
unchanged_Percentile: .asciiz "Unchanged Percentile\n"
unchanged_NetId: .asciiz "Unchanged NetId\n"
unchanged_Id: .asciiz "Unchanged Id\n"
unchanged_Grade: .asciiz "Unchanged Grade\n"
unchanged_Recitation: .asciiz "Unchanged Recitation\n"
unchanged_FavTopics:  .asciiz "Unchanged FavTopics\n"

# Any new labels in the .data section should go below this 

# Helper macro for accessing command line arguments via Label
.macro load_args
    sw $a0, numargs
    lw $t0, 0($a1)
    sw $t0, AddressOfNetId
    lw $t0, 4($a1)
    sw $t0, AddressOfId
    lw $t0, 8($a1)
    sw $t0, AddressOfGrade
    lw $t0, 12($a1)
    sw $t0, AddressOfRecitation
    lw $t0, 16($a1)
    sw $t0, AddressOfFavTopics
    lw $t0, 20($a1)
    sw $t0, AddressOfPercentile
.end_macro

.globl main
.text
main:
    load_args()     # Only do this once
    # Your .text code goes below here
	li $t0, 6
	beq $t0, $a0, Equal #If t0 = 6 and $a0 = numargs move to equal
	li $v0, 4 # Syscall for printing the Error String
	la $a0, err_string
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
	
Equal:
	lw $a0, AddressOfId
	li $v0, 84 #atoi to check AddressOfId
	syscall
	move $s2, $v0 #Moves the newly converted ID to s2
	beqz $v1, Checkrec # Checks  to see if it is equal to 0 to see if success
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Checkrec: #Recitation check
	lw $a0, AddressOfRecitation 
	li $v0, 84
	syscall
	move $s3, $v0 #Moves the newly converted recitation number to s3
	beqz $v1, Checkperc # Checks  to see if it is equal to 0 to see if success
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Checkperc: #Percentile Check
	lw $a0, AddressOfPercentile
	li $v0, 85
	syscall
	move $s4, $v0 #Moves the newly converted percentage to s4
	beqz $v1, Validate1 # Checks  to see if it is equal to 0 to see if success
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Validate1: #Checks ID 
	li $t1, 999999999
	bltz $s2, invalid
	ble $s2, $t1, Validate2
invalid: 
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Validate2:# Checks Grade
	lw $t0, AddressOfGrade #Loads Grade into t0
	lbu $s5, ($t0)	#Puts First Ascii String into a0
	lbu $s6, 1($t0)	#Puts First Ascii String into a0
	li $t1, 65
	li $t2, 70
	li $t3, 43
	li $t4, 45
	li $t5, 32
	blt $s5, $t1, Error
	bgt $s5, $t2, Error

	beq $s6, $t3, Validate3
	beq $s6, $t4, Validate3
	beq $s6, $t5, Validate3
Error:
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall	
Validate3: #Recitation must be 8-14
	li $t0, 8
	bge $s3, $t0, Validate3v2
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Validate3v2:
	li $t0, 14
	ble $s3, $t0, Validate3v3
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Validate3v3:
	li $t0, 11
	bne $s3, $t0, Validate4
	lw $a0, err_string
	li $v0, 4
	syscall
	li $v0, 10
	syscall
Validate4: #Uses bitwise operations to see if Favtopics is valid
	lw $t0, AddressOfFavTopics
	li $t1, 48 #Ascii Value for 0
	li $t2, 49 #Ascii Value for 1
Val4v1:
	lb $t3, 0($t0)
	blt $t3, $t1, Val4Error
	bgt $t3, $t2, Val4Error
Val4v2:
	lb $t4, 1($t0)
	blt $t4, $t1, Val4Error
	bgt $t4, $t2, Val4Error
Val4v3:
	lb $t5, 2($t0)
	blt $t5, $t1, Val4Error
	bgt $t5, $t2, Val4Error
Val4v4:
	lb $t6, 3($t0)
	blt $t6, $t1, Val4Error
	bgt $t6, $t2, Val4Error
j Validate5
Val4Error:
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
	
Validate5: #Checks Percentile
	la $t0, float0
	lw $t0, ($t0)
	la $t1, float100
	lw $t1, ($t1)
	bge $s4, $t0, Validate5v2 #Checks if greater than or equal to 0.0
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
Validate5v2:	
	ble $s4, $t1, Part2 #Checks if greater than or equal to 100.0
	la $a0, err_string # Prints Error String
	li $v0, 4
	syscall
	li $v0, 10	#Syscall for quitting the program
	syscall
	
Part2:
	la $s0, Student_Data
	lw $t0, 0($s0) #Sets ID into t0 for comparison
	beq $t0, $s2, SameId #Checks if Ids are same
	la $a0, updated_Id
	li $v0, 4
	syscall
	sw $s2, 0($s0)
	j Netid
SameId:
	la $a0, unchanged_Id
	li $v0, 4
	syscall
	j Newid
Newid:
	sw $s2, 0($s0)
	la $a0,updated_Id
  	li $v0,4
   	syscall
Netid:
	lw $t1, 4($s0) #t1 = netid from struct
	lw $t0, AddressOfNetId
	
checkloop:
	lb $t2, ($t0)
	lb $t3, ($t1)
	bne $t2, $t3, SameNetid
	beqz $t2, SameNetid
	beqz $t3, SameNetid
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	j checkloop
SameNetid:
	la $a0, unchanged_NetId
	li $v0, 4
	syscall
	j Percentile
NewNetid:
	la $s7, AddressOfNetId
	lw $s7, 0($s7)
	sw $s7, 4($s0)
	la $a0,updated_NetId
  	li $v0,4
   	syscall

Percentile:
	lw $t2, 8($s0) #t2 = Percentile
	beq $s4, $t2, SamePercentile
	j NewPercentile
SamePercentile:
	la $a0,unchanged_Percentile
    li $v0,4
    syscall
    j Grade
NewPercentile:
   sw $s4,8($s0)
   la $a0,updated_Percentile
   li $v0,4
   syscall
j Grade

Grade:
	lb $t3, 12($s0)
	lb $t4, 13($s0)
	bne $s5, $t3, NewGrade
	bne $s6, $t4, NewGrade
SameGrade:
	la $a0,unchanged_Grade
   li $v0,4
   syscall
	j Recitation
NewGrade:
   sb $s5, 12($s0)
   sb $s6, 13($s0)
   la $a0,updated_Grade
   li $v0,4
   syscall
   j Recitation
   
Recitation:
	lb $t6, 14($s0)
	andi $t6, $t6, 0x7
	beq $t6, $s3 ,SameRecitation
SameRecitation:
	la $a0,unchanged_Grade
   li $v0,4
   syscall
	j FavTopics
NewRecitation:
	
FavTopics:
	lb $t5, 14($s0)
	andi $t5, $t5, 0xf0
	lw $t8, AddressOfFavTopics
	beq $t5, $t8, SameTopics
SameTopics:
   la $a0, unchanged_FavTopics
   li $v0,4
   syscall
NewTopics:

li $t1, 0
print:
   lb $t0, ($s0)
   li $t2, 14
   li $v0,34
   syscall
   addi $t1,$t1,1
   addi $s0,$s0,1
   beq $t2,$t1, done
   j print
done:
	li $v0, 10
	syscall
