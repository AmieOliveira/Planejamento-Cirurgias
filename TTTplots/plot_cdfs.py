import pandas as pd
import matplotlib.pyplot as plt

titulo = "I4\nσ1=10, σ2=5, σ3=15. Objetivo: 1497200"
# "I1\nσ1=10, σ2=5, σ3=15. Objetivo: 260870"        # I1
# "I2\nσ1=10, σ2=5, σ3=15. Objetivo: 42778"         # I2
# "I2\nσ1=10, σ2=5, σ3=15. Objetivo: 383300"        # I3
# "I4\nσ1=10, σ2=5, σ3=15. Objetivo: 1497200"       # I4
# "I5\nσ1=10, σ2=5, σ3=15. Objetivo: 1526900"       # I5
# "I6\nσ1=10, σ2=5, σ3=15. Objetivo: 1939500"       # I6
# "I7\nσ1=10, σ2=5, σ3=15. Objetivo: 9680"          # I7
# "I8\nσ1=10, σ2=5, σ3=15. Objetivo: 47200"         # I8
# "I9\nσ1=10, σ2=5, σ3=15. Objetivo: 40800"         # I9
# "I10\nσ1=10, σ2=5, σ3=15. Objetivo: 98400"        # I10
# "I11\nσ1=10, σ2=5, σ3=15. Objetivo: 139500"       # I11
# "I12\nσ1=10, σ2=5, σ3=15. Objetivo: 21807.5"      # I12
# "I13\nσ1=10, σ2=5, σ3=15. Objetivo: 20100"        # I13
# "I14\nσ1=10, σ2=5, σ3=15. Objetivo: 15750"        # I14

output = "plots/timetotarget_10-5-15_i4_N100_t1497200_randomFit_r2_s50_t16-4"
# "plots/timetotarget_10-5-15_i1_N100_t260870_randomFit_r2_s15_t8-4"                # I1
# "plots/timetotarget_10-5-15_i2_N100_t427778_randomFit_r2_s15_t16-4"               # I2
# "plots/timetotarget_10-5-15_i3_N100_t383300_randomFit_r2_s50_t8-4"                # I3
# "plots/timetotarget_10-5-15_i4_N100_t1497200_randomFit_r2_s50_t16-4"              # I4
# "plots/timetotarget_10-5-15_i5_N50_t1526900_randomFit_r5_s100_t8-4"               # I5
# "plots/timetotarget_10-5-15_i6_N50_t1939500_randomFit_r5_s100_t16-4"              # I6
# "plots/timetotarget_10-5-15_i7_N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12"      # I7
# "plots/timetotarget_10-5-15_i8_N50_t47200_Indefinidas - i8"                       # I8
# "plots/timetotarget_10-5-15_i9_N50_t40800_Indefinidas - i9"                       # I9
# "plots/timetotarget_10-5-15_i10_N50_t98400_Indefinidas - i10"                     # I10
# "plots/timetotarget_10-5-15_i11_N50_t139500_Indefinidas - i11"                    # I11
# "plots/timetotarget_10-5-15_i12_N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20"    # I12
# "plots/timetotarget_10-5-15_i13_N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15"    # I13
# "plots/timetotarget_10-5-15_i14_N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20"    # I14

files = [
    ("ttt_allOps_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso, Pior, Shaw\ne Arrependimento", 1000),
    ("ttt_rand+greedy+worst+shaw_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
    ("ttt_rand+greedy+worst_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso e Pior", 1000),
    ("ttt_rand+greedy_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório e Guloso", 1000),
    ("ttt_randOnly_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Somente aleatório", 1000),
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
#    ("ttt_allOps_10-5-15__N100_t1497200_randomFit_r2_s50_t16-4.dat", "Aleatório, Guloso, Pior, Shaw e\nArrependimento", 1000),
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

# I6
#[
#    ("ttt_allOps_10-5-15__N50_t1939500_randomFit_r5_s100_t16-4.dat", "Aleatório, Guloso, Pior, Shaw e\nArrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t1939500_randomFit_r5_s100_t16-4.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t1939500_randomFit_r5_s100_t16-4.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t1939500_randomFit_r5_s100_t16-4.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t1939500_randomFit_r5_s100_t16-4.dat", "Somente aleatório", 1000),
#]

# I7
#[
#    ("ttt_allOps_10-5-15__N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12.dat", "Aleatório, Guloso, Pior, Shaw\ne Arrependimento", 200),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12.dat", "Aleatório, Guloso, Pior e Shaw", 200),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12.dat", "Aleatório, Guloso e Pior", 200),
#    ("ttt_rand+greedy_10-5-15__N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12.dat", "Aleatório e Guloso", 200),
#    ("ttt_randOnly_10-5-15__N50_t9680_fullrand_s50_p1-4_w20_t6-20_e4_g12.dat", "Somente aleatório", 200),
#]

# I8
#[
#    ("ttt_allOps_10-5-15__N50_t47200_Indefinidas - i8.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t47200_Indefinidas - i8.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t47200_Indefinidas - i8.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t47200_Indefinidas - i8.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t47200_Indefinidas - i8.dat", "Somente aleatório", 1000),
#]

# I9
#[
#    ("ttt_allOps_10-5-15__N50_t40800_Indefinidas - i9.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 200),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t40800_Indefinidas - i9.dat", "Aleatório, Guloso, Pior e Shaw", 200),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t40800_Indefinidas - i9.dat", "Aleatório, Guloso e Pior", 200),
#    ("ttt_rand+greedy_10-5-15__N50_t40800_Indefinidas - i9.dat", "Aleatório e Guloso", 200),
#    ("ttt_randOnly_10-5-15__N50_t40800_Indefinidas - i9.dat", "Somente aleatório", 200),
#]

# I10
#[
#    ("ttt_allOps_10-5-15__N50_t98400_Indefinidas - i10.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t98400_Indefinidas - i10.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t98400_Indefinidas - i10.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t98400_Indefinidas - i10.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t98400_Indefinidas - i10.dat", "Somente aleatório", 1000),
#]

# I11
#[
#    ("ttt_allOps_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t139500_Indefinidas - i11.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t139500_Indefinidas - i11.dat", "Somente aleatório", 1000),
#]

# I12
#[
#    ("ttt_allOps_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso, Pior e Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório, Guloso e Worst", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t21807_fullrand_s70_p1-4_w20_t5-20_e5_g20.dat", "Somente aleatório", 1000),
#]

# I13
#[
#    ("ttt_allOps_10-5-15__N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15.dat", "Aleatório, Guloso, Pior,\nShaw e Arrependimento", 1000),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15.dat", "Aleatório, Guloso, Pior\ne Shaw", 1000),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15.dat", "Aleatório, Guloso e Pior", 1000),
#    ("ttt_rand+greedy_10-5-15__N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15.dat", "Aleatório e Guloso", 1000),
#    ("ttt_randOnly_10-5-15__N50_t20100_fullrand_s70_p1-4_w30_t5-20_e3_g15.dat", "Somente aleatório", 1000),
#]

# I14
#[
#    ("ttt_allOps_10-5-15__N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20.dat", "Aleatório, Guloso, Pior, Shaw e Arrependimento", 500),
#    ("ttt_rand+greedy+worst+shaw_10-5-15__N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20.dat", "Aleatório, Guloso, Pior e Shaw", 500),
#    ("ttt_rand+greedy+worst_10-5-15__N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20.dat", "Aleatório, Guloso e Pior", 500),
#    ("ttt_rand+greedy_10-5-15__N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20.dat", "Aleatório e Guloso", 500),
#    ("ttt_randOnly_10-5-15__N50_t15750_fullrand_s90_p1-4_w20_t6-20_e5_g20.dat", "Somente aleatório", 500),
#]


teto = 150
# 8      # I1
# 6      # I2
# 50     # I3
# 150    # I4
# 80     # I6
# 50     # I7
# 50     # I10
# 100    # I13
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
plt.legend(loc="lower right")

plt.savefig(f"{output}.pdf")
plt.show()