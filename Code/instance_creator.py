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
	parser.add_argument('--surgery_total', '-s', metavar='s', type=int, nargs=1, \
		help='total number of surgeries', required=True)
	parser.add_argument('--priority', '-p', metavar='p', type=int, nargs=2, \
		help='priority range (min; max)', required=True)
	parser.add_argument('--waiting', '-w', metavar='w', type=int, nargs=1, \
		help='max waiting time', required=True)
	parser.add_argument('--duration', '-t', metavar='t', type=int, nargs=2, \
		help='duration time range (min; max)', required=True)
	parser.add_argument('--specialties', '-e', metavar='e', type=int, nargs=1, \
		help='total number of specialties', required=True)
	parser.add_argument('--surgeons', '-g', metavar='g', type=int, nargs=1, \
		help='total number of surgeons', required=True)
	parser.add_argument('--waiting_dist', '-wD', metavar='wD', type=str, nargs=1, \
		help='distribution of waiting time', required=False)

	args = parser.parse_args()

	data = {
		"Cirurgia (c)": [],
		"Prioridade (p)": [],
		"Dias_espera (w)": [],
		"Especialidade (e)": [],
		"Cirurgião (h)": [],
		"Duração (tc)": []
	}

	for i in range(0, args.surgery_total[0]):
		data["Cirurgia (c)"].append(i + 1)

		data["Especialidade (e)"].append(np.random.random_integers(1, args.specialties[0]))
		data["Cirurgião (h)"].append(np.random.random_integers(1, args.surgeons[0]))
		data["Duração (tc)"].append(np.random.random_integers(args.duration[0], args.duration[1]))

		priority = np.random.random_integers(args.priority[0], args.priority[1])
		data["Prioridade (p)"].append(priority)

		max_waiting = np.min([DEADLINES[priority - 1] - 2, args.waiting[0]])
		waiting_time = np.random.random_integers(0, max_waiting)
		data["Dias_espera (w)"].append(waiting_time)

	try:
		output_filename = args.filename[0]
	except:
		output_filename = f"fullrand_s{args.surgery_total[0]}_p{args.priority[0]}-{args.priority[1]}_w{args.waiting[0]}" \
						+ f"_t{args.duration[0]}-{args.duration[1]}_e{args.specialties[0]}_g{args.surgeons[0]}.csv"

	df = pd.DataFrame(data=data)
	df.to_csv(os.path.join(args.path[0], output_filename), sep=';', index=False)