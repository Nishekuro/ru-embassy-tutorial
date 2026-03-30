#import "template.typ": *
#show: template

#grid(
  columns: 1fr, rows: (1fr, 1fr),
  align: horizon+center,
  stroke: black,
  [*Руководство по Embassy на русском*],
  align(left)[
  Почта: denj.n3.0\@gmail.com

  Githab: #link("https://github.com/Nishekuro/ru-embassy-tutorial")
  ]
)

#pagebreak()

#outline()
#pagebreak()

#show raw.where(block: true): it => pad(it, left: 1.25cm, top: 0.5em, bottom: 0.5em)

#show link: underline

#include "themes/1-intro.typ"
#pagebreak()
#include "themes/2-project-structure.typ"
#pagebreak()
#include "themes/3-GPIO-EXTI.typ"
// #include "themes/platforms/rp2040.typ"
