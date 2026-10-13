#import "template/lib.typ": conf
#import "template/fig.typ": abnt-figure, abnt-image, abnt-tabela, abnt-quadro
#import "template/pretextuais.typ": apendice, anexo, glossario
#import "template/citacoes.typ": citacao-longa
#import "template/titulos.typ": titulo-sem-numero

// Esqueleto da monografia: somente títulos, sem texto de desenvolvimento.
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

== Contextualização e aplicações

== Problema de pesquisa

== Objetivos

=== Objetivo geral

=== Objetivos específicos

== Justificativa e contribuição esperada

== Delimitação do escopo

== Organização do trabalho

= Fundamentação teórica e trabalhos correlatos

== Princípio de funcionamento e ciclo de operação da SGTC

== Comparação entre SGTC, SSTC e DRSSTC

== Ressonância, sintonia e acoplamento magnético

== Transferência de energia, batimentos e dissipação

== Amortecimento e fator de qualidade

== Capacitância própria, terminal capacitivo e influência do ambiente

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
    style: "associacao-brasileira-de-normas-tecnicas",
  )
]

#apendice("A", "Derivações matemáticas", [])

#apendice("B", "Memórias de dimensionamento", [])

#apendice("C", "Entradas e saídas das ferramentas computacionais", [])

#apendice("D", "Desenhos e lista de materiais", [])

#apendice("E", "Orçamentos detalhados de incerteza", [])

#apendice("F", "Protocolos, registros de dados e reprodução da análise", [])
