# Seja uma matriz tridimensional B de números inteiros, de 32 bits, com as dimensões 5 × 5 × 10. 
# Escreva um programa em assembly, para o processador MIPS, para
# ler e somar os elementos A1,3,7 e A2,2,3 e escrever o resultado no elemento A1,4,8 da
# matriz. Teste o código usando uma matriz global com os elementos Ai,j,k = i+j +k.
.data
B:	.space 1000		# 4⋅(5*5*10)
i:	.word 0
j:	.word 0
k:	.word 0
.text
main:
# MAPAS
#  REGS
#	$s0 = endereço base de B
#	$s1 = endereço de i
#	$s2 = endereço de j
#	$s3 = endereço de k
# 	$s4 = B[1][3][7] e B[1][3][7]+B[2][2][3]
# 	$s5 = B[2][2][3]
	la	$s0, B		# $s0 = end B
	la	$s1, i		# $s1 = end i
	la	$s2, j		# $s2 = end j
	la	$s3, k		# $s3 = end k
	jal	completa_matriz
	
	addi	$a0, $zero, 1
	addi	$a1, $zero, 3
	addi	$a2, $zero, 7
	jal	pega_end
	add	$t0, $s0, $v0	# $t0 = end B[1][3][7]
	lw	$s4, 0($t0)	# $s4 = B[1][3][7]
	
	addi	$a0, $zero, 2
	addi	$a1, $zero, 2
	addi	$a2, $zero, 3
	jal	pega_end
	add	$t0, $s0, $v0	# $t0 = end B[2][2][3]
	lw	$s5, 0($t0)	# $s5 = B[2][2][3]
	
	add	$s4, $s5, $s4	# $s4 = B[1][3][7]+B[2][2][3]
	
	addi	$a0, $zero, 1
	addi	$a1, $zero, 4
	addi	$a2, $zero, 8
	jal	pega_end
	add	$t0, $s0, $v0	# $t0 = end B[1][4][8]
	sw	$s4, 0($t0)	# B[1][4][8] = B[1][3][7]+B[2][2][3]
	
	addi	$a0, $zero 0
	addi	$v0, $zero, 17
	syscall 		# return 0;
# Endereço = base +4⋅(i+j*D2+k*D2*D3)
pega_end:
# MAPAS
#  REGS
#	$t0 e $t1 = valores temporarios
#  PARAMETROS
#	$a0 = i
#	$a1 = j
#	$a2 = k
	mul	$t0, $a1, 5	# $t0 = j*5
	mul	$t1, $a2, 5	# $t1 = k*5
	mul	$t1, $t1, 5	# $t1 = k*25
	
	add	$t0, $a0, $t0	# $t0 = i + j*5
	add	$t0, $t0, $t1	# $t0 = i + j*5 + k*25
	mul	$v0, $t0, 4	# $v0 = 4(i + j*5 + k*25)
	jr	$ra		# retorna para quem chamou
completa_matriz:
# MAPAS
#  REGS
#	$t1 = valor de i
#	$t2 = valor de j
#	$t3 = valor de k
#	$t4 = endereço de k
	sw	$zero, 0($s1)	# zera i
	sw	$zero, 0($s2)	# zera j
	sw	$zero, 0($s3)	# zera k
	lw	$t1, 0($s1)	# $t1 = i 
	lw	$t2, 0($s2)	# $t2 = j
	lw	$t3, 0($s3)	# $t3 = k
	for_k:
	move	$t2, $zero	# zera j
	for_j:
	move	$t1, $zero	# zera i
	for_i:
	mul	$t4, $t2, 5	# $t4 = j * 5 
	mul	$t5, $t3, 5	# $t5 = k * 5
	mul	$t5, $t5, 5	# $t5 = k * 25
	
	add	$t4, $t4, $t5	# $t4 = (j*5) + (k*25)
	add	$t4, $t4, $t1	# $t4 = (j*5) + (k*25) + i
	mul	$t4, $t4, 4	# $t4 = 4*[(j*5) + (k*25) + i]
	add	$t4, $t4, $s0	# $t4 = endereço solicitado + endereço base
	
	add	$t5, $t1, $t2	# $t5 = i+j
	add	$t5, $t5, $t3	# $t5 = i+j+k
	
	sw	$t5, 0($t4)	# B[i][j][k] = i+j+k
	addi	$t1, $t1, 1	# i++
	beq	$t1, 5, fora_i	# se i == 5 sai do loop i
	j	for_i		# folta para o inicio do loop i
	fora_i:
	addi	$t2, $t2, 1	# j++
	beq	$t2, 5, fora_j	# se j == 5 sai do loop j
	j	for_j		# folta para o inicio do loop j
	fora_j:
	addi	$t3, $t3, 1	# k++
	beq	$t3, 10, fora_k	# se j == 10 sai do loop k
	j	for_k		# folta para o inicio do loop k
	fora_k:
	jr	$ra		# Volta para onde chamou