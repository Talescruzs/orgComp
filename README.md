# Simulador de processador MIPS
Neste repositório será explicado o [fluxo de funcionamento](#fluxo-de-funcionamento), [funcionalidades simuladas](#funções-assembly-mips-simuladas) e [limitações](#limitações) do código. <br>
Bem como as [instruções](#instruções) para realização do trabalho de organização de computadores ELC1011 do primeiro semestre de 2024 no curso de Sistemas de Informação da UFSM. <br>
O código do arquivo mips.asm recebe o arquivo trabalho_01-2024_1.bin (contendo os comandos do programa) e trabalho_01-2024_1.dat (contendo os dados usados no programa)
### IDE utilizada
Para realizar a simulação foi utilizado o simulador MIPS chamado [MARS](http://courses.missouristate.edu/KenVollmar/MARS/)

## Instruções
No primeiro trabalho do curso será desenvolvido um programa para simular um subconjunto de instruções do
processador MIPS. O simulador do processador será escrito em linguagem assembly para o processador MIPS.
O trabalho pode ser realizado individualmente ou em uma equipe de no máximo dois alunos.
A entrega do trabalho será realizada por meio da ferramenta Moodle, até a data da 1ª prova1 .
Para a avaliação do trabalho, envie um arquivo compactado (tipo ZIP) contendo o relatório do trabalho (em PDF)
e os arquivos-fontes dos programas desenvolvidos. O relatório do trabalho deve conter as seguintes seções:
introdução, objetivos, revisão bibliográfica, metodologia, experimento, resultados, discussão e conclusões e
perspectivas. O código-fonte deve estar completo e comentado.
Uma ilustração do primeiro projeto da disciplina ELC1011, do primeiro semestre de 2024, é apresentado na
[Figura 1](./Images/fig1.png): Ilustração do primeiro projeto da disciplina ELC1011.

O programa lerá o arquivo binário trabalho_01-2024_1.bin, contendo as instruções que serão simuladas.
Estas instruções, em linguagem de máquina, serão armazenadas na memória usada pelo simulador. As
instruções do arquivo binário calculam o fatorial de 5, apresentando o resultado em um terminal. Também é
incluído o arquivo trabalho_01-2024_1.asm, em assembly, utilizado para a montagem do arquivo binário.
As instruções deste arquivo binário serão lidas, decodificadas e executadas pelo programa simulador, como
mostra a [Figura 2](./Images/fig2.png): Estados simulados do processador: busca da instrução B, decodificação da instrução D e execução da instrução E.

No estado B, na busca da instrução, o programa lê uma instrução na memória do simulador e armazena em
um registrador IR (Instruction Register ). A instrução lida depende do endereço do registrador PC (Program
Counter ). No próximo estado do simulador, estado D, é realizada a decodificação da instrução. Neste estado,
a instrução é separada em seus campos e verificada a operação que deve ser realizada pelo simulador do
processador MIPS. Neste estado também incrementamos o registrador PC. No estado E, execução da instrução,
a instrução decodificada é executada. Na sequência, voltamos ao estado B e o ciclo recomeça para a próxima
instrução.
Os arquivos binário e em assembly estão na pasta ’arquivos de entrada’. O professor acompanhará e auxiliará
os alunos no desenvolvimento do simulador e realizará atividades em sala de aula para auxiliar a execução
do trabalho. Um documento de ajuda será mantido com as perguntas e respostas frequentes (FAQ) e será
atualizado ao longo da execução do trabalho. Utilize o documento de ajuda como referência para dúvidas
frequentes. Em caso de dúvidas não contempladas no FAQ, entre em contato com o professor.
## Fluxo de Funcionamento
TODO
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
## Limitações
TODO
