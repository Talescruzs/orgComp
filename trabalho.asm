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
    	jal le_instrucao
    	jal imprime_instrucao
    	
    	li      $v0, 10             	# Código do sistema para encerrar o programa
    	syscall     

# Abre arquivo para leitura
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
                   	
# Lê uma instrução do arquivo binário
le_instrucao:
    	li      $v0, 14              	# Código do sistema para ler arquivo
    	lw      $a0, desc_arquivo    	# Carrega o descritor do arquivo
    	la      $a1, buff_leitura    	# Endereço do buffer de leitura
    	li      $a2, 4               	# Número de bytes a serem lidos (tamanho da instrução)
    	syscall                      	# Chamada do sistema
    	# Verifica erro
    	bltz    $v0, erro_leitura    	# Se $v0 < 0, houve um erro
    	# Carrega a instrução lida no buffer temporário para variavel de instrucao
    	lw      $t0, 0($a1)          	# Carrega a instrução lida no buffer temporário
    	la	$t1, instrucao		# Armazena o endereco da variavel de instrucao
    	sw      $t0, 0($t1)       	# Armazena a instrução na variavel instrucao
    	jr      $ra

# Imprime instrucao
imprime_instrucao:
    	# Exibe a instrução binária lida
    	li      $v0, 4              	# Código do sistema para imprimir string
    	la      $a0, msg_instrucao  	# Endereço da mensagem "Instrução binária lida: "
    	syscall                     	# Chamada do sistema

    	# Exibe os bytes da instrução binária
	lw	$a0, instrucao          # Endereço do buffer de leitura
    	li      $v0, 34             	# Código do sistema para imprimir bytes em hexadecimal
    	syscall                     	# Chamada do sistema

    	# Fecha o arquivo
    	li      $v0, 16             	# Código do sistema para fechar arquivo
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
buff_leitura:   .word 0
desc_arquivo:   .word 0
instrucao:	.word 0
n_instrucao:	.word 0
nome_arquivo:   .asciiz "trabalho_01-2024_1.bin"
#############################################

############## STRINGS ##############

# I/O #
msg_instrucao: 	.asciiz "\nInstrução binária lida: "
#######

# ERRO #
msg_erro_abert: .asciiz "Erro ao abrir o arquivo\n"
msg_erro_leitura: .asciiz "Erro ao ler instrucao\n"
########

#####################################
