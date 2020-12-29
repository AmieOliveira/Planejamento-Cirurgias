# Planejamento-Cirurgias
Planejamento de cirurgias eletivas em hospitais. Implementação de heurísticas 
baseadas em ALNS para minimizar o período de espera entre a entrada na fila para 
a cirurgia e a sua realização.

Trabalho para Meta-heurísticas em Otimização Combinatória (CPS783)

#### Solução
Uma solução é representada por 6 arrays:

``` 
solution = sc_d, sc_r, sc_h, e, sg_tt, sc_ts 
```

Onde: 
- `sc_d` é uma lista com os dias de realiação das cirurgias (elemento 
`[i]` dá o dia da cirurgia i).
- `sc_r` é uma lista com as salas de realizações das cirurgias (elemento 
`[i]` dá a sala da cirurgia i).
- `sc_h` é uma lista com as horas de realizações das cirurgias (elemento 
`[i]` dá a hora da cirurgia i).
- `e` é um array bidimensional com as especialidades das salas a cada dia 
(elemento `[i, j]` dá a especialidade da sala j no dia i).
- `sg_tt` é um array bidimensional com o tempo alocado a cada cirurgião a 
cada dia (elemento `[i, j]` dáo tempo gasto pelo cirurgião j em cirurgias 
no dia i).
- `sc_ts` é um array com os intervalos de tempo ocupados em cada sala a 
cada dia. `sc_ts[i, j]` contém as listas de intervalos alocados no dia i 
para a sala j. Cada intervalo é organizado como um array de quatro 
elementos: o slot de início da cirurgia, o slot de término (incluindo 
tempo de limpeza), a cirurgia e o cirurgião.





## TODOs:
- Verificar o operador de insercao gulosa: Ordem de prioridades está esquisita.
- Função de Shuffle das cirurgias de um mesmo dia (sem perder a viabilidade) - 
Inclusive maximizar o espaço livre
- Adicionar outros operadores de inserção e remoção
    - Fazer operadores de inserção/remoção retornarem o valor da F.O.? (Avaliar)
	- Qual quantidade de cirurgias retirar nas remoções? (Avaliar)
    - Pior remoção ✓
    - Remoção Shaw: por dias, por cirurgiões ou por especialidade (✓)
        * Discutir função por cirurgiões
        * Funções não estão independentes da estrutura de dados (problema?)
    - Remoção Shaw: fazer versão aleatória e versão determinística? Fazer uma probabilidade 
    tendenciosa para cirurgias com piores índices?
    - Inserção Gulosa adicionando todas as cirurgias possíveis ✓
    - Inserção por arrependimento
    - Quais outras inserções e remoções? (Olhar material sugerido)
    - Inserção "gulosa" com outras prioridades? Máximo de cirurgias, por exemplo
- Tunar parâmetros do ALNS!
    - Verificação dos operadores escolhidos e os ganhos (ou não) na solução ✓ 
        ⟹ Está sorteando, mas quase não encontra soluções melhores do que a atual! Problema 
        nas opções de operadores, nos operadores em si, nos parâmetros ou em outra coisa?
    - Análise de como está a exploração do espaço de busca (será que está explorando de fato 
    alternativas ou ficando sempre na redondeza da solução inicial?)
- Análise de quantos quartos são necessários para agendar todas as cirurgias de uma instância, 
ou para agendar sem ultrapassar o tempo máximo de espera (parte de análise do código)
- Verificar técnicas e métricas de comparação de meta-heurísticas no PDF "Tema 14"

---

- ~~Código verificador de viabilidade de uma solução?~~ ✓
- ~~Acertar a ordem de prioridades (incluir comparacao por dia)~~ ✓
- ~~Plots das solução~~ ~~Mudança das cores nas plots (e o que mais julgarmos que seja bom)~~  ✓
- ~~Função para assinalar as cirurgias fora do prazo em uma solução (evidenciar essas coisas)~~ ✓
- ~~FO: Implementar penalidades duplas, penalizar quando passar do prazo~~ ✓
- ~~FO: Verificar se vale a pena aumentar o peso da passagem do tempo (multiplicar os dias transcorridos por um fator multiplicativo? Fator depende do tempo restante para acabar o prazo?)~~ ✓
- ~~Toys para avaliar trade-offs específicos (para verificar se as cirurgias mais antigas estão sendo priorizadas e para avaliar o viés com relação à duração da cirurgia)  ==> Precisamos dividir a criação dos toys com a turma~~ ✓
- ~~F.O. Fechar com a turma qual vamos usar~~ ✓
- ~~most_prioritary: colocar para cirurgias menores terem preferencia quando as considerações de tempo e antiguidade sao iguais, e so se for tudo igual mesmo usar o id~~ ✓
~~Com mais de um quarto, ainda está agendando prioridades para o segundo dia sem necessidade (obs.: pode ter problema na F.O.)~~ tinha necessidade, cirurgião único
- ~~Ajustar a funcao eval_function para refletir a F.O. final (do Cleiton)~~
- ~~Parar de enviar as penalidades como argumento das instancias? (ja que vamos ter que sempre usar as mesmas)~~ 
- ~~Análise do tempo: botar um timer pra computar quanto tempo está demorando pra rodar~~
    - ~~Rodar pra um toy e pra uma instância de 1000 cirurgias, e pra uma de 10000 cirurgias. Como o tempo evolui?~~
- ~~Produzir output CSV com a solução~~
- ~~Verificar se o tempo dos cirurgioes esta contando com o tempo de limpeza (isso pode ser considerado como o tempo que ele precisa entre uma cirurgia e outra). (NAIVE & ALNS)~~
- ~~Mudar estrutura de dados do ALNS para aumentar a eficiencia da heuristica (diminuir tempo que leva para rodar)~~: 
    1. ~~free_timeslots como array de intervalos de tempo livre (tuplas `((inicio tempo ocupado, fim tempo ocupado), idx_surgery, idx_surgeon)`)~~
    2. ~~array com especialidades das salas por sala por dia~~
    3. ~~array com tempos de cirurgiao por dias (sum pra semanal)~~
- ~~Verificar se é possível remover sc_d, sc_h, sc_r no ALNS~~
- ~~Alterar NAIVE para comportar novas estruturas de dados com redundancia (tentar remover sc_d, sc_h, sc_r. acho que será possivel)~~ 
- ~~Botar penalidades CAPS LOCK~~
- ~~Verificar se esta contanto o tempo semanal dos cirurgioes (NAIVE & ALNS)~~
- ~~Acertar a greedy_insertion (testar colocando so um ou tantos quanto o possivel?)~~