.text        

.globl main
main:	
	addi	$sp, $sp, -8
	addi	$t0, $0, 15
	addi	$t1, $0, 5
	add	$t2, $t0, $t1
	sw	$t2, 0($sp)
	
	addiu	$t0, $0, 15
	addiu	$t1, $0, 5
	addu	$t2, $t0, $t1
	sw	$t2, 4($sp)
	
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	
	addi	$sp, $sp, 8
	bne  	$t0, $t1, fracasso
	j	teste_loop
loop_mentira:
	j	fracasso
teste_loop:
	j	fora
	loop:
	add	$t1, $t1, $t1
	bne 	$t1, $t0, sai_loop
	jr	$ra
	j	fracasso
	fora:
	mul	$t2, $t1, $t0
	jal	loop
	j	fracasso
	sai_loop:
sucesso:
	li	$v0, 4
	la	$a0, sucesso_teste1
	syscall 
	li	$v0, 17
	syscall 
fracasso:
	li	$v0, 4
	la	$a0, fracasso_teste1
	syscall 
	li	$v0, 17
	syscall 

.data
sucesso_teste1:	.asciiz "\nTodos os testes funcionaram ;)\n"
fracasso_teste1:.asciiz "\nNão passou no teste\n"