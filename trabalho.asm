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
pega_op: # $v0 <-- op_code
	srl     $t0, $a0, 26
	move    $v0, $t0
	jr      $ra

pega_rs: # $v0 <-- r_s
	sll     $t0, $a0, 6
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra

pega_rt: # $v0 <-- r_t
	sll     $t0, $a0, 11
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
	
pega_rd: # $v0 <-- r_d
	sll     $t0, $a0, 16
	srl     $t0, $t0, 27
	move    $v0, $t0
	jr      $ra
	
decodifica:
	sw 	$ra, 0($sp)
	la	$sp, 4($sp)
	
	lw 	$a0, instrucao
	
	jal 	pega_op
	sw 	$v0, op_code
	jal 	pega_rs
	sw 	$v0, r_s
	jal 	pega_rt
	sw 	$v0, r_t
	jal 	pega_rd
	sw 	$v0, r_d
	
	jal imprime_instrucao
	jal imprime_op_code
	jal imprime_rs
	jal imprime_rt
	jal imprime_rd

	la	$sp, -4($sp)
	lw	$ra, 0($sp)
	jr      $ra

####################################

# Imprime instrucao
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
    	sw 	$ra, 0($sp)
	la	$sp, 4($sp)
	
	la	$a0, msg_instrucao
	la	$a1, instrucao
    	jal 	imprime_geral_hex
    	
    	la	$sp, -4($sp)
	lw	$ra, 0($sp)
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
#######

# ERRO #
msg_erro_abert: .asciiz "Erro ao abrir o arquivo\n"
msg_erro_leitura: .asciiz "Erro ao ler instrucao\n"
########

#####################################
