// ---------------------------------------------------------------------------
// Elementos pré-textuais e pós-textuais — ABNT NBR 14724:2024
//   §4.2.1  ordem e conteúdo dos pré-textuais
//   §4.2.3  ordem e conteúdo dos pós-textuais
//   §5.2.3  títulos sem indicativo numérico: centralizados
//   §5.2.4  elementos sem título (dedicatória, epígrafe): alinhados do meio da
//           mancha gráfica até a margem direita, na parte inferior da página
// A ordem em que aparecem no documento é definida no `lib.typ`.
// ---------------------------------------------------------------------------
#import "paginas.typ": nova-pagina
#import "resumo.typ": _plano, _conta, _aviso
#import "titulos.typ": titulo-sem-numero

// Página de elemento sem indicativo numérico. O título é um `heading` e o
// `show heading` do `lib.typ` já quebra para página nova e centraliza — NÃO
// chamar `nova-pagina()` aqui de novo (a quebra é fraca, mas evita duplicidade).
#let _pagina(titulo, corpo, sumario: false) = {
  titulo-sem-numero(titulo, sumario: sumario)
  corpo
}

// Conteúdo alinhado do meio da mancha gráfica (8 cm) até a margem direita,
// na parte inferior da página (§5.2.4).
#let _meio-direita(corpo) = {
  v(1fr)
  grid(
    columns: (8cm, 1fr),
    [],
    align(left, corpo),
  )
}

// ---- B1. Ficha catalográfica ----------------------------------------------
// §4.2.1.1.2: no VERSO da folha de rosto (em formato eletrônico, imediatamente
// após a página de rosto). §5.3: NÃO pode ser contada nem numerada.
// O layout segue o MODELO do template oficial da Biblioteca UFU: a linha
// padrão do sistema, o QUADRO com os dados de catalogação e os créditos dos
// bibliotecários. Os dados oficiais são gerados automaticamente no Portal do
// Aluno (ver `ficha-nota` no main.typ); até lá, use um texto provisório.
#let ficha-catalografica(ficha, nota: none) = {
  // `weak: true` porque a folha de rosto já termina em quebra de página: sem
  // isto seria criada uma página fantasma entre ela e a ficha (validado).
  pagebreak(weak: true)
  block(
    width: 100%,
    inset: (left: 0.5cm, right: 0.5cm),
    {
      // Fonte menor e uniforme (10 pt) e espaço simples — §5.1 e §5.2.
      set par(
        leading: 1.15em - 0.693em,
        spacing: 1.15em - 0.693em,
        first-line-indent: 0em,
        justify: false,
      )
      set text(size: 10pt)
      align(center)[
        Ficha Catalográfica Online do Sistema de Bibliotecas da UFU \
        com dados informados pelo(a) próprio(a) autor(a).
      ]
      v(0.6em)
      block(width: 100%, stroke: 0.6pt, inset: 8pt, ficha)
      v(0.6em)
      align(center)[
        Bibliotecários responsáveis pela estrutura de acordo com o AACR2: \
        Gizele Cristine Nunes do Couto - CRB6/2091 \
        Nelson Marcos Ferreira - CRB6/3074
      ]
      if nota != none {
        v(1.2em)
        nota
      }
    },
  )
  // Devolve uma página ao contador: a ficha não é contada, então a folha
  // seguinte retoma a numeração como se ela não existisse.
  context counter(page).update(counter(page).get().first() - 1)
}

// ---- B10. Folha de aprovação -------------------------------------------------
// §4.2.1.3: elemento OBRIGATÓRIO, inserido logo após a folha de rosto (na
// prática, depois da ficha catalográfica). Deve conter: nome do autor, título e
// subtítulo, natureza (tipo do trabalho, objetivo, instituição e área de
// concentração), data de aprovação e nome, titulação e assinatura dos membros
// da banca examinadora, com as instituições a que pertencem.
// §5.2: a natureza do trabalho é alinhada do meio da mancha gráfica até a
// margem direita — mesmo tratamento da folha de rosto. Não tem título
// (§5.2.3 não o lista).
// `dados` é um dicionário com `local-data` (opcional), `area` (opcional) e
// `banca` — lista de trios (nome, titulação/função, instituição).
#let folha-aprovacao(
  autores: (),
  titulo: none,
  subtitulo: none,
  natureza: none,
  dados: (:),
) = {
  let local-data = dados.at("local-data", default: none)
  let area = dados.at("area", default: none)
  let banca = dados.at("banca", default: ())
  nova-pagina()
  align(center)[
    #for autor in autores {
      block()[
        #strong(upper(autor))
      ]
    }
    #v(1fr)
    #strong(upper(titulo))#if subtitulo != none [:] \
    #if subtitulo != none { text(subtitulo) }
    #v(1fr)
  ]
  context {
    set par(
      leading: 1.15em - 0.693em,
      spacing: 1.15em - 0.693em,
      first-line-indent: 0em,
      justify: true,
    )
    grid(
      columns: (8cm, 1fr),
      [],
      block[
        #natureza
        #if area != none [
          #linebreak()
          #area
        ]
        #if local-data != none [
          #linebreak()
          #local-data
        ]
      ],
    )
  }
  v(1fr)
  align(center)[Banca Examinadora:]
  for membro in banca {
    v(2.8em)
    align(center, line(length: 70%))
    align(center)[#membro.at(0) – #membro.at(1) (#membro.at(2))]
  }
}

// ---- B2. Abstract (resumo em língua estrangeira) ---------------------------
// §4.2.1.8: obrigatório. Segue a NBR 6028, como o resumo — parágrafo único,
// 150 a 500 palavras e as CINCO palavras-chave exigidas pela FEELT (aqui em
// "Keywords:"). Emite as MESMAS verificações automáticas do resumo.
#let abstract-abnt(abstract: none, keywords: ()) = {
  let n-palavras = _plano(abstract).split().len()
  let n-paragrafos = _conta(abstract, parbreak) + _conta(abstract, par)
  let n-equacoes = _conta(abstract, math.equation)
  let n-chaves = keywords.len()
  let rotulo = "Conformidade do abstract (ABNT NBR 6028:2021)"
  _pagina("Abstract", [
    #abstract
    #v(1em)
    #context {
      set par(first-line-indent: 0em)
      strong("Keywords: ")
      text(keywords.join("; "))
      text(".")
    }
    #if n-palavras < 150 or n-palavras > 500 {
      _aviso([#n-palavras palavras no abstract — a norma pede de 150 a 500 (§4.1.8).], rotulo: rotulo)
    }
    #if n-paragrafos > 0 {
      _aviso([o abstract deve ser um parágrafo único, sem quebras nem enumeração de tópicos (§4.1.2).], rotulo: rotulo)
    }
    #if n-equacoes > 0 {
      _aviso([evitar fórmulas, equações e símbolos no abstract (§3.3).], rotulo: rotulo)
    }
    #if n-chaves != 5 {
      _aviso([#n-chaves keywords — as regras da FEELT fixam cinco.], rotulo: rotulo)
    }
  ])
}

// ---- B3/B4. Listas de ilustrações, tabelas e quadros -----------------------
// §4.2.1.9-10: na ordem de apresentação, com o nome específico, travessão, o
// título e o respectivo número de página. Só é renderizada quando existe pelo
// menos um item. O formato das entradas é definido no `show outline.entry` do
// `lib.typ` (travessão + pontos de preenchimento + página).
#let lista-ilustracoes(tipo, titulo) = context {
  // O `kind` é comparado por IDENTIDADE: uma figura comum tem kind = elemento
  // `image` (vale para `figure(rect(...))` e `figure(image(...))`), uma tabela
  // tem kind = elemento `table` e o quadro, criado por nós, tem kind = a string
  // "quadro". Por isso o mapa abaixo, e não uma string única.
  let seletor = if tipo == "figura" {
    figure.where(kind: image)
  } else if tipo == "tabela" {
    figure.where(kind: table)
  } else {
    figure.where(kind: "quadro")
  }
  if query(seletor).len() > 0 {
    _pagina(titulo, outline(target: seletor, title: none, indent: 0em))
  }
}

#let lista-figuras() = lista-ilustracoes("figura", "Lista de Figuras")
#let lista-tabelas() = lista-ilustracoes("tabela", "Lista de Tabelas")
#let lista-quadros() = lista-ilustracoes("quadro", "Lista de Quadros")

// ---- B5/B6. Listas de siglas e de símbolos ---------------------------------
// §4.2.1.11-12: relação (alfabética, no caso das siglas) seguida do significado
// por extenso. `itens` é um array de pares: (("ABNT", "Associação ..."), ...)
// `sumario: true` é usado só pelo glossário: sendo PÓS-textual, ele deve constar
// do sumário (NBR 6027), enquanto as listas pré-textuais não podem.
#let lista-de(itens, titulo, sumario: false) = {
  _pagina(titulo, grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    row-gutter: 0.35em,
    ..itens.flatten(),
  ), sumario: sumario)
}

#let lista-siglas(itens) = lista-de(itens, "Lista de Siglas")
#let lista-simbolos(itens) = lista-de(itens, "Lista de Símbolos")

// ---- B7. Elementos opcionais pré-textuais ----------------------------------
// §4.2.1.2 errata (logo após a folha de rosto), §4.2.1.4 dedicatória,
// §4.2.1.5 agradecimentos, §4.2.1.6 epígrafe.
#let pagina-errata(texto) = _pagina("Errata", texto)
#let pagina-agradecimentos(texto) = _pagina("Agradecimentos", texto)

// Dedicatória e epígrafe não têm título e ficam na parte inferior da página,
// do meio da mancha gráfica até a margem direita (§5.2.4).
#let pagina-dedicacao(texto) = {
  nova-pagina()
  _meio-direita(texto)
}

#let pagina-epigrafe(texto, autoria: none) = {
  nova-pagina()
  _meio-direita(if autoria == none { texto } else { [#texto #v(0.5em) #align(right)[(#autoria)]] })
}

// ---- B8. Elementos pós-textuais --------------------------------------------
// §4.2.3.2 glossário (ordem alfabética), §4.2.3.3 apêndice e §4.2.3.4 anexo
// (identificados por letra maiúscula consecutiva e travessão, com o MESMO
// destaque da seção primária).
#let glossario(itens) = lista-de(itens, "Glossário", sumario: true)

#let apendice(letra, titulo, corpo) = {
  // Sem `nova-pagina()`: o título é um `heading` de nível 1 e o `show heading`
  // do `lib.typ` já quebra para página nova. `sumario: true` porque apêndice é
  // pós-textual e deve constar do sumário (NBR 6027).
  titulo-sem-numero("Apêndice " + letra + " – " + titulo, sumario: true)
  corpo
}

#let anexo(letra, titulo, corpo) = {
  // Idem apêndice: sem `nova-pagina()` (o heading quebra) e com `sumario: true`.
  titulo-sem-numero("Anexo " + letra + " – " + titulo, sumario: true)
  corpo
}
