// Cada elemento pré-textual, cada seção e cada elemento pós-textual começa em
// NOVA página. Em trabalho só no anverso não há exigência de página ímpar:
// a NBR 14724 §5.2.2 diz que, "para trabalhos apresentados apenas no anverso,
// os títulos das seções primárias devem começar em nova página".
//
// (Histórico: até 30/09/2026 o template seguia a regra 2 da FEELT — cada
// elemento em página ímpar, para impressão frente e verso — usando
// `pagebreak(to: "odd")`, que inseria folhas em branco. Com a decisão do
// orientador de manter só o anverso, a exigência de ímpar caiu.)
//
// `weak: true` evita folha fantasma quando o conteúdo anterior já terminou
// exatamente no início de uma página (validado: a quebra só é inserida se a
// página atual tiver conteúdo).
//
// Fica em módulo próprio porque é usado tanto pelo `lib.typ` (folha de rosto,
// resumo, sumário, seções) quanto pelo `pretextuais.typ`.
#let nova-pagina() = pagebreak(weak: true)
