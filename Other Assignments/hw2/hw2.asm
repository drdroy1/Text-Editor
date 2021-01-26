# Homework #2
# name: Dhruba Roy
# sbuid: 11094686

# There should be no .data section in your homework!

.text

###############################
# Part 1 functions
###############################
recitationCount:
    move $t0, $a0 #Load arguments into temp registers.
	move $t1, $a1
	move $t2, $a2
	blez $t1, error
	li $t3, 11
	beq $t2, $t3, error # If rnum is 11
	li $t4, 8
	blt $t2, $t4, error #If rnum is less than 8
	li $t4, 14
	bgt $t2, $t4, error #If rnum is greater than 14
	li $t8, 0 #Counter for classSize
	li $t9, 0 #Counter for number of students
	rnumloop:
		beq $t8, $t1, samernum
		lb $t3, 14($t0)
		sll $t3, $t3, 28
		srl $t3, $t3, 28
		beq $t3, $t2, addtoclass
		adder:
		addi $t0, $t0, 16
		addi $t8, $t8, 1 #Adds 1 to counter at the end of the loop
		j rnumloop
		
	addtoclass:
		addi $t9, $t9, 1
		j adder
	error: 
		li $v0, -1
		j return
	
	samernum:
		move $v0, $t9
		j return
		
	return:
	jr $ra #return address

#Question 1b
aveGradePercentage:
    move $t0, $a0
    move $t1, $a1
    li $t2, 0
    mtc1 $t2, $f3
    li $t7, 0 # No. of students
    li $t8, 0 #Counter for loop
    li $t9, 12 #Where loop should stop
    avgLoop:
    	beq $t8, $t9, avgFloat #Will go to this 
    	lw $t3, 0($t0)
    	add $t7, $t3, $t7 #Number of students
    	lw $t4, 0($t1)
    	mtc1 $t3, $f0
    	mtc1 $t4, $f1
    	bltz $t3, error2
    	bltz $t4, error2
    	cvt.s.w $f0, $f0 #Converts the pulled out histogram value to float
    	mul.s $f2, $f0, $f1 #Multiplies the students by the grade value
    	add.s $f3, $f3, $f2 #Adds the total to a register f3
    	addi $t0, $t0, 4 #Moves up a word histogram
    	addi $t1, $t1, 4 #Moves up a word in gradepoint
    	addi $t8, $t8, 1 #Adds to counter
    	j avgLoop
    error2: 
		li $t8, -1
     	mtc1 $t8, $f0
     	cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		j return2
	avgFloat:
		mfc1 $t2, $f3
		beqz $t2, error2
		mtc1 $t7, $f4 #Turns students into float
		cvt.s.w $f4, $f4
		div.s $f5, $f3, $f4
		mfc1 $v0, $f5
		j return2
	return2:
		jr $ra

#Question 1c
favtopicPercentage:
	move $t0, $a0
	move $t1, $a1 #What percentage will be divided by 
	move $t2, $a2
	blez $t1, error3
	li $t3, 1
	li $t4, 15 	
	blt $t2, $t3, error3
	bgt $t2, $t4, error3
	li $t3, 0
	li $t7, 0 #Counter for percentage
	li $s1, 4
	favTopicLoop:
		li $s0, 0
		beq $t3, $t1, percentage
		lb $t4, 14($t0)
		sll $t4, $t4, 24
		srl $t4, $t4, 28 #Retrieve Favtopics from struct
		li $t5, 2
		move $t2, $a2
			binconverter: #Goes through to check whether any one matches up
				beqz $t4, cont
				andi $t8, $t2, 0x1
				andi $t9, $t4, 0x1
				and $t8, $t8, $t9
				srl $t2, $t2, 1
				srl $t4, $t4, 1
				beq $t8, 1, sametopic #Compare first and if they are equal check if they are both 1
				j binconverter
		
	cont:
		addi $t0, $t0, 16
		addi $t3, $t3, 1
		j favTopicLoop
   	sametopic: #If they are both the same one position then it will add 1 to the counter
		addi $t7, $t7, 1
		j cont
     error3: 
     	li $t8, -1
     	mtc1 $t8, $f0
     	cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		j return3
	
	percentage:
		mtc1 $t7, $f0
		cvt.s.w $f0,$f0
		mtc1 $t1, $f1 
		cvt.s.w $f1,$f1
		div.s $f2, $f0, $f1 #Divide to get percentage
		mfc1 $v0, $f2
		j return3
	return3:
	jr $ra

#Question 1d
findFavtopic:
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s6, 24($sp)
	
    move $s0, $a0
	move $s1, $a1 #What percentage will be divided by 
	move $s2, $a2
	blez $s1, error4
	li $t3, 1
	li $t4, 15 	
	blt $s2, $t3, error4
	bgt $s2, $t4, error4
    beqz $s2, error4
    li $t6, 0
    li $t7, 0
    li $t8, 0
    li $t9, 0 #These four will be the counters for the fave topics
    li $s7, 4
    favTopicLoop2:
		beq $s6, $s7, checkgreater
		lb $s3, 14($s0)
		sll $s3, $s3, 24
		srl $s3, $s3, 28 #Retrieve Favtopics from struct
		li $t2, 1
		li $t3, 2 #Used to divide
		li $t4, 3
		li $t5, 4
		li $s4, 0 #Counter for binconverter
		move $s2, $a2
		move $s1, $a1
			binconverter2: #Goes through to check whether any one matches up
				beq $s4, $t5, cont2
				andi $t0, $s2, 0x1
				andi $t1, $s3, 0x1
				and $t0, $t0, $t1
				srl $s2, $s2, 1
				srl $s3, $s3, 1
				addi $s4, $s4, 1
				beq $t0, 1, checkcounter #Compare first and if they are equal check if they are both 1
				j binconverter2
				checkcounter:
					beq $s4, $t2, datapaths
					beq $s4, $t3, digitallogic
					beq $s4, $t4, booleanlogic
					beq $s4, $t5, mips

	mips:
		addi $t9, $t9, 1
		j binconverter2
	booleanlogic:
		addi $t8, $t8, 1
		j binconverter2
	digitallogic:
		addi $t7, $t7, 1
		j binconverter2
	datapaths:
		addi $t6, $t6, 1
		j binconverter2
	cont2:
		addi $s0, $s0, 16
		addi $s6, $s6, 1
		j favTopicLoop2
	checkgreater: #Check which one is greater
		bge $t9, $t8, mipsgreater #If t9 greater than t8
		bge $t8, $t7, boolgreater #If t8, greater than t7
		bge $t7, $t6, digigreater #If t7 greater than t6
	datagreater:
		addi $v0, $0, 1
		j return4
	mipsgreater:
		bge $t9, $t7, mipsgreater2
		j digigreater
	mipsgreater2:
		bge $t9, $t6, mipsgreater3
		j datagreater
	mipsgreater3:
		addi $v0, $0, 8
		j return4
		
	boolgreater:
		bge $t8, $t6, boolgreater2
		j datagreater
		
	boolgreater2:
		addi $v0, $0, 4
		j return4
		
	digigreater:
		blt $t7, $t6, datagreater
		addi $v0, $0, 2
		j return4
		
    error4: 
		li $v0, -1
		j return4
	
    return4:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra


###############################
# Part 2 functions
###############################

twoFavtopics:
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
    move $t0, $a0
    move $t1, $a1
    blez $t1, error5
    li $a2, 15
    jal findFavtopic
    li $t2, 1
    li $t3, 2
    li $t4, 4
    li $t5, 8
    move $s0, $v0
    beq $t2, $v0, first
    beq $t3, $v0, second
    beq $t4, $v0, third
    beq $t5, $v0, fourth
    first:
  		li $a2, 14
    	jal findFavtopic
    	j setargs
    second:
    	li $a2, 13
    	jal findFavtopic
    	j setargs
    third:
    	li $a2, 11
   		jal findFavtopic
   		j setargs
    fourth:
   		li $a2, 7
    	jal findFavtopic
    	j setargs
    error5:
		li $v0, -1
		li $v1, -1
		j return5
	setargs:
	move $v1, $v0
    move $v0, $s0
    j return5
   	return5:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra


calcAveClassGrade:
    addi $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)	
	sw $s3, 16($sp)
	sw $s5, 20($sp)
		
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	blez $s1, error6
	
	li $t0, 0
	resethist:
		beq $t0, 12, histprep
		sw $0, ($s2)
		addi $s2, $s2, 4
		addi $t0, $t0, 1
		j resethist
		
	histprep:
	li $s5, 0
	move $s2, $a2
	
	histloop:
		beq $s5, $s1, calcGradePercentage
		lh $a0, 12($s0)
		jal getGradeIndex
		beq $v0, -1, error6
		sll $v0, $v0, 2
		add $t1, $v0, $s2
		lw $t2, ($t1)
		addi $t2, $t2, 1
		sw $t2, ($t1)
		addi $s0, $s0, 16
		addi $s5, $s5, 1
		j histloop
	
	error6: 
     	li $t9, -1
     	mtc1 $t9, $f0
     	cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		j return6
	
	calcGradePercentage:
	move $a1, $s3
	move $a0, $s2
	jal aveGradePercentage
	
	return6:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	jr $ra


updateGrades:
    addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)	
	sw $s3, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	
	blez $s2, error7
	lw $t0, ($s2)
	li $t1, 1
	addi $t2, $s2, 4
	percentileerror:
		beq $t1, 12, perrorend
		lw $t3, 0($t2)
		bgt $t3, $t0, error7
		move $t0, $t3
		addi $t2, $t2, 4
		addi $t1, $t1, 1
		bne $t1, 11, percentileerror
		beq $t3, 0, error7
		j percentileerror
		
	perrorend:
	li $s3, 0
	gradeloop:
		beq $s3, $s1, success7
		lw $t0, 8($s0)
		mtc1 $t0, $f0
		cvt.s.w $f0 $f0
		li $t1, 0
		move $t2, $s2
		percentileloop:
			beq $t1, 12, continuegradeloop
			lw $t3, ($t2)
			blt $t0, $t3, continuepercentile
			setgrade:
			move $a0, $t1
			jal getGrade
			sh $v0, 12($s0)
			j continuegradeloop
			continuepercentile:
			addi $t2, $t2, 4
			addi $t1, $t1, 1
			j percentileloop
		continuegradeloop:
		addi $s0, $s0, 16
		addi $s3, $s3, 1
		j gradeloop
		
	error7:
		li $v0, -1
		j return7

	success7:
	li $v0, 0
	
	return7:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

###############################
# Part 3 functions
###############################

find_cheaters:
     addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)	
	sw $s3, 16($sp)
		
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
    
    blez $s1, error8
    blez $s2, error8
    
    cheaterloop:
    
    
    error8:
		li $v0, -1
		li $v1, -1
		j return8
    
    return8:
    lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	lw $s3, 16($sp)
	addi $sp, $sp, 20
    
	jr $ra

