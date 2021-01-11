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
