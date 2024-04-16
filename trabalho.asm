# Autores: Tales Cruz da Silva, Diego Rochenbach - Estudantes de Sistemas de Informacao na UFSM
# Descrição: Simulador de um processador MIPS
#
#*******************************************************************************
	 	  
#	1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#      	M     	O		#
.text		
		
        # teste de utilizacao de componentes simulados (soma de dois valores com salvamento nos registradores simulados)
      	la	$t0, regs	# $t0 <- endereço inicial dos registradores 
      	li	$t1, 10		# $t1 <- valor 10 
      	li	$t2, 15 	# $t2 <- valor 15
      	sw    	$t1, 4($t0)  	# regs[1] <- valor $t1
      	sw    	$t2, 8($t0)  	# regs[2] <- valor $t2
      	lw    	$t3, 4($t0) 	# $t3 <- regs[1] 
      	lw    	$t4, 8($t0) 	# $t4 <- regs[2]
      	add   	$t5, $t3, $t4	# $t5 <- soma de $t3 com $t4
      	sw    	$t5, 12($t0)  	# regs[3] <- valor $t5

.data
#memory:		.word 0xABCDE080

PC:		.word 0
IR:		.word 0
regs:		.space 128
memoria_text: 	.space 1024
memoria_data: 	.space 1024
memoria_pilha: 	.space 1024
end_text:	.word 0x00400000
end_data:	.word 0x10010000
end_pilha:	.word 0x7FFFEFFC
