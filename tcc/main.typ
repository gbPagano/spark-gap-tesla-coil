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
acoplados. Para avaliar o modelo, serão realizados ensaios de caracterização
em baixa energia, sem descargas no secundário, nos quais serão comparados os
valores previstos e medidos das frequências naturais e do amortecimento.
Em uma etapa distinta, o protótipo será operado com acionamento pelo centelhador
e produção de descargas elétricas no secundário.

== Contextualização e aplicações

A bobina de Tesla é um transformador ressonante com núcleo de ar destinado à
geração de altas tensões em alta frequência. Em 1891, Nikola Tesla descreveu,
na patente US 454.622, um sistema de iluminação elétrica que empregava a
descarga oscilatória de um capacitor em um circuito primário para induzir altas
tensões em um circuito secundário @tesla1891-lighting.

Esse princípio é empregado na configuração clássica com centelhador, denominada
SGTC, do inglês _spark gap Tesla coil_. Nela, uma fonte de alta tensão carrega
o capacitor primário.
Quando o centelhador conduz, fecha-se a malha oscilatória primária e inicia-se
a transferência de energia ao secundário por acoplamento magnético. Esse
funcionamento corresponde ao descrito na patente de
#cite(<tesla1891-lighting>, form: "prose").

Para analisar essa transferência na aproximação por parâmetros concentrados,
o primário e o secundário são representados por dois circuitos ressonantes
magneticamente acoplados, com resistência (R), indutância (L) e capacitância (C),
denominados circuitos RLC.
A análise desses circuitos considera a indutância mútua e a sintonia dos
ressonadores, de modo que a elevação de tensão não depende apenas da razão
entre os números de espiras @terman1943.

Além do acionamento por centelhador, o primário pode ser excitado por
semicondutores. Nas bobinas de estado sólido, denominadas SSTC, do inglês
_solid state Tesla coil_,
o primário é excitado eletronicamente, sem o tanque ressonante primário da
configuração clássica. A topologia DRSSTC, do inglês
_double resonant solid state Tesla coil_, incorpora esse tanque ao acionamento
eletrônico, formando um sistema de dupla ressonância. As topologias diferem
quanto à alimentação do ressonador e aos recursos de controle do acionamento
@wasatonic2013.

Quanto às aplicações, bobinas de Tesla são empregadas na geração de pulsos de
alta tensão, em ensaios de materiais isolantes e no estudo de descargas
elétricas @denicolai2001.
Também são utilizadas em demonstrações educacionais de ressonância, acoplamento
magnético e ruptura dielétrica @wasatonic2013. Esses usos abrangem diferentes
montagens e regimes de operação. A adequação do modelo e do protótipo deve,
portanto, ser avaliada conforme as condições de cada aplicação.

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
enquanto as perdas determinam o amortecimento @denicolai2001. Por essa razão,
na comparação experimental, a transferência de energia entre os circuitos deve ser
distinguida da dissipação. A ressonância do secundário com a malha primária
aberta, por sua vez, deve ser analisada separadamente dos modos do sistema
acoplado.

Essas condições delimitam o problema de pesquisa: em que medida um modelo
linear de circuitos RLC magneticamente acoplados descreve as frequências
naturais e o amortecimento de um protótipo de bobina de
Tesla com centelhador, em ensaios de caracterização em baixa energia, sem
descargas no secundário, considerando a variação do acoplamento, as
configurações do terminal capacitivo e as incertezas associadas às medições?

Para responder a essa questão, os resultados analíticos, simulados e medidos
serão comparados para as mesmas grandezas. A comparação entre a solução
analítica e a integração numérica servirá à verificação da implementação,
enquanto a comparação com as medições será destinada à validação do modelo.
Nessa análise, serão distinguidas as previsões nominais, definidas antes
da coleta, das previsões atualizadas com parâmetros medidos e daquelas obtidas
com parâmetros ajustados às respostas experimentais. A reprodução dos dados
usados para identificar parâmetros não será considerada validação independente.

== Objetivos

Para investigar o problema proposto, será construído um protótipo de duas
bobinas com centelhador estático, enquanto as topologias SSTC e DRSSTC serão
abordadas apenas na revisão bibliográfica. Nesse recorte, a validação se
limitará aos modos de interesse do modelo RLC concentrado e não abrangerá a
distribuição espacial no secundário nem a dinâmica não linear do
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
seu estado de condução e mantém a malha primária fechada. Já no _ring-down_ do
secundário, essa malha permanecerá aberta, considerando-se o carregamento
residual da medição. Assim, o fator de qualidade do secundário será avaliado
separadamente dos fatores de qualidade dos modos acoplados.

Na etapa de operação com descargas, o centelhador realizará o chaveamento do
circuito primário, e serão registrados o comprimento das descargas no secundário
e a taxa de repetição do centelhador. Essa avaliação funcional será distinta
da validação do modelo linear e terá como meta prática complementar a obtenção
de descargas de aproximadamente 1 m. Esse comprimento não será usado como
critério de validade do modelo nem apresentado como desempenho garantido.

Os ensaios dependerão de autorização e de supervisão, e seguirão os
procedimentos do laboratório e as medidas de controle de risco previstas na
Norma Regulamentadora nº 10 (NR-10) @nr10-2019.

== Justificativa e contribuição esperada

A motivação formativa da pesquisa é aplicar conhecimentos de circuitos
elétricos, eletromagnetismo, altas tensões e medidas elétricas à construção e à
avaliação do protótipo. Nessa abordagem, o dimensionamento dos componentes será
relacionado à modelagem e à análise dos transitórios. Ao longo da caracterização
dos parâmetros e do planejamento das medições, serão registradas as decisões
técnicas e as limitações encontradas. O protótipo e a documentação também poderão
subsidiar futuras atividades didáticas, condicionadas aos requisitos de
segurança e de uso dos laboratórios.

A relação entre modelagem e caracterização experimental aparece no trabalho de
#cite(<denicolai2001>, form: "prose"), que descreve o projeto de uma bobina de
Tesla e o ajuste de parâmetros para reproduzir suas respostas transitórias.
Quanto aos limites dessa representação, #cite(<craven2014>, form: "prose")
investiga modelos do secundário, modos superiores e fator de qualidade,
considerando os efeitos do terminal e do carregamento da medição. Já o relato
técnico de #cite(<queiroz2006>, form: "prose") apresenta uma sequência de
ensaios em que a sintonia e a observação dos transitórios em baixa potência
antecedem a operação com descargas. A comparação entre métodos e a medição do
fator de qualidade nesses estudos orientam a estratégia experimental da
pesquisa, que também separa a caracterização em baixa energia da avaliação
funcional com descargas.

A partir dessas referências, a contribuição esperada tem caráter aplicado:
avaliar uma mesma SGTC de forma integrada e rastreável, relacionando o
dimensionamento à montagem final, aos
parâmetros medidos e às respostas do sistema. Essa avaliação reunirá a curva de
separação entre as frequências modais em função do acoplamento, a caracterização
do decaimento livre do secundário e a comparação de configurações do terminal
capacitivo e do ponto de descarga. Para permitir a reexecução das comparações,
os dados brutos, as entradas computacionais e os procedimentos de análise serão
preservados. Esse registro também permitirá distinguir o desempenho das
previsões nominais daquele obtido após atualização ou ajuste de parâmetros.

Conforme o GUM, um resultado de medição é uma estimativa que deve ser
acompanhada de sua incerteza, e correlações relevantes entre grandezas de entrada
devem ser consideradas nessa avaliação @jcgm100-2008. As diferenças relativas
entre previsões e medições serão, portanto, discutidas considerando o orçamento
de incerteza e as condições de ensaio. Com isso, a análise buscará identificar
a adequação e os limites do modelo nas configurações investigadas, inclusive
diante de resultados incompatíveis ou inconclusivos.

= Fundamentação teórica

A descrição teórica da bobina de Tesla relaciona a excitação do primário à
transferência de energia e à resposta do secundário. Para a análise em baixa
energia, adota-se a aproximação por circuitos ressonantes acoplados, com perdas
representadas por resistências equivalentes. Nessa aproximação, a resposta
depende tanto das condições de sintonia e acoplamento quanto dos parâmetros
atribuídos a cada circuito. Por isso, a análise também considera as
contribuições capacitivas e a distribuição espacial de tensão e corrente no
secundário, que delimitam a aplicação desses parâmetros equivalentes.

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
circuitos, enquanto o acoplamento promove sua transferência ao secundário ao
longo de vários ciclos. Na condição de sintonia, essa transferência se manifesta
pelo crescimento inicial da envoltória da tensão secundária e pela redução da
envoltória das oscilações primárias. Se o centelhador continuar conduzindo,
parte da energia retorna ao primário. Essa troca está associada à superposição
dos dois modos do conjunto, que produz batimentos na resposta. Ao mesmo tempo,
as perdas nos componentes e no centelhador reduzem progressivamente a energia
total. Caso a tensão secundária inicie descargas no ar, elas também retiram
energia do ressonador @queiroz2006.

A interrupção dessa condução é denominada extinção, ou _quenching_. Se a malha
for aberta em um mínimo de energia no primário, impede-se o retorno da energia
por esse circuito e, na descrição idealizada, a energia remanescente decai no
secundário. A ocorrência desse mínimo, porém, não garante a extinção: a corrente
precisa deixar de sustentar a descarga, e o meio entre os eletrodos deve
recuperar capacidade isolante suficiente para evitar a reignição. A extinção
pode, assim, ocorrer depois do primeiro mínimo @burnett-quenching. Quando o
centelhador volta a permanecer aberto, a fonte retoma a carga do capacitor
primário, permitindo outro disparo.

No centelhador estático, a taxa de repetição depende da tensão aplicada, da
capacitância primária e das condições de ruptura do ar. Essa taxa descreve a
repetição do ciclo de carga e disparo, enquanto cada disparo inicia um
transitório com vários ciclos de alta frequência. Portanto, a taxa de disparos,
as frequências das oscilações e a frequência da alimentação são grandezas
distintas. Por isso, observar a repetição das descargas não basta para determinar
as frequências naturais ou o amortecimento dos circuitos.

== Comparação entre SGTC, SSTC e DRSSTC

As topologias SGTC, SSTC e DRSSTC diferem quanto à forma de fornecer energia
aos ressonadores e à presença de um tanque ressonante no primário, conforme os circuitos da
@fig-circuitos-topologias e a comparação do @quadro-topologias. Na SGTC, a
energia de cada transitório é acumulada no capacitor antes do disparo. O
centelhador fecha a malha de descarga, e sua condução depende das condições
de manutenção e extinção do arco. No centelhador rotativo, a posição dos
eletrodos também determina os instantes em que o disparo pode ocorrer;
a duração da condução continua sem controle eletrônico independente.

Já na SSTC, uma ponte de semicondutores alimentada por um barramento contínuo
aplica tensão alternada ao primário, com frequência escolhida em função da
ressonância do secundário. Na configuração de ressonância simples, não há
capacitor dimensionado para formar um tanque com o primário. Um capacitor
usado apenas para bloquear a componente contínua não exerce essa função.

Na DRSSTC, a inclusão de um capacitor de tanque em série com o primário forma
um segundo circuito ressonante, que recebe energia do barramento durante os
ciclos de acionamento. A realimentação de corrente permite acompanhar a
oscilação e comutar próximo das passagens por zero da corrente. Para limitar
o tempo de crescimento da corrente no tanque, o sinal de interrupção define
os intervalos de excitação e sua repetição. A SGTC e a DRSSTC têm, assim, dois ressonadores,
mas diferem quanto à excitação: na primeira, o transitório parte da descarga
do capacitor previamente carregado; na segunda, a ponte continua fornecendo
energia durante o acionamento.

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

Como exemplo de acionamento eletrônico duplamente ressonante, o projeto de
#cite(<obeidat2023>, form: "prose") emprega ponte completa,
realimentação e interrupção programada em uma DRSSTC. Já
#cite(<wasatonic2013>, form: "prose") compara o acionamento eletrônico
duplamente ressonante com um centelhador rotativo no mesmo ressonador. Nessa
comparação, a relação entre comprimento de descarga e alimentação dependeu
da duração e da repetição dos pulsos. Os resultados se aplicam às condições
ensaiadas, sem estabelecer uma vantagem fixa de uma topologia. Neste trabalho,
essa comparação fica restrita à revisão bibliográfica, pois a construção será
limitada à SGTC.

== Ressonância, sintonia e acoplamento magnético

Para analisar os ressonadores, considera-se inicialmente cada circuito de
forma isolada. Em um RLC série com parâmetros constantes, a ressonância de
corrente ocorre quando as reatâncias indutiva e capacitiva se cancelam, e sua
frequência depende do produto entre indutância e capacitância
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

As frequências isoladas estabelecem a condição de sintonia, mas a resposta do
conjunto também depende da interação entre os enrolamentos. Essa interação é
descrita pela indutância mútua $M$, que relaciona a variação de corrente em um
enrolamento à tensão induzida no outro. A partir dela, define-se o coeficiente
de acoplamento por

$ k = abs(M) / sqrt(L_p L_s). $ <eq-coeficiente-acoplamento>

Adota-se $0 <= k < 1$, enquanto o sinal dos termos de indutância mútua nas
equações depende dos sentidos dos enrolamentos e das referências de corrente.
A posição relativa das bobinas altera $M$ e $k$. O deslocamento vertical do
primário permite, portanto, variar o acoplamento. A sintonia precisa ser verificada
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

Essas expressões descrevem as frequências naturais sem perdas, cuja definição
difere daquela das frequências amortecidas e dos picos de resposta forçada.
Ao considerar as perdas e o circuito de excitação, a resposta em frequência
se altera, o que pode dificultar a resolução de dois picos. Por isso, a
comparação experimental exige que a previsão e a grandeza extraída do sinal
correspondam à mesma definição e à mesma configuração de ensaio.

== Transferência de energia, batimentos e dissipação

Para relacionar os modos naturais à transferência de energia durante um
disparo, admitem-se correntes iniciais nulas nos enrolamentos, secundário
descarregado e tensão $V_0$ no capacitor primário. Nessas condições, a energia
inicial está armazenada nesse capacitor e é dada por

$ E_0 = 1 / 2 C_p V_0^2. $ <eq-energia-inicial>

Com a malha primária fechada, essa energia se distribui entre os campos
elétricos e magnéticos dos circuitos. A transferência pode se inverter e
devolver energia ao primário, como descreve #cite(<queiroz2006>, form: "prose").
Assim, a redução da energia de um dos ressonadores pode acompanhar o aumento
da energia do outro. Para interpretar o transitório, é necessário distinguir
essa troca da dissipação, que reduz a energia total do sistema.

A troca de energia também se manifesta nos batimentos produzidos pela
superposição dos modos. Pela identidade trigonométrica

$
  cos(omega_(-) t) - cos(omega_(+) t)
  = 2 sin(((omega_(+) + omega_(-)) t) / 2)
      sin(((omega_(+) - omega_(-)) t) / 2)
$ <eq-identidade-batimentos>

uma oscilação rápida é multiplicada por um fator de variação lenta, com
$omega_(-) = 2 pi f_(-)$ e $omega_(+) = 2 pi f_(+)$. Essa forma descreve a
resposta ideal sintonizada com energia inicial no primário. No caso geral,
a envoltória depende também das amplitudes, fases e taxas de amortecimento
dos modos. Como a redução de amplitude pode decorrer da transferência de
energia entre os circuitos, os mínimos de uma tensão medida não indicam, por
si só, que a energia total tenha sido dissipada. Essa distinção é representada
na @fig-batimentos-energia, que relaciona as oscilações ao balanço de energia.

#figura-prevista(
  [Batimentos e transferência de energia entre os circuitos primário e secundário],
  [Painéis com tensões e suas envoltórias, energias dos ressonadores e energia total, contabilizando o termo mútuo. Distinguir a troca entre circuitos da redução da energia total por perdas. Curvas ilustrativas do modelo, sem dados medidos.],
) <fig-batimentos-energia>

Para quantificar a dissipação, consideram-se dois RLC acoplados com parâmetros
constantes, sem fornecimento externo de energia e com perdas representadas
por resistências série $R_p$ e $R_s$. Nessas condições, o balanço energético
obtido das equações de malha resulta em

$
  (upright(d) W) / (upright(d) t)
  = -R_p i_p^2 - R_s i_s^2,
$ <eq-balanco-energia>

em que $W$ inclui a energia elétrica dos capacitores e a energia magnética,
com a contribuição da indutância mútua. As correntes são $i_p$ e $i_s$.
O termo à direita representa as perdas resistivas e deve ser compatível com
a variação da energia calculada na simulação. Já a inclusão de descargas ativas
e de resistência variável do centelhador exigiria termos adicionais ao modelo
linear.

A conservação da energia também permite estabelecer um limite para a tensão
secundária. Se toda a energia inicial fosse armazenada em $C_s$ em um mesmo
instante, esse limite seria

$
  abs(V_s)_max <= abs(V_0) sqrt(C_p / C_s)
  = abs(V_0) sqrt(L_s / L_p),
$ <eq-limite-tensao>

sendo a última igualdade válida para $L_p C_p = L_s C_s$. O valor atingido no
transitório pode, contudo, ser inferior, conforme a relação entre os modos e
as perdas.
Na operação com descargas, o carregamento do secundário e a extinção do
centelhador também alteram a resposta. O limite da @eq-limite-tensao não
determina diretamente o comprimento de descarga.

== Amortecimento e fator de qualidade

Como a transferência de energia e a dissipação afetam de maneiras diferentes
a resposta transitória, a análise do amortecimento deve distinguir o
decaimento de um ressonador da resposta dos modos acoplados. Essa distinção
orienta a estimação do fator de qualidade e a escolha do modelo de ajuste:
a envoltória de um sinal com batimentos não pode ser interpretada da mesma
forma que o decaimento de um único modo. Em ambas as configurações, é preciso
considerar também o carregamento introduzido pela medição, que participa das
perdas observadas.

=== Resposta livre de um ressonador

Na descrição de um ressonador isolado, uma resistência equivalente pode
representar as perdas em uma faixa limitada de frequência. Essa representação
reúne contribuições que vão além da resistência em corrente contínua, pois
participam os efeitos pelicular e de proximidade, que alteram a distribuição
da corrente no enrolamento. A radiação, o ambiente e o carregamento externo
também afetam o decaimento observado @craven2014. O valor equivalente depende,
portanto, do modo e da configuração.

Com as perdas representadas por uma resistência equivalente, a resposta livre
de tensão ou corrente de um RLC série subamortecido com parâmetros constantes
tem a forma

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
Para a amplitude, a constante de tempo é $tau_A = 1 / alpha$. Como a energia
depende do quadrado das tensões e correntes, sua envoltória decai, no regime
de perdas pequenas, com constante de tempo aproximadamente igual a
$tau_E = 1 / (2 alpha)$. Essa diferença deve ser considerada na estimação de Q,
conforme se utilize o decaimento da amplitude ou o da energia.

=== Estimativa por decaimento livre e carregamento da medição

O decaimento descrito pode ser observado pela técnica de _ring-down_, na qual
se registra a resposta após retirar a excitação. Quando um único modo domina
o sinal, pode-se estimar $alpha$ ajustando a envoltória da
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

Como alternativa à análise temporal, Q pode ser estimado no domínio da
frequência pela razão entre a frequência central e a largura de banda de meia
potência, desde que a ressonância esteja
suficientemente isolada e a resposta seja compatível com esse modelo.
#cite(<craven2014>, form: "prose") emprega esse método e medições por carta
de Smith, considerando a influência do gerador e das conexões. O resultado
inclui, portanto, o carregamento do arranjo de ensaio. Retirar a excitação no
_ring-down_ reduz uma fonte de carregamento, mas os efeitos do sensor, das conexões e do
ambiente permanecem.

Neste trabalho, $Q_s$ será o fator de qualidade do secundário medido com a
malha primária aberta, sob o carregamento
residual do ensaio. Para estimá-lo, a janela de ajuste deve conter um trecho
compatível com o decaimento de um único modo. Caso outras oscilações estejam
presentes, ou o trecho escolhido alcance a região dominada pelo ruído ao fim
do sinal, a estimativa pode ser comprometida.

=== Amortecimento dos modos acoplados

Quando a malha primária está fechada, a análise passa a considerar os modos do
sistema acoplado, cujos polos dependem das perdas dos dois circuitos. Para o
par complexo conjugado de cada modo $r$, definem-se

$
  s_r^(plus.minus) = -alpha_r plus.minus j omega_(d,r),
  quad
  Q_r = sqrt(alpha_r^2 + omega_(d,r)^2) / (2 alpha_r),
$ <eq-q-modal>

em que $r$ identifica o modo inferior ou superior, $alpha_r > 0$ e $j^2 = -1$.
O fator $Q_r$ é definido pela razão de amortecimento do par de polos. Em geral,
$Q_(-)$ e $Q_(+)$ diferem de $Q_s$ e dos fatores dos RLC isolados. Os batimentos
da resposta acoplada também impedem ajustar sua envoltória completa por uma
única exponencial de perdas, pois a variação de amplitude inclui a contribuição
da superposição dos modos. Por isso, a caracterização modal exige um ajuste que
considere essa superposição, enquanto o _ring-down_ do secundário será analisado
com a malha primária aberta.

== Capacitância própria, terminal capacitivo e influência do ambiente

As capacitâncias do secundário estão distribuídas entre espiras, terminal
e objetos próximos. Como o potencial varia ao longo do enrolamento, o valor
equivalente $C_s$ depende do modo e das condições de contorno. Sua determinação
deve, portanto, considerar o conjunto nessa configuração, pois a soma das
capacitâncias das partes medidas isoladamente não corresponde necessariamente
ao valor equivalente do ressonador.

Entre essas contribuições, o terminal superior, ou _top-load_, acrescenta
capacitância e modifica o campo elétrico na extremidade da bobina. Para uma
mesma indutância equivalente, esse acréscimo reduz a frequência natural.
O efeito do terminal também depende de sua forma e de seus raios de curvatura,
que afetam o início de corona e de descargas, conforme discutido por
#cite(<craven2014>, form: "prose"). Já o ponto de descarga (_breakout_)
concentra o campo em uma região definida. Como sua instalação altera a
geometria do conjunto, ela deve ser registrada tanto na caracterização sem
descargas como na operação funcional.

A influência da capacitância sobre a frequência pode ser estimada para
pequenas variações e indutância constante. Nessas condições, a diferenciação
da @eq-frequencias-desacopladas fornece

$ (Delta f_(0 s)) / f_(0 s) approx -1 / 2 (Delta C_s) / C_s. $ <eq-sensibilidade-capacitancia>

A relação é válida dentro da aproximação LC; mudanças na distribuição dos
campos também podem alterar os parâmetros efetivos. Um exemplo da influência
do carregamento capacitivo aparece no ressonador estudado por Voitkāns e
Voitkāns (#cite(<voitkans2014>, form: "year")), cuja frequência
fundamental passou de 1,635 MHz sem carga adicionada para 1,362 MHz com uma
esfera de capacitância declarada de 3,62 pF. Os autores observaram influência
mesmo ao conectar capacitâncias da ordem de 1 pF, o que limita a medição
direta por sondas.

Essa sensibilidade também exige cuidado com o ambiente e com a instrumentação.
A altura em relação ao plano de referência, a proximidade de condutores e a
posição dos instrumentos fazem parte da configuração elétrica do ensaio e
devem ser mantidas ou registradas nas comparações. No caso das sondas, a alta
resistência de entrada não elimina a influência sobre o ressonador, pois o
carregamento capacitivo pode deslocar a frequência e introduzir perdas.

Essas particularidades também precisam ser consideradas na comparação com
ferramentas de cálculo. O JavaTC define a capacitância efetiva com as
contribuições distribuídas referidas ao terminal @javatc-ces. A documentação
também distingue a indutância
medida em baixa frequência da indutância série efetiva em ressonância, que
considera a corrente não uniforme no enrolamento @javatc-les. Assim, calcular
$C_s$ com uma frequência medida e uma indutância de baixa frequência não
assegura equivalência com a capacitância fornecida pela ferramenta. A
comparação entre cálculo e medição exige definições compatíveis dos parâmetros.

== Modelos concentrados e distribuídos

A distinção entre parâmetros equivalentes e grandezas distribuídas está
relacionada à forma de representar o secundário. No modelo concentrado, a SGTC
é descrita por duas malhas RLC acopladas pela indutância mútua. Nessa
representação, o centelhador em condução é substituído por uma ligação que fecha
a malha primária, e as perdas são reunidas em parâmetros equivalentes. Como as
cargas dos dois capacitores e as correntes dos enrolamentos constituem as
quatro variáveis de estado, o sistema tem ordem quatro e pode apresentar dois
pares de polos complexos conjugados.

Com essa simplificação, é possível calcular os transitórios e os parâmetros
modais sem resolver a distribuição espacial do campo. Já nos modelos
distribuídos, a tensão e a corrente dependem também da posição ao longo do
enrolamento. Para representar essa dependência, o enrolamento pode ser dividido
em seções com indutâncias e capacitâncias, incluindo as interações entre elas,
ou aproximado por uma linha de transmissão. Essas representações são
comparadas na @fig-modelos-secundario, que também indica as contribuições do
terminal e do ambiente.

#figura-prevista(
  [Representações concentrada e distribuída do secundário e suas contribuições capacitivas],
  [Comparar um RLC equivalente com um enrolamento dividido em seções. Indicar capacitâncias entre espiras, para o terminal e para o ambiente, além de perfis qualitativos de tensão e corrente no modo fundamental.],
) <fig-modelos-secundario>

Essa relação entre as representações aparece no trabalho de Denicolai
(#cite(<denicolai2001>, form: "year")), que obtém parâmetros equivalentes a
partir da distribuição de corrente e potencial do secundário. Com modelos
espaciais, Craven (#cite(<craven2014>, form: "year")) investiga os modos
superiores e as alterações no sentido de enrolamento. O autor também relaciona
a aplicabilidade do modelo concentrado ao carregamento capacitivo e à
frequência de operação em relação às ressonâncias do enrolamento. Outra
abordagem é a de Voitkāns e Voitkāns (#cite(<voitkans2014>, form: "year")),
que adotam uma linha monocondutora equivalente, inicialmente homogênea e sem
perdas, e comparam ressonâncias e distribuições de tensão com medições.

Ao considerar a distribuição espacial, é necessário distinguir os modos
superiores do secundário dos dois modos do sistema acoplado. Os primeiros têm
distribuições espaciais diferentes das do modo fundamental, podem existir com
a malha primária aberta e não precisam ter frequências múltiplas inteiras da
fundamental. O par $f_(-)$ e $f_(+)$, por sua vez, decorre da interação entre
os dois ressonadores na faixa considerada. Assim, a identificação de vários
picos em um espectro exige avaliar sua origem, pois eles podem corresponder
a fenômenos distintos.

Neste trabalho, portanto, o modelo concentrado será avaliado na faixa de
frequência e nas configurações ensaiadas, enquanto as descrições distribuídas
auxiliarão a discussão das discrepâncias, sem validação espacial do enrolamento.
A concordância na fundamental ficará restrita a essas condições e não
assegurará concordância nos modos superiores, com outro terminal ou na operação
com descargas.

= Metodologia

A pesquisa compreenderá o dimensionamento, a construção e a caracterização
experimental de uma SGTC. A avaliação do modelo linear será realizada em baixa
energia, sem descargas no secundário, mediante comparação entre previsões e
medições de frequência e amortecimento. Essa separação das condições de ensaio
permitirá avaliar o modelo sem incluir a dinâmica não linear das descargas.
A operação com centelhador e descargas constituirá, por sua vez, uma etapa
distinta, destinada à demonstração funcional e ao registro complementar do
desempenho.

== Estratégia e etapas da pesquisa

O estudo terá caráter experimental e quantitativo. O dimensionamento analítico
será comparado com as estimativas do JavaTC e do WinTesla para a mesma
geometria, respeitando as definições dos parâmetros de cada ferramenta.
Antes da comparação com as medições, a implementação numérica será verificada
pela solução analítica e pelos casos desacoplado e sem perdas. Com isso,
eventuais diferenças decorrentes da implementação poderão ser examinadas
separadamente daquelas observadas na avaliação experimental do modelo.

As previsões nominais serão arquivadas antes da coleta, para que permaneçam
distintas das previsões posteriormente atualizadas ou ajustadas. Após a
construção, serão registradas as dimensões reais e as alterações do projeto.
Em seguida, serão medidos os componentes e caracterizados os modos acoplados
e o decaimento livre do secundário. Para preparar essa caracterização, ensaios
preliminares orientarão a escolha das faixas de excitação, das posições do
primário e das condições de aquisição. O número de repetições e os critérios
de análise serão definidos antes da série principal, enquanto a demonstração
funcional ficará para uma etapa posterior, sob liberação específica para
alta tensão.

== Grandezas investigadas e configurações de referência

Serão investigados $L_p$, $L_s$, $C_p$, $C_s$, $M$ e $k$, além das
frequências amortecidas, das taxas de amortecimento e dos fatores de qualidade.
Como essas últimas grandezas dependem da configuração dos circuitos, o fator
$Q_s$ será determinado com a malha primária aberta, separadamente dos fatores
dos modos acoplados definidos na @eq-q-modal.

Nos ensaios de baixa energia, a fonte de alta tensão permanecerá fisicamente
desconectada. Para identificar os modos acoplados, o centelhador será
substituído por uma ligação condutora que mantenha a malha primária fechada.
Nesses ensaios, será adotada uma configuração de referência com altura e
tomada do primário, terminal capacitivo e presença ou ausência do ponto de
descarga definidos. Para relacionar cada resultado à montagem correspondente,
serão registradas as mudanças nesses elementos, assim como a posição dos
sensores, as conexões e as condições ambientais disponíveis.

== Instrumentação, condições de ensaio e segurança

A instrumentação prevista compreende medidor de resistência, indutância e
capacitância, gerador de sinais, osciloscópio digital e instrumentos
dimensionais. Modelos, acessórios, faixas e situação de calibração serão
registrados após a confirmação dos equipamentos disponíveis. A escolha das
condições de aquisição deverá permitir resolver as oscilações e seu decaimento
sem saturação. Como o próprio arranjo de medição pode alterar a frequência e
o fator de qualidade, serão avaliados o carregamento dos sensores e a
dependência das estimativas com a amplitude de excitação @craven2014.

Os ensaios dependerão de análise de risco, autorização e supervisão, conforme
os procedimentos do laboratório e a NR-10 @nr10-2019. O planejamento incluirá
barreiras, controle de acesso, parada e proteções elétricas, com limites de
excitação que considerem a elevação ressonante e a energia armazenada.
Intervenções na montagem exigirão desenergização, impedimento de reenergização,
descarga e verificação de ausência de tensão, com dispositivos adequados
@illinois-electrical-safety. Na operação em alta tensão, haverá acompanhamento
presencial, sem contato humano com as descargas, e avaliação dos riscos
elétricos, térmicos, acústicos, ópticos, de gases e de interferência.
Quanto à instrumentação, a proteção de terra será mantida, e sondas comuns não
serão ligadas aos pontos de alta tensão. Se forem constatadas condições fora
da liberação ou falhas de proteção, o ensaio será interrompido e reavaliado
antes da retomada.

== Procedimentos de caracterização em baixa energia

As indutâncias serão medidas com os capacitores externos desconectados e o
outro enrolamento aberto, registrando-se a frequência de teste e compensando-se
os cabos conforme o manual do medidor. Já a capacitância primária será medida
no banco utilizado no protótipo. Na interpretação dessas leituras, os valores
de baixa frequência serão diferenciados dos parâmetros efetivos em ressonância,
conforme discutido no
capítulo anterior @javatc-ces @javatc-les. Se $C_s$ for inferida da frequência
e do amortecimento do secundário pelas relações do RLC, o resultado será
identificado como parâmetro ajustado, com o valor de $L_s$ utilizado explícito.

A indutância mútua será obtida por medição independente das frequências modais,
para que essas frequências possam ser posteriormente comparadas com a
previsão do modelo. Para isso, será empregado o método de associação dos
enrolamentos em série, com as polaridades em concordância e em oposição, em
frequência compatível com a
aproximação indutiva. Dessas leituras, serão calculados

$
  abs(M) = (L_"conc" - L_"op") / 4,
  quad k = abs(M) / sqrt(L_p L_s).
$ <eq-k-serie>

O uso da associação em série para levantar o acoplamento em função da altura
tem precedente em #cite(<denicolai2001>, form: "prose", supplement: [p. 64-65]).
Como o cálculo depende da diferença entre as duas leituras, será verificado
se a resolução é suficiente para determiná-la. Caso não seja, será avaliado
o método de tensão induzida no secundário aberto, com medição da corrente
primária e avaliação do carregamento dos instrumentos.

Varreduras de frequência localizarão as ressonâncias dos circuitos isolados
e do sistema acoplado. Os picos observados orientarão a identificação, mas não
serão automaticamente equiparados às frequências dos polos. Para estimar os
parâmetros modais, os transitórios registrados após a retirada da excitação
serão ajustados por mínimos quadrados à soma de duas senoides amortecidas,
obtendo-se $f_(d,-)$, $f_(d,+)$ e as respectivas taxas de amortecimento.
A avaliação do ajuste incluirá a estabilidade dos parâmetros e o exame dos
resíduos. Dessa forma, a superposição dos modos será considerada na análise,
sem ajustar os batimentos por uma única exponencial de perdas.

Com esse procedimento de identificação, será investigada a influência do
acoplamento sobre as frequências modais. Para isso, a altura do primário será
variada, mantendo-se a concentricidade, a tomada, o capacitor e o terminal de
referência. Em cada posição serão medidos $k$ e
as frequências modais, com verificação da sintonia. As curvas
$f_(d,-)(k)$ e $f_(d,+)(k)$ e a separação
$Delta f_d = f_(d,+) - f_(d,-)$ serão comparadas com as previsões para os
parâmetros de cada posição. Caso seja realizada uma ressintonia por mudança
de tomada, as medições correspondentes constituirão uma série distinta.
As medições serão repetidas, incluindo o retorno à posição de referência para
avaliar o reposicionamento.

Para caracterizar o secundário separadamente, seu _ring-down_ será realizado
com a malha primária aberta e captação de fraco acoplamento. Uma senoide
amortecida será ajustada ao trecho posterior à retirada da excitação e anterior
ao domínio do ruído, fornecendo
$f_(d,s)$ e $alpha_s$. O fator $Q_s$ será calculado pela combinação da
@eq-parametros-decaimento com a @eq-q-amortecimento, com verificação pelo
decréscimo logarítmico quando os picos forem resolvidos. O resultado incluirá
o carregamento residual da medição. Além dessa caracterização, os decaimentos
dos ressonadores isolados também poderão fornecer perdas equivalentes por
$R = 2 L alpha$, para posterior
comparação com novos transitórios acoplados.

Por fim, a influência do terminal será investigada pela comparação entre o
secundário sem terminal adicional, com o terminal de referência e com esse
terminal acrescido do ponto de descarga. Mantidas as demais condições de
montagem, serão avaliadas as diferenças de frequência, amortecimento e $Q_s$.
Como o objetivo dessa comparação é avaliar o efeito da geometria do terminal
e do ponto de descarga, todos esses ensaios ocorrerão sem corona ou descargas
ativas. Se algum modo ou decaimento não puder ser resolvido, essa condição
será registrada como limitação da identificação.

== Demonstração funcional e caracterização complementar das descargas

A montagem final será operada com o centelhador para demonstrar o funcionamento
e registrar as descargas, respeitando as condições autorizadas de alimentação
e duração. Nessa etapa, o comprimento será estimado por imagens com escala e
geometria de câmera documentadas, sem exposição de pessoas à região energizada.
Para interpretar essas estimativas, serão explicitados o critério de
comprimento, as limitações de perspectiva e a distinção entre descargas livres
e até um alvo condutor. Além dos eventos de maior extensão, os registros
incluirão a duração da observação e a repetibilidade, permitindo discutir o
desempenho nas condições documentadas.

A taxa média de disparos será estimada por contagem óptica em intervalo
conhecido, após verificar a resolução temporal e a ausência de contagens
duplicadas ou eventos perdidos. Como essa contagem descreve a repetição dos
disparos, seu resultado será diferenciado das frequências de oscilação dos
circuitos. Já a meta de aproximadamente 1 m será avaliada como desempenho
complementar, sem integrar a validação linear nem justificar operação fora
dos limites liberados. Caso não seja possível demonstrar o funcionamento,
essa limitação será registrada na avaliação do atendimento dos objetivos.

== Tratamento, rastreabilidade e preservação dos dados

Os dados brutos serão preservados com identificadores que relacionem cada
aquisição à configuração e à repetição correspondentes. Para manter esse
vínculo, os registros incluirão instrumentos, faixas, excitação, conexões e
condições de ensaio. O processamento será realizado por rotinas versionadas,
com documentação das conversões, janelas e ajustes, de modo que os resultados
possam ser relacionados aos dados de origem. Mesmo os dados rejeitados
permanecerão arquivados com justificativa, e uma discrepância em relação ao
modelo não será motivo suficiente para exclusão.

Serão mantidos separadamente os conjuntos de previsões nominais, atualizadas
com parâmetros medidos e obtidas por ajuste, com identificação dos dados
utilizados em cada conjunto. Essa organização, acompanhada de cópias de
segurança e instruções de reprodução da análise, permitirá recuperar os
registros e reavaliar os resultados, conforme a orientação do GUM
#cite(<jcgm100-2008>, supplement: [seção 7]).

== Erros relativos e orçamento de incerteza conforme o GUM

Para cada grandeza comparável $x$, será adotada a diferença
$Delta x = x_"prev" - x_"med"$ e o erro relativo assinado

$
  e_x = 100 (x_"prev" - x_"med") / x_"med",
$ <eq-erro-relativo-metodos>

expresso em porcentagem, sem tratar a medição como valor verdadeiro exato.
Quando o valor medido for nulo ou não distinguível de zero, será utilizada a
diferença absoluta. Já na verificação entre solução analítica e numérica, a
referência será o valor analítico.

O orçamento seguirá o GUM @jcgm100-2008, com avaliações do tipo A pelas
repetições e do tipo B por calibração, especificações e resolução dos
instrumentos. Além dessas contribuições, serão considerados o posicionamento,
o carregamento e a sensibilidade dos ajustes. Essas contribuições serão
propagadas pelo modelo de medição: para
$Y = g(X_1, dots, X_m)$, a incerteza-padrão combinada será calculada por

$
  u_c^2(y) = sum_(i=1)^m c_i^2 u^2(x_i)
    + 2 sum_(i=1)^(m-1) sum_(j=i+1)^m
      c_i c_j op("cov")(x_i, x_j),
  quad c_i = (∂ g) / (∂ x_i),
$ <eq-incerteza-combinada>

com os coeficientes de sensibilidade avaliados nas estimativas das entradas.
Como parâmetros de um mesmo ajuste e previsões e medições que compartilhem
dados podem estar correlacionados, essas correlações serão preservadas na
avaliação. Também será verificada a adequação da propagação de primeira ordem
nas expressões não lineares. Ao calcular a incerteza da diferença entre
previsão e medição, serão incluídas as contribuições de ambas e sua covariância.

A incerteza expandida será $U = k_"abr" u_c$, com probabilidade de abrangência
pretendida de aproximadamente 95% e fator justificado pela distribuição e
pelos graus de liberdade aplicáveis. $k_"abr"$ será distinguido do acoplamento
$k$. Na apresentação de cada resultado, constarão a estimativa, a unidade,
a incerteza e o fator de abrangência, com as fontes e contribuições documentadas
no orçamento.

== Critérios de comparação e interpretação das discrepâncias

A comparação utilizará grandezas com a mesma definição e configuração.
Assim, as frequências amortecidas serão confrontadas com o módulo da parte
imaginária dos polos dividido por $2 pi$, e as taxas de amortecimento, com o
módulo da parte real. Essa correspondência também será mantida nas varreduras:
seus picos serão comparados à resposta forçada, enquanto as expressões ideais
de sintonia ficarão restritas às suas hipóteses.

Será adotada a regra $abs(Delta x) <= U_(Delta x)$ para indicar compatibilidade
pontual, sendo $U_(Delta x)$ a incerteza expandida da diferença. Essa escolha
da pesquisa não constitui critério universal de validação do GUM. Além dessa
verificação pontual, a interpretação considerará as tendências da curva modal
e os resíduos dos ajustes. As discrepâncias serão
examinadas quanto à dessintonia, ao carregamento, às perdas e aos limites do
modelo concentrado, enquanto os resultados sem resolução ou incerteza
adequadas serão classificados como inconclusivos.

As conclusões distinguirão previsões nominais, atualizadas e ajustadas.
Essa distinção é necessária porque a reprodução dos dados usados para
identificar parâmetros não será considerada validação independente. A
adequação do modelo ficará, assim, limitada às configurações e grandezas
ensaiadas em baixa energia, sem extensão automática à operação com descargas.

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
