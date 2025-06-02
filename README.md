# Simulação de Fórum sobre Jogos com Freechains

## Objetivo da simulação:
Observar a evolução da reputação dos usuários e as dinâmicas de interação entre diferentes perfis ao longo de 90 dias. A simulação foca em como esses usuários postam conteúdo, reagem a postagens de outros e como o "conteúdo impróprio" é tratado com base nas regras de comportamento definidas para cada perfil.

## Importante:
Para que o script rode corretamente, considere que:
* O script deve ser executado no diretório que contém os executáveis `freechains` e `freechains-host`;
* É necessário ter o `gnome-terminal` instalado;
* As portas 5000 até 5003 serão utilizadas;
* A execução do script é **lenta**. Serão gerados 2 arquivos com os resultados da simulação: `reps_simulacao.txt` e `msgs_simulacao.txt` no diretório onde for executado o script;


## Funcionamento do fórum:

Cada usuário possui um comportamento programado:

### Pioneiro
- Criador do fórum.
- Posta todo dia.
- Sempre dá like em postagens que mencionem `Starcraft`, `Pokemon` ou `Dormir`, desde que a reputação do autor seja maior que 0.
- Sempre dá dislike em postagens de usuários que desrespeitem as regras do fórum, desde que esteja com a própria reputação maior que 5.
- Tem 10% de chance de postar conteúdo impróprio.

### Ativo
- É o usuário mais ativo.
- Comenta e curte sempre que tem reputação disponível.
- Posta a cada 2 dias.
- Sempre dá like em postagens que mencionem `Pokemon`, desde que a reputação do autor seja maior que 0.
- Sempre dá dislike em postagens de usuários que desrespeitem as regras do fórum, desde que esteja com a própria reputação maior que 2.
- Tem 10% de chance de postar conteúdo impróprio.

### Troll
- Posta a cada 2 dias.
- Primeiro mês: tem 10% de chance de postar conteúdo impróprio (se comporta como usuário Ativo).
- Segundo mês: tem 50% de chance de postar conteúdo impróprio.
- Terceiro mês: tem 100% de chance de postar conteúdo impróprio.
- Só dá dislike nas postagens dos outros, desde que esteja com a própria reputação maior que 5.
- Nunca dá like.

### Novato
- É o menos ativo e interage pouco.
- Posta a cada 6 dias.
- Nunca dá like/dislike.
- Tem 10% de chance de postar conteúdo impróprio.
- Passa a se *comportar como usuário Ativo* quando atinge 5 de reputação.

### Conteúdo impróprio:
Termos marcados como `XXXXX` nas mensagens. Simula palavras que violem as regras da comunidade.

### Chances de postar conteúdo impróprio:
As mensagens estão separadas em 3 tipos e a escolha do usuário é simulada com o comando shuf.
- `OK`: 9 mensagens normais e 1 imprópria;
- `NOT_OK`: 5 mensagens normais e 5 impróprias;
- `BAD`: 10 mensagens impróprias.

