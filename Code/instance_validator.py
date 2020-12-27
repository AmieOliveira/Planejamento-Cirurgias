import pandas as pd
import numpy as np
import argparse
import pdb

PENALTIES = [90, 20, 5, 1]
DEADLINES = [3, 15, 60, 365]

def is_overlap(x1, x2, y1, y2):
	return x1 <= y2 and y1 <= x2

if __name__ == '__main__':
	"""
	Example:
		python instance_validator.py -i "../Dados/toy2.csv" -r 2 -s "../Dados/toy2_solution.csv"
	"""
	
	parser = argparse.ArgumentParser(description='Surgery instance validator.')
	parser.add_argument('--instance', '-i', metavar='i', type=str, nargs=1, \
		help='filepath of the instance CSV', required=True)
	parser.add_argument('--rooms', '-r', metavar='r', type=int, nargs=1, \
		help='number of rooms available', required=True)
	parser.add_argument('--solution', '-s', metavar='s', type=str, nargs=1, \
		help='filepath of the solution CSV', required=True)

	args = parser.parse_args()

	ins_df = pd.read_csv(args.instance[0], sep=";")
	sol_df = pd.read_csv(args.solution[0], sep=";").fillna(-1)
	df = ins_df.set_index("Cirurgia (c)").join(sol_df.set_index("Cirurgia (c)"))

	# Check if some room has more than one specialty in the same day
	for day in range(1, 5+1):
		for room in range(1, args.rooms[0]+1):
			surgeries = df.loc[(df["Sala (r)"] == room) & (df["Dia (d)"] == day)]
			specialties = surgeries["Especialidade (e)"].values

			if len(set(specialties)) > 1:
				print(f"Room {room} has more than one specialty at day {day}. Check surgeries: {surgeries.index.values}.")

	# Check if some surgeon exceeds limit of 24 timesteps
	for day in range(1, 5+1):
		surgeons = set(df.loc[df["Dia (d)"] == day]["Cirurgião (h)"].values)
		for surgeon in surgeons:
			durations = df.loc[(df["Dia (d)"] == day) & (df["Cirurgião (h)"] == surgeon)]["Duração (tc)"].values
			total_time = np.sum(durations) + 2 * (len(durations) - 1)
			if total_time > 24:
				print(f"Surgeon {surgeon} exceeds his time limit of 24 timesteps at day {day}. Actual duration: {total_time}.")

	# Check if some surgeon has overlapping surgeries
	for day in range(1, 5+1):
		surgeons = set(df.loc[df["Dia (d)"] == day]["Cirurgião (h)"].values)
		for surgeon in surgeons:
			surgeries = df.loc[(df["Dia (d)"] == day) & (df["Cirurgião (h)"] == surgeon)]
			timeslots = [(idx, s["Horário (t)"], s["Horário (t)"] + s["Duração (tc)"] - 1) for idx, s in surgeries.iterrows()]
			timeslots = sorted(timeslots, key=lambda tup: tup[1])
			for prev, curr in zip(timeslots, timeslots[1:]):
				if is_overlap(prev[1], prev[2], curr[1], curr[2]):
					print(f"Surgeon {surgeon} has overlapping surgeries scheduled for day {day}. Check surgeries {prev[0]} and {curr[0]}.")

	# Check if surgeries overlap
	for day in range(1, 5+1):
		for room in range(1, args.rooms[0]+1):
			surgeries = df.loc[(df["Sala (r)"] == room) & (df["Dia (d)"] == day)]
			timeslots = [(idx, s["Horário (t)"], s["Horário (t)"] + s["Duração (tc)"] + 2 - 1) for idx, s in surgeries.iterrows()]
			timeslots = sorted(timeslots, key=lambda tup: tup[1])
			for prev, curr in zip(timeslots, timeslots[1:]):
				if is_overlap(prev[1], prev[2], curr[1], curr[2]):
					print(f"Room {room} has overlapping surgeries at day {day}. Check surgeries {prev[0]} and {curr[0]}.")

	# Check if surgeries with highest priority are not scheduled for day1
	late_surgeries = df.loc[(df["Prioridade (p)"] == 1) & (df["Dia (d)"] != 1)]
	for idx, surgery in late_surgeries.iterrows():
		print(f"Warning: surgery {surgery.name} is priority 1 but isn't scheduled for day 1.")

	# Evaluates and prints the target function for this solution
	target_fn = 0
	for idx, surgery in df.iterrows():
		surgery_target_fn = 0
		print(f"Cirurgia {idx}:")

		ksi_p = PENALTIES[int(surgery['Prioridade (p)']) - 1]
		l_p = DEADLINES[int(surgery['Prioridade (p)']) - 1]
		w_c = surgery['Dias_espera (w)']
		d = surgery['Dia (d)']
		p = surgery['Prioridade (p)']

		is_scheduled = (d != -1)
		exceeded_deadline = (w_c + 2 + (d if d != -1 else 7)) > DEADLINES[int(surgery["Prioridade (p)"]) - 1] + 1

		if p == 1 and d != 1:
			val = (10 * (w_c + 2)) ** (d if is_scheduled else 7)
			surgery_target_fn += val
			print(f"\t surgery with priority 1 not scheduled for day 1.")
			print(f"\t penalty: (10 * ({w_c} + 2)) ** {(d if is_scheduled else 7)} = {val}")

		if is_scheduled:
			val = (w_c + 2 + d) ** 2
			surgery_target_fn += val
			print(f"\t scheduled: ({w_c} + 2 + {d}) ** 2 = {val}")
			if exceeded_deadline:
				val = (w_c + 2 + d - l_p) ** 2
				surgery_target_fn += val
				print(f"\t exceeded deadline! ({w_c} + 2 + {d} - {l_p}) ** 2 = {val}")
		else:
			val = ksi_p * (w_c + 7) ** 2
			surgery_target_fn += val
			print(f"\t not scheduled: {ksi_p} * ({w_c} + 7) ** 2 = {val}")
			if exceeded_deadline:
				val = ksi_p * (w_c + 2 + 7 - l_p) ** 2
				surgery_target_fn += val
				print(f"\t exceeded deadline! {ksi_p} * ({w_c} + 2 + 7 - {l_p}) ** 2 = {val}")

		print(f"\t-- total: {surgery_target_fn}")
		target_fn += surgery_target_fn

	print(f"Target function: {target_fn}")