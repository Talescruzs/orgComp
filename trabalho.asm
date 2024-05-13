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
main:
	jal abre_arquivo
    	jal le_arquivo
loop:
    	jal pega_instrucao
    	lw $s0, instrucao		# Verifica se acabaram as instrucoes
    	beqz  $s0, loop_fim		# Sai do simulador se acabaram as instrucoes
    	
    	jal decodifica
    	
    	jal passa_instrucao
    	j loop
loop_fim:
    	jal fecha_arquivo
    	li      $v0, 10             	# Código do sistema para encerrar o programa
    	syscall


                   	
#### INSTRUCOES DE INTERACAO COM ARQUIVO ####
abre_arquivo:
	# Abrir o arquivo para leitura
    	li      $v0, 13             	# Código do sistema para abrir arquivo
    	la      $a0, nome_arquivo   	# Endereço do nome do arquivo
    	li      $a1, 0              	# Modo de abertura (0 para leitura)
    	syscall                     	# Chamada do sistema
    	# Verifica se houve erro ao abrir o arquivo
    	bltz    $v0, erro_abertura
    	# Salva descritor do arquivo na variável
    	sw      $v0, desc_arquivo   	# Armazena o descritor do arquivo em desc_arquivo
    	jr $ra
    	
le_arquivo:
    	li      $v0, 14              	# Código do sistema para ler arquivo
    	lw      $a0, desc_arquivo    	# Carrega o descritor do arquivo
    	la      $a1, buff_leitura    	# Endereço do buffer de leitura
    	li      $a2, 1024               # Número de bytes a serem lidos (tamanho da instrução)
    	syscall                      	# Chamada do sistema
    	# Verifica erro
    	bltz    $v0, erro_leitura    	# Se $v0 < 0, houve um erro
    	jr      $ra
    	
pega_instrucao:
    	lw	$t0, n_instrucao	# Carrega qual o numero da instrucao que vai ser pega
    	la	$t1, buff_leitura	# Carrega buffer de leitura
    	# Operacao de pegar a instrucao desejada
    	add 	$t1, $t1, $t0		# Soma a posicao com o buffer para pegar apenas a instrucao desejada
    	lw      $t2, 0($t1)          	# Carrega a instrução lida no buffer temporário
    	la	$t1, instrucao		# Armazena o endereco da variavel de instrucao
    	sw      $t2, 0($t1)       	# Armazena a instrução na variavel instrucao
    	jr      $ra			

passa_instrucao:
	lw	$t0, n_instrucao	# Carrega qual o numero da instrucao que vai ser pega
	addi	$t0, $t0, 4		# Soma 4 (tamanho de uma instrucao)
    	sw	$t0, n_instrucao	# Atualiza valor do numero da instrucao
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
	sll     $t0, $a0, 5
	srl     $t0, $t0, 5
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
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_r
    	syscall                     	# Chamada do sistema
    	
	lw	$a0, instrucao
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
	
	jal imprime_rs
	jal imprime_rt
	jal imprime_rd
	jal imprime_shamt
	jal imprime_funct
	
	lw	$t0, funct
	beq  	$t0, 0x20, fadd
	
	retorno_tipo_r:
	j       ponto_retorno_decodificacao
tipo_i:
	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_i
    	syscall                     	# Chamada do sistema
    	
	lw	$a0, instrucao
	jal 	pega_rs
	sw 	$v0, r_s
	jal 	pega_rt
	sw 	$v0, r_t
	
	jal 	pega_int 		# Aceita numeros negativos (provavel que seja mudado)
	sw 	$v0, v_imediato
	
	jal imprime_rs
	jal imprime_rt
	jal imprime_int
	j       ponto_retorno_decodificacao

tipo_j:

	li      $v0, 4              	# Código do sistema para imprimir int
	la      $a0, str_tipo_j
    	syscall                     	# Chamada do sistema
    	lw	$a0, instrucao
	jal 	pega_endereco
	sw 	$v0, endereco
	jal imprime_end
	
	j       ponto_retorno_decodificacao
#######################
decodifica:
	addi    $sp, $sp, -4
	sw 	$ra, 0($sp)
	
	lw 	$a0, instrucao	
	jal 	pega_op
	sw 	$v0, op_code
	
	jal imprime_instrucao
	jal imprime_op_code
	
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
#### TIPO R ####
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
	la	$a1, instrucao
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
memoria_text:   .space 1024
memoria_data:   .space 1024
memoria_pilha:  .space 1024
end_text:   	.word 0x00400000
end_data:   	.word 0x10010000
end_pilha:  	.word 0x7FFFEFFC
##################################

### VARIAVEIS PARA MANIPULACAO DE ARQUIVO ###
buff_leitura:   .space 1024
desc_arquivo:   .word 0
instrucao:	.word 0

op_code:	.word 0
r_s:		.word 0
r_t:		.word 0
r_d:		.word 0
shamt:		.word 0
funct:		.word 0
endereco:	.word 0
v_imediato:	.word 0

n_instrucao:	.word 0
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

str_add:	.asciiz "\nadd "

#######
# ERRO #
msg_erro_abert: .asciiz "Erro ao abrir o arquivo\n"
msg_erro_leitura: .asciiz "Erro ao ler instrucao\n"
########
#####################################
