#*******************************************************************************
# Trabalho 1 - Organizacao de Computadores
#
# Autores: Tales Cruz da Silva, Diego Rochenbach - Estudantes de Sistemas de Informacao na UFSM
# Descrição: Simulador de um processador MIPS
#
#*******************************************************************************
	 	  
#	1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#      	M     	O			#
.text        
.globl main
### PROCESSOS INICIAIS ###
ini:					# Processos de inicialização do programa
	jal	zera_registradores
	jal	ajusta_sp_simulado
	jal	ajusta_pc_simulado
	j 	main
zera_registradores:
	la	$t0, regs		#$t0 <- end inicial dos registradores simulados
	li	$t1, 4			#$t1 <- 4(tamanho de um registrador)
	loop_zera_regs:
	sw	$zero, 0($t0)		# Zera o valor do registrador
	add	$t0, $t0, $t1		# Passo para o registrador seguinte
	ble  	$t0, 128 loop_zera_regs	# Volta o loop se não tiver chegado no final dos registradores
	jr	$ra
ajusta_sp_simulado:
	la 	$t0, regs
	addi	$t1, $t0, 116		# $t1 <- endereço do registrador $sp simulado
	la 	$t0, m_pilha		# $t0 <- endereço inicial da pilha simulada
	sw	$t0, 0($t1)		# $sp simulado <- endereço inicial da pilha
	jr	$ra	
ajusta_pc_simulado:
	la 	$t1, PC
	li	$t2, 0x00400000
	sw	$t2, 0($t1)		# PC simulado <- endereço inicial de código
	jr	$ra
##########################
### MANUTENÇÃO DO SIMULADOR ###	
passa_instrucao:
	lw	$t0, PC			# Carrega o endereco da instrucão atual
	lw	$t1, end_text		# Carrega o endereco inicial das intruções simuladas
	sub 	$t0, $t0, $t1		# Insere em $t0 a diferença do PC para o endereço inicial de texto
	la	$t1, m_text		# $t1 <- end inicial do .text simulado
	add	$t0, $t0, $t1		# $t0 <- endereço real da instrução simulada
	lw	$t1, 0($t0)		# Carrega a instrução atual em $t1
	sw	$t1, IR			# Armazena a instrução em IR
	lw	$t0, PC			# $t0 <- valor de PC simulado
	addi	$t0, $t0, 4		# Soma 4 (tamanho de uma instrucao)
	sw	$t0, PC			# Atualiza valor de PC
    	jr      $ra
###############################
### INTERNAS ###
pega_registrador_simulado:
#***************************************************		
# parametros: $a0 <- numero do registrador; 
# retorno: $v0 <- endereço do registrador solicitado
#***************************************************
	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	add	$t1, $a0, $zero		# $t1 <- numero do registrador desejado
    	sll	$t1, $t1, 2		# $t1 <- posição no vetor dos registradores
    	
    	add	$v0, $t0, $t1		# $v0 <- posição real do registrador
    	jr 	$ra
pega_valor_registrador_simulado:
#***************************************************		
# parametros: $a0 <- numero do registrador; 
# retorno: $v0 <- valor armazenado no registrador solicitado
#***************************************************
	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	add	$t1, $a0, $zero		# $t1 <- numero do registrador desejado
    	sll	$t1, $t1, 2		# $t1 <- posição no vetor dos registradores

    	add	$t0, $t0, $t1		# $t0 <- posição real do registrador
    	lw	$v0, 0($t0)		# $v0 <- valor armazenado no registrador simulado
    	jr 	$ra
################
main:
	jal abre_arquivo
    	jal le_arquivo
loop:
	jal passa_instrucao
    	lw $s0, IR			# Verifica se acabaram as instrucoes
    	beqz  $s0, loop_fim		# Sai do simulador se acabaram as instrucoes
    	
    	jal decodifica

    	j loop
loop_fim:
    	jal fecha_arquivo
    	la	$a0, msg_sucesso
    	j termina
    	syscall                   	
#### INSTRUCOES DE INTERACAO COM ARQUIVO ####
abre_arquivo:
	# Abrir o arquivo para leitura
    	li      $v0, 13             	# Código do sistema para abrir arquivo
    	la      $a0, nome_arquivo   	# Endereço do nome do arquivo
    	li      $a1, 0              	# Flag de abertura (0 para leitura)
    	li      $a2, 0              	# Modo de abertura
    	syscall                     	# Chamada do sistema
    	# Verifica se houve erro ao abrir o arquivo
    	bltz    $v0, erro_abertura
    	# Salva descritor do arquivo na variável
    	sw      $v0, desc_arquivo   	# Armazena o descritor do arquivo em desc_arquivo
    	jr $ra
le_arquivo:
	lw      $a0, desc_arquivo    	# Carrega o descritor do arquivo
    	la      $a1, m_text    		# Endereço do buffer de leitura
    	li      $a2, 16		        # Número de bytes a serem lidos (tamanho da instrução)
	loop_leitura:
    	li      $v0, 14              	# Código do sistema para ler arquivo
    	syscall                      	# Chamada do sistema
    	add 	$a1, $a1, $a2
     	bltz    $v0, erro_leitura    	# Se $v0 < 0, houve um erro
     	blt  	$v0, $a2, sai_leitura
     	j loop_leitura
     	sai_leitura:
    	jr      $ra
fecha_arquivo:
    	li      $v0, 16             	# Código do sistema para fechar arquivo
    	syscall                     	# Chamada do sistema
    	jr      $ra
#############################################
#### DECODIFICACAO DE INSTRUCAO ####
## PEGA PARTE DA INSTRUCAO ##
pega_op: # $a0 = instrucao; $v0 <-- op_code
	srl     $t0, $a0, 26
	move    $v0, $t0
	jr      $ra
pega_rs: # $a0 = instrucao; $v0 <-- r_s
	sll     $t0, $a0, 6
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
pega_rt: # $a0 = instrucao; $v0 <-- r_t
	sll     $t0, $a0, 11
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
pega_rd: # $a0 = instrucao; $v0 <-- r_d
	sll     $t0, $a0, 16
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
pega_shamt: # $a0 = instrucao; $v0 <-- shamt
	sll     $t0, $a0, 21
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
pega_funct: # $a0 = instrucao; $v0 <-- funct
	sll     $t0, $a0, 26
	srl     $t0, $t0, 26
	move    $v0, $t0
	jr      $ra
pega_endereco: # $a0 = instrucao; $v0 <-- endereco
	sll     $t0, $a0, 16
	srl     $t0, $t0, 16
	move    $v0, $t0
	jr      $ra
pega_int: # $a0 = instrucao; $v0 <-- inteiro em complemento de 2
	sll     $t0, $a0, 16
	sra     $t0, $t0, 16
	move    $v0, $t0
	jr      $ra
#############################
## TIPOS DE OPERACAO ##
tipo_r:
	#jal imprime_rs
	#jal imprime_rt
	#jal imprime_rd
	#jal imprime_shamt
	#jal imprime_funct
	
	lw	$t0, funct
	beq  	$t0, 0xc, fsyscall
	beq  	$t0, 0x20, fadd
	beq  	$t0, 0x21, faddu
	## ESCREVER OS OUTROS TIPOS DE FUNÇÃO R
	
	
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_r
    	syscall                     	# Chamada do sistema
    	jal imprime_instrucao
    	jal imprime_funct
	
	retorno_tipo_r:
	j       ponto_retorno_decodificacao
tipo_i:    		
	lw	$t0, op_code
	beq  	$t0, 0x5, fbne
	beq  	$t0, 0x9, faddiu
	beq  	$t0, 0x2b, fsw
	beq  	$t0, 0x23, flw
	
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_i
    	syscall                     	# Chamada do sistema
    	jal imprime_instrucao
    	jal imprime_op_code
	
	retorno_tipo_i:
	
	j       ponto_retorno_decodificacao

tipo_j:
	#jal imprime_end
	
	lw	$t0, op_code
	beq  	$t0, 0x3, fjal
	
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_j
    	syscall                     	# Chamada do sistema
    	jal imprime_instrucao
    	jal imprime_op_code
    	
	retorno_tipo_j:
	
	j       ponto_retorno_decodificacao
#######################
decodifica:
	addi    $sp, $sp, -4
	sw 	$ra, 0($sp)
	
	lw 	$a0, IR	
	jal 	pega_op
	sw 	$v0, op_code
	jal 	pega_rs
	sw 	$v0, r_s
	jal 	pega_rt
	sw 	$v0, r_t
	jal 	pega_rd
	sw 	$v0, r_d
	jal 	pega_shamt
	sw 	$v0, shamt
	jal 	pega_funct
	sw 	$v0, funct
	jal 	pega_int 		# Aceita numeros negativos (provavel que seja mudado)
	sw 	$v0, v_imediato
	jal 	pega_endereco
	sw 	$v0, endereco
	
	#jal imprime_instrucao
	#jal imprime_op_code
	
	lw	$t0, op_code
	
	beqz    $t0, tipo_r		# if opcode == 0 instrucao do tipo r
	bge 	$t0, 4, tipo_i		# else if opcode >= 4 instrucao do tipo i
	j	tipo_j			# else instrucao do tipo j
	ponto_retorno_decodificacao:
	
	lw	$ra, 0($sp)
	addi    $sp, $sp, 4
	jr      $ra

####################################

###### FUNCOES DO SIMULADOR ######
### SYSCALLS ###
sys_imprime_int:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_sys_p_int
    	syscall                     	# Chamada do sistema
    	
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 1			# $v0 <- 1 (serviço de imprimir int)
    	syscall
    	j retorno_syscall
sys_imprime_str:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_sys_p_str
    	syscall                     	# Chamada do sistema

    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 4			# $v0 <- 14 (serviço de imprimir str)
    	syscall
    	j retorno_syscall
sys_imprime_char:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_sys_p_char
    	syscall 
    	
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 11			# $v0 <- 11 (serviço de imprimir char)
    	syscall
    	j retorno_syscall
sys_exit:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_sys_exit
    	syscall                     	# Chamada do sistema
    	
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 17			# $v0 <- 17 (serviço de encerramento do programa)
    	syscall
    	
################
#### TIPO R ####
fsyscall: 
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_syscall
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	li	$t1, 2			# $t1 <- registrador 2
    	sll	$t1, $t1, 2		# $t1 <- posição no vetor dos registradores
    	
    	add	$t0, $t0, $t1		# $t0 <- posição real do registrador $v0 simulado
    	lw	$t1, 0($t0)		# $t1 <- valor armazenado no registrador $v0 simulado
    	
    	
    	beq  	$t1, 0x1, sys_imprime_int
    	beq  	$t1, 0x4, sys_imprime_str
    	beq  	$t1, 0xb, sys_imprime_char
    	beq  	$t1, 0x11, sys_exit
	
	retorno_syscall:
	j	retorno_tipo_r
	
fadd: #funcao que simula operacao add do processador MIPS
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_add
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	
    	lw	$t1, r_d		# $t1 <- numero do registrador de destino simulado
    	li	$s0, 4			# Insere tamanho do registrador em $s0
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de destino simulado
    	add 	$t2, $t0, $t1		# $t2 <- endereco do registrador de destino simulado
    	
    	lw	$t1, r_s
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de inicio da soma simulado
    	add 	$t3, $t0, $t1		# $t3 <- endereco do registrador inicio da soma simulado
    	
    	lw	$t1, r_t
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador dois da soma simulado
    	add 	$t4, $t0, $t1		# $t4 <- endereco do registrador dois da soma simulado
    	
    	li	$s0, 4			# Insere tamanho do registrador em $s0
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de destino
    	
    	lw	$t5, 0($t2)		# Valor do registrador de destino simulado
    	lw	$t6, 0($t3)		# Valor do registrador um da soma simulado
    	lw	$t7, 0($t4)		# Valor do registrador dois da soma simulado
    	
    	add	$t5, $t6, $t7		# Soma dos valores dos registradores da soma
    	
    	sw	$t5, 0($t2)		# Insere o valor da soma no registrador de destino simulado
    	
	j	retorno_tipo_r
faddu: 
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_addu
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados

    	lw	$t1, r_s		# $t1 <- numero do registrador rs
    	sll	$t1, $t1, 2		# $t1 <- numero do registrador * 4
    	add	$t1, $t1, $t0		# $t1 <- endereço do registrador rs
    	lw	$t2, r_t		# $t2 <- numero do registrador rt
    	sll	$t2, $t2, 2		# $t2 <- numero do registrador * 4
    	add	$t2, $t2, $t0		# $t2 <- endereço do registrador rt
    	lw	$t3, r_d		# $t3 <- numero do registrador rd
    	sll	$t3, $t3, 2		# $t3 <- numero do registrador * 4
    	add	$t3, $t3, $t0		# $t3 <- endereço do registrador rd
    	
    	lw	$t4, 0($t1)		# $t4 <- valor armazenado no endereço armazenado no rs
    	lw	$t5, 0($t2)		# $t5 <- valor armazenado no endereço armazenado no rt
    	
    	add	$t5, $t4, $t5		# Modifica endereço com base no valor imediato
    	sw	$t5, 0($t3)		# Insere valor no endereco solicitado
    	
	j	retorno_tipo_r
################
#### TIPO I ####
fbne: #funcao que simula operacao addiu do processador MIPS
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_bne
    	syscall                     	# Chamada do sistema
    	    
    	lw	$a0, r_s
    	jal 	pega_valor_registrador_simulado
    	move	$t0, $v0		# $t0 <- valor do registrador rs simulado
    	
    	lw	$a0, r_t
    	jal 	pega_valor_registrador_simulado
    	move	$t1, $v0		# $t1 <- valor do registrador rt simulado
    	
    	beq  	$t0, $t1, retorno_tipo_i# se $t0 e $t1 forem iguais, retorna e não faz nada
    	
    	lw	$t3, v_imediato		# $t3 <- v_imediato para pular
    	lw	$t4, PC			# $t4 <- endereço do PC simulado
    	
    	sll	$t3, $t3, 2		# $t3 <- endereço, relativo ao .text simulado para pular (cada instrução possui 4 bytes, por isso *4)
    	add 	$t4, $t3, $t4		# $t4 <- endereçoa para pular
    	sw	$t4, PC			# Pula para a instrução desejada

	j	retorno_tipo_i

faddiu: #funcao que simula operacao addiu do processador MIPS
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_addiu
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	
    	li	$s0, 4			# Insere tamanho do registrador em $s0
    	
    	lw	$t1, r_s
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de inicio da soma simulado
    	add 	$t3, $t0, $t1		# $t3 <- endereco do registrador inicio da soma simulado
    	
    	lw	$t1, r_t
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador dois da soma simulado
    	add 	$t4, $t0, $t1		# $t4 <- endereco do registrador dois da soma simulado
    	
    	lw	$t5, v_imediato
    	lw	$t6, 0($t3)		# Valor do registrador um da soma simulado
    	lw	$t7, 0($t4)		# Valor do registrador dois da soma simulado
    	
    	add	$t6, $t7, $t5		# Soma dos valores dos registradores da soma
    	
    	sw	$t6, 0($t4)		# Insere o valor da soma no registrador de destino simulado
	j	retorno_tipo_i
	
fsw:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_sw
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	
    	li	$s0, 4			# Insere tamanho do registrador em $s0
    	
    	lw	$t1, r_s
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de inicio da soma simulado
    	add 	$t3, $t0, $t1		# $t3 <- endereco do rs
    	
    	lw	$t1, r_t
    	mult	$t1, $s0		# Vai para o registrador chamado com base em seu tamanho * posição
    	mflo  	$t1			# $t1 <- registrador de inicio da soma simulado
    	add 	$t4, $t0, $t1		# $t4 <- endereco do rt
    	
    	lw	$t5, v_imediato		# $t5 <- valor imediato
    	
    	lw	$t6, 0($t3)		# $t6 <- valor armazenado no endereço armazenado no rs
    	lw	$t7, 0($t4)		# $t7 <- valor armazenado no endereço armazenado no rt
    	
	add	$t6, $t6, $t5		# Modifica endereço com base no valor imediato
    	sw	$t7, 0($t6)		# Insere valor no endereco solicitado
	j	retorno_tipo_i

flw:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_lw
    	syscall                     	# Chamada do sistema
    	
    	la	$t0, regs		# $t0 <- valor inicial dos endereços dos registradores simulados
    	lw	$t1, r_s		# $t1 <- numero do registrador rs
    	sll	$t1, $t1, 2		# $t1 <- numero do registrador * 4
    	add	$t1, $t1, $t0		# $t1 <- endereço do registrador rs
    	lw	$t2, r_t		# $t2 <- numero do registrador rt
    	sll	$t2, $t2, 2		# $t2 <- numero do registrador * 4
    	add	$t2, $t2, $t0		# $t2 <- endereço do registrador rt
    	lw	$t3, v_imediato		# $t3 <- valor imediato
    	
    	lw	$t4, 0($t1)		# $t4 <- valor armazenado no endereço armazenado no rs
    	lw	$t5, 0($t2)		# $t5 <- valor armazenado no endereço armazenado no rt
    	
    	add	$t4, $t4, $t3		# Modifica endereço com base no valor imediato
    	sw	$t5, 0($t4)		# Insere valor no endereco solicitado
	j	retorno_tipo_i
    	
################
#### TIPO J ####
fjal:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_jal
    	syscall                     	# Chamada do sistema
    	
    	li	$a0, 31
    	jal 	pega_registrador_simulado
    	lw	$t0, PC			# $t0 <- endereço da instrução atual
    	addi	$t0, $t0, 4		# $t0 <- endereço da proxima instrução
    	sw	$t0, 0($v0)		# $ra simulado <- endereço de retorno
    	
    	lw	$t0, endereco		# $t0 <- endereço para pular
    	la	$t1, PC			# $t1 <- endereço do PC simulado
    	lw	$t2, end_text		# $t2 <- endereço inicial do .text simulado
    	andi 	$t0, $t0, 0xffff	# $t0 <- numero da instrução para pular
    	sll	$t0, $t0, 2		# $t0 <- endereço, relativo ao .text simulado para pular (cada instrução possui 4 bytes, por isso *4)
    	add 	$t0, $t0, $t2		# $t0 <- endereço, efetivo da instrução desejada
    	sw	$t0, 0($t1)		# PC simulado <- endereço da instrução solicitada
    	
    	j	retorno_tipo_j
    	
    	
################
#### IMPRESSAO ####
imprime_geral_hex: # a0 = menssagem de contexto; a1 = valor hexadecimal
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	syscall                     	# Chamada do sistema

    	# Exibe os bytes da instrução binária
	lw	$a0, 0($a1)          	# Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	
    	jr      $ra
    	
imprime_instrucao:
    	# Exibe a instrução binária lida
    	addi    $sp, $sp, -4
	sw 	$ra, 0($sp)
	la	$a0, msg_instrucao
	la	$a1, IR
    	jal 	imprime_geral_hex
    	lw	$ra, 0($sp)
	addi    $sp, $sp, 4
    	jr      $ra	
imprime_op_code:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_op_code  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, op_code          # Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra	
imprime_rs:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_rs  		# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, r_s          # Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra	
imprime_rt:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_rt  		# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, r_t          # Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra	
imprime_rd:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_rd  		# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, r_d          # Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra	
imprime_shamt:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_shamt  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, shamt          	# Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra
imprime_funct:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_funct  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, funct          	# Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra
imprime_end:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_end  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, endereco          	# Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra
imprime_int:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_imediato  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema
    	# Exibe os bytes da instrução binária
	lw	$a0, v_imediato         # Endereço do buffer de leitura
    	li      $v0, 1             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema
    	jr      $ra
###################
##################################
###### TRATAMENTO DE ERROS ######
termina:
	li      $v0, 4              	# Código do sistema para imprimir string
    	syscall                     	# Chamada do sistema
    	li      $v0, 10             	# Código do sistema para encerrar o programa
    	syscall 
    	
erro_abertura:
    	la      $a0, msg_erro_abert 	# Endereço da mensagem de erro
    	j termina

erro_leitura:
	la	$a0, msg_erro_leitura 	# Endereço da mensagem de erro
	j termina
#################################

.data
#memory:       .word 0xABCDE080

##### VARIAVEIS DA SIMULACAO #####
PC:         	.word 0
IR:         	.word 0
regs:       	.space 128
m_text:   	.space 1024
m_data:   	.space 1024
m_pilha:  	.space 1024
end_text:   	.word 0x00400000
end_data:   	.word 0x10010000
end_pilha:  	.word 0x7FFFEFFC
##################################

### VARIAVEIS PARA MANIPULACAO DE ARQUIVO ###
desc_arquivo:   .word 0
op_code:	.word 0
r_s:		.word 0
r_t:		.word 0
r_d:		.word 0
shamt:		.word 0
funct:		.word 0
endereco:	.word 0
v_imediato:	.word 0

nome_arquivo:   .asciiz "trabalho_01-2024_1.bin"
#############################################

############## STRINGS ##############
# I/O #
msg_instrucao: 	.asciiz "\nInstrução binária lida: "
msg_op_code: 	.asciiz "\nOp_code lida: "
msg_rs: 	.asciiz "\nrs lido: "
msg_rt: 	.asciiz "\nrt lido: "
msg_rd: 	.asciiz "\nrd lido: "
msg_shamt: 	.asciiz "\nshamt lido: "
msg_funct: 	.asciiz "\nfunct lido: "
msg_end: 	.asciiz "\nendereco lido: "
msg_imediato: 	.asciiz "\nvalor imediato lido: "

str_tipo_r:	.asciiz "\ntipo r "
str_tipo_i:	.asciiz "\ntipo i "
str_tipo_j:	.asciiz "\ntipo j "

str_syscall:	.asciiz "\nsyscall "
str_sys_p_int: 	.asciiz "\nimprime int "
str_sys_p_str:	.asciiz "\nimprime str "
str_sys_p_char:	.asciiz "\nimprime char  "
str_sys_exit:	.asciiz "\nexit "


str_add:	.asciiz "\nadd "
str_addu:	.asciiz "\naddu "

str_bne:	.asciiz "\nbne "
str_addiu:	.asciiz "\naddiu "
str_sw:		.asciiz "\nsw "
str_lw:		.asciiz "\nlw "

str_jal:	.asciiz "\njal "

#######
# SUCESSO #
msg_sucesso: .asciiz "\nPrograma finalizou com sucesso\n"
###########
# ERRO #
msg_erro_abert: .asciiz "Erro ao abrir o arquivo\n"
msg_erro_leitura: .asciiz "Erro ao ler instrucao\n"
########
#####################################
