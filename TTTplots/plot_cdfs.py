import pandas as pd
import matplotlib.pyplot as plt

titulo = "I11\nσ1=10, σ2=5, σ3=15. Objetivo: 139500"         # I5
# "I1\nσ1=10, σ2=5, σ3=15. Objetivo: 260870"        # I1
# "I2\nσ1=10, σ2=5, σ3=15. Objetivo: 42778"         # I2
# "I2\nσ1=10, σ2=5, σ3=15. Objetivo: 383300"        # I3
# "I4\nσ1=10, σ2=5, σ3=15. Objetivo: 1497200"       # I4
# "I5\nσ1=10, σ2=5, σ3=15. Objetivo: 1526900"       # I5
#
# "I12\nσ1=10, σ2=5, σ3=15. Objetivo: 21807.5"      # I12

output = "plots/timetotarget_10-5-15_i11_N50_t139500_Indefinidas - i11"
# "timetotarget_10-5-15_i1_N100_t260870_randomFit_r2_s15_t8-4"               # I1
# "timetotarget_10-5-15_i2_N100_t427778_randomFit_r2_s15_t16-4"              # I2
# "timetotarget_10-5-15_i3_N100_t383300_randomFit_r2_s50_t8-4"               # I3
# "timetotarget_10-5-15_i4_N100_t1497200_randomFit_r2_s50_t16-4"             # I4
# "timetotarget_10-5-15_i5_N50_t1526900_randomFit_r5_s100_t8-4"              # I5
#
# "timetotarget_10-5-15_i12_N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20"    # I12

files = [
    ("ttt_allOps_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
    ("ttt_rand+greedy+worst_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso e Pior", 1000),
    ("ttt_rand+greedy_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório e Guloso", 1000),
    ("ttt_randOnly_10-5-15__N50_t139500_Indefinidas - i11.dat", "Somente aleatório", 1000),
]

# I1
#[
#    ("ttt_allOps_10-5-15__N100_t260870_randomFit_r2_s15_t8-4.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 30),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N100_t260870_randomFit_r2_s15_t8-4.dat", "Aleatório, Guloso, Pior e Shaw", 30),
#    ("ttt_rand+greedy+worst_10-5-15__N100_t260870_randomFit_r2_s15_t8-4.dat", "Aleatório, Guloso e Pior", 30),
#    ("ttt_rand+greedy_10-5-15__N100_t260870_randomFit_r2_s15_t8-4.dat", "Aleatório e Guloso", 30),
#    ("ttt_randOnly_10-5-15__N100_t260870_randomFit_r2_s15_t8-4.dat", "Somente aleatório", 30),
#]

# I2
#[
#    ("ttt_allOps_10-5-15__N100_t42778_randomFit_r2_s15_t16-4.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 30),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N100_t42778_randomFit_r2_s15_t16-4.dat", "Aleatório, Guloso, Pior e Shaw", 30),
#    ("ttt_rand+greedy+worst_10-5-15__N100_t42778_randomFit_r2_s15_t16-4.dat", "Aleatório, Guloso e Pior", 30),
#    ("ttt_rand+greedy_10-5-15__N100_t42778_randomFit_r2_s15_t16-4.dat", "Aleatório e Guloso", 30),
#    ("ttt_randOnly_10-5-15__N100_t42778_randomFit_r2_s15_t16-4.dat", "Somente aleatório", 30),
#]

# I3
#[
#    ("ttt_allOps_10-5-15__N100_t383300_randomFit_r2_s50_t8-4.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N100_t383300_randomFit_r2_s50_t8-4.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N100_t383300_randomFit_r2_s50_t8-4.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N100_t383300_randomFit_r2_s50_t8-4.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N100_t383300_randomFit_r2_s50_t8-4.dat", "Somente aleatório", 1000),
#]

# I4
#[
#    ("ttt_allOps_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Somente aleatório", 1000),
#]

# I5
#[
#    ("ttt_allOps_10-5-15__N50_t1526900_randomFit_r5_s100_t8-4.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t1526900_randomFit_r5_s100_t8-4.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t1526900_randomFit_r5_s100_t8-4.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t1526900_randomFit_r5_s100_t8-4.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t1526900_randomFit_r5_s100_t8-4.dat", "Somente aleatório", 1000),
#]

# I12
#[
#    ("ttt_allOps_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso e Worst", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Somente aleatório", 1000),
#]

teto = 200
# 8      # I1
# 6      # I2
# 50     # I3
# 500    # I4
# 500    # I12

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

    plt.step(times + [teto], prob + [1],  where='post', label=lab)

plt.xlabel("Tempo (s)")
plt.ylabel("Probabilidade Acumulada")
plt.title(titulo)
plt.grid(color='grey', linestyle='-', linewidth=1, alpha=.1)
plt.legend()

plt.savefig(f"{output}.pdf")
plt.show()