.text        
.globl main
main:	
#################################
#      TESTE DE ADD E ADDI	#
#################################
	addi	$sp, $sp, -8
	addi	$t0, $0, 15
	addi	$t1, $0, 5
	add	$t2, $t0, $t1
#################################
#      TESTE DE SW E PILHA	#
#################################
	sw	$t2, 0($sp)
	
#################################
#    TESTE DE ADDU E ADDIU	#
#################################
	addiu	$t0, $0, 15
	addiu	$t1, $0, 5
	addu	$t2, $t0, $t1
	sw	$t2, 4($sp)
#################################
#         TESTE DE LW    	#
#################################
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	
	addi	$sp, $sp, 8
#################################
#       TESTE DE DECISÃO    	#
#################################
	bne  	$t0, $t1, fracasso
#################################
#         TESTE DE J	    	#
#################################
	j	teste_loop
loop_mentira:
	j	fracasso
teste_loop:
	j	fora
	loop:
	add	$t1, $t1, $t1
	bne 	$t1, $t0, sai_loop
#################################
#         TESTE DE JR	    	#
#################################
	jr	$ra
	j	fracasso
	fora:
#################################
#        TESTE DE MUL	    	#
#################################
	mul	$t2, $t1, $t0
#################################
#        TESTE DE JAL	    	#
#################################
	jal	loop
	j	fracasso
	sai_loop:
#################################
#   TESTE DE LI, LA E SYSCALL	#
#################################
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
sucesso_teste1:	.asciiz "Todos os testes funcionaram "
fracasso_teste1:.asciiz "Não passou no teste"
