import pandas as pd
import numpy as np
import argparse
import os


if __name__ == '__main__':
	"""
	Example:
		python instance_creator.py --path "../Data/" --surgery_total 50 --priority 1 4 --waiting 1 20 --duration 2 20 --specialties 4 --surgeons 4
	"""

	DEADLINES = [3, 15, 60, 365]
	
	parser = argparse.ArgumentParser(description='Surgery instance generator.')
	parser.add_argument('--path', '-fp', metavar='fp', type=str, nargs=1, \
		help='filepath of the CSV output', required=True)
	parser.add_argument('--filename', '-fn', metavar='fn', type=str, nargs=1, \
		help='name of the CSV output', required=False)
	parser.add_argument('--rooms', '-r', metavar='rooms', type=int, nargs=1,
						help='number of rooms', required=True)
	parser.add_argument('--surgery_total', '-s', metavar='s', type=int, nargs=1, \
		help='total number of surgeries', required=True)
	parser.add_argument('--duration', '-t', metavar='t', type=int, nargs=2, \
		help='duration parameters (mean; deviation)', required=True)

	args = parser.parse_args()

	data = {
		"Cirurgia (c)": [],
		"Prioridade (p)": [],
		"Dias_espera (w)": [],
		"Especialidade (e)": [],
		"Cirurgião (h)": [],
		"Duração (tc)": []
	}

	n_esp = args.rooms[0]
	n_docs = 3*args.rooms[0]
	surgeon_usage = np.zeros(n_docs)

	for i in range(3*args.rooms[0]):
		data["Cirurgia (c)"].append(i + 1)
		data["Prioridade (p)"].append(1)
		data["Dias_espera (w)"].append(1)

		data["Cirurgião (h)"].append(i+1)

		tc = int(np.random.normal(args.duration[0], args.duration[1]))
		if tc < 2:
			tc = 2
		elif tc > 22:
			tc = 22
		data["Duração (tc)"].append(tc)
		surgeon_usage[i] += tc

		data["Especialidade (e)"].append(np.random.randint(1, n_esp+1))


	for i in range(2*args.rooms[0], args.surgery_total[0]):
		data["Cirurgia (c)"].append(i + 1)

		data["Especialidade (e)"].append(np.random.randint(1, n_esp+1))

		tc = int(np.random.normal(args.duration[0], args.duration[1]))
		if tc < 2:
			tc = 2
		elif tc > 22:
			tc = 22
		data["Duração (tc)"].append(tc)

		doc = np.random.randint(1, n_docs+1)
		while surgeon_usage[doc-1] + tc > 100:
			try:
				doc = doc+1
			except IndexError:
				doc = 0
		data["Cirurgião (h)"].append(doc)
		surgeon_usage[doc-1] += tc

		priority = np.random.randint(2, 4+1)
		data["Prioridade (p)"].append(priority)

		max_waiting = DEADLINES[priority - 1] - 2
		waiting_time = np.random.randint(0, max_waiting+1)
		data["Dias_espera (w)"].append(waiting_time)

	try:
		output_filename = args.filename[0]
	except TypeError:
		output_filename = f"randomFit_r{args.rooms[0]}_s{args.surgery_total[0]}" \
						+ f"_t{args.duration[0]}-{args.duration[1]}.csv"

	df = pd.DataFrame(data=data)
	df.to_csv(os.path.join(args.path[0], output_filename), sep=';', index=False)