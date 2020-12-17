# Planejamento-Cirurgias
Planejamento de cirurgias eletivas em hospitais. Implementação de heurísticas 
baseadas em ALNS para minimizar o período de espera entre a entrada na fila para 
a cirurgia e a sua realização.

Trabalho para Meta-heurísticas em Otimização Combinatória (CPS783)




## TODOs:
- Toys para avaliar trade-offs específicos (para verificar se as cirurgias 
mais antigas estão sendo priorizadas e para avaliar o viés com relação à 
duração da cirurgia)  ==> Precisamos dividir a criação dos toys com a turma
- FO: Implementar penalidades duplas, penalizar quando passar do prazo
- FO: Verificar se vale a pena aumentar o peso da passagem do tempo 
(multiplicar os dias transcorridos por um fator multiplicativo? Fator depende 
do tempo restante para acabar o prazo?)
- Verificar o algoritmo guloso: tem que marcar as urgencias na segunda -> 
Parcialmente concluido. **Com mais de um quarto, ainda está agendando 
prioridades para o segundo dia sem necessidade** (obs.: pode ter problema 
na F.O.)
- Mudar estrutura de dados do ALNS para aumentar a eficiencia da heuristica 
(diminuir tempo que leva para rodar): free_timeslots como array de intervalos 
de tempo livre e array com especialidades das salas
- Acertar a greedy_insertion (testar colocando so um ou tantos quanto o possivel)
- Função de Shuffle das cirurgias de um mesmo dia (sem perder a viabilidade) - 
Inclusive maximizar o espaço livre
- Adicionar outros operadores de inserção e remoção
- Análise de quantos quartos são necessários para agendar todas as cirurgias de 
uma instância, ou para agendar sem ultrapassar o tempo máximo de espera 
(parte de análise do código)


- ~~Código verificador de viabilidade de uma solução?~~ ✓
- ~~Acertar a ordem de prioridades (incluir comparacao 
por dia)~~ ✓
- ~~Plots das solução~~ ~~Mudança das cores nas plots 
(e o que mais julgarmos que seja bom)~~  ✓
- ~~Função para assinalar as cirurgias fora do prazo em uma solução 
(evidenciar essas coisas)~~ ✓