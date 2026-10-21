# Quadro de Observação — Desnormalização de Banco de Dados

**Instituição:** Universidade Braz Cubas  
**Disciplina:** Modelagem de Banco de Dados  
**Projeto:** Desnormalização: quando a redundância compensa  
**Integrantes:** Felipe Carvalho Pereira, Maria Queiroz e João Pedro Forastieri  
**Data:** 20/10/2026

## 1. Objetivo

Analisar duas referências técnicas para identificar boas práticas de organização, clareza e apresentação de exemplos, utilizando essas observações na construção de um artigo web sobre desnormalização de bancos de dados.

## 2. Referências analisadas

### Referência 1 — Alura

**Artigo:** Normalização em Banco de Dados — Estrutura

**Endereço:** https://www.alura.com.br/artigos/normalizacao-banco-de-dados-estrutura

**Observações:**

- Utiliza uma linguagem acessível para apresentar conceitos técnicos.
- Organiza o conteúdo em seções com subtítulos.
- Apresenta exemplos de tabelas para facilitar a compreensão das formas normais.
- Relaciona conceitos de normalização com problemas encontrados na organização dos dados.

**Aplicação proposta ao projeto:**

Adotar explicações progressivas, começando pelo problema da redundância e apresentando exemplos de tabelas antes de aprofundar os conceitos de desnormalização.

### Referência 2 — PostgreSQL

**Documentação:** Materialized Views

**Endereço:** https://www.postgresql.org/docs/17/rules-materializedviews.html

**Observações:**

- Apresenta explicações técnicas diretamente relacionadas ao funcionamento do SGBD.
- Utiliza comandos SQL para demonstrar os conceitos.
- Explica como visões materializadas armazenam resultados de consultas.
- Demonstra como os dados das visões podem ser atualizados por meio de comandos específicos.

**Aplicação proposta ao projeto:**

Apresentar exemplos SQL reproduzíveis, explicando como uma visão materializada pode facilitar consultas e por que sua atualização precisa ser considerada.

## 3. Três decisões do grupo

### Decisão 1 — Utilizar exemplos práticos com dados fictícios

**Justificativa:** Facilitar o entendimento do leitor e demonstrar os efeitos da desnormalização sem utilizar informações pessoais reais.

### Decisão 2 — Comparar consultas normalizadas e desnormalizadas

**Justificativa:** Demonstrar, por meio de consultas SQL, planos de execução e medições, em quais situações a desnormalização pode trazer benefícios e quais custos adicionais podem surgir.

### Decisão 3 — Publicar uma página web com demonstrações interativas

**Justificativa:** Permitir que os estudantes explorem os conceitos visualmente e observem o comportamento das consultas, relacionando a teoria com a prática.

## 4. O que o grupo decidiu não implementar

**Proposta para validação:** Não desenvolver um sistema completo de vendas com cadastro e autenticação de usuários.

**Justificativa:** O objetivo do projeto é explicar e demonstrar a desnormalização de bancos de dados. A implementação de funcionalidades comerciais completas aumentaria a complexidade sem contribuir diretamente para esse objetivo didático.

## 5. Conclusão

A análise das referências destacou a importância de combinar linguagem acessível, exemplos práticos e precisão técnica. O projeto busca utilizar essas características para explicar quando a desnormalização pode ser vantajosa, sem deixar de apresentar seus riscos relacionados à redundância, consistência dos dados e manutenção.
