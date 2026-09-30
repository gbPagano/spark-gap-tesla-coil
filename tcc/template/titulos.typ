// Títulos de elementos SEM indicativo numérico.
//
// NBR 14724:2024 §5.2.3 — errata, agradecimentos, lista de ilustrações, lista de
// tabelas, lista de abreviaturas e siglas, lista de símbolos, resumos, sumário,
// referências, glossário, apêndice(s), anexo(s) e índice(s): centralizados.
// NBR 14724:2024 §5.4 / NBR 6027 — com o mesmo destaque das seções primárias.
//
// É renderizado como um `heading` de nível 1 SEM numeração, e não como texto
// solto, por dois motivos:
//   • NBR 6027 §6.2 — os elementos PÓS-textuais (glossário, apêndices, anexos)
//     devem constar do sumário, e só um `heading` entra no `outline`;
//   • NBR 6027 §6.3 — os elementos PRÉ-textuais NÃO podem constar do sumário,
//     daí o `sumario: false` (padrão), que desliga o `outlined`.
//
// O `show heading` do `lib.typ` já centraliza este caso (ramo sem número) e já
// quebra para página nova — portanto os chamadores NÃO precisam chamar
// `nova-pagina()` de novo (a quebra é fraca, mas o costume evita duplicidade).
#let titulo-sem-numero(corpo, sumario: false) = heading(
  level: 1,
  numbering: none,
  outlined: sumario,
  corpo,
)
