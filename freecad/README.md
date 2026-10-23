# Modelos FreeCAD

Todas as dimensões estão em milímetros. Os modelos são preliminares e ainda
não incluem enrolamento. `assembly.FCStd` contém as peças por links externos
e ferragens paramétricas da bancada Fasteners; ainda não há juntas cinemáticas.

## Cano de PVC — `cano-pvc.FCStd`

- Diâmetro externo: 100 mm; interno: 96 mm; parede resultante: 2 mm.
- Comprimento: 550 mm, incluindo a folga solicitada.
- Diâmetros aproximados, pendentes de medição definitiva.
- Para editar os diâmetros, alterar as restrições `DiametroExterno` e
  `DiametroInterno` no esboço `SecaoAnular`.
- Para editar o comprimento, alterar `Length` na extrusão `Comprimento`.

## Topload — `topload.FCStd`

- Tubo de alumínio representado por um toro liso: raio maior de 200 mm e
  raio menor de 50 mm, resultando em diâmetro externo de 500 mm e abertura
  interna de 300 mm. Editar `Radius1` e `Radius2` em `TuboAluminio`.
- O sólido do toro representa apenas o envelope externo, não a quantidade de
  alumínio. Não foram modeladas parede interna, corrugação ou emenda.
- Forma de pizza idealizada como superfície de fundo plano e parede vertical,
  com diâmetro de 300 mm e profundidade de 10 mm, sem espessura de chapa.
- Editar `RaioForma` e `ProfundidadeForma` no esboço `PerfilForma` para ajustar
  a forma. A revolução aberta gera uma superfície, não um sólido de material.
- Provisoriamente, a altura da forma está centralizada no plano médio do toro
  (fundo em Z = −5 mm e borda em Z = +5 mm). A posição real deve ser conferida.
- A simplificação sem espessuras foi confirmada pelo usuário. Os modelos não
  devem ser usados para estimar massa ou consumo de material.

## Encaixes e suporte — Part Design

- `encaixe-inferior.FCStd`: batente de Ø 106 × 10 mm e espigão de
  Ø 95,4 × 20 mm, com chanfro de entrada de 0,8 mm. A borda radial sobre
  o PVC de Ø 100 mm é de 3 mm, reduzida dos 6 mm anteriores.
- `suporte-topload.FCStd`: **encaixe superior e pedestal em uma única peça**,
  substituindo os dois componentes separados anteriores. Espigão de
  Ø 95,4 × 20 mm, batente de Ø 106 mm com borda radial de 3 mm e perfil
  externo de coluna nervurada, com **duas pequenas flanges de Ø 70 mm**:
  uma na base da coluna e outra sob a forma. A coluna não se abre até o batente
  de Ø 106 mm; esse batente pertence ao encaixe no PVC e é independente.
  O corpo junto às pequenas flanges tem Ø 66 mm e o centro tem **Ø 42 mm**.
  Oito nervuras longitudinais de **2,1 mm**, com projeção radial de **4,2 mm**,
  formam um envelope central nominal de Ø 50,4 mm. A cintura e as nervuras
  seguem o fator radial 0,7 da versão anterior à redução do topo de 100 para
  70 mm: não se manteve o centro de 60 mm que deixava a coluna quase reta.
  A altura total é 91 mm: 20 mm entram no cano e 71 mm ficam acima dele.
  As transições do corpo e das nervuras usam curvas cúbicas tangentes,
  restaurando a cintura e o esquema curvo anterior em proporções menores. O batente
  tem borda inferior arredondada; as duas pequenas flanges têm chanfros de
  0,8 mm e espessura de 3 mm.
  A superfície plana superior tem aproximadamente Ø 68,4 mm após o chanfro.
  A área projetada da mesa caiu cerca de 51%; isso não é a economia de filamento
  da peça inteira, que depende do fatiamento. A espessura superior permanece 3 mm.
  As nervuras são contínuas entre as pequenas flanges. Seus extremos têm
  margem de 1,5 mm em relação ao perímetro dessas flanges, ficando um pouco
  acima do contorno do corpo da coluna, sem aletas terminando no meio dela.
  As uniões sobrepostas evitam a degeneração por tangência observada na revisão
  que reduzia apenas a mesa superior.
- Ambos recebem um **parafuso M6 inserido pelo lado interno**, com a rosca
  saindo pela face externa, sem necessidade de heat-insert. A porca inferior
  fica no rebaixo externo; a superior, acima da forma.
- O furo axial de Ø 6,6 mm é **passante**. Na face interna, há um rebaixo de
  Ø 20 × 8 mm. No encaixe inferior ele acomoda a cabeça larga do **parafuso
  francês M6 × 50 mm DIN 603, com pescoço quadrado e ROSCA INTEIRA**, sem arruela interna.
- **Antirrotação inferior:** um alojamento quadrado de **6,8 × 6,8 × 5 mm**,
  sob o apoio da cabeça, recebe o pescoço do parafuso francês. A cabeça apoia
  diretamente no plástico, a 22 mm da face externa. A arruela e a porca
  externas permanecem no rebaixo inferior. Não usar um M6 sextavado comum
  esperando que essa trava funcione: ela exige o pescoço quadrado.
- As medidas de referência foram conferidas na tabela DIN603 do Fasteners:
  M6 com pescoço de até 6,48 mm entre faces e 4,6 mm de comprimento; cabeça
  de até Ø 16,55 mm. A profundidade de 5 mm evita apoiar a ponta do pescoço
  antes da cabeça. Não é leitura da norma original ou controle de uma ferragem
  comprada: medir o parafuso real e testar o ajuste impresso antes de colar.
  A geometria da bancada é nominal, não um ensaio de tolerâncias ou torque.
- **Não comprar a versão de rosca parcial.** Há M6 × 50 mm com somente 18 mm
  de rosca na ponta; o trecho liso não permite levar a porca ao rebaixo desta
  peça. A Dapco lista a variante de rosca inteira no código `2PFM6X50`.
  Isso é uma referência de catálogo, não estoque ou compra confirmados.
- No **suporte superior**, a arruela interna permanece e o rebaixo circular
  ainda não trava a cabeça sextavada. O assento fica a 8 mm do extremo que
  entra no cano; a cabeça e a arruela devem caber nos 8 mm de profundidade.
  Segurar com chave durante a montagem e planejar o acesso antes da colagem.
  A melhoria de antirrotação desta revisão foi aplicada apenas ao encaixe inferior.
- Arruela, terminal olhal e porca externos prendem o fio, que continua por fora.
- A cabeça interna está rebaixada, mas ainda **sem cobertura isolante
  modelada**. A revisão remove a barreira plástica cega anterior; não equivale
  a proteção contra arcos ou a aprovação elétrica. Avaliar proteção isolante
  da ferragem interna antes de operar a bobina.
- No encaixe inferior, a face externa também tem um rebaixo circular de
  **Ø 20 × 7 mm** para a arruela e a porca. Ambas ficam inteiramente embutidas:
  a porca termina 0,7 mm para dentro da face. Há acesso com chave, sem trava
  sextavada de rotação. Esse rebaixo não é um encaixe para a futura base.
  O parafuso inferior francês **M6 × 50 mm** deixa aproximadamente **28 mm
  além da face inferior**, reservados para a futura base. A retirada da arruela
  interna aumentou a reserva anterior de 26,4 mm em 1,6 mm.
  O comprimento é provisório, a conferir com a espessura da base e suas ferragens.
- A fixação de ambos os encaixes ao PVC passa a ser **por colagem**, conforme
  escolha do usuário. Os seis pilotos laterais e todas as ferragens radiais de
  nylon foram removidos. Não é necessário furar lateralmente o cano para isso.
  Não foi modelada uma camada de adesivo nem selecionado um produto.
- O parafuso M6 atravessa o suporte superior integrado e a forma e recebe
  arruela, terminal olhal e porca pelo lado de fora. Usar arruelas largas e
  aperto compatível com a chapa para distribuir a carga. O comprimento sob a
  cabeça precisa cobrir 83 mm entre o assento e o apoio da forma, a arruela
  interna, a chapa, as ferragens externas e o engate da porca. A montagem usa
  provisoriamente M6 × 100 mm; confirmar o comprimento com as ferragens reais.
  A forma ainda precisa de um furo central correspondente, não modelado nesta etapa.
- Cada arquivo contém uma planilha **Parametros**, esboços totalmente
  restringidos e histórico nativo: Pad, Pocket e Chamfer no encaixe inferior;
  Revolution, Pad, PolarPattern, Pocket, Fillet e Chamfer no suporte superior
  integrado. Os perfis usam B-splines cúbicas cujos polos são dirigidos pela
  planilha; as oito nervuras são um padrão polar nativo. Não é uma união
  booleana das peças antigas nem um sólido estático importado.
- No encaixe inferior adaptado, os nomes internos históricos `FuroAxialCego`,
  `PerfilPorcaM6` e `AlojamentoPorcaM6` foram preservados para manter as
  dependências do histórico. Seus rótulos e geometrias agora correspondem
  ao furo passante e ao rebaixo interno. A macro nova usa nomes atualizados.

### Folgas, material e validação

A folga diametral do espigão é de 0,6 mm para um cano nominalmente com ID
96 mm, correspondendo a uma junta radial nominal de **0,3 mm para a colagem**.
Conferir essa folga com as medições, o material impresso e a ficha do adesivo
escolhido; não há resistência da junta calculada ou ensaiada. A compatibilidade
com PVC e com o polímero impresso, preparo, cura e esforços precisam ser
validados antes de sustentar o conjunto pelo encaixe colado.

Não há mais folga de centragem entre tampa superior e pedestal: agora são
um único sólido. As demais folgas são valores de protótipo, não tolerâncias
de fabricação comprovadas. Medir o cano em
vários eixos, confirmar ovalização e imprimir um pequeno corpo de prova
antes das peças completas. Alterar os parâmetros conforme o resultado.

As peças foram verificadas quanto à validade dos sólidos e às interferências
volumétricas nos encaixes mostrados, mas não quanto à carga, tombamento,
fluência, temperatura, RF ou isolação. A forma fina também pode precisar de
reforço; o apoio central não valida a rigidez da bandeja inteira. Não escolher
filamento condutivo ou carregado com carbono. O material e o processo de
impressão ainda precisam ser definidos e ensaiados; não há aprovação elétrica
de PLA/PETG ou outro polímero implícita neste modelo.

O fio do secundário deve seguir **pelo exterior**, com conexão elétrica própria
ao terminal; o CAD não demonstra continuidade elétrica. Não atravessar o cano
com haste metálica ligando as extremidades e não levar o fio para seu interior.

### Assembly e ferragens Fasteners

`assembly.FCStd` substitui o antigo nome `estudo-encaixes.FCStd`. Manter os
arquivos na mesma pasta para preservar os links externos. A montagem é estática,
sem juntas cinemáticas; as posições não acompanham automaticamente alterações
nas dimensões das peças. O nome do arquivo não implica uso da bancada Assembly.
A assembly usa quatro componentes por links: PVC, encaixe inferior, suporte
superior integrado e topload. O suporte integrado ocupa Z = 530–621 mm, com o
cano terminando em Z = 550 mm. A superfície idealizada do fundo da forma
continua em Z = 621 mm. O fundo nominal do toro fica 26 mm acima do topo do
cano; isso é geometria do estudo, **não afastamento elétrico aprovado**.

O grupo **Ferragens** contém 7 objetos reais do Fasteners, com norma e tamanho
editáveis, não cilindros desenhados para imitar parafusos:

- 1 parafuso sextavado ISO 4014 M6 × 100 mm no encaixe superior, com haste
  parcialmente roscada, agora dentro do suporte integrado. Esse comprimento
  existe na tabela da bancada; não foi
  convertido em ISO 4017 de comprimento personalizado.
- 1 parafuso francês DIN 603 M6 × 50 mm **rosca inteira** no encaixe inferior, com pescoço
  quadrado alojado na peça e sobra reservada para a futura base.
- 3 arruelas largas ISO 7093-1 M6, Ø externo 18 mm e espessura 1,6 mm:
  uma sob a cabeça superior e uma sob cada porca externa. A cabeça larga do
  francês inferior substitui a arruela interna daquele encaixe.
- 2 porcas ISO 4032 M6.

As cabeças M6 ficam dentro dos rebaixos; somente a superior tem arruela interna.
A rosca segue para fora do tubo. No modelo atual, a arruela superior está sobre a superfície
de espessura zero da forma. Chapa e terminal olhal reais exigirão reposicioná-la
e conferir novamente o engate. A sobra atual do parafuso superior acima da porca
é de aproximadamente 9,1 mm, sem considerar espessura da chapa ou terminal.
O M6 inferior de 50 mm também é provisório: a base de apoio ainda não existe.
A sobra de 28 mm é medida a partir da face do encaixe; incluir base,
terminal olhal, arruela e porca adicionais consumirá essa reserva. A porca
atualmente embutida no encaixe não representa a porca da futura base.

As 7 ferragens foram verificadas como sólidos válidos e não invadem as peças
plásticas. Não há mais ferragens atravessando a parede do PVC. Isso não é
liberação para fabricação ou aprovação da junta colada. Não há terminais
olhal, fio, furação da forma ou proteção isolante das cabeças internas modelados.
O teste geométrico de girar o francês 45° produz interferência com a trava,
ao contrário da posição de montagem nominal, livre de interferência. Isso
confirma a função geométrica, mas não qualifica resistência ao aperto, desgaste
ou fluência do material impresso. Não usar aperto de impacto na peça plástica.

As roscas helicoidais estão desativadas (`Thread = false`) para manter a
montagem leve. A bancada Fasteners precisa estar instalada para editar e
recalcular seus objetos; as formas salvas continuam disponíveis no arquivo.
No francês inferior, o objeto DIN603 fornece cabeça e pescoço, mas a variante
de compra exige rosca inteira, registrada na propriedade `RoscaExigida`.
O gerador padrão da bancada usa comprimento parcial de 18 mm para M6 nesta
faixa: habilitar `Thread = true` sem adaptar a variante **não** representa o
parafuso de rosca inteira exigido. O modelo simplificado não valida engate de
rosca; confirmar a variante e experimentar a porca real antes de colar.

### Reprodução

`criar-encaixes.FCMacro` reproduz o encaixe inferior, o suporte integrado e
`assembly.FCStd` no FreeCAD com GUI, partindo de `cano-pvc.FCStd` e `topload.FCStd`.
Chama `criar-suporte-integrado.FCMacro`, que usa `criar-corpo-suporte.FCMacro`,
e depois `adicionar-ferragens.FCMacro`.
Recusa sobrescrever destinos existentes.
Para testar, usar outra pasta com cópias dos dois modelos iniciais e das
**quatro macros**, com a bancada Fasteners instalada.

`criar-suporte-integrado.FCMacro` também gera somente o suporte em uma pasta
sem `suporte-topload.FCStd`, mantendo seu histórico nativo e planilha. Precisa
do arquivo auxiliar `criar-corpo-suporte.FCMacro` na mesma pasta. Este auxiliar
gera o corpo intermediário; não representa sozinho a versão final nervurada.

As imagens e o desenho técnico enviados pelo usuário motivaram a coluna com
nervuras e flanges finas. **Não foram adotadas as cotas de 300/450 mm do desenho**:
o formato foi adaptado ao PVC de Ø 100 mm, à forma existente e à altura atual.
Não foram presumidos autoria, resistência ou detalhes internos não verificados.

`adicionar-ferragens.FCMacro` também pode ser executada separadamente em uma
assembly sem ferragens. Recusa duplicar o grupo existente. As coordenadas são
as da versão inicial do projeto; não é um posicionador automático universal.

### Referências do desenho

- [Franzoli, Alpha-DR Mark II](https://franzolielectronics.com/alpha-dr-mark-ii/):
  texto e fotografia principal examinados. Inspiração visual do pedestal
  estreito com apoio alargado. Medidas e ferragens acima são propostas deste
  projeto, não dimensões publicadas por Franzoli.
- [Franzoli, Alpha-DR](https://franzolielectronics.com/alpha-dr/) e
  [DRSSTC IV](https://franzolielectronics.com/drsstc-iv/): fichas consultadas
  para contexto mecânico; não se transfere o projeto elétrico de DRSSTC à SGTC.
- [Gary Lau, My Secondary](https://www.laushaus.com/tesla/secondary.htm):
  precedente de tampões com rosca local e barreira isolante interna.
- [DeepFriedNeon, Secondary Coil](https://deepfriedneon.com/tesla_secondary.html):
  precedente de fechamento das pontas do tubo, especialmente da superior.

Fontes novas cadastradas em `tcc/referencias.yml`. Nenhuma constitui norma
ou certificação destas peças.
