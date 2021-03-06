import matplotlib.pyplot as plt
import numpy as np
import pdb
from scipy.stats import t

if __name__ == '__main__':
	# df = [
	# 	(
	# 		"I3 (randomFit_r2_s50_t8-4)",
	# 		[
	# 			("Naive", [397618, 1e-10, 397618, 397618, 10, 0]),
	# 			("Random", [383721, 2949, 381779, 389535, 10, 9.2]),
	# 		    ("+ Greedy insertions", [383876, 2818, 381873, 389471, 10, 11.9]),
	# 		    ("+ Worst removals", [382753, 711, 382053, 384458, 10, 16.2]),
	# 		    ("+ Shaw removals", [382682, 904, 381755, 384735, 10, 18.5]),
	# 		    ("+ Regret insertion", [382647, 505, 381932, 383601, 10, 30.3])
	# 		]
	# 	), (
	# 		"I6 (randomFit_r5_s100_t16-4)",
	# 		[
	# 			("Naive", [1960222, 1e-10, 1960222, 1960222, 10, 0]),
	# 			("Random", [1936883, 1007, 1935602, 1938871, 10, 17.3]),
	# 		    ("+ Greedy insertions", [1940519, 1128, 1938314, 1942169, 10, 19.2]),
	# 		    ("+ Worst removals", [1941818, 1386, 1939580, 1944037, 10, 42.1]),
	# 		    ("+ Shaw removals", [1938368, 1475, 1935923, 1940531, 10, 44.5]),
	# 		    ("+ Regret insertion", [1939535, 1371, 1936869, 1940907, 10, 75.7])
	# 		]
	# 	), (
	# 		"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
	# 		[
	# 			("Naive", [35202, 1e-10, 35202, 35202, 10, 0]),
	# 			("Random", [20004, 342, 19515, 20516, 10, 107.7]),
	# 		    ("+ Greedy insertions", [21197, 549, 20317, 22067, 10, 201.5]),
	# 		    ("+ Worst removals", [22240, 1863, 20192, 24708, 10, 701.1]),
	# 		    ("+ Shaw removals", [19819, 642, 19031, 20811, 10, 714.2]),
	# 		    ("+ Regret insertion", [19482, 548, 18890, 20625, 10, 476.9]),
	# 		]
	# 	)
	# ]

	# df = [
	# 	(
	# 		"I3 (randomFit_r2_s50_t8-4)",
	# 		[
	# 			("Baseline", [383096, 688, 382369, 384447, 10]),
	# 			("w/ Squeeze", [382647, 505, 381932, 383601, 10]),
	# 		]
	# 	),(
	# 		"I6 (randomFit_r5_s100_t16-4)",
	# 		[
	# 		    ("Baseline", [1939108, 1803, 1936443, 1941443, 10]),
	# 			("w/ Squeeze", [1939535, 1371, 1936869, 1940907, 10]),
	# 		]
	# 	),(
	# 		"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
	# 		[
	# 			("Baseline", [19830, 664, 18830, 20797, 10]),
	# 			("w/ Squeeze", [19482, 548, 18890, 20625, 10]),
	# 		]
	# 	)
	# ]

	# df = [
	# 	(
	# 		"I3 (randomFit_r2_s50_t8-4)",
	# 		[
	# 			("Naive", [397618, 1e-10, 397618, 397618, 10, 0]),
	# 			("100", [384575, 974, 383272, 386494, 10, 11.0]),
	# 			("250", [383007, 353, 382566, 383718, 10, 10.6]),
	# 			("500", [383038, 882, 382056, 385029, 10, 22]),
	# 			("1000", [382554, 560, 381841, 383692, 10, 38]),
	# 		]
	# 	), (
	# 		"I6 (randomFit_r5_s100_t16-4)",
	# 		[
	# 			("Naive", [1960222, 1e-10, 1960222, 1960222, 10, 0]),
	# 			("100", [1942415, 1422, 1940206, 1944082, 10, 13]),
	# 			("250", [1941211, 1462, 1939385, 1943531, 10, 28]),
	# 			("500", [1939397, 1506, 1937277, 1942667, 10, 66]),
	# 			("1000", [1938044, 1166, 1936214, 1939856, 10, 122]),
	# 		]
	# 	), (
	# 		"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
	# 		[
	# 			("Naive", [35202, 1e-10, 35202, 35202, 10, 0]),
	# 			("100", [20804, 840, 19770, 22532, 10, 79]),
	# 			("250", [19707, 565, 18799, 20612, 10, 188]),
	# 			("500", [19645, 476, 18860, 20671, 10, 427]),
	# 			("1000", [19468, 537, 18646, 20615, 10, 1001]),
	# 		]
	# 	)
	# ]

	# df = [
	# 	(
	# 		"I3 (randomFit_r2_s50_t8-4)",
	# 		[
	# 			("Geométrico", [382354.5, 557.3, 381611.0, 383521.0, 382280.5, 32.1]),
	# 			("Rápido", [381975.7, 223.2, 381652.0, 382409.0, 381981.5, 191.4]),
	# 		]
	# 	),(
	# 		"I6 (randomFit_r5_s100_t16-4)",
	# 		[
	# 			("Geométrico", [1936130.8, 846.7, 1935061.0, 1937954.0, 1935951.5, 69.6]),
	# 			("Rápido", [1935079.3, 1051.2, 1933414.0, 1936501.0, 1935102.0, 463.0]),
	# 		]
	# 	),(
	# 		"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
	# 		[
	# 			("Geométrico", [19576.3, 421.3, 18896.0, 20485.0, 19608.0, 302.9]),
	# 			("Rápido", [19547.2, 302.6, 19041.0, 20232.0, 19521.0, 3667.6]),
	# 		]
	# 	)
	# ]

	df = [
		(
			"I3 (randomFit_r2_s50_t8-4)",
			[
				("$(0.4, 10, 5, 1)$", [382344.8, 257.9, 381928.0, 382737.0, 382275.0, 37.7]),
				("$(0.1, 10, 5, 1)$", [382354.5, 557.3, 381611.0, 383521.0, 382280.5, 32.1]),
				("$(0.1, 1, 0, 5)$", [382445.2, 330.1, 382044.0, 383123.0, 382369.0, 22.3]),
				("$(0.1, 5, 5, 5)$", [382639.6, 569.4, 382029.0, 383943.0, 382524.5, 15.9]),
			]
		),(
			"I6 (randomFit_r5_s100_t16-4)",
			[
				("$(0.4, 10, 5, 1)$", [1937844.5, 1818.1, 1935408.0, 1941617.0, 1937749.0, 121.1]),
				("$(0.1, 10, 5, 1)$", [1936130.8, 846.7, 1935061.0, 1937954.0, 1935951.5, 69.6]),
				("$(0.1, 1, 0, 5)$", [1938436.3, 1199.0, 1936719.0, 1940263.0, 1938396.5, 37.2]),
				("$(0.1, 5, 5, 5)$", [1938489.2, 1398.3, 1936651.0, 1940576.0, 1938319.0, 44.6]),
			]
		),(
			"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
			[
				("$(0.4, 10, 5, 1)$", [19396.3, 541.6, 18730.0, 20674.0, 19464.0, 942.4]),
				("$(0.1, 10, 5, 1)$", [19576.3, 421.3, 18896.0, 20485.0, 19608.0, 302.9]),
				("$(0.1, 1, 0, 5)$", [19534.7, 452.1, 18857.0, 20249.0, 19664.5, 200.4]),
				("$(0.1, 5, 5, 5)$", [19805.2, 409.4, 19141.0, 20671.0, 19728.0, 277.2]),
			]
		)
	]

	fig, ax = plt.subplots()

	should_color = False
	c1, c2 = 'pink', 'green'

	fig, axs = plt.subplots(1, 3)

	for (i, (subtitle, data)) in enumerate(df):
		boxes = []
		times = []

		for (label, d) in data:
			mean, std_dev, min, max, n, tm = d
			print(t.interval(0.95, n, mean, std_dev))
			boxes.append({
				'label' : label,
		        'whislo': t.interval(0.95, n, mean, std_dev)[0],    # Bottom whisker position
		        'q1'    : t.interval(0.95, n, mean, std_dev)[0],    # First quartile (25th percentile)
		        'med'   : mean,    # Median         (50th percentile)
		        'q3'    : t.interval(0.95, n, mean, std_dev)[1],    # Third quartile (75th percentile)
		        'whishi': t.interval(0.95, n, mean, std_dev)[1],    # Top whisker position
		        'fliers': [min, max]        # Outliers
		    })
			times.append(tm)

		axs[i].set_title(subtitle)
		bxp_plt = axs[i].bxp(boxes, patch_artist=should_color)
	
		if should_color:
			# for item in ['boxes', 'whiskers', 'fliers', 'medians', 'caps']:
			# 	plt.setp(bxp_plt[item], color=c2)
			plt.setp(bxp_plt["boxes"], facecolor=c1)
			plt.setp(bxp_plt["fliers"], markeredgecolor=c2)

		plt.setp(axs[i].xaxis.get_majorticklabels(), rotation=90)

		ax2 = axs[i].twinx()

		axs[i].set_ylabel("Função objetivo")
		ax2.set_ylabel('tempo médio de execução (s)')

		ax2.plot(range(1, len(times) + 1), times)
		ax2.scatter(range(1, len(times) + 1), times)

	fig.tight_layout()

	plt.subplots_adjust(bottom=0.23, wspace=0.3)
	# plt.subplots_adjust(top=0.35)
	plt.show()