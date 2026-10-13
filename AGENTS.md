# Referências do TCC

- Ao encontrar uma nova referência relevante para o projeto, cadastrá-la em
  `tcc/referencias.yml`, mesmo que ainda não seja citada na monografia.
- Usar formato Hayagriva, chave estável, autores em caixa mista e metadados
  verificáveis. Evitar duplicatas por título/DOI e preservar chaves já utilizadas.
- Para autores institucionais, usar `{ name: "Nome completo" }`, evitando que
  o nome da organização seja interpretado como nome pessoal.
- Registrar DOI ou URL de recuperação quando disponível; separar data de
  publicação da data de acesso. Não inventar autoria, datas, páginas ou edição.
- Registrar origem, finalidade, nível de leitura e pendências em comentários
  YAML, sem apresentar metadados/resumo consultados como leitura integral.
- Manter `full: false` na bibliografia de `tcc/main.typ`: somente obras citadas
  devem aparecer nas referências do documento final.
