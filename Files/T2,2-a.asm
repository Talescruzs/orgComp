.data
prompt:     	.asciiz "Insira o valor de x em radianos: "
result_msg: 	.asciiz "cos(x) = "
newline:    	.asciiz "\n"
x:          	.double 0.0
result:     	.double 0.0

# Coefficients for the Taylor series
coef_1:		.double 1.0
fat2:		.double 2.0
fat4:		.double 24.0
fat6:		.double 720.0
fat8:		.double 40320.0
fat10:		.double 3628800.0
fat12:		.double 479001600.0
fat14:		.double 87178291200.0
negativo:	.double -1.0
.text
.globl main

main:
    # Printa prompt
    li $v0, 4
    la $a0, prompt
    syscall
    # Le valor de x
    li $v0, 7
    syscall
    # Move x para o primeiro parametro da função
    mov.d $f12, $f0
    jal cos
    # Bota resultado na variável
    s.d $f0, result
    # Printa resultado
    li $v0, 4
    la $a0, result_msg
    syscall
    l.d $f12, result
    li $v0, 3
    syscall
    # Printa newline
    li $v0, 4
    la $a0, newline
    syscall
    # Exit
    li $v0, 10
    syscall
    
cos:
	# n = 0
    	l.d  	$f4, coef_1
	# n = 1
    	mul.d 	$f10, $f12, $f12	# $f10 = x^2
    	l.d	$f8, fat2		# $f8 = 2!
    	div.d 	$f6, $f10, $f8 		# $f6 = x^2/2!
    	l.d	$f8, negativo		# $f8 = -1
    	mul.d 	$f6, $f6, $f8		# $f6 = -(x^2/2!)
    	add.d 	$f4, $f4, $f6 		# $f4 = 1-(x^2/2!)
    	# n = 2
    	mul.d 	$f6, $f10, $f10		# $f6 = x^4
    	l.d	$f8, fat4		# $f7 = 4!
    	div.d 	$f12, $f6, $f8 		# $f12 = x^4/4!6
    	#l.d		$f7, -1
    	#mul.d 	$f6, $f6, $f7
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)
    	# n = 3
    	mul.d 	$f6, $f6, $f10		# $f6 = x^6
    	l.d 	$f8, fat6		# $f7 = 6!
    	div.d 	$f12, $f6, $f8 		# $f8 = x^6/6!
    	l.d	$f8, negativo
    	mul.d 	$f12, $f12, $f8
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)-(x^6/6!)
    	# n = 4
    	mul.d 	$f6, $f6, $f10		# $f6 = x^8
    	l.d	$f8, fat8		# $f7 = 8!
    	div.d 	$f12, $f6, $f8 		# $f8 = x^8/8!
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)-(x^6/6!)+(x^8/8!)
    	# n = 5
    	mul.d 	$f6, $f6, $f10		# $f6 = x^10
    	l.d	$f8, fat10		# $f7 = 10!
    	div.d 	$f12, $f6, $f8 		# $f8 = x^10/10!
    	l.d	$f8, negativo
    	mul.d 	$f12, $f12, $f8
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)-(x^6/6!)+(x^8/8!)-(x^10/10!)
    	# n = 6
    	mul.d 	$f6, $f6, $f10		# $f6 = x^12
    	l.d	$f8, fat12		# $f7 = 12!
    	div.d 	$f12, $f6, $f8 		# $f8 = x^12/12!
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)-(x^6/6!)+(x^8/8!)-(x^10/10!)+(x^12/12!)
    	# n = 7
    	mul.d 	$f6, $f6, $f10		# $f6 = x^14
    	l.d	$f8, fat14		# $f7 = 14!
    	div.d 	$f12, $f6, $f8 		# $f8 = x^14/14!
    	l.d	$f8, negativo
    	mul.d 	$f12, $f12, $f8
    	add.d 	$f4, $f4, $f12 		# $f4 = 1-(x^2/2!)+(x^4/4!)-(x^6/6!)+(x^8/8!)-(x^10/10!)+(x^12/12!)-(x^14/14!)
	
	mov.d $f0, $f4
    	# Return
    	jr $ra
