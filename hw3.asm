#Dhruba Roy
#ID: 111094686

##################################
# Part 1 - String Functions
##################################
#Part A
is_whitespace: #With this function we check if the character is whitespace or not
	li $t0, 0
	beq $t0, $a0, whitespacetrue #For null character 
	li $t0, 10
	beq $t0, $a0, whitespacetrue
	li $t0, 32
	beq $t0, $a0, whitespacetrue
	whitespacefalse:
	li $v0, 0
	j whitespacedone
	
	whitespacetrue:
	li $v0, 1
	j whitespacedone
	
	whitespacedone:
	jr $ra

#Part B
cmp_whitespace: #Must call whitespace for verifying two characters
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s0, $a0 #Save a0  because it will end up changing

	jal is_whitespace #First jump and link for the first a0
	move $s1, $v0
	
	#Next Part for checking second character
	move $a0, $a1 #This is where we change the value of a0 to jal again
	jal is_whitespace
	move $s2, $v0
	
	move $a0, $s0 #Returns original value to a0
	#Now check if each character is a whitespace
	beqz $s1, notwhitespace
	beqz $s2, notwhitespace
	li $v0, 1
	j whitespacetwodone
	
	notwhitespace:
	li $v0, 0
	j whitespacetwodone
	
	whitespacetwodone:
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra

#Part C
strcpy: #Copies n bytes from string src to dest if <= then nothing
	#Need loop to copy
	li $t0, 0 #Will be counter for loop
	ble $a0, $a1, strcpyfinish
	
	copyloop:
		beq $t0, $a2, strcpyfinish
		lbu $t1,($a0)
		sb $t1, ($a1)
		addi $t0, $t0, 1
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j copyloop
	strcpyfinish:
	jr $ra

#Part D
strlen: #Calculates length of string
	#Need stack because we are calling other fxns
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)

	li $s1, 0 #We want a saved register because when we jal a temp might change
	move $s0, $a0
	strlenloop: #Loop to count string
		#Check for whitespace first thing
		lbu $t0, 0($s0)
		move $a0, $t0
		jal is_whitespace			#Checks if character is whitespace
		li $t1, 1				
		beq $v0, $t1, strlenfinish		#If whitespace then done
		addi $s0, $s0, 1
		addi $s1, $s1, 1			# Add one to counter for no whitespace
		j strlenloop
	
	strlenfinish:
	move $v0, $s1	#length of string
	lw $s1, 12($sp)
	lw $s0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################
#Part E
set_state_color:
	li $t0, 1
	li $t1, 2 #Will use this for mode comparison
	beq $a2, $t0, highlightcolor # Check if category is 0 or 1
	
	defaultcolor: #Sets color from a1 into the default colors in struct
		srl $t2, $a1, 4 #Obtains Background color 
		sll $t3, $a1, 28
		srl $t3, $t3, 28 # Shifted 28 to left to get fg bits then 28 bits back for first 4 bits
		sll $t6, $t2, 4 # We will need to or this later but we need it in a format to or it so it wont change fg
		beqz $a3, defaultcolorboth
		beq $a3, $t0, defaultcolorfg
		beq $a3, $t1, defaultcolorbg
		defaultcolorfg: #Changes default color fg in struct
			move $t4, $a0 #We want to obtain values from #a0 but not change original
			lbu $t5, 0($t4) #Loads both default nibbles
			srl $t5, $t5, 4
			sll $t5, $t5, 4 #Erases original fg, turns into 0000
			or $t5, $t5, $t3 #This effectively changes the fg and leaves the bg alone 
			sb $t5, 0($t4) #Stores the new changed one into fg
		j setstatecolordone	
			
		defaultcolorbg: #Changes default color bg in struct
			move $t4, $a0 #We want to obtain values from #a0 but not change original
			lbu $t5, 0($t4) #Loads both default nibbles
			sll $t5, $t5, 28
			srl $t5, $t5, 28  #Erases original bg, turns into 0000 and leaves fg 
			or $t5, $t5, $t6 #This effectively changes the fg and leaves the bg alone 
			sb $t5, 0($t4) #Stores the new changed one into fg
		j setstatecolordone
			
		defaultcolorboth:  #Changes default color fg and bg in struct
			move $t4, $a0
			sb $a1, 0($t4)
			
		j setstatecolordone
			
	highlightcolor: #Sets color from a1 into the highlight colors in struct
		srl $t2, $a1, 4 #Obtains Background color 
		sll $t3, $a1, 28
		srl $t3, $t3, 28 # Shifted 28 to left to get fg bits then 28 bits back for first 4 bits
		sll $t6, $t2, 4 # We will need to or this later but we need it in a format to or it so it wont change fg
		beqz $a3, highlightcolorboth
		beq $a3, $t0, highlightcolorfg
		beq $a3, $t1, highlightcolorbg
		
		highlightcolorfg: #Changes highlight color fg  in struct
			move $t4, $a0 #We want to obtain values from #a0 but not change original
			lbu $t5, 1($t4) #Loads both default nibbles
			srl $t5, $t5, 4
			sll $t5, $t5, 4 #Erases original fg, turns into 0000
			or $t5, $t5, $t3 #This effectively changes the fg and leaves the bg alone 
			sb $t5, 1($t4) #Stores the new changed one into fg
		j setstatecolordone
		
		highlightcolorbg: #Changes highlight color bg in struct
			move $t4, $a0 #We want to obtain values from #a0 but not change original
			lbu $t5, 1($t4) #Loads both default nibbles
			sll $t5, $t5, 28
			srl $t5, $t5, 28  #Erases original bg, turns into 0000 and leaves fg 
			or $t5, $t5, $t6 #This effectively changes the fg and leaves the bg alone 
			sb $t5, 1($t4) #Stores the new changed one into fg
		j setstatecolordone
		
		highlightcolorboth: #Changes highlight color fg and bg in struct
			move $t4, $a0
			sb $a1, 1($t4)
		j setstatecolordone
		
	setstatecolordone:
	jr $ra
#Part F
save_char: #Change the Ascii Value in the MMIO Cell in the specified address
	#We must take the cursor values from the struct and use it to calculate the address
	li $t0, 160 #Each row is 160 bytes so you multiply x by this
	li $t1, 2 #Column is 2 bytes in size
	lbu $t2, 2($a0)  # cursor x
	lbu $t3, 3($a0)  # cursor y 
	mul $t4, $t2, $t0 # t4= cursor x * 160
	mul $t5, $t3, $t1 # t5 = cursor y * 2 
	add $t6, $t4, $t5 #t6 = t4 + t5
	addi $t6, $t6, 0xFFFF0000
	sb $a1, 0($t6)
	jr $ra
#Part G
reset:
	li $t0, 0  #Counter
	#Number of cells to reset is 80*25 = 2000, this will be where our counter stops
	li $t1, 2000
	lbu $t2, 0($a0)	#The default color from the struct aka the two nibbles
	addi $t3, $0, 0xFFFF0000 # We need to start with the first cell block when resetting so first address
	li $t4, 0 # This will be null in Ascii
	beqz $a1, colorzeroloop
	clearcolorloop:
		beq $t0, $t1, resetdone
		sb $t2, 1($t3) #Stores default color into Vt100 color block regardless of a1
		addi $t3, $t3, 2
		addi $t0, $t0, 1
		j clearcolorloop
	colorzeroloop:
		beq $t0, $t1, resetdone
		sb $t4, 0($t3) #Null set on the ascii value of color_only is 0 
		sb $t2, 1($t3) # #Stores default color into Vt100 color block regardless of a1
		addi $t3, $t3, 2
		addi $t0, $t0, 1
		j colorzeroloop
	resetdone:
	jr $ra
#Part H
clear_line:
	li $t0, 160 #Each row is 160 bytes so you multiply x by this
	li $t1, 2 #Column is 2 bytes in size
	move $t2, $a0  # cursor x
	move $t3, $a1  # cursor y 
	mul $t4, $t2, $t0 # t4= cursor x * 160
	mul $t5, $t3, $t1 # t5 = cursor y * 2 
	add $t6, $t4, $t5 # t6 = t4 + t5
	addi $t6, $t6, 0xFFFF0000 #Address of (x,y)
	
	move $t0, $a2 #Just to make sure a2 doesnt change for any reason
	li $t8, 80
	li $t9, 0 # Will be null character
	
	clearlineloop:
		beq $t3, $t8, clearlinedone
		sb $t9, 0($t6) #Sets null character on ascii
		sb $t0, 1($t6) #Sets color into VT100
		addi $t6, $t6, 2 # Moves up 2 in address
		addi $t3, $t3, 1 # We want the column value to go all the way to 80 to get all the cells
		j clearlineloop
	
	clearlinedone:
	jr $ra
#Part I
set_cursor:
	lbu $t1, 2($a0) #Loads current x
	lbu $t2, 3($a0) #Loads current y
	#We want the current address of the struct to reinvert colors
	li $t3, 160 #Each row is 160 bytes so you multiply x by this
	li $t4, 2 #Column is 2 bytes in size
	mul $t5, $t1, $t3 # t5= cursor x * 160
	mul $t6, $t2, $t4 # t6 = cursor y * 2 
	add $t7, $t5, $t6 # t7 = t5 + t6
	addi $t7, $t7, 0xFFFF0000 #Address of current (x,y)  in t7
	
	#New (x,y) address
	move $t1, $a1 #t1 = new x
	move $t2, $a2 #t2 = new y
	mul $t5, $t1, $t3 # t5= cursor x * 160
	mul $t6, $t2, $t4 # t6 = cursor y * 2 
	add $t8, $t5, $t6 # t8 = t5 + t6
	addi $t8, $t8, 0xFFFF0000 #Address of new (x,y)  in t8

	li $t9, 136 #We will xor this in order to flip the bits because it is 10001000 which is both of the bold bits
	beqz $a3, clearcursor
	j update
	clearcursor: #Invert the bold bits so you flip the first bit for fg and bg by using xor 
		lbu $t0, 1($t7)
		xor $t0, $t0, $t9
		sb $t0, 1($t7)
	update: #Runs regardless of initial and sets new x and y position
		sb $a1, 2($a0) #Sets new x position
		sb $a2, 3($a0) #Sets new y position
	set: #Inverts the color bit of the new position
		lbu $t0, 1($t8)
		xor $t0, $t0, $t9
		sb $t0, 1($t8)
	setcursorfinish:	
		jr $ra
#Part J
move_cursor:
	# Will call Set cursor so must implement stack
	addi $sp, $sp, -4
	sw $ra 0($sp)
	
	#Set Ascii Values
	li $t0, 104 #Ascii 104- h-left 
	li $t1, 106 #Ascii 106- j-Down
	li $t2, 107 #Ascii 107- k-Up
	li $t3, 108 #Ascii 108- l-Right 
	
	#Load Bytes from struct
	lbu $t4, 2($a0) # Current x in struct
	lbu $t5, 3($a0) # Current y in struct
	
	
	#Set boundaries - 24, 79
	li $t6, 24
	li $t7, 79
	
	beq $a1, $t0, left
	beq $a1, $t1, down
	beq $a1, $t2, up
	beq $a1, $t3, right
	j movecursordone
	left:
		beqz $t5, movecursordone
		addi $t5, $t5, -1
		j movecursor		
	down:
		beq $t4, $t6, movecursordone
		addi $t4, $t4, 1
		j movecursor				
	up:
		beqz $t4, movecursordone
		addi $t4, $t4, -1
		j movecursor		
	right:
		beq $t5, $t7, movecursordone
		addi $t5, $t5, 1
		j movecursor
				
	movecursor:
	#Time to Pass to set cursor
	move $a1, $t4 #Set a1 for set cursor to new x
	move $a2, $t5 #Set a2 for set cursor to new y
	li $a3, 0 #Set initial to 0 
	jal set_cursor
	
	movecursordone:
	lw $ra 0($sp)
	addi $sp, $sp, 4
	jr $ra
#Part K
mmio_streq:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)

	#Requires use of other fxns so must save to stack
	move $s0, $a0
	move $s1, $a1
	#Initialize counter
	mmioloop:
		lbu $t0, 0($s0) #First character of mmio
		lbu $t1, 0($s1) #First character of b
		bne $t0, $t1, notequal
		
		move $a0, $t0
		move $a1, $t1
		jal cmp_whitespace
		li $t2, 1
		beq $v0, $t2, checkifequal #If it encounters a whitespace, check if both were a whitespace and the same
		addi $s0, $s0, 2
		addi $1, $s1, 1
		j mmioloop	
		
		checkifequal:
			li $v0, 1
			j mmiofinish
			
	notequal:
		li $v0, 0
		j mmiofinish
	mmiofinish:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
##################################
# Part 3 - UI/UX Functions
##################################
#Part L
handle_nl:
#Will be calling other fxns, implement stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	move $s0, $a0 #a0 will change eventually
	li $a1, 10
	jal save_char 
	
	lbu $t2, 2($s0) #Gets x of struct
	lbu $t3, 3($s0) #Gets y of stuct
	lbu $t4, 0($s0) #Default color for clearline
	li $t5, 24
	
	beq $t2, $t5, lastrow #If x position is last row
	move $a0, $t2
	move $a1, $t3
	move $a2, $t4
	jal clear_line
	move $a0, $s0 #Return struct just in case
	lbu $a1, 2($a0)
	addi $a1, $a1, 1 #Moves to next row
	li $a2, 0 #First column
	li $a3, 0
	jal set_cursor #To set the cursor for the newline
	j newlinedone
	
	lastrow: #For the last row
	move $a0, $t2
	move $a1, $t3
	move $a2, $t4
	jal clear_line
	move $a0, $s0 #Return struct just in case
	li $a1, 24 #Since last row x will be 24
	li $a2, 0 #Starts at 1st column so 0
	li $a3, 0 #Initial set to 0
	jal set_cursor
	j newlinedone
	
	newlinedone:
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
#Part M
handle_backspace:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)

	lbu $s0, 3($a0)
	li $t0, 79
	sb $t0, 3($a0)
	li $a1, 0
	jal save_char #Tests for the boundaries and saves the characters
	
	sb $s0, 3($a0)
	lbu $t0, 2($a0)
	lbu $t1, 3($a0)
	li $t2, 79
	subu $t3, $t2, $t1
	li $t7, 2
	mul $a2, $t3, $t7
	
	li $t2, 160					
	mul $t0, $t0, $t2			
	li $t2, 2					
	mul $t1, $t1, $t2			
	add $t0, $t1, $t0		
	addi $t2, $t0, 0xFFFF0000  #Gets current address of the cursor
	move $a1, $t2
	addi $a0, $a1, 2
	jal strcpy #Runs strcpy to cpoy one part of the string from one postion  to the other
	
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
#Part N
highlight:
	move $t0, $a0
	move $t1, $a1
	li $t2, 160	
	li $t3, 2									
	mul $t0, $t0, $t2			

	mul $t1, $t1, $t3			
	add $t0, $t1, $t0			
	addi $t4, $t0, 0xFFFF0000 #Gets address of current cursor in struct	
	li $t3, 0
	highlightloop:
		beq $t3, $a3, highlightdone #Highlights through the word
		sb $a2, 1($t4)
		addi $t3, $t3, 1
		addi $t4, $t4, 2
		j highlightloop
	highlightdone:
	jr $ra
#Part O
highlight_all: #Highlight certain words in the dictionary 
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	

	li $s0, 0xFFFF0000
	move $s2, $a0
	move $s3, $a1
	li $s4, 0
	li $s5, 0
	displayloop:
		li $t0, 0xFFFF0FA0
		beq $s0, $t0, highlight_all_done
		whitespacehloop:
			lbu $a0, 0($s0)
			jal is_whitespace
			beqz $v0, highlight_all_cont
			addi $s0, $s0, 2
			addi $s5, $s5, 1
			bne $s5, 80, displayloop
			li $s5, 0
			addi $s4, $s4, 1
			j displayloop
		highlight_all_cont:
		move $s1, $s0
		move $s6, $s3
		dictionary_highlight:
			lw $a0, 0($s6)
			beqz $a0, whitespacenhloop
			jal strlen
			move $t1, $v0
			
			li $t2, 0
			check_str_equal:
				beq $t1, $t2, str_equal
				lbu $t3, 0($a0)
				lbu $t4, 0($s1)
				bne $t3, $t4, str_nequal
				addi $t2, $t2, 1
				addi $s1, $s1, 2
				addi $a0, $a0, 1
				j check_str_equal
			str_nequal:
			addi $s6, $s6, 4
			move $s1, $s0
			j dictionary_highlight
			
		str_equal:
		move $a0, $s4
		move $a1, $s5
		move $a2, $s2
		move $a3, $v0
		jal highlight
		
		whitespacenhloop:
			lbu $a0, 0($s0)
			jal is_whitespace
			bnez $v0, displayloop
			addi $s0, $s0, 2
			addi $s5, $s5, 1
			bne $s5, 80, whitespacenhloop
			li $s5, 0
			addi $s4, $s4, 1
			j whitespacenhloop
	
	highlight_all_done:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32
	jr $ra

