# TODOs:

- Selecionar cirurgias "viaveis" dentre as 6 fullrand
- Colocar novas cirurgias no drive
- Resultados das instancias do drive
- TTPLOTS!
- Tunar parâmetros do ALNS!
    - Verificação dos operadores escolhidos e os ganhos (ou não) na solução ✓ 
        ⟹ Observação empírica mostra que os melhores operadores (por scores) dependem da instância avaliada
    - Análise de como está a exploração do espaço de busca (será que está explorando de fato alternativas ou ficando sempre na redondeza da solução inicial?)
        ⟹ **Screenshots das soluções parciais do algoritmo!** Salvar algumas soluções ao longo do ALNS e usar o plot_solution para uma comparação visual
    - Análise da evolução da F.O. ao longo do algoritmo: salvar os valores da F.O. das soluções parciais s (aceitas) e plotar um gráfico da evolução no tempo
- Plot solution: 
    - Colocar o valor da F.O. na imagem
    - Assinalar cirurgião de cada cirurgia (por cor? por texto?)
    - Plot alternativa: "dia por salas" um pdf por dia, mostrando todas as salas lado a lado (ia facilitar a visualização da solução!)
    - Plot alternativa 2: Gráfico dos cirurgiões por dia (assinalando a sala) -> um pdf por cirurgiao (com todos os dias) ou um por dia (com todos os cirurgioes)?
- Reorganização das cirurgias (para maximizar o espaço livre)
    ⟹ Ideia: diferentes funções que realizam diferentes tipos de otimização de espaço, e retornam uma booleana dizendo se o dia está otimizado ou não
    - ~~Deslocar todas as cirurgias para o início~~ ✓
    - Deslocar cirurgias para o fim
    - (Ideia: solucoes mais complexas poderiam ser feitas tentando retirar uma cirurgia, deslocar todas para o inicio ou para o final, e depois colocar a cirurgia retirada de maneira adequada)
- Adicionar outros operadores de inserção e remoção
	- Qual quantidade de cirurgias retirar nas remoções? (Avaliar)
    - ~~Pior remoção~~ ✓
    - Remoção Shaw: por dias, por cirurgiões ou por especialidade (✓)
        * Discutir função por cirurgiões
        * Funções não estão independentes da estrutura de dados (problema?)
    - Remoção Shaw: fazer versão aleatória e versão determinística? Fazer uma probabilidade tendenciosa para cirurgias com piores índices?
    - ~~Inserção Gulosa adicionando todas as cirurgias possíveis~~ ✓
    - ~~Inserção por arrependimento~~ ✓
    - ~~Inserção aleatória~~ ✓
    - Quais outras inserções e remoções? (Olhar material sugerido)
    - Inserção "gulosa" com outras prioridades? Máximo de cirurgias, por exemplo
    - Verificar o impacto de tirar algumas operações no resultado final obtido
        ⟹ Será que o ótimo local para o qual converge vai ser o mesmo se ele nao usar os 'singles', por exemplo?
- Plot dos scores: mudar cores para ficar mais diferente, e salvar em PDF.
    - Botar best solution em tracejado no plot da target function
    - Trocar label x pra temperatura
- Assinalar quais instâncias parecem mais difíceis para o ALNS
- Análise de quantos quartos são necessários para agendar todas as cirurgias de uma instância, ou para agendar sem ultrapassar o tempo máximo de espera (parte de análise do código)
- Verificar técnicas e métricas de comparação de meta-heurísticas no PDF "Tema 14"
- Otimizações:
    - Fazer operadores de inserção/remoção retornarem o valor da F.O.? 
    - Verificar `can_surgeon_fit_surgery_in_timeslot`
    - Botar no relatório a diferença de tempo das antigas estruturas pras novas estruturas
    - Otimização da verificação de disponibilidade do cirurgião:
    No momento ele verifica se o cirurgião esta livre ou nao em um timeslot. Mas se ele estiver parcialmente livre o timeslot é descartado de qualquer forma. Poderíamos trocar a função de verificação para retornar o tempo dentro do timeslot no qual o cirurgião está livre, e se o 
    timeslot retornado for nulo, ele parte para o próximo

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
- ~~Verificar o operador de insercao gulosa: Ordem de prioridades está esquisita.~~ 
- ~~Fazer batch montar média e desvio padrão~~ ✓
- ~~Implementar parada por número de iterações sem melhora~~ ✓