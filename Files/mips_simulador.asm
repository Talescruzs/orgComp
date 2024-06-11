#*******************************************************************************
# Trabalho 1 - Organizacao de Computadores
#
# Autores: Tales Cruz da Silva, Diego Rochenbach - Estudantes de Sistemas de Informacao na UFSM
# DescriÃ§Ã£o: Simulador de um processador MIPS
#
#*******************************************************************************
	 	  
#	1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#      	M     	O			#
.text        
.globl main
### PROCESSOS INICIAIS ###
ini:					# Processos de inicializaÃ§Ã£o do programa
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
	ble  	$t0, 128 loop_zera_regs	# Volta o loop se nÃ£o tiver chegado no final dos registradores
	jr	$ra
ajusta_sp_simulado:
	la 	$t0, regs
	addi	$t1, $t0, 116		# $t1 <- endereÃ§o do registrador $sp simulado
	lw 	$t0, end_pilha		# $t0 <- endereÃ§o inicial da pilha simulada
	sw	$t0, 0($t1)		# $sp simulado <- endereÃ§o inicial da pilha
	jr	$ra	
ajusta_pc_simulado:
	la 	$t1, PC
	lw	$t2, end_text
	sw	$t2, 0($t1)		# PC simulado <- endereÃ§o inicial de cÃ³digo
	jr	$ra
##########################
### INTERNAS DO SIMULADOR ###	
passa_instrucao:
	lw	$t0, PC			# Carrega o endereco da instrucÃ£o atual
	lw	$t1, end_text		# Carrega o endereco inicial das intruÃ§Ãµes simuladas
	sub 	$t0, $t0, $t1		# Insere em $t0 a diferenÃ§a do PC para o endereÃ§o inicial de texto
	la	$t1, m_text		# $t1 <- end inicial do .text simulado
	add	$t0, $t0, $t1		# $t0 <- endereÃ§o real da instruÃ§Ã£o simulada
	lw	$t1, 0($t0)		# Carrega a instruÃ§Ã£o atual em $t1
	sw	$t1, IR			# Armazena a instruÃ§Ã£o em IR
    	jr      $ra
pega_end_pilha:
	move	$t0, $a0		# $t0 <- endereço solicitado
	lw	$t1, end_pilha		# $t1 <- endereço inicial de dados simulado
	sub  	$t2, $t1, $t0		# $t2 <- end solicitado na pilha simulada
	
	la	$t3, m_pilha		# $t3 <- endereço final da pilha
	lw	$t4, tam_pilha		# $t4 <- tamanho da pilha
	add	$t3, $t3, $t4		# $t3 <- endereço inicial da pilha
	sub	$t3, $t3, $t2		# $t3 <- endereço solicitado na pilha
	move	$v0, $t3
	j	prologo_converte_end
pega_end_data:
# $a0 recebe endereço solicitado do segmento de dados; 
# $v0 -> retorno como endereço da pilha simulada
	move	$t0, $a0		# $t0 <- endereço solicitado
	lw	$t1, end_data		# $t1 <- endereço inicial de dados simulado
	sub  	$t2, $t0, $t1		# $t2 <- diferença do end solicitado com o inicio o entereço de dados simulado
	
	la	$t3, m_data		# $t3 <- endereço inicial de dados
	add	$t3, $t2, $t3		# $t3 <- endereço solicitado no segmento de texto simulado
	move	$v0, $t3
	j	prologo_converte_end
pega_end_text:
# $a0 recebe endereço solicitado do segmento de dados; 
# $v0 -> retorno como endereço da pilha simulada
	move	$t0, $a0		# $t0 <- endereço solicitado
	lw	$t1, end_text		# $t1 <- endereço inicial de texto simulado
	sub  	$t2, $t0, $t1		# $t2 <- diferença do end solicitado com o inicio o entereço de text simulado
	
	la	$t3, m_text		# $t3 <- endereço inicial de texto
	add	$t3, $t2, $t3		# $t3 <- endereço solicitado no segmento de texto simulado
	move	$v0, $t3
	j	prologo_converte_end
converte_end:
# $a0 recebe endereço solicitado do segmento de dados; 
# $v0 -> retorno como endereço correto
	addi	$sp, $sp, -4		# Aloca empilhamento
	sw	$ra, 0($sp)		# Empilha parametro $a0
	
	move	$t0, $a0
	lw	$t1, end_data		# $t1 <- endereço inicial de dados simulado
	lw	$t2, end_pilha		# $t2 <- endereço inicial da pilha simulada
	lw	$t3, end_text		# $t3 <- endereço inicial de texto simulado
	lw	$t4, tam_data		# $t4 <- tamanho de dados simulado
	add	$t4, $t4, $t1		# $t4 <- endereço final de dados simulados
	lw	$t5, tam_pilha		# $t5 <- tamanho da pilha simulada
	sub	$t5, $t5, $t2		# $t5 <- endereço final da pilha simulada
	lw	$t6, tam_pilha		# $t6 <- tamanho de texto simulado
	add	$t6, $t6, $t3		# $t6 <- endereço final de texto simulado
	
	blt  	$t0, $t3, erro_fora_memoria# Endereço solicitado menor que o endereço inicial de texto = erro
	blt  	$t0, $t6, pega_end_text	   # Endereço solicitado pertence ao segmento de texto
	blt  	$t0, $t1, erro_fora_memoria# Endereço solicitado entre o inicio de dados e fim de texto = erro
	blt  	$t0, $t4, pega_end_data    # Endereço solicitado pertence ao segmento de dados
	blt  	$t0, $t5, erro_fora_memoria# Endereço solicitado entre o fim da pilha e o fim dos dados = erro
	blt   	$t0, $t2, pega_end_pilha   # Endereço solicitado pertence ao segmento da pilha
	j 	erro_fora_memoria
	
	prologo_converte_end:
	lw	$ra, 0($sp)		# Desempilha parametro $a0
	addi	$sp, $sp, 4		# Desaloca empilhamento
	jr	$ra
pega_registrador_simulado:
#***************************************************		
# parametros: $a0 <- numero do registrador; 
# retorno: $v0 <- endereÃ§o do registrador solicitado
#***************************************************
	la	$t0, regs		# $t0 <- valor inicial dos endereÃ§os dos registradores simulados
    	add	$t1, $a0, $zero		# $t1 <- numero do registrador desejado
    	sll	$t1, $t1, 2		# $t1 <- posiÃ§Ã£o no vetor dos registradores
    	
    	add	$v0, $t0, $t1		# $v0 <- posiÃ§Ã£o real do registrador
    	jr 	$ra
pega_valor_registrador_simulado:
#***************************************************		
# parametros: $a0 <- numero do registrador; 
# retorno: $v0 <- valor armazenado no registrador solicitado
#***************************************************
	la	$t0, regs		# $t0 <- valor inicial dos endereÃ§os dos registradores simulados
    	add	$t1, $a0, $zero		# $t1 <- numero do registrador desejado
    	sll	$t1, $t1, 2		# $t1 <- posiÃ§Ã£o no vetor dos registradores

    	add	$t0, $t0, $t1		# $t0 <- posiÃ§Ã£o real do registrador
    	lw	$v0, 0($t0)		# $v0 <- valor armazenado no registrador simulado
    	jr 	$ra
pega_rd_rs_rt:
#***************************************************		
# PARAMETROS: 
# $a0 <- endereço incial para salvar os dados de retorno
# obs: tamanho do retorno = 12 bytes
# MAPAS: 
# 	1-PILHA:
#		0 = $ra
#		4 = $a0
#		8 = $t0
#		12 = $t1
# 	2-REGISTRADORES:
#		$t0 = endereço do rd simulado
#		$t1 = valor do rs simulado
#		$t2 = valor do rt simulado
# 	3-RETORNO:
#		0($a0) = end_rd
#		4($a0) = v_rs
#		8($a0) = v_rt
#***************************************************
	addi	$sp, $sp, -16		# Aloca espaço da pilha
	sw	$ra, 0($sp)		# Empilha endereço de retorno do procedimento
	sw	$a0, 4($sp)		# Empilha parametro $a0
	
	lw	$a0, r_d
    	jal	pega_registrador_simulado
    	sw	$v0, 8($sp)		# Empilha $t0 para guardar valor e poder ir para outros procedimentos
    	
    	lw	$a0, r_s
    	jal	pega_valor_registrador_simulado
    	sw	$v0, 12($sp)		# Empilha $t0 para guardar valor e poder ir para outros procedimentos
    	
    	lw	$a0, r_t
    	jal	pega_valor_registrador_simulado
    	move	$t2, $v0		# $t1 <- valor do registrador rs solicitado
    	lw	$a0, 4($sp)		# Recupera $a0
    	lw	$t0, 8($sp)		# Recupera end rd em $t0
    	lw	$t1, 12($sp)		# Recupera valor rs em $t1
    	
    	sw	$t0, 0($a0)		# Escreve endereço do rd na posição solicitada
    	sw	$t1, 4($a0)		# Escreve valor do rs na posição solicitada
    	sw	$t2, 8($a0)		# Escreve valor do rt na posição solicitada
    	
    	lw	$ra, 0($sp)		# Recupera endereço de retorno do procedimento
    	addi	$sp, $sp, 16		# Desaloca espaço da pilha
    	jr	$ra			# Retorna
pega_rs_rt:
#***************************************************		
# PARAMETROS: 
# $a0 <- endereço incial para salvar os dados de retorno
# obs: tamanho do retorno = 16 bytes
# MAPAS: 
# 	1-PILHA:
#		0 = $ra
#		4 = $a0
#		8 = $t0
# 	2-REGISTRADORES:
#		$t0 = endereço do rs simulado
#		$t1 = endereço do rt simulado
# 	3-RETORNO:
#		0($a0) = end_rs
#		4($a0) = end_rt
#		8($a0) = v_rs
#		12($a0) = v_rt
#***************************************************
	addi	$sp, $sp, -12		# Aloca espaço da pilha
	sw	$ra, 0($sp)		# Empilha endereço de retorno do procedimento
	sw	$a0, 4($sp)		# Empilha parametro $a0
	
	lw	$a0, r_s
    	jal	pega_registrador_simulado
    	move	$t0, $v0		# $t0 <- endereço na memória do simulador do registrador rt solicitado
    	sw	$t0, 8($sp)		# Empilha $t0 para guardar valor e poder ir para outros procedimentos
    	
    	lw	$a0, r_t
    	jal	pega_registrador_simulado
    	move	$t1, $v0		# $t1 <- endereço na memória do simulador do registrador rs solicitado
    	lw	$t0, 8($sp)		# Recupera $t0
    	lw	$a0, 4($sp)		# Recupera $a0
    	
    	lw	$t2, 0($t0)
    	lw	$t3, 0($t1)
    	
    	sw	$t0, 0($a0)		# Escreve endereço do rs na posição solicitada
    	sw	$t1, 4($a0)		# Escreve endereço do rt na posição solicitada
    	sw	$t2, 8($a0)		# Escreve endereço do rs na posição solicitada
    	sw	$t3, 12($a0)		# Escreve endereço do rt na posição solicitada
    	
    	lw	$ra, 0($sp)		# Recupera endereço de retorno do procedimento
    	addi	$sp, $sp, 12		# Desaloca espaço da pilha
    	jr	$ra			# Retorna
################
main:
	jal recebe_data
    	jal recebe_text
loop:
	jal passa_instrucao
    	
    	jal decodifica

    	j loop
loop_fim:
    	jal fecha_arquivo
    	la	$a0, msg_sucesso
    	j termina
    	syscall                   	
#### INSTRUCOES DE INTERACAO COM ARQUIVO ####
abre_arquivo:	# recebe em $a0 o endereço do nome do arquivo
	# Abrir o arquivo para leitura
    	li      $v0, 13             	# CÃ³digo do sistema para abrir arquivo
    	li      $a1, 0              	# Flag de abertura (0 para leitura)
    	li      $a2, 0              	# Modo de abertura
    	syscall                     	# Chamada do sistema
    	# Verifica se houve erro ao abrir o arquivo
    	bltz    $v0, erro_abertura
    	jr $ra
le_arquivo: # recebe em $a0 o descritor do arquivo; recebe em $a1 o endereço inicial para onde transferir os dados lidos
    	li      $a2, 16		        # NÃºmero de bytes a serem lidos (tamanho da instruÃ§Ã£o)
	loop_leitura:
    	li      $v0, 14              	# CÃ³digo do sistema para ler arquivo
    	syscall                      	# Chamada do sistema
    	add 	$a1, $a1, $a2
     	bltz    $v0, erro_leitura    	# Se $v0 < 0, houve um erro
     	blt  	$v0, $a2, sai_leitura
     	j loop_leitura
     	sai_leitura:
    	jr      $ra
recebe_text:
	# Abrir o arquivo para leitura
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
    	la      $a0, arquivo_text   	# EndereÃ§o do nome do arquivo
    	jal 	abre_arquivo
    	move	$a0, $v0
    	la      $a1, m_text    		# EndereÃ§o do buffer de leitura
    	jal 	le_arquivo
    	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
    	jr $ra
recebe_data:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
    	la      $a0, arquivo_data   	# EndereÃ§o do nome do arquivo
    	jal 	abre_arquivo
    	move	$a0, $v0
    	la      $a1, m_data    		# EndereÃ§o do buffer de leitura
    	jal 	le_arquivo
    	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
    	jr $ra
fecha_arquivo:
    	li      $v0, 16             	# CÃ³digo do sistema para fechar arquivo
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
	
	lw	$t0, PC			# $t0 <- valor de PC simulado
	addi	$t0, $t0, 4		# Soma 4 (tamanho de uma instrucao)
	sw	$t0, PC			# Atualiza valor de PC

	lw	$t0, op_code	
	beqz    $t0, tipo_r		# if opcode == 0 instrucao do tipo r
	bge 	$t0, 4, tipo_i		# else if opcode >= 4 instrucao do tipo i
	j	tipo_j			# else instrucao do tipo j
	ponto_retorno_decodificacao:
	
	lw	$ra, 0($sp)
	addi    $sp, $sp, 4
	jr      $ra

####################################
## TIPOS DE OPERACAO ##
tipo_r:
	#jal imprime_rs
	#jal imprime_rt
	#jal imprime_rd
	#jal imprime_shamt
	#jal imprime_funct
	
	lw	$t0, funct
	beq  	$t0, 0x8, fjr
	beq  	$t0, 0xc, fsyscall
	beq  	$t0, 0x20, fadd
	beq  	$t0, 0x21, faddu
	## ESCREVER OS OUTROS TIPOS DE FUNÃ‡ÃƒO R
	retorno_tipo_r:
	j       ponto_retorno_decodificacao
tipo_i:    		
	lw	$t0, op_code
	beq  	$t0, 0x5, fbne
	beq  	$t0, 0x8, faddi
	beq  	$t0, 0x9, faddiu
	beq  	$t0, 0xd, fori
	beq  	$t0, 0xf, flui
	beq  	$t0, 0x1c, fmul
	beq  	$t0, 0x2b, fsw
	beq  	$t0, 0x23, flw
	retorno_tipo_i:
	
	j       ponto_retorno_decodificacao

tipo_j:
	#jal imprime_end
	
	lw	$t0, op_code
	beq  	$t0, 0x2, fj
	beq  	$t0, 0x3, fjal
	retorno_tipo_j:
	
	j       ponto_retorno_decodificacao
	
#######################
###### FUNCOES DO SIMULADOR ######
### SYSCALLS ###
sys_imprime_int:
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 1			# $v0 <- 1 (serviÃ§o de imprimir int)
    	syscall
    	j 	retorno_syscall
sys_imprime_str:
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	jal 	converte_end
    	move	$a0, $v0
    	li	$v0, 4			# $v0 <- 14 (serviÃ§o de imprimir str)
    	syscall
    	j retorno_syscall
sys_imprime_char:
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 11			# $v0 <- 11 (serviÃ§o de imprimir char)
    	syscall
    	j retorno_syscall
sys_exit:
    	li	$a0, 4			# $a0 <- 4 (numero do registrador a0 simulado)
    	jal	pega_registrador_simulado
    	lw	$a0, 0($v0)		# $a0 <- valor do $a0 simulado
    	li	$v0, 17			# $v0 <- 17 (serviÃ§o de encerramento do programa)
    	syscall
    	
################
#### TIPO R ####
fjr: 
    	lw	$a0, r_s
    	jal 	pega_valor_registrador_simulado
    	move	$t0, $v0		# $t0 <- valor do registrador rs simulado (endereÃ§o para ir)
    	la	$t1, PC			# $t1 <- endereÃ§o do PC simulado
    	sw	$t0, 0($t1)		# PC simulado <- endereÃ§o da instruÃ§Ã£o solicitada
	j	retorno_tipo_r
fsyscall: 
    	li	$a0, 2
    	jal 	pega_valor_registrador_simulado
    	move	$t0, $v0
    	beq  	$t0, 0x1, sys_imprime_int
    	beq  	$t0, 0x4, sys_imprime_str
    	beq  	$t0, 0xb, sys_imprime_char
    	beq  	$t0, 0x11, sys_exit
	retorno_syscall:
	j	retorno_tipo_r
	
fadd: 	
    	addi 	$sp, $sp, -12		# aloca 24bytes da pilha para receber os valores do procediemnto
    	move	$a0, $sp		# move o endereço de escrita para $a0
    	jal 	pega_rd_rs_rt
    	lw	$t0, 0($sp)		# $t0 <- endereço do rd
    	lw	$t1, 4($sp)		# $t1 <- valor do rs
    	lw	$t2, 8($sp)		# $t2 <- valor do rt
    	addi 	$sp, $sp, 12		# Desaloca espaço da pilha
    	
    	add	$t3, $t1, $t2		# Soma dos valores dos registradores da soma
    	sw	$t3, 0($t0)		# Insere o valor da soma no registrador de destino simulado
	j	retorno_tipo_r
faddu: 
	addi 	$sp, $sp, -12		# aloca 24bytes da pilha para receber os valores do procediemnto
    	move	$a0, $sp		# move o endereço de escrita para $a0
    	jal 	pega_rd_rs_rt
    	lw	$t0, 0($sp)		# $t0 <- endereço do rd
    	lw	$t1, 4($sp)		# $t1 <- valor do rs
    	lw	$t2, 8($sp)		# $t2 <- valor do rt
    	addi 	$sp, $sp, 12		# Desaloca espaço da pilha
    	
    	addu	$t3, $t1, $t2		# Modifica endereÃ§o com base no valor imediato
    	sw	$t3, 0($t0)		# Insere valor no endereco solicitado
	j	retorno_tipo_r
################
#### TIPO I ####
fbne:
    	addi	$sp, $sp, -16
    	move	$a0, $sp
    	jal 	pega_rs_rt
    	lw	$t0, 8($sp)
    	lw	$t1, 12($sp)
    	addi	$sp, $sp, 16
    	
    	beq  	$t0, $t1, bne_epilogo	# se $t0 e $t1 forem iguais, retorna e nÃ£o faz nada
    	
    	lw	$t3, v_imediato		# $t3 <- v_imediato para pular
    	lw	$t4, PC			# $t4 <- endereÃ§o do PC simulado
    	
    	sll	$t3, $t3, 2		# $t3 <- endereÃ§o, relativo ao .text simulado para pular (cada instruÃ§Ã£o possui 4 bytes, por isso *4)
    	add 	$t4, $t3, $t4		# $t4 <- endereÃ§oa para pular
    	sw	$t4, PC			# Pula para a instruÃ§Ã£o desejada
    	
    	bne_epilogo:
	j	retorno_tipo_i
faddi:	    
    	addi	$sp, $sp, -16
    	move	$a0, $sp
    	jal 	pega_rs_rt
    	lw	$t0, 8($sp)
    	lw	$t1, 4($sp)
    	addi	$sp, $sp, 16
    	
    	lw	$t3, v_imediato		# $t3 <- v_imediato para somar
    	add 	$t0, $t0, $t3		# Soma valor do rt simulado com valor imediato
    	sw	$t0, 0($t1)		# Armazena soma no registrador rs simulado
	j	retorno_tipo_i

faddiu:
    	addi	$sp, $sp, -16
    	move	$a0, $sp
    	jal 	pega_rs_rt
    	lw	$t0, 0($sp)
    	lw	$t1, 4($sp)
    	lw	$t3, 8($sp)
    	lw	$t4, 12($sp)
    	addi	$sp, $sp, 16
    	lw	$t2, v_imediato		# $t2 <- valor imediato inserido

    	addu	$t3, $t3, $t2		# Realiza addiu
    	sw	$t3, 0($t1)		# Insere resultado no registrador rt simulado
	j	retorno_tipo_i
flui:
 	lw	$a0, r_t
 	jal	pega_registrador_simulado
 	move	$t0, $v0		# $t0 <- endereço na memória do simulador do registrador rt solicitado
 	
 	lw	$t1, v_imediato		# $t1 <- valor imediato inserido
 	sll	$t1, $t1, 16		# Move os bits do valor simulado para a metade mais significativa
 	sw	$t1, 0($t0)		# Insere resultado no registrador rt simulado
	j	retorno_tipo_i

fori:	
    	addi	$sp, $sp, -16
    	move	$a0, $sp
    	jal 	pega_rs_rt
    	lw	$t0, 8($sp)
    	lw	$t1, 4($sp)
    	addi	$sp, $sp, 16
    	
    	lw	$t2, v_imediato		# $t2 <- valor imediato inserido
    	or 	$t3, $t0, $t2		# Realiza o OR
    	sw	$t3, 0($t1)		# Insere resultado no registrador rt simulado
	j	retorno_tipo_i
fmul:
	addi 	$sp, $sp, -12		# aloca 24bytes da pilha para receber os valores do procediemnto
    	move	$a0, $sp		# move o endereço de escrita para $a0
    	jal 	pega_rd_rs_rt
    	lw	$t0, 0($sp)		# $t0 <- endereço do rd
    	lw	$t1, 4($sp)		# $t1 <- valor do rs
    	lw	$t2, 8($sp)		# $t2 <- valor do rt
    	addi 	$sp, $sp, 12		# Desaloca espaço da pilha
    	
    	mul	$t3, $t1, $t2		# Realiza a multiplicação
    	sw	$t3, 0($t0)		# Insere o valor da multiplicação no registrador rd simulado
	j	retorno_tipo_i
fsw:
    	addiu	$sp, $sp, -8		# Aloca espaço pilha
    	sw	$ra, 0($sp)		# Empilha endereço de retorno
    	
    	lw	$a0, r_s
    	jal 	pega_valor_registrador_simulado
    	move	$a0, $v0		# $a0 <- valor de rs
    	
    	jal 	converte_end
    	move	$t0, $v0		# $t0 <- valor real de memoria solicitado
    	sw	$t0, 4($sp)		# Empilha rt
    	
    	lw	$a0, r_t		# $t2 <- valor de rs
    	jal 	pega_valor_registrador_simulado
    	move	$t1, $v0		# $t3 <- valor de rt
    	lw	$t2, v_imediato		# $t4 <- valor imediato
    	lw	$t0, 4($sp)
    	
	add	$t0, $t0, $t2		# Modifica endereÃ§o com base no valor imediato
    	sw	$t1, 0($t0)		# Insere valor no endereco solicitado
    	
    	lw	$ra, 0($sp)
    	addiu	$sp, $sp, 8
	j	retorno_tipo_i
flw: # Precisa melhorar
    	addiu	$sp, $sp, -8		# Aloca espaço pilha
    	sw	$ra, 0($sp)		# Empilha endereço de retorno
    	
    	lw	$a0, r_s
    	jal 	pega_valor_registrador_simulado
    	move	$a0, $v0		# $a0 <- valor de rs
    	
    	jal 	converte_end
    	move	$t0, $v0		# $t0 <- valor real de memoria solicitado
    	sw	$t0, 4($sp)		# Empilha rt
    	
    	lw	$a0, r_t		# $t2 <- valor de rs
    	jal 	pega_registrador_simulado
    	move	$t1, $v0		# $t3 <- valor de rt
    	lw	$t2, v_imediato		# $t4 <- valor imediato
    	lw	$t0, 4($sp)
    	
	add	$t0, $t0, $t2		# Modifica endereÃ§o com base no valor imediato
    	sw	$t0, 0($t1)		# Insere valor no endereco solicitado
    	
    	lw	$ra, 0($sp)
    	addiu	$sp, $sp, 8
	j	retorno_tipo_i
################
#### TIPO J ####
fjal:
    	li	$a0, 31
    	jal 	pega_registrador_simulado
    	lw	$t0, PC			# $t0 <- endereÃ§o da instruÃ§Ã£o atual
    	sw	$t0, 0($v0)		# $ra simulado <- endereÃ§o de retorno
    	j 	fj		
fj: 	
    	lw	$t0, endereco		# $t0 <- endereÃ§o para pular
    	la	$t1, PC			# $t1 <- endereÃ§o do PC simulado
    	lw	$t2, end_text		# $t2 <- endereÃ§o inicial do .text simulado
    	sll	$t0, $t0, 2		# $t0 <- endereÃ§o, relativo ao .text simulado para pular (cada instruÃ§Ã£o possui 4 bytes, por isso *4)
    	add 	$t0, $t0, $t2		# $t0 <- endereÃ§o, efetivo da instruÃ§Ã£o desejada
    	sw	$t0, 0($t1)		# PC simulado <- endereÃ§o da instruÃ§Ã£o solicitada
    	j	retorno_tipo_j
################
##################################
###### TRATAMENTO DE ERROS ######
termina:
	li      $v0, 4              	# CÃ³digo do sistema para imprimir string
    	syscall                     	# Chamada do sistema
    	li      $v0, 10             	# CÃ³digo do sistema para encerrar o programa
    	syscall				# Chamada do sistema
erro_abertura:
    	la      $a0, msg_erro_abert 	# EndereÃ§o da mensagem de erro
    	j termina

erro_leitura:
	la	$a0, msg_erro_leitura 	# EndereÃ§o da mensagem de erro
	j termina
erro_fora_pilha:
	la	$a0, msg_erro_fora_pilha# EndereÃ§o da mensagem de erro
	j termina
erro_fora_data:
	la	$a0, msg_erro_fora_data# EndereÃ§o da mensagem de erro
	j termina
erro_fora_text:
	la	$a0, msg_erro_fora_text# EndereÃ§o da mensagem de erro
	j termina
erro_fora_memoria:
	la	$a0, msg_erro_fora_memoria# EndereÃ§o da mensagem de erro
	j termina
#################################
.data
##### VARIAVEIS DA SIMULACAO #####
PC:         	.word 0
IR:         	.word 0
regs:       	.space 128
m_text:   	.space 1024
m_data:   	.space 1024
m_pilha:  	.space 1024
tam_text:   	.word 1024
tam_data:   	.word 1024
tam_pilha:  	.word 1024
end_text:   	.word 0x00400000
end_data:   	.word 0x10010000
end_pilha:  	.word 0x7FFFEFFC
##################################
### VARIAVEIS PARA MANIPULACAO DE ARQUIVO ###
op_code:	.word 0
r_s:		.word 0
r_t:		.word 0
r_d:		.word 0
shamt:		.word 0
funct:		.word 0
endereco:	.word 0
v_imediato:	.word 0

arquivo_text:   .asciiz "trabalho_01-2024_1.bin"
arquivo_data:   .asciiz "trabalh0_01-2024_1.dat"
#############################################
############## STRINGS ##############
#######
# SUCESSO #
msg_sucesso: .asciiz "\nPrograma finalizou com sucesso\n"
###########
# ERRO #
msg_erro_abert: .asciiz "Erro ao abrir o arquivo\n"
msg_erro_leitura: .asciiz "Erro ao ler instrucao\n"
msg_erro_fora_pilha: .asciiz "\nSolicitou endereço fora da pilha\n"
msg_erro_fora_data: .asciiz "\nSolicitou endereço fora do segmento de dados\n"
msg_erro_fora_text: .asciiz "\nSolicitou endereço fora do segmento de texto\n"
msg_erro_fora_memoria: .asciiz "\nSolicitou endereço indevido de memoria\n"
########
#####################################
