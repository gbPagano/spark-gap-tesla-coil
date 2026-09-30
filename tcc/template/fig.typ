// ---------------------------------------------------------------------------
// Ilustrações, tabelas e quadros — NBR 14724:2024 §5.1, §5.2, §5.8 e §5.9
//   §5.1  título (legenda) e fonte em tamanho MENOR e UNIFORME — aqui: 10 pt
//   §5.2  título e fonte em ESPAÇO SIMPLES
//   §5.8  qualquer ilustração é precedida da palavra designativa (Figura, Quadro,
//         Gráfico...) + número de ordem + travessão + título, e seguida
//         IMEDIATAMENTE pela fonte consultada (NBR 10520). A fonte é obrigatória
//         mesmo quando a ilustração é do próprio autor, e deve dizer
//         "elaborado pelo autor", "elaboração própria" ou "o próprio autor".
//   §5.9  tabelas conforme as normas de apresentação tabular do IBGE (abertas
//         nas laterais, com o dado numérico como informação central).
// Tipo, número, título, fonte e notas respeitam as margens da ilustração.
// ---------------------------------------------------------------------------

#set text(lang: "pt")

// Legenda e fonte: 10 pt, espaço simples e CENTRALIZADAS sob a ilustração
// (preferência do autor — as normas não fixam o alinhamento; o template oficial
// da Biblioteca alinha à esquerda). O parâmetro `centralizado` permite voltar ao
// padrão do template sem tocar nos chamadores: `centralizado: false`.
#let legenda-menor(corpo, centralizado: false) = {
  set par(
    leading: 1.15em - 0.693em,
    spacing: 1.15em - 0.693em,
    first-line-indent: 0em,
    justify: false,
  )
  set text(size: 10pt)
  let alinhamento = if centralizado { center } else { left }
  block(width: 100%, align(alinhamento, corpo))
}

// Fonte consultada — elemento obrigatório (§5.8 e §5.9), inclusive quando o
// trabalho é do próprio autor.
#let fonte-consultada(fonte) = {
  if fonte == none {
    block(
      inset: 4pt,
      stroke: 0.4pt + rgb("#b00020"),
      radius: 2pt,
      text(size: 9pt, fill: rgb("#b00020"))[
        *⚠ Fonte obrigatória (§5.8/§5.9):* informe "elaborado pelo autor (ano)",
        "elaboração própria (ano)" ou a referência conforme a NBR 10520.
      ],
    )
  } else {
    legenda-menor([Fonte: #fonte], centralizado: true)
  }
}

// Imagem já com a fonte consultada abaixo — use dentro de `figure` com
// `caption:` (a legenda acima é montada pelo próprio `figure`).
// ATENÇÃO ao caminho: o Typst resolve o caminho em relação ao arquivo onde o
// `image()` é chamado — como este helper fica em `template/`, a partir do
// `main.typ` escreva `"../assets/exemplo.png"`.
#let abnt-image(
  body,
  source: none,
  width: 100%,
) = stack(
  spacing: 0.8em,
  block(width: 100%, align(center, image(body, width: width))),
  fonte-consultada(source),
)

// Figura com qualquer conteúdo (diagrama, gráfico, desenho, foto...).
#let abnt-figure(
  body,
  title: none,
  source: none,
) = figure(
  gap: 0.8em,
  caption: title,
  stack(
    spacing: 0.8em,
    block(width: 100%, align(center, body)),
    fonte-consultada(source),
  ),
)

// Tabela — normas de apresentação tabular do IBGE (§5.9): ABERTA nas laterais,
// sem linhas verticais. As células são passadas como argumentos POSICIONAIS
// (como em `table`), senão o Typst ignora `table.header()` e `table.hline()`.
#let abnt-tabela(
  title: none,
  source: none,
  columns: auto,
  align: center + horizon,
  ..celulas,
) = figure(
  kind: table,
  supplement: [Tabela],
  gap: 0.8em,
  caption: title,
  stack(
    spacing: 0.8em,
    table(columns: columns, align: align, stroke: none, ..celulas),
    fonte-consultada(source),
  ),
)

// Quadro — é uma ILUSTRAÇÃO (§5.8): FECHADO nas laterais, com a palavra
// designativa "Quadro" (e não "Tabela"), e dados não numéricos.
#let abnt-quadro(
  title: none,
  source: none,
  columns: auto,
  align: center + horizon,
  stroke: 0.5pt,
  ..celulas,
) = figure(
  kind: "quadro",
  supplement: [Quadro],
  gap: 0.8em,
  caption: title,
  stack(
    spacing: 0.8em,
    table(columns: columns, align: align, stroke: stroke, ..celulas),
    fonte-consultada(source),
  ),
)

// =============== EXEMPLOS DE USO ===============
//
// #figure(
//   abnt-image("../assets/foto.jpg", width: 70%, source: "elaborado pelo autor (2026)."),
//   caption: [Descrição da figura.],
// ) <fig-exemplo>
//
// #abnt-figure(
//   rect(width: 3cm, height: 2cm),
//   title: [Descrição da figura.],
//   source: "elaborado pelo autor (2026).",
// )
//
// #abnt-tabela(
//   title: [Resultados medidos.],
//   source: "elaborado pelo autor (2026).",
//   columns: (auto, 1fr, 1fr),
//   table.header([Ensaio], [Tensão (V)], [Corrente (A)]),
//   table.hline(),
//   [1], [127,0], [1,40],
//   [2], [130,7], [1,57],
//   table.hline(),
// )
//
// #abnt-quadro(
//   title: [Comparação entre ligações.],
//   source: "adaptado de SANTOS (2024, p. 12).",
//   columns: (auto, 1fr),
//   [Estrela-estrela], [Bloqueia a sequência zero],
//   [Delta-estrela], [Bloqueia a sequência zero e defasa em 30°],
// )
