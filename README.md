# Planejamento-Cirurgias
Planejamento de cirurgias eletivas em hospitais. Implementação de heurísticas 
baseadas em ALNS para minimizar o período de espera entre a entrada na fila para 
a cirurgia e a sua realização.

Trabalho para Meta-heurísticas em Otimização Combinatória (CPS783)



## TODOs:
- Código verificador de viabilidade de uma solução?
- Acertar a ordem de prioridades (incluir comparacao por dia)
- Mudar estrutura de dados do ALNS para aumentar a eficiencia da heuristica 
(diminuir tempo que leva para rodar): free_timeslots como array de intervalos 
de tempo livre e array com especialidades das salas
- Acertar a greedy_insertion (testar colocando so um ou tantos quanto o possivel)
- Função de Shuffle das cirurgias de um mesmo dia (sem perder a viabilidade) - 
Inclusive maximizar o espaço livre
- Adicionar outros operadores de inserção e remoção
- Plots das solução
- Duas FOs: comparar o impacto de multiplicar pela duracao da cirurgia
- Análise de quantos quartos são necessários para agendar todas as cirurgias de 
uma instância, ou para agendar sem ultrapassar o tempo máximo de espera 
(parte de análise do código)