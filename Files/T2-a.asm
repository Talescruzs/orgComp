# Traduza o seguinte programa em C, para o assembly do processador MIPS. Comente
# bem o seu código. Indique nos comentários o trecho do código em C que está
# sendo traduzido. Faça o mapa da pilha para cada um dos procedimentos. Compile
# e execute o seu programa assembly usando o programa MARS. Quais os valores
# de inc1, inc2, g1 e g2 antes e após a execução dos procedimentos incrementa1 e
# incrementa2?

.data
# int g1; // variável global
g1:	.word 0
# int g2; // variável global
g2:	.word 0

.text
_init:
	j	main
_f_init:
	addi	$v0, $zero, 17
	addi	$a0, $zero, 0
	syscall
# // y: ponteiro para um inteiro
# int incrementa2(int *y) {
incrementa2:
# MAPAS:
#  REGS:
#	$t0 = valor temporario
#	$a0 = endereço apontado por y
#	$v0 = retorno, valor apontado por y somado de 1
# *y = *y + 1;
	lw 	$t0, 0($a0)	# $t0 = valor apontado por y
	addi 	$t0, $t0 1	# $t0 = *y + 1
	sw	$t0, 0($a0)	# Endereço apontado por y = $t0
# return *y;
	move	$v0, $t0	# $v0 = *y + 1
	jr	$ra
# }

# // x: um valor inteiro
# int incrementa1(int x) {
incrementa1:
# MAPAS:
#  REGS:
#	$a0 = valor de x
#	$v0 = retorno, de x somado de 1
# x = x + 1;
	addi	$v0, $a0, 1
# return x;
	jr	$ra
# }
# int main(void) {
main:
# MAPAS:
#  REGS:
#	$a0 = valor de x
#	$v0 = retorno, de x somado de 1
#	$s0 = inc1
#	$s1 = inc2
#	$s2 = g1
#	$s3 = g2
#  PILHA:
#	$0(sp) = inc1
#	$4(sp) = inc2
#	$8(sp) = g1
#	$12(sp) = g2
	addiu	$sp, $sp, -16
# int inc1; // variável local
	lw	$s0, 0($sp)
# int inc2; // variável local
	lw	$s1, 4($sp)
# g1 = 10;
	addi	$s2, $zero, 10
	sw	$s2, 8($sp)
# g2 = 10;
	addi	$s3, $zero, 10
	sw	$s3, 12($sp)
# inc1 = incrementa1(g1);
	move	$a0, $s2
	jal	incrementa1
	move	$s0, $v0
	sw	$s0, 0($sp)
# inc2 = incrementa2(&g2);
	addi	$a0, $sp, 12
	jal	incrementa2
	sw	$v0, 4($sp)
# return 0;
	addiu	$sp, $sp, 16
	j	_f_init
#}
