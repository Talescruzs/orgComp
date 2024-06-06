# Simulador de processador MIPS
Neste repositório será explicado o funcionamento e caracteristicas do código em assembly MIPS que simula um processador MIPS.
O código do arquivo mips.asm recebe o arquivo algumaCoisa.bin e outraCoisa.dat
### IDE utilizada
Para realizar a simulação foi utilizado o simulador MIPS chamado MARS
## Funções Assembly MIPS simuladas
### Tipo r
* jr
* add
* addu
### Tipo i
* bne
* addi
* addiu
* lui
* ori
* mul
* sw
* lw
### Tipo j
* jal
* j
### Syscalls
* $v0 = 1 (imprimir int)
* $v0 = 4 (imprimir str)
* $v0 = 11 (imprimir char)
* $v0 = 17 (exit)
