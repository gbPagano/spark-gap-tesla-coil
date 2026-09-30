#import "template/lib.typ": conf
#import "template/fig.typ": abnt-figure, abnt-image, abnt-tabela, abnt-quadro
#import "template/pretextuais.typ": apendice, anexo, glossario
#import "template/citacoes.typ": citacao-longa
// Utilitários opcionais de fasores / números complexos (polar, cadd, cmul, cmag, ...).
// Descomente se o trabalho for usar esses cálculos.
// #import "template/complex.typ": *

// =====================================================================
// DOCUMENTO DE TESTE DE FORMATAÇÃO
// Todo o conteúdo abaixo é Lorem ipsum (textos, imagens geradas e valores
// irrelevantes) — serve apenas para conferir a formatação do PDF.
// Ao escrever o trabalho real, substitua os textos mantendo a estrutura
// de seções e os helpers de figura/tabela/quadro/citação.
// =====================================================================
#show: conf.with(
  universidade: "UNIVERSIDADE FEDERAL DE UBERLÂNDIA",
  faculdade: "Curso de Engenharia Elétrica",
  autores: (
    "Guilherme Borges Pagano - 12111EEL020",
  ),
  titulo: "Lorem ipsum dolor sit amet, consectetur adipiscing",
  subtitulo: "Análise de sed do eiusmod tempor incididunt ut labore",
  cidade: "Uberlândia",
  ano: "2026",
  natureza: "Trabalho de Conclusão de Curso apresentado à Faculdade de Engenharia Elétrica da Universidade Federal de Uberlândia como requisito parcial para a obtenção do título de Bacharel em Engenharia Elétrica.",
  orientador: "Prof. Dr. Lorem Ipsum Dolor",

  // --- elementos pré-textuais opcionais (conteúdo de teste) ---
  ficha: [
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      // Coluna da esquerda: código de biblioteca + ano (como no modelo).
      [P134 \ 2026],
      [
        *PAGANO, Guilherme Borges.* \
        Lorem ipsum dolor sit amet, consectetur adipiscing elit: sed do eiusmod tempor incididunt ut labore et dolore [recurso eletrônico] / Guilherme Borges Pagano. – Uberlândia, 2026. \
        87 p. \
        #v(0.5em)
        Orientador: Prof. Dr. Lorem Ipsum Dolor. \
        Trabalho de Conclusão de Curso (Graduação em Engenharia Elétrica) – Universidade Federal de Uberlândia, Faculdade de Engenharia Elétrica. \
        Modo de acesso: Internet. \
        Disponível em: https://example.com/lorem-ipsum (dados de teste). \
        Inclui bibliografia. \
        Inclui ilustrações. \
        #v(0.5em)
        1\. Lorem ipsum. 2. Dolor sit amet. 3. Consectetur adipiscing. I. Título.
      ],
    )
    #v(0.4em)
    #align(right)[CDU: 621.3]
  ],
  ficha-nota: [
    #align(center)[#text(size: 9pt, style: "italic")[
      Nota de teste: a ficha oficial é gerada automaticamente no Portal do Aluno.
      Tutorial: #link("https://bibliotecas.ufu.br/sites/bibliotecas.ufu.br/files/media/documento/ficha_catalografica_online_-_tutorial.pdf")[ficha catalográfica online – tutorial (PDF)]
      · Portal: #link("https://www.portalestudante.ufu.br/")[www.portalestudante.ufu.br]
    ]]
  ],
  aprovacao: (
    area: "Área de concentração: Engenharia Elétrica.",
    local-data: "Uberlândia, ____ de ____________ de 2026.",
    banca: (
      ("Prof. Dr. Lorem Ipsum Dolor", "Orientador", "UFU/FEELT"),
      ("Prof. Dr. Sit Amet Consectetur", "Membro interno", "UFU/FEELT"),
      ("Prof. Dr. Adipiscing Elit", "Membro externo", "UFU/FEELT"),
    ),
  ),
  dedicacao: [
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  ],
  agradecimentos: [
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
  ],
  epigrafe: [
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    #v(0.5em)
    #align(right)[(Lorem Ipsum, 2026)]
  ],
  resumo: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.],
  palavras-chave: ("lorem ipsum", "consectetur", "adipiscing elit", "sed do eiusmod", "tempor incididunt"),
  abstract: [This work presents a lorem ipsum dolor sit amet study on consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. The methodology adopts ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat, with measurements of duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Results indicate that excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum, while sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. It is concluded that nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt, and that neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Additional remarks follow at vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.],
  keywords: ("lorem ipsum", "consectetur", "adipiscing elit", "sed do eiusmod", "tempor incididunt"),
  siglas: (
    ("ABNT", "Associação Brasileira de Normas Técnicas"),
    ("FEELT", "Faculdade de Engenharia Elétrica"),
    ("IBGE", "Instituto Brasileiro de Geografia e Estatística"),
    ("TCC", "Trabalho de Conclusão de Curso"),
    ("UFU", "Universidade Federal de Uberlândia"),
  ),
  simbolos: (
    ([$f_0$], "Frequência de ressonância."),
    ([$L$], "Indutância total do circuito."),
    ([$C$], "Capacitância equivalente."),
    ([$eta$], "Rendimento lorem ipsum."),
  ),
)

// NBR 14724:2024 §4.2.2: o trabalho acadêmico NÃO pode ser dividido em
// "capítulos" — deve ser organizado em seções, com numeração progressiva
// (NBR 6024). A estrutura textual é Introdução / Desenvolvimento / Conclusão;
// os títulos das seções ficam a critério do autor (nota do Esquema 1).
//
// §5.6 — Siglas: na PRIMEIRA menção no texto, escreva o nome completo seguido
// da sigla entre parênteses; depois use apenas a sigla.
= Introdução

A engenharia elétrica contemporânea lorem ipsum dolor sit amet, consectetur
adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna
aliqua. O tema deste trabalho insere-se no contexto de ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris, e sua relevância é evidenciada pelas
aplicações discutidas em @lorem2026 e @dolor2025.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur.#footnote[Nota de rodapé de teste — lorem ipsum dolor sit
amet, em espaço simples e com fonte menor (§5.2.1).] Excepteur sint occaecat
cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est
laborum, conforme discutido por @amet2024.

O objetivo geral do trabalho é lorem ipsum dolor sit amet, consectetur
adipiscing elit. Como objetivos específicos, têm-se:

+ Ipsum dolor sit amet, consectetur adipiscing elit;
+ Sed do eiusmod tempor incididunt ut labore et dolore;
+ Ut enim ad minim veniam, quis nostrud exercitation;
+ Duis aute irure dolor in reprehenderit in voluptate.

Quanto à organização, a seção 2 apresenta o referencial teórico lorem ipsum; a
seção 3 descreve a metodologia adotada; a seção 4 discute os resultados
obtidos; e a seção 5 traz as considerações finais.

= Referencial Teórico

O referencial teórico parte dos fundamentos estabelecidos por @tesla1904 e
complementados por @dolor2025. Lorem ipsum dolor sit amet, consectetur
adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna
aliqua.

== Lorem ipsum dolor

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. A frequência de ressonância do circuito de
teste é dada pela equação:

$ f_0 = 1 / (2 pi sqrt(L C)) $

em que $f_0$ é a frequência de ressonância, $L$ é a indutância total e $C$ é a
capacitância equivalente lorem ipsum. A estrutura de blocos considerada neste
trabalho é mostrada na @fig-diagrama.

#abnt-figure(
  grid(
    columns: (auto, auto, auto, auto, auto),
    column-gutter: 0.9em,
    align(horizon, rect(width: 3cm, height: 1.6cm, stroke: 0.6pt, radius: 2pt, align(center + horizon)[Oscilador])),
    align(horizon)[#text(size: 16pt)[$arrow.r$]],
    align(horizon, rect(width: 3cm, height: 1.6cm, stroke: 0.6pt, radius: 2pt, align(center + horizon)[Bobina])),
    align(horizon)[#text(size: 16pt)[$arrow.r$]],
    align(horizon, rect(width: 3cm, height: 1.6cm, stroke: 0.6pt, radius: 2pt, align(center + horizon)[Carga])),
  ),
  title: [Diagrama de blocos do sistema lorem ipsum de teste.],
  source: "elaborado pelo autor (2026).",
) <fig-diagrama>

=== Consectetur adipiscing elit

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Segundo @tesla1904, "lorem ipsum dolor sit amet" é
condição necessária para o funcionamento de consectetur adipiscing elit.

==== Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua, ut enim ad minim veniam

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus
error sit voluptatem accusantium doloremque laudantium, totam rem aperiam.

== Tempor incididunt ut labore

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed
quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. A
comparação entre os modelos de teste é apresentada no @quadro-modelos.

#abnt-quadro(
  title: [Comparação entre os modelos lorem ipsum de teste.],
  source: "elaborado pelo autor (2026).",
  columns: (auto, 1fr),
  table.header([Modelo], [Característica principal]),
  [Modelo A], [Lorem ipsum dolor sit amet, consectetur adipiscing elit.],
  [Modelo B], [Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
  [Modelo C], [Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.],
) <quadro-modelos>

#citacao-longa[
  At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis
  praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias
  excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui
  officia deserunt mollitia animi, id est laborum et dolorum fuga @dolor2025.
]

= Metodologia

A metodologia segue a abordagem lorem ipsum dolor sit amet, consectetur
adipiscing elit. Os materiais utilizados estão descritos no @quadro-materiais e
o procedimento experimental é detalhado na sequência.#footnote[Segunda nota de
rodapé de teste — duis aute irure dolor in reprehenderit in voluptate
(§5.2.1).]

== Materiais e métodos

Foram utilizados componentes lorem ipsum com valores irrelevantes, relacionados
no @quadro-materiais.

#abnt-quadro(
  title: [Materiais utilizados no experimento de teste.],
  source: "elaborado pelo autor (2026).",
  columns: (auto, 1fr),
  table.header([Item], [Descrição]),
  [Item 1], [Lorem ipsum dolor sit amet, consectetur adipiscing elit.],
  [Item 2], [Sed do eiusmod tempor incididunt ut labore et dolore.],
  [Item 3], [Ut enim ad minim veniam, quis nostrud exercitation ullamco.],
) <quadro-materiais>

== Procedimento experimental

O procedimento foi executado nas seguintes etapas:

+ Preparação lorem ipsum do aparato experimental;
+ Registro das grandezas com valores irrelevantes;
+ Repetição do ensaio em três condições distintas;
+ Tratamento estatístico dos dados obtidos.

O rendimento do conjunto é estimado por:

$ eta = P_"útil" / P_"total" $

em que $P_"útil"$ é a potência útil e $P_"total"$ é a potência total
consumida. A montagem experimental de teste é mostrada na @fig-montagem.

#figure(
  abnt-image("../assets/lorem-gradiente.png", width: 78%, source: "elaborado pelo autor (2026)."),
  caption: [Montagem experimental lorem ipsum (imagem de teste).],
) <fig-montagem>

= Resultados e Discussão

Os ensaios produziram os valores irrelevantes apresentados na @tab-ensaios. A
dispersão observada é típica de duis aute irure dolor in reprehenderit.

#abnt-tabela(
  title: [Valores irrelevantes medidos no primeiro ensaio.],
  source: "elaborado pelo autor (2026).",
  columns: (auto, 1fr, 1fr, 1fr),
  table.hline(),
  table.header([Ensaio], [Tensão (V)], [Corrente (A)], [Potência (W)]),
  table.hline(),
  [1], [127,4], [1,42], [180,9],
  [2], [132,8], [1,51], [200,5],
  [3], [118,9], [1,33], [158,1],
  [4], [145,2], [1,64], [238,1],
  [5], [139,7], [1,58], [220,7],
  table.hline(),
) <tab-ensaios>

Na sequência, a disposição dos componentes de teste é mostrada na @fig-formas.

#figure(
  abnt-image("../assets/lorem-formas.png", width: 52%, source: "elaborado pelo autor (2026)."),
  caption: [Disposição dos componentes lorem ipsum (imagem de teste).],
) <fig-formas>

Conforme discutido por @amet2024, os dados não apresentam relação física
alguma, o que era esperado em um documento de teste.

== Consectetur adipiscing elit

Na segunda condição de ensaio, os valores medidos estão na @tab-frequencias e o
comportamento geral é ilustrado na @fig-grafico.

#abnt-tabela(
  title: [Valores irrelevantes medidos na segunda condição.],
  source: "elaborado pelo autor (2026).",
  columns: (auto, 1fr, 1fr, 1fr),
  table.hline(),
  table.header([Amostra], [Frequência (Hz)], [Indutância (mH)], [Capacitância (nF)]),
  table.hline(),
  [A], [50,0], [12,45], [81,3],
  [B], [60,0], [10,08], [69,8],
  [C], [40,0], [15,60], [101,4],
  [D], [70,0], [8,64], [59,9],
  table.hline(),
) <tab-frequencias>

#figure(
  abnt-image("../assets/lorem-grafico.png", width: 72%, source: "elaborado pelo autor (2026)."),
  caption: [Valores irrelevantes medidos no ensaio lorem ipsum.],
) <fig-grafico>

A análise da @fig-grafico permite concluir que duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

= Conclusão

O trabalho apresentou um estudo de lorem ipsum dolor sit amet, retomando os
objetivos da Introdução e sintetizando os resultados das seções anteriores. As
referências @lorem2026 e @dolor2025 embasaram as discussões.

Como propostas para trabalhos futuros, destacam-se:

- Ut enim ad minim veniam, quis nostrud exercitation;
- Duis aute irure dolor in reprehenderit in voluptate;
- Excepteur sint occaecat cupidatat non proident.

Espera-se que este documento de teste seja integralmente substituído pelo
conteúdo real do trabalho.

// =====================================================================
// REFERÊNCIAS (padrão ABNT NBR 6023)
// =====================================================================
// O título "Referências" é um heading sem indicativo numérico: o `conf` já o
// centraliza e aplica o destaque das seções primárias (§5.2.3 e §5.4).
//
// NBR 14724 §5.2 + NBR 6023:2025: cada referência em espaço SIMPLES, alinhada à
// esquerda, e as referências SEPARADAS ENTRE SI por uma linha em branco. O valor
// de `spacing` abaixo resulta em duas linhas simples (13,8 + 13,8 pt a 12 pt)
// porque, no Typst, o `spacing` de parágrafo SUBSTITUI o `leading` na virada.
#set par(
  leading: 1.15em - 0.693em,
  spacing: 1.6em,
  justify: false,
  first-line-indent: 0em,
)
// `full: false` lista apenas as obras CITADAS no texto — é o que a NBR 6023
// define como referência ("documentos citados").
#bibliography(
  "referencias.yml",
  title: "Referências",
  full: false,
  style: "associacao-brasileira-de-normas-tecnicas"
)

// =====================================================================
// ELEMENTOS PÓS-TEXTUAIS (NBR 14724 §4.2.3) — conteúdo de teste
// =====================================================================
#glossario((
  ("Lorem", "Dolor sit amet, consectetur adipiscing elit."),
  ("Ipsum", "Sed do eiusmod tempor incididunt ut labore."),
  ("Dolor", "Ut enim ad minim veniam, quis nostrud exercitation."),
))

#apendice("A", "Dados brutos do ensaio lorem ipsum", [
  Os dados brutos coletados no ensaio de teste são apresentados na
  @tab-brutos, com valores totalmente irrelevantes.

  #abnt-tabela(
    title: [Dados brutos irrelevantes do ensaio de teste.],
    source: "elaborado pelo autor (2026).",
    columns: (auto, 1fr, 1fr, 1fr),
    table.hline(),
    table.header([Leitura], [Grandeza 1], [Grandeza 2], [Grandeza 3]),
    table.hline(),
    [1], [10,1], [20,2], [30,3],
    [2], [11,4], [21,5], [31,6],
    [3], [12,7], [22,8], [32,9],
    table.hline(),
  ) <tab-brutos>
])

#anexo("A", "Documento de terceiros lorem ipsum", [
  Este anexo reproduz, para fins de teste de formatação, um trecho de documento
  de terceiros.

  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
  incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
  nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat,
  conforme @amet2024.
])
