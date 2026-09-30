#import "capa.typ": capa, contra-capa
#import "fig.typ": abnt-figure, legenda-menor
#import "paginas.typ": nova-pagina
#import "pretextuais.typ": ficha-catalografica, folha-aprovacao, abstract-abnt, lista-figuras, lista-tabelas, lista-quadros, lista-siglas, lista-simbolos, pagina-errata, pagina-dedicacao, pagina-agradecimentos, pagina-epigrafe
#import "resumo.typ": resumo-abnt
#import "titulos.typ": titulo-sem-numero

#let conf(
  universidade: none,
  faculdade: none,
  autores: (),
  titulo: none,
  subtitulo: none,
  cidade: none,
  ano: none,
  natureza: none,
  orientador: none,
  resumo: none,
  palavras-chave: (),
  // --- elementos pré-textuais adicionais (NBR 14724 §4.2.1) ---
  // Todos opcionais, exceto `abstract` (obrigatório no uso: preencha em main.typ)
  abstract: none,
  keywords: (),
  ficha: none,
  ficha-nota: none,
  errata: none,
  // Folha de aprovação (§4.2.1.3, obrigatória): dicionário com `area`
  // (opcional), `local-data` (opcional) e `banca` — lista de trios
  // (nome, titulação/função, instituição). Ver `folha-aprovacao` em pretextuais.typ.
  aprovacao: none,
  dedicacao: none,
  agradecimentos: none,
  epigrafe: none,
  siglas: none,
  simbolos: none,
  doc,
) = {
  
  // Trabalho diagramado SÓ NO ANVERSO (decisão do orientador, 30/09/2026):
  // margens fixas — esquerda/superior 3 cm e direita/inferior 2 cm em todas as
  // páginas (NBR 14724 §5.1a, caso "anverso"). Sem espelhamento e sem
  // `binding`, que só seriam necessários no frente e verso.
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 2cm, left: 3cm, right: 2cm),
  )
  
  // Fonte: Times New Roman 12 pt em todo o texto, inclusive na capa
  // (Regras de Formatação da FEELT; a NBR 14724 §5.1 recomenda fonte 12).
  set text(
    font: "Times New Roman",
    size: 12pt,
    lang: "pt",
    
  )
  
  // Entrelinha ABNT "1,5": no padrão Word equivale a 1,5 × 1,15 em = 1,725 em
  // (é o que o template oficial da UFU usa: w:line="360" ⇒ 20,7 pt a 12 pt).
  // O Typst SOMA o `leading` à altura natural da fonte, por isso subtraímos
  // essa altura: 0,693 em = altura natural da Times New Roman.
  // Se a família mudar, remedir: Arial = 0,728 em · Liberation Serif = 0,655 em.
  // Alternativa LaTeX/abnTeX2 (18,0 pt): 1.5em - 0.693em.
  set par(
    first-line-indent: (amount: 1.25cm, all: true),
    justify: true,
    leading: 1.725em - 0.693em,
    // A ABNT não exige espaço extra entre parágrafos: o template oficial usa
    // zero (contextualSpacing) e separa os parágrafos só pelo recuo de 1,25 cm.
    // Atenção: no Typst o `spacing` SUBSTITUI o `leading` na virada de parágrafo.
    // Repetir o mesmo valor é o que dá "espaço zero" (a virada fica idêntica a
    // uma linha normal); com `spacing: 0em` as linhas se sobrepõem — validado.
    spacing: 1.725em - 0.693em,
  )
      
  // Notas de rodapé — NBR 14724 §5.2.1: filete de 5 cm a partir da margem
  // esquerda, espaço simples entre as linhas e fonte menor e uniforme (10 pt).
  // As propriedades de `footnote.entry` precisam ser uniformes por trecho de
  // páginas e definidas antes de qualquer conteúdo — por isso ficam aqui.
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
    // `indent: 0pt` faz a nota começar na margem; a partir da 2ª linha o
    // alinhamento é feito com `hanging-indent` (abaixo), abaixo da primeira
    // letra da primeira palavra, como manda a §5.2.1 (o padrão do Typst é o
    // inverso: indenta a 1ª linha e joga a continuação na margem).
    indent: 0pt,
  )
  show footnote.entry: it => {
    set par(
      leading: 1.15em - 0.693em,
      spacing: 1.15em - 0.693em,
      first-line-indent: 0em,
      // ≈ largura do expoente + espaço (nota de 1 dígito) — validado em 3,75 pt.
      hanging-indent: 0.375em,
    )
    set text(size: 10pt)
    it
    // O conteúdo de uma nota é inline: sem um `parbreak` o Typst não cria um
    // parágrafo de verdade e as propriedades de parágrafo (como o
    // `hanging-indent` acima) não se aplicam — validado.
    parbreak()
  }

  // Equações e fórmulas (§5.7): destacadas no texto e, se necessário, numeradas
  // com algarismos arábicos entre parênteses, alinhados à direita.
  set math.equation(numbering: "(1)")

  set heading(numbering: "1.1")

  // Destaque tipográfico em cascata (§5.4), idêntico no sumário e no texto:
  //   1º nível: caixa alta + negrito · 2º: negrito
  //   3º: negrito + itálico · 4º: itálico
  // Usa wrappers explícitos (strong/text) por causa do ESCOPO de `set` no Typst:
  // um `set` vale apenas para o conteúdo produzido no MESMO bloco/ramo. Como o
  // nível é escolhido por `if`, um `set` dentro do ramo não alcançaria o
  // conteúdo montado depois dele — validado (sem os wrappers, o nível 3 saía sem
  // itálico).
  // Observação: `set` dentro de `context` POR SI SÓ funciona normalmente
  // (tamanho, estilo e peso aplicam) — o problema era o escopo do ramo.
  let _destaca(conteudo, nivel) = {
    if nivel == 1 or nivel == 2 { strong(conteudo) }
    else if nivel == 3 { text(weight: "bold", style: "italic", conteudo) }
    else if nivel == 4 { text(weight: "regular", style: "italic", conteudo) }
    else { text(weight: "regular", conteudo) }
  }

  // Número e título ficam em colunas de uma grade para que a 2ª linha do título
  // fique alinhada sob a primeira letra da primeira palavra (§5.2.2).
  // O contador do título só é acessível dentro de `context`.
  show heading: it => context {
    let nivel = it.level
    let corpo = _destaca(if nivel == 1 { upper(it.body) } else { it.body }, nivel)
    let numero = if it.numbering == none {
      none
    } else {
      _destaca(numbering(it.numbering, ..counter(heading).get()), nivel)
    }
    if nivel == 1 { nova-pagina() }
    // "um espaço de 1,5 entre as linhas" (§5.2.2) = 20,7 pt a 12 pt = 1,725 em
    block(
      below: 1.725em,
      breakable: false,
      text(size: 12pt,
        if numero != none {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.5em,
            align(left, numero),
            corpo,
          )
        } else if nivel == 1 {
          // §5.2.3: títulos sem indicativo numérico (referências, resumos,
          // listas, agradecimentos, apêndices...) são centralizados.
          // `width: 100%` é necessário: o block encolhe para o tamanho do
          // conteúdo e, sem largura cheia, o align(center) não teria efeito.
          block(width: 100%, align(center, corpo))
        } else {
          corpo
        }
      ),
    )
  }

  set list(indent: 1.25cm)
  set enum(indent: 1.25cm)

  // A legenda das figuras (título acima e fonte abaixo) é configurada junto do
  // corpo do trabalho — ver `show figure.caption` adiante.

  capa(
    universidade: universidade,
    faculdade: faculdade,
    autores: autores, 
    titulo: titulo, 
    subtitulo: subtitulo, 
    cidade: cidade, 
    ano: ano
  )

  // Folha de rosto: primeiro pré-textual contado (a capa não conta — §5.3).
  // A `capa` já termina em quebra de página; `nova-pagina()` é fraca e não
  // gera folha fantasma.
  nova-pagina()
  counter(page).update(1)
  
  contra-capa(
    autores: autores, 
    titulo: titulo, 
    subtitulo: subtitulo,
    natureza: natureza,
    orientador: orientador,
    cidade: cidade, 
    ano: ano
  )

  // §4.2.1.1.2 — a ficha catalográfica fica no verso da folha de rosto (dados
  // fornecidos pela Biblioteca) e NÃO é contada nem numerada (§5.3).
  if ficha != none { ficha-catalografica(ficha, nota: ficha-nota) }

  // §4.2.1.2-6 — elementos na ordem da norma. A errata é opcional; a FOLHA DE
  // APROVAÇÃO (§4.2.1.3) é obrigatória e vem logo depois da folha de rosto.
  if errata != none { pagina-errata(errata) }
  if aprovacao != none {
    folha-aprovacao(
      autores: autores,
      titulo: titulo,
      subtitulo: subtitulo,
      natureza: natureza,
      dados: aprovacao,
    )
  }
  if dedicacao != none { pagina-dedicacao(dedicacao) }
  if agradecimentos != none { pagina-agradecimentos(agradecimentos) }
  if epigrafe != none { pagina-epigrafe(epigrafe) }

  // Os elementos pré-textuais (resumo, abstract, listas, sumário) NÃO têm recuo
  // de primeira linha; o texto do trabalho tem 1,25 cm — restaurado adiante, ao
  // entrar na parte textual.
  set par(first-line-indent: 0em)

  // O título do resumo é um `heading` de nível 1: ele mesmo já começa em página
  // nova — não chamar `nova-pagina()` aqui de novo.
  resumo-abnt(
    resumo: resumo, 
    palavras-chave: palavras-chave,
  )

  // §4.2.1.8 — resumo em língua estrangeira (obrigatório).
  abstract-abnt(abstract: abstract, keywords: keywords)
  
  // §5.4 / NBR 6027: o destaque é *idêntico* no sumário e no texto.
  // Entradas das listas de ilustrações/tabelas/quadros trazem legenda própria:
  // recebem nome específico + número + TRAVESSÃO + título + pontos + página
  // (§4.2.1.9-10). As entradas do sumário caem no destaque em cascata.
  show outline.entry: it => {
    let cap = it.element.fields().at("caption", default: none)
    if cap != none and cap.func() == figure.caption {
      legenda-menor(grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.35em,
        [
          #strong(cap.supplement)
          #strong(context numbering(cap.numbering, ..cap.counter.at(it.element.location())))
          #h(0.25em) -- #h(0.25em)
          #cap.body
        ],
        repeat[.],
        [#context counter(page).at(it.element.location()).first()],
      ))
    } else if it.level == 1 {
      strong(upper(it))
    } else if it.level == 2 {
      strong(it)
    } else if it.level == 3 {
      text(weight: "bold", style: "italic", it)
    } else if it.level == 4 {
      text(weight: "regular", style: "italic", it)
    } else {
      it
    }
  }
  // NBR 6027 §5.1: a palavra "sumário" centralizada e com a mesma tipologia das
  // seções primárias — por isso o helper compartilhado.
  // §5.2 (recomendação): alinhar os títulos das entradas pela margem do
  // indicativo mais extenso. O `outline.entry` do Typst expõe apenas
  // `level`, `element` e `fill` — o número não é separável do título, então
  // mantemos o layout nativo: indicativo na margem, título logo em seguida e as
  // linhas seguintes alinhadas sob o título (recuo pendente nativo).
  // §6.3: elementos pré-textuais NÃO podem constar do sumário.
  // §4.2.1.9-12 — listas, na ordem da norma. As de figuras/tabelas/quadros só
  // são renderizadas quando existe conteúdo correspondente; as de
  // siglas/símbolos, quando fornecidas em `main.typ`.
  lista-figuras()
  lista-tabelas()
  lista-quadros()
  if siglas != none { lista-siglas(siglas) }
  if simbolos != none { lista-simbolos(simbolos) }

  // O título do sumário é um `heading`: ele mesmo quebra para página nova —
  // não chamar `nova-pagina()` aqui de novo.
  titulo-sem-numero("Sumário")
  outline(title: none, indent: 0em)

  // A partir daqui é a parte TEXTUAL: volta o recuo de primeira linha de 1,25 cm
  // (§5.2 e convenção do template oficial).
  set par(first-line-indent: (amount: 1.25cm, all: true))

  // Numeração (§5.3, trabalho só no anverso): algarismos arábicos no canto
  // superior DIREITO de todas as páginas; o número a 2 cm da borda superior e o
  // último algarismo a 2 cm da borda direita. O número é desenhado pelo
  // cabeçalho contextual (que `numbering` não aceita `context`).
  // ATENÇÃO: `numbering` junto com `header` faz o número sair DUAS vezes — no
  // cabeçalho e centralizado no rodapé (validado por medição) — por isso
  // `numbering` fica de fora aqui.
  set page(
    header: context { align(right, counter(page).display("1")) },
    // Calibra a altura do cabeçalho para o número ficar a 2 cm do topo da folha
    // (medido: 1,99 cm).
    header-ascent: 22%,
  )

  // Legenda das ilustrações e tabelas: palavra designativa + número + travessão
  // + título, ACIMA do elemento; corpo 10 pt, espaço simples e CENTRALIZADA sob
  // o elemento (preferência do autor; as normas não fixam o alinhamento).
  // A fonte consultada vem logo abaixo, pelo helper `fonte-consultada`
  // (fig.typ), também centralizada.
  // O separador é o travessão CURTO (en dash "–", que o `--` do Typst produz):
  // conferido contra o template oficial da Biblioteca, que grafa
  // "Tabela 1 – Gestores administrativos" e "Quadro 1 – ...".
  set figure.caption(position: top, separator: [ -- ])
  show figure.caption: it => legenda-menor(
    strong(it.supplement)
      + " "
      + strong(context it.counter.display(it.numbering))
      + it.separator
      + it.body,
    centralizado: true,
  )
  set figure(gap: 0.8em)
  
  doc
}

