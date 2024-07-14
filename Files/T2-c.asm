# Escreva um procedimento soma() em assembly para o processador MIPS. Os
# argumentos do procedimento são dois números A e B, inteiros sem sinal, de 32
# bits. No procedimento retornamos a soma A + B e verificamos se há o estouro
# (overflow) na operação de soma. Se há estouro, a mensagem “overflow na operação
# de soma” é apresentada. Teste o procedimento com os valores A e B iguais a
# 0x1234 1234 e 0x1122 3344. Repita o teste com os valores A = 0x8989 1122 e
# B=0xABCD 9876.
.data
quebra:	.asciiz "\n"
corta:	.asciiz "-------------------------------------------------------------------\n"
mais:	.asciiz " + "
igual:	.asciiz " = "
texto:	.asciiz "overflow na operação de soma\n"
.text
main:
	li	$a0, 0x12341234
	li	$a1, 0x11223344
	jal	soma
	la	$a0, corta
	addi	$v0, $zero, 4
	syscall 
	li	$a0, 0x89891122
	li	$a1, 0xABCD9876
	jal	soma
	la	$a0, corta
	addi	$v0, $zero, 4
	syscall 
	addi	$v0, $zero, 17
	add	$a0, $zero, 0
	syscall 
soma:
	addu	$t0, $a0, $a1
	
	addi	$v0, $zero, 1
	syscall 
	
	move	$t1, $a0
	
	la	$a0, mais
	addi	$v0, $zero, 4
	syscall 
	move	$a0, $a1
	addi	$v0, $zero, 1
	syscall 
	la	$a0, igual
	addi	$v0, $zero, 4
	syscall 
	move	$a0, $t0
	addi	$v0, $zero, 1
	syscall 
	la	$a0, quebra
	addi	$v0, $zero, 4
	syscall 
	
	move	$a0, $t1
	
	move	$t1, $zero
	
	bltz 	$a0, negativoA
	addi	$t1, $t1, 1
	negativoA:
	bltz 	$a1, negativoB
	addi	$t1, $t1, 1
	negativoB:
	bne  	$t1, 1, iguais
	j	final_soma
	iguais:
	beq 	$t1, 0, negativos
	beq 	$t1, 2, positivos
	negativos:
	bgez   	$t0, overflow
	j	final_soma
	positivos:
	bltz 	$t0, overflow
	j	final_soma
	
	overflow:
	la	$a0, texto
	li	$v0, 4
	syscall 
	jr	$ra
	
	final_soma:
	move	$v0, $t0
	jr	$ra