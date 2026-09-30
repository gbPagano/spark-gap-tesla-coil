#let capa(
  universidade: none,
  faculdade: none,
  autores: (), 
  titulo: none, 
  subtitulo: none,
  cidade: none, 
  ano: none, 
) = {
  align(center)[
    #place(top + center, block[
      #strong(upper(universidade))
      
      #strong(upper(faculdade))
    ])

    // centralizado entre titulo e univesidade
    #v(1fr)
    // A ordem dos autores é a informada em `main.typ` — não ordenar aqui, pois
    // a ordem da capa é decisão de conteúdo.
    #for autor in autores {
      block()[
        #strong(upper(autor))
      ]
    }
    #v(3fr)

    #place(horizon + center, block()[
      // O dois-pontos só aparece quando existe subtítulo (ele o precede).
      #strong(upper(titulo))#if subtitulo != none [:]
      
      #if subtitulo != none { text(subtitulo) }
    ])

    #place(bottom + center, block[
      #strong(upper(cidade))
    
      #strong(ano)
    ])
  ]
  pagebreak()
}

#let contra-capa(
  autores: (), 
  titulo: none, 
  subtitulo: none,
  natureza: none,
  orientador: none,
  cidade: none, 
  ano: none,
) = {
  align(center)[
    #for autor in autores {
      block()[
        #strong(upper(autor))
      ]
    }

    #v(1fr)
    #strong(upper(titulo))#if subtitulo != none [:]
    
    #if subtitulo != none { text(subtitulo) }
    #v(1fr)
  ]
  

  // Natureza do trabalho: alinhada do meio da mancha gráfica até a margem
  // direita (NBR 14724 §5.2) e em espaço simples (§5.2).
  // Mancha gráfica = 16 cm (A4 − 3 cm − 2 cm), então o meio fica a 8 cm da
  // margem esquerda. Espaço simples no padrão Word = 1,15 em ⇒ 13,8 pt a 12 pt
  // (no Typst o `leading` é somado à altura natural da fonte: 1,15 − 0,693).
  context {
    set par(
      justify: true,
      leading: 1.15em - 0.693em,
      spacing: 1.15em - 0.693em,
      first-line-indent: 0em,
    )
    grid(columns: (8cm, 1fr),
      [],
      block[
        #natureza
        #parbreak()
        #("Orientador: " + orientador)
      ],
    )
  }

  v(1fr)
  align(center)[
    #strong(upper(cidade))
    
    #strong(ano)
  ]
  pagebreak()
}
