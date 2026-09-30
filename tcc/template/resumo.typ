// ---------------------------------------------------------------------------
// Conformidade do resumo — ABNT NBR 6028:2021
//   §4.1.2  parágrafo único, frases concisas, sem enumeração de tópicos
//   §4.1.4  verbo na 3ª pessoa
//   §4.1.7  palavras-chave com iniciais minúsculas (exceto substantivos
//           próprios e nomes científicos), separadas por ponto e vírgula e
//           finalizadas por ponto
//   §4.1.8  150 a 500 palavras nos trabalhos acadêmicos
//   §3.3    evitar fórmulas, equações, diagramas e símbolos
// As regras de conteúdo (§4.1.2, §4.1.4) são de redação: os avisos abaixo
// cobrem o que é verificável automaticamente. A contagem de palavras é
// aproximada — serve de alerta, não substitui a conferência do texto final.
// ---------------------------------------------------------------------------

#import "titulos.typ": titulo-sem-numero

// Texto plano do conteúdo: percorre a árvore e concatena os trechos de texto.
#let _plano(c) = {
  if type(c) == str { c }
  else if type(c) == array { c.map(_plano).join("") }
  else if type(c) == content {
    let f = c.func()
    if f == text { c.text }
    // O parser do Typst transforma parte dos espaços num elemento `space`, que
    // não tem campos nem variável global acessível — a comparação é feita pelo
    // nome do elemento. Sem isto as palavras colam ("TODO:escrever").
    else if repr(f) == "space" { " " }
    else if f == math.equation { " " }
    else if f == parbreak { "\n" }
    else if f == par { " " + c.fields().values().map(_plano).join("") }
    else { c.fields().values().map(_plano).join("") }
  } else { "" }
}

// Conta quantos elementos de um dado tipo aparecem dentro do conteúdo.
#let _conta(c, tipo) = {
  if type(c) == array { c.map(x => _conta(x, tipo)).sum(default: 0) }
  else if type(c) == content {
    let proprio = if c.func() == tipo { 1 } else { 0 }
    proprio + c.fields().values().map(x => _conta(x, tipo)).sum(default: 0)
  } else { 0 }
}

// Aviso de conformidade: só aparece quando algo está fora da norma.
// `rotulo` permite reaproveitar o aviso no abstract (mesma norma, outro idioma).
#let _aviso(msg, rotulo: "Conformidade do resumo (ABNT NBR 6028:2021)") = block(
  above: 1.2em,
  inset: 5pt,
  stroke: 0.4pt + rgb("#b00020"),
  radius: 2pt,
  text(size: 9pt, fill: rgb("#b00020"))[
    *⚠ #rotulo:* #msg
  ],
)

#let resumo-abnt(
  resumo: none, 
  palavras-chave: (), 
) = {
  let n-palavras = _plano(resumo).split().len()
  let n-paragrafos = _conta(resumo, parbreak) + _conta(resumo, par)
  let n-equacoes = _conta(resumo, math.equation)
  let n-chaves = palavras-chave.len()

  // §5.2.3: título sem indicativo numérico, centralizado e com o destaque das
  // seções primárias (mesmo helper do sumário e das referências).
  titulo-sem-numero("Resumo")

  resumo
  
  context {
    set par(
      first-line-indent: 0em,
    )
    strong("Palavras-chave: ")
    // §4.1.7: separadas por ponto e vírgula, finalizadas por ponto.
    text(palavras-chave.join("; "))
    text(".")

  }

  if n-palavras < 150 or n-palavras > 500 {
    _aviso([#n-palavras palavras no resumo — a norma pede de 150 a 500 (§4.1.8).])
  }
  if n-paragrafos > 0 {
    _aviso([o resumo deve ser um parágrafo único, sem quebras nem enumeração de tópicos (§4.1.2).])
  }
  if n-equacoes > 0 {
    _aviso([evitar fórmulas, equações e símbolos no resumo (§3.3).])
  }
  if n-chaves != 5 {
    _aviso([#n-chaves palavras-chave — as regras da FEELT fixam cinco (§4.1.7 define o formato).])
  }
  // Sem quebra de página no fim: o título do abstract (heading de nível 1) já
  // começa em página nova.
}
