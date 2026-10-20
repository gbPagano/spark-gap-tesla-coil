#import "template/lib.typ": conf
#import "template/fig.typ": abnt-figure, abnt-image, abnt-tabela, abnt-quadro
#import "template/pretextuais.typ": apendice, anexo, glossario
#import "template/citacoes.typ": citacao-longa
#import "template/titulos.typ": titulo-sem-numero

// Introdução em desenvolvimento; os demais capítulos permanecem em esqueleto.
// Resumo e abstract permanecem vazios; os avisos do template indicam
// os requisitos de preenchimento para a versão final.
#show: conf.with(
  universidade: "UNIVERSIDADE FEDERAL DE UBERLÂNDIA",
  faculdade: "Curso de Engenharia Elétrica",
  autores: (
    "Guilherme Borges Pagano - 12111EEL020",
  ),
  titulo: "Projeto e validação experimental de uma bobina de Tesla com centelhador baseada em circuitos ressonantes acoplados",
  cidade: "Uberlândia",
  ano: "2026",
  natureza: "Trabalho de Conclusão de Curso apresentado à Faculdade de Engenharia Elétrica da Universidade Federal de Uberlândia como requisito parcial para a obtenção do título de Bacharel em Engenharia Elétrica.",
  orientador: "Prof. Luiz Carlos Gomes de Freitas",
  resumo: "",
  palavras-chave: (),
  abstract: "",
  keywords: (),
  // Preencher os demais elementos pré-textuais quando houver dados reais:
  // ficha, aprovacao, dedicacao, agradecimentos, epigrafe, siglas e simbolos.
)

= Introdução

Este trabalho aborda o projeto e a construção de uma bobina de Tesla com
centelhador e a validação experimental de seu modelo de circuitos ressonantes
acoplados. O estudo incluirá a operação do protótipo com acionamento pelo
centelhador e produção de descargas elétricas no secundário. Em uma etapa
distinta, serão realizados ensaios de caracterização em baixa energia, sem
descargas no secundário, para comparar os valores previstos e medidos das
frequências naturais e do amortecimento.

== Contextualização e aplicações

A bobina de Tesla é um transformador ressonante com núcleo de ar destinado à
geração de altas tensões em alta frequência. Em 1891, Nikola Tesla descreveu,
na patente US 454.622, um sistema de iluminação elétrica que empregava a
descarga oscilatória de um capacitor em um circuito primário para induzir altas
tensões em um circuito secundário @tesla1891-lighting.

Na configuração clássica com centelhador, denominada SGTC, do inglês
_spark gap Tesla coil_, uma fonte de alta tensão carrega o capacitor primário.
Quando o centelhador conduz, fecha-se a malha oscilatória primária e inicia-se
a transferência de energia ao secundário por acoplamento magnético. Esse
princípio de funcionamento está descrito na patente de
#cite(<tesla1891-lighting>, form: "prose").

Na aproximação por parâmetros concentrados, os circuitos primário e secundário
são representados por dois circuitos ressonantes magneticamente acoplados, com
resistência (R), indutância (L) e capacitância (C), denominados circuitos RLC.
A análise desses circuitos considera a indutância mútua e a sintonia dos
ressonadores, de modo que a elevação de tensão não depende apenas da razão
entre os números de espiras @terman1943.

O primário também pode ser acionado por semicondutores. Nas bobinas de estado
sólido, denominadas SSTC, do inglês _solid state Tesla coil_,
o primário é excitado eletronicamente, sem o tanque ressonante primário da
configuração clássica. A topologia DRSSTC, do inglês
_double resonant solid state Tesla coil_, incorpora esse tanque ao acionamento
eletrônico, formando um sistema de dupla ressonância. As topologias diferem
quanto à alimentação do ressonador e aos recursos de controle do acionamento
@wasatonic2013.

Bobinas de Tesla são empregadas na geração de pulsos de alta tensão, em ensaios
de materiais isolantes e no estudo de descargas elétricas @denicolai2001.
Também são utilizadas em demonstrações educacionais de ressonância, acoplamento
magnético e ruptura dielétrica @wasatonic2013. Esses usos abrangem diferentes
montagens e regimes de operação, para os quais a adequação do modelo e do
protótipo deve ser avaliada.

== Problema de pesquisa

O dimensionamento de uma bobina de Tesla requer estimativas de indutâncias,
capacitâncias e perdas, além da definição do acoplamento entre os enrolamentos.
O secundário, porém, apresenta parâmetros distribuídos e pode sustentar
ressonâncias que um único circuito RLC não descreve integralmente. Por isso,
a aproximação por parâmetros concentrados deve ser avaliada na faixa de
frequência e nas condições de carregamento em que será utilizada @craven2014.
A medição também deve considerar o carregamento capacitivo da instrumentação:
Voitkāns e Voitkāns (#cite(<voitkans2014>, form: "year")) observaram que a
conexão de pequenas capacitâncias alterava as condições do ressonador.

No modelo de dois circuitos ressonantes acoplados, as frequências dos dois
modos naturais dependem do coeficiente de acoplamento e dos parâmetros dos
circuitos. A superposição dos modos produz batimentos na resposta transitória,
enquanto as perdas determinam o amortecimento @denicolai2001. Na comparação
experimental, a transferência de energia entre os circuitos deve ser
distinguida da dissipação. A ressonância do secundário com a malha primária
aberta também deve ser analisada separadamente dos modos do sistema acoplado.

Em que medida um modelo linear de circuitos RLC magneticamente acoplados
descreve as frequências naturais e o amortecimento de um protótipo de bobina de
Tesla com centelhador, em ensaios de caracterização em baixa energia, sem
descargas no secundário, considerando a variação do acoplamento, as
configurações do terminal capacitivo e as incertezas associadas às medições?

Os resultados analíticos, simulados e medidos serão comparados para as mesmas
grandezas. A comparação entre a solução analítica e a integração numérica
servirá à verificação da implementação; a comparação com as medições, à
validação do modelo. Serão distinguidas as previsões nominais, definidas antes
da coleta, das previsões atualizadas com parâmetros medidos e daquelas obtidas
com parâmetros ajustados às respostas experimentais. A reprodução dos dados
usados para identificar parâmetros não será considerada validação independente.

== Objetivos

Será construído um protótipo de duas bobinas com centelhador estático. As
topologias SSTC e DRSSTC serão abordadas apenas na revisão bibliográfica.
A validação se limitará aos modos de interesse do modelo RLC concentrado e não
abrangerá a distribuição espacial no secundário nem a dinâmica não linear do
centelhador e das descargas.

=== Objetivo geral

Projetar e construir uma bobina de Tesla com centelhador e avaliar a validade
do modelo linear de circuitos RLC magneticamente acoplados, comparando as
frequências naturais e o amortecimento obtidos por métodos analíticos,
simulação e medição em ensaios de caracterização em baixa energia.

=== Objetivos específicos

+ Descrever o princípio de funcionamento das bobinas de Tesla e comparar as
  topologias SGTC, SSTC e DRSSTC em revisão bibliográfica;
+ Implementar o modelo matemático de circuitos RLC magneticamente acoplados,
  com indutância mútua, perdas e a energia inicial do capacitor primário;
+ Dimensionar o protótipo por métodos analíticos convencionais;
+ Comparar o dimensionamento analítico com as estimativas das ferramentas
  WinTesla e JavaTC;
+ Simular o comportamento transitório do sistema acoplado em simulador de
  circuitos ou por integração numérica das equações;
+ Construir um protótipo funcional de bobina de Tesla com centelhador;
+ Medir as indutâncias, as capacitâncias e o coeficiente de acoplamento do
  protótipo;
+ Traçar a curva experimental de separação entre as frequências dos modos
  naturais em função do coeficiente de acoplamento, mediante variação da altura
  do primário;
+ Avaliar o fator de qualidade do secundário pela técnica do decaimento livre
  (_ring-down_), bem como os efeitos do terminal capacitivo e do ponto de
  descarga (_breakout_) na frequência de ressonância e no amortecimento;
+ Caracterizar, de forma complementar, o desempenho de descarga do protótipo
  pelo registro do comprimento das descargas e da taxa de repetição do
  centelhador;
+ Quantificar as diferenças relativas entre os resultados analíticos, simulados
  e medidos e elaborar o orçamento de incerteza das medições conforme o Guia
  para a Expressão da Incerteza de Medição (GUM).

Nos ensaios de caracterização em baixa energia, a fonte de alta tensão
permanecerá desconectada. Para analisar os modos acoplados, o centelhador será
substituído, no circuito de ensaio, por uma ligação condutora que representa
seu estado de condução e mantém a malha primária fechada. No _ring-down_ do
secundário, essa malha permanecerá aberta, considerando-se o carregamento
residual da medição. O fator de qualidade do secundário será avaliado
separadamente dos fatores de qualidade dos modos acoplados.

Na etapa de operação com descargas, o centelhador realizará o chaveamento do
circuito primário. Serão registrados o comprimento das descargas no secundário
e a taxa de repetição do centelhador. Essa avaliação funcional será distinta
da validação do modelo linear.
A obtenção de descargas de aproximadamente 1 m é uma meta prática complementar.
Esse comprimento não será usado como critério de validade do modelo nem
apresentado como desempenho garantido.

Os ensaios dependerão de autorização e de supervisão, e seguirão os
procedimentos do laboratório e as medidas de controle de risco previstas na
Norma Regulamentadora nº 10 (NR-10) @nr10-2019.

== Justificativa e contribuição esperada

A motivação formativa da pesquisa é aplicar conhecimentos de circuitos
elétricos, eletromagnetismo, altas tensões e medidas elétricas à construção e à
avaliação do protótipo. O dimensionamento dos componentes será relacionado à
modelagem e à análise dos transitórios. A caracterização dos parâmetros e o
planejamento das medições serão acompanhados do registro das decisões técnicas
e das limitações encontradas. O protótipo e a documentação também poderão
subsidiar futuras atividades didáticas, condicionadas aos requisitos de
segurança e de uso dos laboratórios.

#cite(<denicolai2001>, form: "prose") descreve o projeto, a modelagem e a
caracterização de uma bobina de Tesla, com ajustes de parâmetros para
reproduzir respostas transitórias. #cite(<craven2014>, form: "prose")
investiga modelos do secundário, modos superiores e fator de qualidade,
considerando os efeitos do terminal e do carregamento da medição. No relato
técnico de #cite(<queiroz2006>, form: "prose"), a sintonia e a observação dos
transitórios em baixa potência antecedem a operação com descargas. Esses
estudos de comparação entre métodos e de medição do fator de qualidade
orientam a estratégia experimental da pesquisa.

A contribuição esperada tem caráter aplicado: avaliar uma mesma SGTC de forma
integrada e rastreável, relacionando o dimensionamento à montagem final, aos
parâmetros medidos e às respostas do sistema. Essa avaliação reunirá a curva de
separação entre as frequências modais em função do acoplamento, a caracterização
do decaimento livre do secundário e a comparação de configurações do terminal
capacitivo e do ponto de descarga. Os dados brutos, as entradas computacionais e os procedimentos de
análise serão preservados para reexecutar as comparações e distinguir o
desempenho das previsões nominais daquele obtido após atualização ou ajuste de
parâmetros.

Conforme o GUM, um resultado de medição é uma estimativa que deve ser
acompanhada de sua incerteza, e correlações relevantes entre grandezas de entrada
devem ser consideradas nessa avaliação @jcgm100-2008. As diferenças relativas
entre previsões e medições serão discutidas considerando o orçamento de
incerteza e as condições de ensaio. A análise buscará identificar a adequação e
os limites do modelo nas
configurações investigadas, inclusive diante de resultados incompatíveis ou
inconclusivos.

= Fundamentação teórica e trabalhos correlatos

== Princípio de funcionamento e ciclo de operação da SGTC

== Comparação entre SGTC, SSTC e DRSSTC

== Ressonância, sintonia e acoplamento magnético

== Transferência de energia, batimentos e dissipação

== Amortecimento e fator de qualidade

== Capacitância própria, terminal capacitivo e influência do ambiente

A capacitância do ressonador secundário inclui as contribuições do enrolamento,
do terminal capacitivo superior (_top-load_) e do ambiente @denicolai2001.

== Modelos concentrados e distribuídos

== Síntese crítica dos trabalhos correlatos

== Posicionamento e contribuição deste trabalho

= Metodologia

== Estratégia e etapas da pesquisa

== Grandezas investigadas e configurações de referência

== Instrumentação, condições de ensaio e segurança

== Procedimentos de caracterização em baixa energia

=== Medição de indutâncias e capacitâncias

=== Determinação da indutância mútua e do coeficiente de acoplamento

=== Varredura de frequência e identificação dos modos

=== Variação da altura do primário e levantamento da separação modal

=== Decaimento livre (ring-down), amortecimento e fator de qualidade do secundário

=== Comparação das configurações de terminal capacitivo e ponto de descarga

== Demonstração funcional e caracterização complementar das descargas

== Tratamento, rastreabilidade e preservação dos dados

== Erros relativos e orçamento de incerteza conforme o GUM

== Critérios de comparação e interpretação das discrepâncias

= Modelagem matemática e simulação

== Circuito equivalente, parâmetros e convenções de sinais

== Hipóteses e domínio de validade

== Equações diferenciais e representação em espaço de estados

== Condições iniciais e energia armazenada no capacitor primário

== Frequências desacopladas e modos naturais em função do acoplamento

== Polos, amortecimento e fator de qualidade modal

== Respostas transitórias e transferência de energia

== Implementação numérica e verificação de consistência

== Sensibilidade aos parâmetros e às perdas

= Projeto, dimensionamento e construção do protótipo

== Requisitos de projeto e restrições práticas

== Seleção e justificativa da fonte de alimentação

== Dimensionamento do secundário

=== Geometria, fio e número de espiras

=== Indutância e autocapacitância

== Terminal capacitivo e ponto de descarga

== Dimensionamento do primário e faixa de sintonia

== Capacitor primário e centelhador estático

== Dimensionamento no JavaTC e WinTesla

== Consolidação dos parâmetros e previsões nominais

== Construção e integração dos subconjuntos

== Proteções, estrutura e aterramento de radiofrequência

== Montagem final conforme construída e alterações de projeto

= Resultados e discussão

== Parâmetros previstos, construídos e medidos

== Comparação do dimensionamento analítico com JavaTC e WinTesla

== Comparação das frequências analíticas, simuladas e medidas

== Curva experimental de separação modal em função do acoplamento

== Decaimento livre, amortecimento e fator de qualidade

== Efeitos do terminal capacitivo e do ponto de descarga

== Erros relativos, incertezas e análise das discrepâncias

== Demonstração funcional e desempenho complementar de descarga

== Adequação e limites do modelo nas condições investigadas

= Conclusões

== Resposta ao problema de pesquisa e principais resultados

== Atendimento dos objetivos específicos

== Limitações experimentais e de modelagem

== Recomendações para trabalhos futuros

// O banco pode conter obras ainda não usadas: apenas as citadas entram no PDF.
#titulo-sem-numero("Referências", sumario: true)
#[
  #set par(
    leading: 1.15em - 0.693em,
    spacing: 1.6em,
    justify: false,
    first-line-indent: 0em,
  )
  #bibliography(
    "referencias.yml",
    title: none,
    full: false,
    // Ajuste local: exibir a data mesmo quando a editora não foi informada.
    style: "template/abnt-datas.csl",
  )
]

#apendice("A", "Derivações matemáticas", [])

#apendice("B", "Memórias de dimensionamento", [])

#apendice("C", "Entradas e saídas das ferramentas computacionais", [])

#apendice("D", "Desenhos e lista de materiais", [])

#apendice("E", "Orçamentos detalhados de incerteza", [])

#apendice("F", "Protocolos, registros de dados e reprodução da análise", [])
