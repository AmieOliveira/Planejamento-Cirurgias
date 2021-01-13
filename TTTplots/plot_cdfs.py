import pandas as pd
import matplotlib.pyplot as plt

titulo = "σ1=10, σ2=5, σ3=15. Objetivo: 21807.5"
output = "allOps_shaw_worst_greedy_randOnly_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20"

files = [
    ("ttt_allOps_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
    ("ttt_rand+greedy+worst_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso e Worst", 1000),
    ("ttt_rand+greedy_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório e Guloso", 1000),
    ("ttt_randOnly_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Somente aleatório", 1000),
]
#("ttt_allOps_10-5-1__N100_randomFit_r2_s50_t8-4.dat", "Todos os operadores", 500),
#("ttt_randOnly__N100_randomFit_r2_s50_t8-4.dat", "Somente aleatório", 500)

teto = 500

fig = plt.Figure()

for f in files:
    lab = f[1]
    data = pd.read_table(f[0], names=[lab])
    tetoOld = f[2]

    data = data.sort_values(by=[lab])

    times = data[lab].tolist()

    for i, item in enumerate(times):
        if item == tetoOld:
            times[i] = teto

    N = len(times)

    prob = [(i+1)/N for i in range(N)]

    plt.step(times + [500], prob + [1],  where='post', label=lab)

plt.xlabel("Tempo (s)")
plt.ylabel("Probabilidade Acumulada")
plt.title(titulo)
plt.grid(color='grey', linestyle='-', linewidth=1, alpha=.1)
plt.legend()

plt.savefig(f"{output}.pdf")
plt.show()