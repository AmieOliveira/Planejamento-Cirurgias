# Planejamento-Cirurgias
Planejamento de cirurgias eletivas em hospitais. Implementação de heurísticas 
baseadas em ALNS para minimizar o período de espera entre a entrada na fila para 
a cirurgia e a sua realização.

Trabalho para Meta-heurísticas em Otimização Combinatória (CPS783)




## TODOs:
~~- Ajustar a funcao eval_function para refletir a F.O. final (do Cleiton)~~
~~- Parar de enviar as penalidades como argumento das instancias? (ja que vamos ter que sempre usar as mesmas)~~ 
- Análise do tempo: botar um timer pra computar quanto tempo está demorando pra rodar
	- Rodar pra um toy e pra uma instância de 1000 cirurgias, e pra uma de 10000 cirurgias. Como o tempo evolui?
~~- Produzir output CSV com a solução~~
~~- Verificar se o tempo dos cirurgioes esta contando com o tempo de limpeza (isso pode ser considerado como o tempo que ele precisa entre uma cirurgia e outra). (NAIVE & ALNS)~~
- Verificar se esta contanto o tempo semanal dos cirurgioes (NAIVE & ALNS)
- Verificar o algoritmo guloso: 
	1. tem que marcar as urgencias na segunda.
- Mudar estrutura de dados do ALNS para aumentar a eficiencia da heuristica (diminuir tempo que leva para rodar): 
	1. free_timeslots como array de intervalos de tempo livre (tuplas `((inicio tempo ocupado, fim tempo ocupado), idx_surgery, idx_surgeon)`)
	2. array com especialidades das salas por sala por dia
	3. array com tempos de cirurgiao por dias (sum pra semanal)
- Verificar se é possível remover sc_d, sc_h, sc_r no ALNS
- Alterar NAIVE para comportar novas estruturas de dados com redundancia (tentar remover sc_d, sc_h, sc_r. acho que será possivel)
- Botar penalidades CAPS LOCK
- Acertar a greedy_insertion (testar colocando so um ou tantos quanto o possivel?)
- Função de Shuffle das cirurgias de um mesmo dia (sem perder a viabilidade) - 
Inclusive maximizar o espaço livre
- Adicionar outros operadores de inserção e remoção
	- Fazer operadores de remoção que remove mais de 1? Testar no fim
- Análise de quantos quartos são necessários para agendar todas as cirurgias de uma instância, ou para agendar sem ultrapassar o tempo máximo de espera (parte de análise do código)

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

