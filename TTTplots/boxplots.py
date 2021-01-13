import matplotlib.pyplot as plt
import numpy as np
import pdb
from scipy.stats import t

if __name__ == '__main__':
	df = [
		(
			"I3 (randomFit_r2_s50_t8-4)",
			[("Naive", [397618, 1e-10, 397618, 397618, 10]),
					("Random", [383721, 2949, 381779, 389535, 10]),
				    ("+ Greedy insertions", [383876, 2818, 381873, 389471, 10]),
				    ("+ Worst removals", [382753, 711, 382053, 384458, 10]),
				    ("+ Shaw removals", [382682, 904, 381755, 384735, 10]),
				    ("+ Regret insertion", [382647, 505, 381932, 383601, 10])
			]
		), (
			"I6 (randomFit_r5_s100_t16-4)",
			[("Naive", [1960222, 1e-10, 1960222, 1960222, 10]),
					("Random", [1936883, 1007, 1935602, 1938871, 10]),
				    ("+ Greedy insertions", [1940519, 1128, 1938314, 1942169, 10]),
				    ("+ Worst removals", [1941818, 1386, 1939580, 1944037, 10]),
				    ("+ Shaw removals", [1938368, 1475, 1935923, 1940531, 10]),
				    ("+ Regret insertion", [1939535, 1371, 1936869, 1940907, 10])
			]
		), (
			"I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)",
			[("Naive", [35202, 1e-10, 35202, 35202, 10]),
					("Random", [20004, 342, 19515, 20516, 10]),
				    ("+ Greedy insertions", [21197, 549, 20317, 22067, 10]),
				    ("+ Worst removals", [22240, 1863, 20192, 24708, 10]),
				    ("+ Shaw removals", [19819, 642, 19031, 20811, 10]),
				    ("+ Regret insertion", [19482, 548, 18890, 20625, 10]),
			]
		)
	]

	# title = "I3 (randomFit_r2_s50_t8-4)"
	# data = [
	# 	("Baseline", [383096, 688, 382369, 384447, 10]),
	# 	("w/ Squeeze", [382647, 505, 381932, 383601, 10]),
	# ]
	# title = "I6 (randomFit_r5_s100_t16-4)"
	# data = [
	#     ("Baseline", [1939108, 1803, 1936443, 1941443, 10]),
	# 	("w/ Squeeze", [1939535, 1371, 1936869, 1940907, 10]),
	# ]
	# title = "I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)"
	# data = [
	# 	("Baseline", [19830, 664, 18830, 20797, 10]),
	# 	("+ Squeeze", [19482, 548, 18890, 20625, 10]),
	# ]

	# title = "I3 (randomFit_r2_s50_t8-4)"
	# data = [
	# 	("Naive", [397618, 1e-10, 397618, 397618, 10]),
	# 	("100", [384575, 974, 383272, 386494, 10]),
	# 	("250", [383007, 353, 382566, 383718, 10]),
	# 	("500", [383038, 882, 382056, 385029, 10]),
	# 	("1000", [382554, 560, 381841, 383692, 10]),
	# ]
	# title = "I6 (randomFit_r5_s100_t16-4)"
	# data = [
	#	("Naive", [1960222, 1e-10, 1960222, 1960222, 10]),
		# ("100", [1942415, 1422, 1940206, 1944082, 10]),
		# ("250", [1941211, 1462, 1939385, 1943531, 10]),
		# ("500", [1939397, 1506, 1937277, 1942667, 10]),
		# ("1000", [1938044, 1166, 1936214, 1939856, 10]),
	# ]
	# title = "I12 (fullrand_s70_p1-4_w20_t5-20_e5_g20)"
	# data = [
	# 	("Naive", [35202, 1e-10, 35202, 35202, 10]),
	# 	("100", [20804, 840, 19770, 22532, 10]),
	# 	("250", [19707, 565, 18799, 20612, 10]),
	# 	("500", [19645, 476, 18860, 20671, 10]),
	# 	("1000", [19468, 537, 18646, 20615, 10]),
	# ]

	fig, ax = plt.subplots()

	should_color = False
	c1, c2 = 'pink', 'green'

	fig, axs = plt.subplots(1, 3)

	for (i, (subtitle, data)) in enumerate(df):
		boxes = []

		for (label, d) in data:
			mean, std_dev, min, max, n = d
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

		axs[i].set_title(subtitle)
		bxp_plt = axs[i].bxp(boxes, patch_artist=should_color)
	
		if should_color:
			# for item in ['boxes', 'whiskers', 'fliers', 'medians', 'caps']:
			# 	plt.setp(bxp_plt[item], color=c2)
			plt.setp(bxp_plt["boxes"], facecolor=c1)
			plt.setp(bxp_plt["fliers"], markeredgecolor=c2)

		plt.setp(axs[i].xaxis.get_majorticklabels(), rotation=90)

	axs[0].set_ylabel("Função objetivo")
	plt.subplots_adjust(bottom=0.23, wspace=0.3)
	# plt.subplots_adjust(top=0.35)
	plt.show()