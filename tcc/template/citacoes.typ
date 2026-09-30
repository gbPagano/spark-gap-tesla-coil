// ---------------------------------------------------------------------------
// Citações — ABNT NBR 10520:2023
//   §7.1    citação direta de até três linhas: no corpo do texto, entre aspas
//           duplas (aspas simples marcam citação dentro da citação).
//   §7.1.1  citação direta com mais de três linhas: destacada com recuo
//           padronizado em relação à margem esquerda, com letra MENOR que a do
//           texto, em espaço simples e SEM aspas. O recuo de 4 cm é recomendado.
//   Autores: até três, todos na chamada; com quatro ou mais admite-se indicar
//   apenas o primeiro seguido de "et al." (em itálico) — mas o critério deve
//   ser uniforme em todo o documento.
//   Sistema de chamada: autor-data (sobrenome, ano), conforme o estilo
//   bibliográfico configurado em `referencias.yml`.
// ---------------------------------------------------------------------------

// Citação direta com MAIS DE TRÊS LINHAS (recuo recomendado de 4 cm).
#let citacao-longa(corpo, recuo: 4cm) = block(
  width: 100%,
  inset: (left: recuo),
  {
    set par(
      leading: 1.15em - 0.693em,
      spacing: 1.15em - 0.693em,
      first-line-indent: 0em,
      justify: true,
    )
    set text(size: 10pt)
    corpo
  },
)
