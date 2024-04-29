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
    # Abrir o arquivo para leitura
    li      $v0, 13             # Código do sistema para abrir arquivo
    la      $a0, nome_arquivo   # Endereço do nome do arquivo
    li      $a1, 0              # Modo de abertura (0 para leitura)
    syscall                     # Chamada do sistema

    # Verifica se houve erro ao abrir o arquivo
    bltz    $v0, erro_abertura

    # Lê a primeira instrução binária do arquivo
    la      $t0, desc_arquivo   # Endereço do descritor do arquivo
    move    $t1, $v0            # Move o descritor do arquivo para $t1
    sw      $t1, 0($t0)         # Armazena o descritor do arquivo em desc_arquivo

    li      $v0, 14             # Código do sistema para ler arquivo
    lw      $a0, 0($t0)         # Carrega o descritor do arquivo
    la      $a1, buff_leitura   # Endereço do buffer de leitura
    li      $a2, 4              # Número de bytes a serem lidos (tamanho da instrução)
    syscall                     # Chamada do sistema

    # Exibe a instrução binária lida
    li      $v0, 4              # Código do sistema para imprimir string
    la      $a0, msg_instrucao  # Endereço da mensagem "Instrução binária lida: "
    syscall                     # Chamada do sistema

    # Exibe os bytes da instrução binária
    move    $a0, $a1            # Endereço do buffer de leitura
    li      $a1, 4              # Número de bytes a serem exibidos
    li      $v0, 34             # Código do sistema para imprimir bytes em hexadecimal
    syscall                     # Chamada do sistema

    # Fecha o arquivo
    li      $v0, 16             # Código do sistema para fechar arquivo
    syscall                     # Chamada do sistema

    # Termina o programa
    li      $v0, 10             # Código do sistema para encerrar o programa
    syscall                     # Chamada do sistema

# Tratamento de erro ao abrir o arquivo
erro_abertura:
    li      $v0, 4              # Código do sistema para imprimir string
    la      $a0, msg_erro_abertura # Endereço da mensagem de erro
    syscall                     # Chamada do sistema

    # Termina o programa
    li      $v0, 10             # Código do sistema para encerrar o programa
    syscall                     # Chamada do sistema

.data
#memory:       .word 0xABCDE080

PC:         	.word 0
IR:         	.word 0
regs:       	.space 128
memoria_text:   .space 1024
memoria_data:   .space 1024
memoria_pilha:  .space 1024
end_text:   	.word 0x00400000
end_data:   	.word 0x10010000
end_pilha:  .word 0x7FFFEFFC

desc_arquivo:   .word 0
nome_arquivo:   .asciiz "trabalho_01-2024_1.bin"

msg_instrucao: .asciiz "Instrução binária lida: "
msg_erro_abertura: .asciiz "Erro ao abrir o arquivo\n"

buff_leitura:   .space 32

