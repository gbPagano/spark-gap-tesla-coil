// Aritmética de fasores / números complexos para os cálculos do relatório.
// Um fasor é representado internamente como a tupla retangular (re, im).
// Os cálculos são executados pelo próprio Typst em tempo de compilação.

// Constrói um fasor a partir da forma polar (módulo, ângulo em graus).
#let polar(mag, deg) = (mag * calc.cos(deg * 1deg), mag * calc.sin(deg * 1deg))

// Soma de fasores (variádica).
#let cadd(..xs) = {
  let re = 0.0
  let im = 0.0
  for x in xs.pos() {
    re += x.at(0)
    im += x.at(1)
  }
  (re, im)
}

// Produto de dois fasores.
#let cmul(a, b) = (
  a.at(0) * b.at(0) - a.at(1) * b.at(1),
  a.at(0) * b.at(1) + a.at(1) * b.at(0),
)

// Multiplicação por escalar real.
#let cscale(k, a) = (k * a.at(0), k * a.at(1))

// Módulo e ângulo (em graus) de um fasor.
#let cmag(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let cangd(a) = calc.atan2(a.at(0), a.at(1)).deg()

// Operador de rotação a = 1 ang 120 e a^2 = 1 ang 240.
#let A = polar(1, 120)
#let A2 = polar(1, 240)

// Componentes simétricas (referência na fase A) a partir de uma lista
// de três fasores de fase [(mag,ang), (mag,ang), (mag,ang)].
#let seqpos(p) = cscale(1 / 3, cadd(polar(..p.at(0)), cmul(A, polar(..p.at(1))), cmul(A2, polar(..p.at(2)))))
#let seqneg(p) = cscale(1 / 3, cadd(polar(..p.at(0)), cmul(A2, polar(..p.at(1))), cmul(A, polar(..p.at(2)))))
#let seqzero(p) = cscale(1 / 3, cadd(polar(..p.at(0)), polar(..p.at(1)), polar(..p.at(2))))

// Fator de desequilíbrio (%) = |seq. negativa| / |seq. positiva| * 100.
#let fdi(p) = cmag(seqneg(p)) / cmag(seqpos(p)) * 100

// Formatação numérica em padrão pt-BR (vírgula decimal, casas fixas).
#let fmtn(x, dec) = {
  let r = calc.round(x, digits: dec)
  if r == 0 { r = 0 }
  let s = str(r)
  if dec > 0 {
    if not s.contains(".") {
      s = s + "." + "0" * dec
    } else {
      let parts = s.split(".")
      let frac = parts.at(1)
      if frac.len() < dec { frac = frac + "0" * (dec - frac.len()) }
      s = parts.at(0) + "." + frac
    }
  }
  s.replace(".", ",")
}

// Fasor formatado "módulo ang ângulo°" para uso em modo matemático.
#let php(c, dec: 2, adec: 1) = $#fmtn(cmag(c), dec) angle #fmtn(cangd(c), adec)°$
