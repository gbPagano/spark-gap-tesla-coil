#import "template/lib.typ": conf
#import "template/fig.typ": abnt-figure, abnt-image, abnt-tabela, abnt-quadro
#import "template/pretextuais.typ": apendice, anexo, glossario
#import "template/citacoes.typ": citacao-longa
#import "template/titulos.typ": titulo-sem-numero

// Introdução, fundamentação e metodologia redigidas, sujeitas à revisão;
// os capítulos seguintes permanecem em esqueleto.
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

= Fundamentação teórica

A descrição teórica da bobina de Tesla relaciona a excitação do primário à
transferência de energia e à resposta do secundário. Para a análise em baixa
energia, adota-se a aproximação por circuitos ressonantes acoplados, com perdas
representadas por resistências equivalentes. Sua aplicação requer definir as
condições de sintonia e acoplamento e considerar os efeitos das capacitâncias
e da distribuição espacial de tensão e corrente no secundário.

// Espaços reservados da versão de trabalho. Substituir pelos arquivos das
// figuras e informar sua autoria/origem antes da versão final.
#let figura-prevista(titulo, descricao) = abnt-figure(
  rect(
    width: 100%,
    height: 4.2cm,
    inset: 12pt,
    stroke: 0.5pt + luma(70%),
    fill: luma(97%),
    align(center + horizon)[
      #set text(size: 10pt, fill: luma(40%))
      #set par(first-line-indent: 0em, justify: false)
      Espaço reservado para figura

      #descricao
    ],
  ),
  title: titulo,
  source: [A definir na inserção da figura.],
)

== Princípio de funcionamento e ciclo de operação da SGTC

Na SGTC clássica, uma fonte de alta tensão carrega o capacitor primário, cuja
descarga é chaveada pelo centelhador. O primário tem poucas espiras de condutor
de maior seção, e o secundário, muitas espiras de fio fino sobre um suporte
isolante. O terminal metálico superior e as capacitâncias distribuídas do
enrolamento participam da ressonância do secundário @wasatonic2013.

Enquanto o centelhador está aberto, a fonte carrega o capacitor. Quando a tensão
entre os eletrodos provoca a ruptura dielétrica do ar, forma-se um caminho
condutor que fecha a malha do capacitor com o enrolamento primário. A descarga
oscilatória nessa malha é o mecanismo de excitação descrito por
#cite(<tesla1891-lighting>, form: "prose"). A @fig-circuito-sgtc indica as
ligações correspondentes às etapas de carga e de condução.

#figura-prevista(
  [Circuito de princípio da SGTC nas etapas de carga do capacitor e condução do centelhador],
  [Esquema em dois painéis: fonte de alta tensão, capacitor primário, centelhador, enrolamentos acoplados, terminal capacitivo e referência de terra; destacar o caminho de corrente em cada etapa.],
) <fig-circuito-sgtc>

Durante a condução, a energia oscila entre os campos elétricos e magnéticos dos
circuitos. O acoplamento transfere energia ao secundário ao longo de vários
ciclos. Na condição de sintonia, a envoltória da tensão secundária cresce
inicialmente enquanto a das oscilações primárias diminui. Se o centelhador
continuar conduzindo, parte da energia retorna ao primário. Os dois modos do
conjunto produzem batimentos, com redução progressiva da energia total pelas
perdas nos componentes e no centelhador. Quando a tensão secundária inicia
descargas no ar, essas descargas também retiram energia do ressonador
@queiroz2006.

A interrupção da condução é denominada extinção, ou _quenching_. A abertura da
malha em um mínimo de energia no primário impede o retorno da energia por esse
circuito; na descrição idealizada, a energia remanescente decai no secundário.
Para que a condução cesse, a corrente precisa deixar de sustentar a descarga
e o meio entre os eletrodos deve recuperar capacidade isolante suficiente para
evitar a reignição. Isso pode ocorrer depois do primeiro mínimo
@burnett-quenching. Com o centelhador novamente aberto, o capacitor primário
volta a ser carregado, permitindo outro disparo.

No centelhador estático, a taxa de repetição depende da tensão aplicada, da
capacitância primária e das condições de ruptura do ar. Cada disparo inicia
um transitório com vários ciclos de alta frequência. A taxa de disparos,
as frequências dessas oscilações e a frequência da alimentação são grandezas
distintas. Observar a repetição das descargas não basta para determinar as
frequências naturais ou o amortecimento dos circuitos.

== Comparação entre SGTC, SSTC e DRSSTC

SGTC, SSTC e DRSSTC diferem pelo acionamento e pela presença de um tanque
ressonante no primário, conforme os circuitos da
@fig-circuitos-topologias e a comparação do @quadro-topologias. Na SGTC, a
energia de cada transitório é acumulada no capacitor antes do disparo. O
centelhador fecha a malha de descarga, e sua condução depende das condições
de manutenção e extinção do arco. No rotativo, a posição dos eletrodos também
determina os instantes em que o disparo pode ocorrer; a duração da condução
continua sem controle eletrônico independente.

Na SSTC, uma ponte de semicondutores alimentada por um barramento contínuo
aplica tensão alternada ao primário, com frequência escolhida em função da
ressonância do secundário. Na configuração de ressonância simples, não há
capacitor dimensionado para formar um tanque com o primário. Um capacitor
usado apenas para bloquear a componente contínua não exerce essa função.

A DRSSTC tem um capacitor de tanque em série com o primário e recebe energia
do barramento durante os ciclos de acionamento. A realimentação de corrente
permite acompanhar a oscilação e comutar próximo das passagens por zero da
corrente. O sinal de interrupção define os intervalos de excitação e sua
repetição, limitando o tempo de crescimento da corrente no tanque. A SGTC e a
DRSSTC têm, assim, dois ressonadores, excitados sob condições diferentes: na
primeira, o transitório parte da descarga do capacitor; na segunda, a ponte
continua fornecendo energia durante o acionamento.

#figura-prevista(
  [Circuitos de acionamento das topologias SGTC, SSTC e DRSSTC],
  [Três esquemas com o mesmo secundário: descarga por centelhador, ponte eletrônica sem tanque primário e ponte eletrônica com capacitor de tanque em série. Identificar a função de cada capacitor.],
) <fig-circuitos-topologias>

#[
  #set text(size: 10pt)
  #set par(leading: 0.35em, spacing: 0em, first-line-indent: 0em, justify: false)
  #set table(inset: 5pt)
  #abnt-quadro(
    title: [Comparação dos princípios de acionamento de SGTC, SSTC e DRSSTC],
    source: [Elaborado pelo autor, com base em #cite(<wasatonic2013>, form: "prose").],
    columns: (0.19fr, 0.27fr, 0.27fr, 0.27fr),
    align: left + top,
    table.header([Aspecto], [SGTC], [SSTC], [DRSSTC]),
    [Chaveamento],
    [Centelhador estático ou rotativo.],
    [Ponte de semicondutores.],
    [Ponte de semicondutores.],
    [Tanque ressonante primário],
    [Presente.],
    [Ausente na configuração de ressonância simples.],
    [Presente.],
    [Fornecimento de energia],
    [Capacitor carregado antes do disparo.],
    [Barramento contínuo durante o acionamento.],
    [Barramento contínuo durante o acionamento do tanque.],
    [Temporização],
    [Vinculada à carga e à ruptura do centelhador; o rotativo também impõe instantes de aproximação dos eletrodos.],
    [Definida pelo circuito de acionamento e por eventual interrupção.],
    [Intervalos de excitação e repetição definidos pelo controle eletrônico.],
    [Limitações do acionamento],
    [Perdas no centelhador e dificuldade de controlar sua extinção.],
    [Esforços nos semicondutores e adequação da frequência de excitação.],
    [Corrente crescente no tanque, exigindo controle e proteção dos semicondutores.],
  ) <quadro-topologias>
]

O projeto de #cite(<obeidat2023>, form: "prose") emprega ponte completa,
realimentação e interrupção programada em uma DRSSTC. Já
#cite(<wasatonic2013>, form: "prose") compara o acionamento eletrônico
duplamente ressonante com um centelhador rotativo no mesmo ressonador. Nessa
comparação, a relação entre comprimento de descarga e alimentação dependeu
da duração e da repetição dos pulsos. Os resultados se aplicam às condições
ensaiadas, sem estabelecer uma vantagem fixa de uma topologia. A construção
deste trabalho se restringe à SGTC; SSTC e DRSSTC são tratadas na revisão
bibliográfica.

== Ressonância, sintonia e acoplamento magnético

Em um RLC série com parâmetros constantes, a ressonância de corrente ocorre
quando as reatâncias indutiva e capacitiva se cancelam. A frequência depende
do produto entre indutância e capacitância
#cite(<terman1943>, supplement: [p. 135-136]). Para o primário e o secundário
considerados separadamente,

$
  f_(0 p) = 1 / (2 pi sqrt(L_p C_p)),
  quad
  f_(0 s) = 1 / (2 pi sqrt(L_s C_s)),
$ <eq-frequencias-desacopladas>

em que $p$ e $s$ identificam primário e secundário. $L_p$ e $L_s$ são as
indutâncias, $C_p$ é a capacitância primária e $C_s$ é a capacitância equivalente
do secundário. Essas são também as frequências naturais não amortecidas de
cada RLC isolado. A sintonia nominal corresponde a
$f_(0 p) = f_(0 s) = f_0$, ou $L_p C_p = L_s C_s$.

O acoplamento magnético depende da indutância mútua $M$, que relaciona a
variação de corrente em um enrolamento à tensão induzida no outro. Define-se
o coeficiente de acoplamento por

$ k = abs(M) / sqrt(L_p L_s). $ <eq-coeficiente-acoplamento>

Adota-se $0 <= k < 1$; o sinal dos termos de indutância mútua nas equações
depende dos sentidos dos enrolamentos e das referências de corrente. A posição
relativa das bobinas altera $M$ e $k$. O deslocamento vertical do primário
permite, portanto, variar o acoplamento. A sintonia precisa ser verificada
em cada posição, pois a alteração mecânica não assegura a igualdade dos
produtos LC.

Com os circuitos acoplados, as oscilações livres pertencem aos modos do
conjunto. No caso sem perdas, com sintonia exata e $k > 0$, a condição de
oscilação obtida da resposta de circuitos acoplados de
#cite(<terman1943>, form: "prose", supplement: [p. 149-155]) fornece

$
  f_(-) = f_0 / sqrt(1 + k),
  quad
  f_(+) = f_0 / sqrt(1 - k).
$ <eq-modos-sintonizados>

Os índices $-$ e $+$ indicam os modos de menor e maior frequência. O aumento
de $k$ amplia sua separação, e ambos tendem a $f_0$ quando $k$ tende a zero,
como previsto na @fig-separacao-modal. Com dessintonia, as frequências dependem
dos dois produtos LC, e a @eq-modos-sintonizados deixa de se aplicar. Nesse
caso, a separação pode persistir mesmo sem acoplamento.

#figura-prevista(
  [Frequências dos modos naturais de dois circuitos sintonizados em função do coeficiente de acoplamento],
  [Gráfico teórico de f−/f₀ e f+/f₀ em função de k, no caso sem perdas. Indicar a frequência desacoplada e a separação entre os ramos; não incluir dados experimentais.],
) <fig-separacao-modal>

As frequências naturais sem perdas, as frequências amortecidas e os picos
de resposta forçada têm definições distintas. As perdas e o circuito de
excitação alteram a resposta em frequência e podem dificultar a resolução de
dois picos. Na comparação experimental, a previsão e a grandeza extraída do
sinal devem corresponder à mesma definição e à mesma configuração de ensaio.

== Transferência de energia, batimentos e dissipação

Para analisar um disparo, admitem-se correntes iniciais nulas nos enrolamentos,
secundário descarregado e tensão $V_0$ no capacitor primário. A energia inicial
é

$ E_0 = 1 / 2 C_p V_0^2. $ <eq-energia-inicial>

Com a malha primária fechada, essa energia se distribui entre os campos
elétricos e magnéticos dos circuitos. A transferência pode se inverter e
devolver energia ao primário, como descreve #cite(<queiroz2006>, form: "prose").
A energia de um ressonador pode diminuir enquanto a do outro aumenta; a
dissipação, por sua vez, reduz a energia total.

A superposição dos modos permite interpretar os batimentos. Pela identidade
trigonométrica

$
  cos(omega_(-) t) - cos(omega_(+) t)
  = 2 sin(((omega_(+) + omega_(-)) t) / 2)
      sin(((omega_(+) - omega_(-)) t) / 2)
$ <eq-identidade-batimentos>

uma oscilação rápida é multiplicada por um fator de variação lenta, com
$omega_(-) = 2 pi f_(-)$ e $omega_(+) = 2 pi f_(+)$. Essa forma descreve a
resposta ideal sintonizada com energia inicial no primário. No caso geral,
a envoltória depende também das amplitudes, fases e taxas de amortecimento
dos modos. Os mínimos de uma tensão medida não indicam, por si só, que a
energia total tenha sido dissipada. A @fig-batimentos-energia relaciona as
oscilações ao balanço de energia.

#figura-prevista(
  [Batimentos e transferência de energia entre os circuitos primário e secundário],
  [Painéis com tensões e suas envoltórias, energias dos ressonadores e energia total, contabilizando o termo mútuo. Distinguir a troca entre circuitos da redução da energia total por perdas. Curvas ilustrativas do modelo, sem dados medidos.],
) <fig-batimentos-energia>

Para dois RLC acoplados com parâmetros constantes, sem fornecimento externo
de energia e com perdas representadas por resistências série $R_p$ e $R_s$,
o balanço energético das equações de malha resulta em

$
  (upright(d) W) / (upright(d) t)
  = -R_p i_p^2 - R_s i_s^2,
$ <eq-balanco-energia>

em que $W$ inclui a energia elétrica dos capacitores e a energia magnética,
com a contribuição da indutância mútua. As correntes são $i_p$ e $i_s$.
O termo à direita representa as perdas resistivas e deve ser compatível com
a variação da energia calculada na simulação. Descargas ativas e resistência
variável do centelhador exigiriam termos adicionais ao modelo linear.

Se toda a energia inicial fosse armazenada em $C_s$ em um mesmo instante,
a conservação da energia imporia o limite

$
  abs(V_s)_max <= abs(V_0) sqrt(C_p / C_s)
  = abs(V_0) sqrt(L_s / L_p),
$ <eq-limite-tensao>

sendo a última igualdade válida para $L_p C_p = L_s C_s$. O transitório
pode atingir um valor inferior, conforme a relação entre os modos e as perdas.
Na operação com descargas, o carregamento do secundário e a extinção do
centelhador também alteram a resposta. O limite da @eq-limite-tensao não
determina diretamente o comprimento de descarga.

== Amortecimento e fator de qualidade

A análise do amortecimento exige distinguir o decaimento de um ressonador
da resposta dos modos acoplados. Essa distinção orienta a estimação do fator
de qualidade e a escolha do modelo de ajuste. Em ambas as configurações,
o carregamento introduzido pela medição participa das perdas observadas.

=== Resposta livre de um ressonador

Uma resistência equivalente pode representar as perdas do ressonador em uma
faixa limitada de frequência. Além da resistência em corrente contínua,
participam os efeitos pelicular e de proximidade, que alteram a distribuição
da corrente no enrolamento. A radiação, o ambiente e o carregamento externo
também afetam o decaimento observado @craven2014. O valor equivalente depende,
portanto, do modo e da configuração.

Para um RLC série subamortecido com parâmetros constantes, a resposta livre
de tensão ou corrente tem a forma

$ x(t) = A_0 e^(-alpha t) cos(omega_d t + phi), $ <eq-decaimento-livre>

com

$
  omega_0 = 1 / sqrt(L C),
  quad alpha = R / (2 L),
  quad omega_d = sqrt(omega_0^2 - alpha^2).
$ <eq-parametros-decaimento>

As condições iniciais determinam $A_0$ e $phi$. A taxa $alpha$ descreve o
decaimento da amplitude, $omega_0$ é a frequência angular natural não
amortecida e $omega_d$ é a frequência angular amortecida. A condição
$alpha < omega_0$ caracteriza o regime subamortecido. Definindo o fator de
qualidade do RLC série como a razão entre a reatância indutiva na ressonância
e a resistência total #cite(<terman1943>, supplement: [p. 135-136, 139]),

$ Q = (omega_0 L) / R = omega_0 / (2 alpha). $ <eq-q-amortecimento>

Quanto maior Q, mais lento é o decaimento em relação ao período de oscilação.
A constante de tempo da amplitude é $tau_A = 1 / alpha$. Como a energia
depende do quadrado das tensões e correntes, sua envoltória decai, no regime
de perdas pequenas, com constante de tempo aproximadamente igual a
$tau_E = 1 / (2 alpha)$. A estimação de Q deve distinguir esses dois
decaimentos.

=== Estimativa por decaimento livre e carregamento da medição

No _ring-down_, observa-se a resposta após retirar a excitação. Quando um
único modo domina o sinal, pode-se estimar $alpha$ ajustando a envoltória da
@eq-decaimento-livre ou calculando o decréscimo logarítmico. Para módulos de
picos de mesmo sinal $A_j$ e $A_(j+N)$, separados por $N$ períodos completos,

$
  delta = 1 / N ln(A_j / A_(j+N)) = alpha T_d,
  quad T_d = (2 pi) / omega_d.
$ <eq-decremento-logaritmico>

A combinação da @eq-parametros-decaimento com a @eq-q-amortecimento e a
@eq-decremento-logaritmico fornece

$ Q = sqrt(1 / 4 + (pi / delta)^2) approx pi / delta, $ <eq-q-decremento>

em que a aproximação exige amortecimento pequeno. A expressão exata conserva
a diferença entre $omega_0$ e $omega_d$. A @fig-ringdown indica os elementos
necessários à leitura do decaimento.

#figura-prevista(
  [Resposta de decaimento livre e parâmetros utilizados na estimação do fator de qualidade],
  [Senoide amortecida com envoltórias ±A₀ exp(−αt), período T_d e dois picos de mesmo sinal separados por N períodos. Indicar uma janela de ajuste e a região dominada pelo ruído. Ilustração, não medição do protótipo.],
) <fig-ringdown>

No domínio da frequência, Q pode ser estimado pela razão entre a frequência
central e a largura de banda de meia potência, desde que a ressonância esteja
suficientemente isolada e a resposta seja compatível com esse modelo.
#cite(<craven2014>, form: "prose") emprega esse método e medições por carta
de Smith, considerando a influência do gerador e das conexões. O resultado
inclui o carregamento do arranjo de ensaio. Retirar a excitação no _ring-down_
reduz uma fonte de carregamento, mas os efeitos do sensor, das conexões e do
ambiente permanecem.

Neste trabalho, $Q_s$ será o fator de qualidade do secundário medido com a
malha primária aberta, sob o carregamento residual do ensaio. A janela de
ajuste deve conter um trecho compatível com o decaimento de um único modo.
A presença de outras oscilações ou do ruído ao fim do sinal pode comprometer
a estimativa.

=== Amortecimento dos modos acoplados

Com a malha primária fechada, as perdas dos dois circuitos contribuem para os
polos do sistema acoplado. Para o par complexo conjugado de cada modo $r$,
definem-se

$
  s_r^(plus.minus) = -alpha_r plus.minus j omega_(d,r),
  quad
  Q_r = sqrt(alpha_r^2 + omega_(d,r)^2) / (2 alpha_r),
$ <eq-q-modal>

em que $r$ identifica o modo inferior ou superior, $alpha_r > 0$ e $j^2 = -1$.
O fator $Q_r$ é definido pela razão de amortecimento do par de polos. Em geral,
$Q_(-)$ e $Q_(+)$ diferem de $Q_s$ e dos fatores dos RLC isolados. Os batimentos
da resposta acoplada também impedem ajustar sua envoltória completa por uma
única exponencial de perdas. A caracterização modal exige um ajuste que
considere a superposição; o _ring-down_ do secundário será analisado com a
malha primária aberta.

== Capacitância própria, terminal capacitivo e influência do ambiente

As capacitâncias do secundário estão distribuídas entre espiras, terminal
e objetos próximos. Como o potencial varia ao longo do enrolamento, o valor
equivalente $C_s$ depende do modo e das condições de contorno. Ele não é
necessariamente a soma das capacitâncias das partes medidas isoladamente.

O terminal superior, ou _top-load_, acrescenta capacitância e modifica o campo
elétrico na extremidade da bobina. Para uma mesma indutância equivalente,
o aumento de capacitância reduz a frequência natural. A forma e os raios de
curvatura do terminal também afetam o início de corona e de descargas, efeitos
discutidos por #cite(<craven2014>, form: "prose"). O ponto de descarga
(_breakout_) concentra o campo em uma região definida. Sua instalação altera
a geometria e deve ser registrada tanto na caracterização sem descargas como
na operação funcional.

Para pequenas variações de capacitância e indutância constante, a
diferenciação da @eq-frequencias-desacopladas fornece

$ (Delta f_(0 s)) / f_(0 s) approx -1 / 2 (Delta C_s) / C_s. $ <eq-sensibilidade-capacitancia>

A relação é válida dentro da aproximação LC; mudanças na distribuição dos
campos também podem alterar os parâmetros efetivos. No ressonador estudado
por Voitkāns e Voitkāns (#cite(<voitkans2014>, form: "year")), a frequência
fundamental passou de 1,635 MHz sem carga adicionada para 1,362 MHz com uma
esfera de capacitância declarada de 3,62 pF. Os autores observaram influência
mesmo ao conectar capacitâncias da ordem de 1 pF, o que limita a medição
direta por sondas.

A altura em relação ao plano de referência, a proximidade de condutores e a
posição da instrumentação fazem parte da configuração elétrica do ensaio.
Essas condições devem ser mantidas ou registradas nas comparações. Uma sonda
pode deslocar a frequência e introduzir perdas, mesmo com alta resistência
de entrada, devido ao carregamento capacitivo.

O JavaTC define a capacitância efetiva com as contribuições distribuídas
referidas ao terminal @javatc-ces. A documentação também distingue a indutância
medida em baixa frequência da indutância série efetiva em ressonância, que
considera a corrente não uniforme no enrolamento @javatc-les. Assim, calcular
$C_s$ com uma frequência medida e uma indutância de baixa frequência não
assegura equivalência com a capacitância fornecida pela ferramenta. A
comparação entre cálculo e medição exige definições compatíveis dos parâmetros.

== Modelos concentrados e distribuídos

O modelo concentrado descreve a SGTC por duas malhas RLC acopladas pela
indutância mútua. O centelhador em condução é substituído por uma ligação que
fecha a malha primária, e as perdas são reunidas em parâmetros equivalentes.
As cargas dos dois capacitores e as correntes dos enrolamentos formam quatro
variáveis de estado. O sistema tem ordem quatro e pode apresentar dois pares
de polos complexos conjugados.

Essa descrição permite calcular os transitórios e os parâmetros modais sem
resolver a distribuição espacial do campo. Nos modelos distribuídos, tensão
e corrente dependem também da posição. O enrolamento pode ser dividido em
seções com indutâncias e capacitâncias, incluindo interações entre elas,
ou aproximado por uma linha de transmissão. A @fig-modelos-secundario
contrapõe essas representações e indica as contribuições do terminal e do
ambiente.

#figura-prevista(
  [Representações concentrada e distribuída do secundário e suas contribuições capacitivas],
  [Comparar um RLC equivalente com um enrolamento dividido em seções. Indicar capacitâncias entre espiras, para o terminal e para o ambiente, além de perfis qualitativos de tensão e corrente no modo fundamental.],
) <fig-modelos-secundario>

Denicolai (#cite(<denicolai2001>, form: "year")) obtém parâmetros equivalentes
a partir da distribuição de corrente e potencial do secundário.
Craven (#cite(<craven2014>, form: "year")) investiga modos superiores e
alterações no sentido de enrolamento com modelos espaciais. Sua análise
também relaciona a aplicabilidade do modelo concentrado ao carregamento
capacitivo e à frequência de operação em relação às ressonâncias do
enrolamento. Voitkāns e Voitkāns (#cite(<voitkans2014>, form: "year"))
adotam uma linha monocondutora equivalente, inicialmente homogênea e sem
perdas, e comparam ressonâncias e distribuições de tensão com medições.

Os modos superiores do secundário têm distribuições espaciais diferentes
das do modo fundamental, podem existir com a malha primária aberta e não
precisam ter frequências múltiplas inteiras da fundamental. Eles diferem do
par $f_(-)$ e $f_(+)$, que decorre da interação entre os dois ressonadores na
faixa considerada. Vários picos em um espectro podem, portanto, ter origens
distintas.

Neste trabalho, o modelo concentrado será avaliado na faixa de frequência
e nas configurações ensaiadas. As descrições distribuídas auxiliarão a
discussão das discrepâncias, sem validação espacial do enrolamento. A
concordância na fundamental não assegura concordância nos modos superiores,
com outro terminal ou na operação com descargas.

= Metodologia

A pesquisa compreenderá o dimensionamento, a construção e a caracterização
experimental de uma SGTC. A avaliação do modelo linear será realizada em baixa
energia, sem descargas no secundário, mediante comparação entre previsões e
medições de frequência e amortecimento. A operação com centelhador e descargas
constituirá uma etapa distinta, destinada à demonstração funcional e ao registro
complementar do desempenho.

== Estratégia e etapas da pesquisa

O estudo terá caráter experimental e quantitativo. O dimensionamento analítico
será comparado com as estimativas do JavaTC e do WinTesla para a mesma
geometria, respeitando as definições dos parâmetros de cada ferramenta.
A implementação numérica será verificada pela solução analítica e pelos
casos desacoplado e sem perdas, antes da comparação com as medições.

As previsões nominais serão arquivadas antes da coleta. Após a construção,
serão registradas as dimensões reais e as alterações do projeto, seguidas da
medição dos componentes, da identificação dos modos acoplados e do decaimento
livre do secundário. Ensaios preliminares orientarão a escolha das faixas de
excitação, das posições do primário e das condições de aquisição. O número
de repetições e os critérios de análise serão definidos antes da série
principal. A demonstração funcional ocorrerá em etapa posterior, sob liberação
específica para alta tensão.

== Grandezas investigadas e configurações de referência

Serão investigados $L_p$, $L_s$, $C_p$, $C_s$, $M$ e $k$, além das
frequências amortecidas, das taxas de amortecimento e dos fatores de qualidade.
O fator $Q_s$ será determinado com a malha primária aberta, separadamente dos
fatores dos modos acoplados definidos na @eq-q-modal.

Nos ensaios de baixa energia, a fonte de alta tensão permanecerá fisicamente
desconectada. Para identificar os modos acoplados, o centelhador será
substituído por uma ligação condutora que mantenha a malha primária fechada.
A configuração de referência terá altura e tomada do primário, terminal
capacitivo e presença ou ausência do ponto de descarga definidos. Mudanças
nesses elementos serão registradas, assim como a posição dos sensores, as
conexões e as condições ambientais disponíveis.

== Instrumentação, condições de ensaio e segurança

A instrumentação prevista compreende medidor de resistência, indutância e
capacitância, gerador de sinais, osciloscópio digital e instrumentos
dimensionais. Modelos, acessórios, faixas e situação de calibração serão
registrados após a confirmação dos equipamentos disponíveis. A aquisição
deverá resolver as oscilações e seu decaimento, sem saturação. Serão avaliados
o carregamento dos sensores e a dependência das estimativas com a amplitude
de excitação, pois o arranjo de medição pode alterar a frequência e o fator
de qualidade @craven2014.

Os ensaios dependerão de análise de risco, autorização e supervisão, conforme
os procedimentos do laboratório e a NR-10 @nr10-2019. Serão previstos
barreiras, controle de acesso, parada e proteções elétricas. Os limites de
excitação considerarão a elevação ressonante e a energia armazenada.
Intervenções na montagem exigirão desenergização, impedimento de reenergização,
descarga e verificação de ausência de tensão, com dispositivos adequados
@illinois-electrical-safety. Na operação em alta tensão, haverá acompanhamento
presencial, sem contato humano com as descargas, e avaliação dos riscos
elétricos, térmicos, acústicos, ópticos, de gases e de interferência.
A proteção de terra dos instrumentos será mantida; sondas comuns não serão
ligadas aos pontos de alta tensão. Condições fora da liberação ou falhas de
proteção determinarão a interrupção do ensaio e sua reavaliação antes da retomada.

== Procedimentos de caracterização em baixa energia

As indutâncias serão medidas com os capacitores externos desconectados e o
outro enrolamento aberto, registrando-se a frequência de teste e compensando-se
os cabos conforme o manual do medidor. A capacitância primária será medida no
banco utilizado no protótipo. As leituras de baixa frequência serão
diferenciadas dos parâmetros efetivos em ressonância, conforme discutido no
capítulo anterior @javatc-ces @javatc-les. Se $C_s$ for inferida da frequência
e do amortecimento do secundário pelas relações do RLC, o resultado será
identificado como parâmetro ajustado, com o valor de $L_s$ utilizado explícito.

A indutância mútua será obtida por medição independente das frequências modais.
Será empregado o método de associação dos enrolamentos em série, com as
polaridades em concordância e em oposição, em frequência compatível com a
aproximação indutiva. Dessas leituras, serão calculados

$
  abs(M) = (L_"conc" - L_"op") / 4,
  quad k = abs(M) / sqrt(L_p L_s).
$ <eq-k-serie>

O uso da associação em série para levantar o acoplamento em função da altura
tem precedente em #cite(<denicolai2001>, form: "prose", supplement: [p. 64-65]).
A resolução da diferença entre leituras será verificada; se insuficiente,
será avaliado o método de tensão induzida no secundário aberto, com medição da
corrente primária e avaliação do carregamento dos instrumentos.

Varreduras de frequência localizarão as ressonâncias dos circuitos isolados
e do sistema acoplado. Os picos orientarão a identificação, sem serem
automaticamente equiparados às frequências dos polos. Após retirar a excitação,
os transitórios acoplados serão ajustados por mínimos quadrados à soma de duas
senoides amortecidas, obtendo-se $f_(d,-)$, $f_(d,+)$ e as respectivas taxas
de amortecimento. A estabilidade dos parâmetros e os resíduos serão examinados;
batimentos não serão ajustados por uma única exponencial de perdas.

A altura do primário será variada, mantendo-se a concentricidade, a tomada,
o capacitor e o terminal de referência. Em cada posição serão medidos $k$ e
as frequências modais, com verificação da sintonia. As curvas
$f_(d,-)(k)$ e $f_(d,+)(k)$ e a separação
$Delta f_d = f_(d,+) - f_(d,-)$ serão comparadas com as previsões para os
parâmetros de cada posição. Eventual ressintonia por mudança de tomada
constituirá uma série distinta. As medições serão repetidas, incluindo o
retorno à posição de referência para avaliar o reposicionamento.

O _ring-down_ do secundário será realizado com a malha primária aberta e
captação de fraco acoplamento. Uma senoide amortecida será ajustada ao trecho
posterior à retirada da excitação e anterior ao domínio do ruído, fornecendo
$f_(d,s)$ e $alpha_s$. O fator $Q_s$ será calculado pela combinação da
@eq-parametros-decaimento com a @eq-q-amortecimento, com verificação pelo
decréscimo logarítmico quando os picos forem resolvidos. O resultado incluirá
o carregamento residual da medição. Decaimentos dos ressonadores isolados
também poderão fornecer perdas equivalentes por $R = 2 L alpha$, para posterior
comparação com novos transitórios acoplados.

Por fim, serão comparados o secundário sem terminal adicional, com o terminal
de referência e com esse terminal acrescido do ponto de descarga. Serão
mantidas as demais condições de montagem e avaliadas as diferenças de
frequência, amortecimento e $Q_s$. Todos esses ensaios ocorrerão sem corona ou
descargas ativas, avaliando o efeito da geometria do terminal e do ponto de
descarga. Modos ou decaimentos não resolvidos serão registrados como limitações
da identificação.

== Demonstração funcional e caracterização complementar das descargas

A montagem final será operada com o centelhador para demonstrar o funcionamento
e registrar as descargas, respeitando as condições autorizadas de alimentação
e duração. O comprimento será estimado por imagens com escala e geometria de
câmera documentadas, sem exposição de pessoas à região energizada. Serão
explicitados o critério de comprimento, as limitações de perspectiva e a
distinção entre descargas livres e até um alvo condutor. Os registros incluirão
a duração da observação e a repetibilidade, além dos eventos de maior extensão.

A taxa média de disparos será estimada por contagem óptica em intervalo
conhecido, após verificar a resolução temporal e a ausência de contagens
duplicadas ou eventos perdidos. Essa taxa será diferenciada das frequências
de oscilação. A meta de aproximadamente 1 m será avaliada como desempenho
complementar, sem integrar a validação linear ou justificar operação fora dos
limites liberados. A impossibilidade de demonstrar o funcionamento será
registrada no atendimento dos objetivos.

== Tratamento, rastreabilidade e preservação dos dados

Os dados brutos serão preservados com identificadores que relacionem cada
aquisição à configuração e à repetição. Os registros incluirão instrumentos,
faixas, excitação, conexões e condições de ensaio. O processamento será
realizado por rotinas versionadas, com documentação das conversões, janelas
e ajustes. Dados rejeitados permanecerão arquivados com justificativa; uma
discrepância em relação ao modelo não será motivo suficiente para exclusão.

Serão mantidos separadamente os conjuntos de previsões nominais, atualizadas
com parâmetros medidos e obtidas por ajuste, identificando os dados utilizados.
Cópias de segurança e instruções de reprodução da análise permitirão recuperar
os registros e reavaliar os resultados, conforme a orientação do GUM
#cite(<jcgm100-2008>, supplement: [seção 7]).

== Erros relativos e orçamento de incerteza conforme o GUM

Para cada grandeza comparável $x$, será adotada a diferença
$Delta x = x_"prev" - x_"med"$ e o erro relativo assinado

$
  e_x = 100 (x_"prev" - x_"med") / x_"med",
$ <eq-erro-relativo-metodos>

expresso em porcentagem, sem tratar a medição como valor verdadeiro exato.
Para valores nulos ou não distinguíveis de zero, será utilizada a diferença
absoluta. Na verificação entre solução analítica e numérica, a referência
será o valor analítico.

O orçamento seguirá o GUM @jcgm100-2008, com avaliações do tipo A pelas
repetições e do tipo B por calibração, especificações e resolução dos
instrumentos. Serão considerados ainda o posicionamento, o carregamento e
a sensibilidade dos ajustes. Para $Y = g(X_1, dots, X_m)$, a incerteza-padrão
combinada será calculada por

$
  u_c^2(y) = sum_(i=1)^m c_i^2 u^2(x_i)
    + 2 sum_(i=1)^(m-1) sum_(j=i+1)^m
      c_i c_j op("cov")(x_i, x_j),
  quad c_i = (∂ g) / (∂ x_i),
$ <eq-incerteza-combinada>

com os coeficientes de sensibilidade avaliados nas estimativas das entradas.
Serão preservadas as correlações entre parâmetros de um mesmo ajuste e entre
previsões e medições que compartilhem dados. A adequação da propagação de
primeira ordem será verificada nas expressões não lineares. A incerteza da
diferença incluirá as contribuições da previsão e da medição e sua covariância.

A incerteza expandida será $U = k_"abr" u_c$, com probabilidade de abrangência
pretendida de aproximadamente 95% e fator justificado pela distribuição e
pelos graus de liberdade aplicáveis. $k_"abr"$ será distinguido do acoplamento
$k$. Cada resultado apresentará estimativa, unidade, incerteza e fator de
abrangência, com as fontes e contribuições documentadas no orçamento.

== Critérios de comparação e interpretação das discrepâncias

A comparação utilizará grandezas com a mesma definição e configuração.
As frequências amortecidas serão confrontadas com o módulo da parte imaginária
dos polos dividido por $2 pi$, e as taxas de amortecimento, com o módulo da
parte real. Picos de varredura serão comparados à resposta forçada, enquanto
as expressões ideais de sintonia ficarão restritas às suas hipóteses.

Será adotada a regra $abs(Delta x) <= U_(Delta x)$ para indicar compatibilidade
pontual, sendo $U_(Delta x)$ a incerteza expandida da diferença. Essa escolha
da pesquisa não constitui critério universal de validação do GUM.
Discrepâncias serão examinadas quanto à dessintonia, ao carregamento, às
perdas e aos limites do modelo concentrado. A interpretação considerará
também as tendências da curva modal e os resíduos dos ajustes; resultados
sem resolução ou incerteza adequadas serão classificados como inconclusivos.

As conclusões distinguirão previsões nominais, atualizadas e ajustadas.
A reprodução dos dados usados para identificar parâmetros não será considerada
validação independente. A adequação do modelo ficará limitada às configurações
e grandezas ensaiadas em baixa energia, sem extensão automática à operação
com descargas.

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
