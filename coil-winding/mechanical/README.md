# Mecânica da enroladora do secundário

Protótipo para tubo nominal Ø100 × 700 mm, com 500 mm centrais reservados
ao enrolamento e acionamento por motor NEMA 17HD48002-24B.

![Vista isométrica da enroladora do secundário no FreeCAD](coil-winding.png)

O [timelapse do enrolamento](../winding-timelapse.mp4) mostra o protótipo
montado em operação, com o tubo apoiado nos berços. É um registro visual, não
uma conferência dimensional do CAD nem uma validação das peças: o acoplamento,
o eixo e as retenções da R02 continuam experimentais.

## Arquivos

- [`coil-winding.FCStd`](coil-winding.FCStd): modelo
  editável mais recente, com Bodies, sketches, Pads e Pockets nativos de
  Part Design. É o arquivo-fonte para alterações de geometria.
- [`coil-winding.3mf`](coil-winding.3mf): projeto de fatiamento existente,
  com suas peças, mesas e configurações. Conferir os perfis de impressora,
  material e processo antes de utilizar.

O FreeCAD e o projeto do fatiador **não são sincronizados automaticamente**.
Após mudar uma peça no CAD, exportá-la novamente e atualizar sua geometria
no fatiador. Não são mantidas cópias antigas em STL/STEP nem scripts de
geração/validação nesta pasta. A imagem `coil-winding.png` documenta a
vista isométrica da montagem no FreeCAD.

## Edição e exportação

1. Abrir `coil-winding.FCStd` na bancada **Part Design**.
2. Abrir a planilha `Params` para editar as dimensões principais. Os valores
   de entrada são números sem sufixo de unidade, interpretados como mm.
   Preservar as fórmulas das dimensões derivadas.
3. Para alterações locais, expandir `01 — Peças Part Design` e editar o
   Sketch, Pad ou Pocket do Body correspondente. Uma cota vinculada à
   planilha deve ser alterada na planilha, ou ter sua expressão removida
   deliberadamente antes de ser editada de forma independente.
4. Recalcular e conferir a montagem. As cópias usam links dos Bodies;
   não é necessário executar scripts para atualizar o modelo.
5. Para imprimir, selecionar o Body final e usar **Arquivo → Exportar**
   em STEP ou STL. Conferir orientação, escala em mm e configurações no
   fatiador antes de gerar G-code.

## Peças da montagem P01

| Body | Quantidade | Função |
|---|---:|---|
| `Saddle` | 2 | Berços duplos do tubo |
| `CollarA` | 1 | Meia abraçadeira com alojamentos de porcas |
| `CollarB` | 1 | Meia abraçadeira com alojamentos de cabeças |
| `DriveSpindle` | 1 | Flange e eixo impresso integrados |
| `Headstock` | 1 | Mancal dos dois rolamentos do eixo |
| `BearingCap` | 2 | Retenção das pistas externas dos rolamentos |
| `MotorBracket` | 1 | Suporte do motor |
| `MotorHub` | 1 | Cubo do acoplamento no motor |
| `SpindleHub` | 1 | Cubo do acoplamento no mandril |
| `OldhamDisc` | 1 | Disco intermediário do acoplamento |
| `RetainingClip` | 5 + reservas | Retenção axial do eixo e dos pinos |
| `RollerPin` | 4 | Pinos impressos dos roletes |

O modelo também conserva os Bodies dos testes de encaixe e a alternativa
P02 com quatro `ModularFork` no lugar dos dois `Saddle`. Não montar as duas
alternativas ao mesmo tempo. Motor, tubo, base e rolamentos representados no
CAD são referências não imprimíveis.

O disco Oldham **não deve ser colado**: suas ranhuras recebem as linguetas
dos cubos e permitem pequeno deslizamento. Os cubos são presos aos eixos
pelos M3; conferir engate e folga axial sem comprimir o disco entre eles.

## Ferragens e base

- **6 rolamentos 608ZZ:** quatro apoiam o tubo e dois ficam no mancal.
- **20 parafusos M3**, de preferência cabeça cilíndrica Allen:
  - 4 × M3×12 para o motor;
  - 8 × M3×10 para os retentores;
  - 4 × M3×40 para flange/abraçadeiras;
  - 2 × M3×25 para fechar as abraçadeiras;
  - 2 × M3×16 para os cubos.
- **8 porcas sextavadas M3 comuns**, não autotravantes nos bolsões.
- Para a madeira de **20 mm**: **16 parafusos próprios para madeira,
  Ø4–5 × 20–25 mm**, preferindo Ø4,5×20, cabeça flangeada ou panela com
  arruela. Não usar cabeça escareada nos furos sem assento cônico.

Conferir comprimentos na montagem antes da compra: os valores são
preliminares. A placa do motor tem 8 mm, então M3×12 entra aproximadamente
4 mm no motor; confirmar a profundidade disponível. Os retentores têm
pilotos Ø2,6 no plástico e precisam de rosca preparada/testada, sem porcas.

A base prevista ocupa aproximadamente **955 × 200 mm**; uma tábua de
**1000 × 250 × 20 mm** oferece margem. Usar madeira seca, reta e com face
de apoio plana. As bases impressas têm 8 mm: parafusos de 20–25 mm entram
aproximadamente 12–17 mm na madeira, sem atravessá-la se a espessura real
for 20 mm. Fazer pré-furos e evitar aperto excessivo no plástico.

## Limitações e cuidados

**O `DriveSpindle` impresso já apresentou duas quebras no uso relatado.**
O eixo, seu canal de clip e a união com o cubo ainda precisam de revisão
e ensaio; aumentar o infill não garante resolver falhas de geometria ou de
adesão entre camadas. Não tratar o projeto como mecanicamente validado.

- Confirmar o DE real do tubo e as medidas do motor antes de imprimir
  peças definitivas. As dimensões da variante do motor não foram
  verificadas por datasheet.
- Testar os encaixes e a retenção dos clips; não forçar os rolamentos no
  eixo impresso. Parar diante de trinca, soltura, patinação ou travamento.
- Girar à mão com o motor desligado e alinhar os apoios antes de um ensaio
  em baixa rotação, sem fio e com corrente limitada.
- Manter os roletes nas margens sem fio; não apoiar o esmalte nos 608.
- Proteger as partes giratórias e desligar antes de ajustar. Nunca usar
  a enroladora com a bobina de Tesla energizada.

## Referências conceituais

- [owl-and-goat/coil-winder](https://github.com/owl-and-goat/coil-winder)
  — enroladora majoritariamente impressa, licença MIT identificada.
- [sandy9159/DIY-Arduino-based-Guitar-Pickup-Coil-Winder](https://github.com/sandy9159/DIY-Arduino-based-Guitar-Pickup-Coil-Winder)
  — arquitetura com rotação e avanço, licença GPL-3.0 identificada.
- [Rylangrayston/winder](https://github.com/Rylangrayston/winder)
  — referência de controle de tensão, licença GPL-3.0 identificada.
- [antonin-leclercq/tesla-coil-winding-machine](https://github.com/antonin-leclercq/tesla-coil-winding-machine)
  — referência conceitual de sustentação de tubos; sem licença identificada
  na raiz consultada, sem cópia de geometria ou código.

Foram consultados READMEs e metadados, não auditados integralmente os
projetos. As referências estão cadastradas em `tcc/referencias.yml`.
