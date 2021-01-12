import pandas as pd
import matplotlib.pyplot as plt

titulo = "σ1=10, σ2=5, σ3=1"
output = "allOps_randOnly"

files = [
    ("ttt_allOps_10-5-1__N100_randomFit_r2_s50_t8-4.dat", "Todos os operadores"),
    ("ttt_randOnly__N100_randomFit_r2_s50_t8-4.dat", "Somente aleatório"),
]

teto = 30

fig = plt.Figure()

for f in files:
    lab = f[1]
    data = pd.read_table(f[0], names=[lab])

    data = data.sort_values(by=[lab])

    times = data[lab].tolist()

    for i, item in enumerate(times):
        if item == 500:
            times[i] = teto

    N = len(times)

    prob = [i+1/N for i in range(N)]

    plt.step(times, prob,  where='post', label=lab)

plt.xlabel("Tempo (s)")
plt.ylabel("Probabilidade Acumulada")
plt.title(titulo)
plt.legend()

plt.savefig(f"{output}.pdf")
plt.show()