import pandas as pd
import numpy as np
import argparse

if __name__ == '__main__':
	"""
	Example:
		python instance_creator.py --output "instance2.csv" --surgery_total 50 --priority 1 4 --waiting 1 20 --duration 2 20 --specialties 4 --surgeons 4
	"""
	
	parser = argparse.ArgumentParser(description='Surgery instance generator.')
	parser.add_argument('--output', '-o', metavar='o', type=str, nargs=1, \
		help='filepath of the CSV output', required=True)
	parser.add_argument('--surgery_total', '-s', metavar='s', type=int, nargs=1, \
		help='total number of surgeries', required=True)
	parser.add_argument('--priority', '-p', metavar='p', type=int, nargs=2, \
		help='priority range (min; max)', required=True)
	parser.add_argument('--waiting', '-w', metavar='w', type=int, nargs=2, \
		help='waiting time range (min; max)', required=True)
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
		data["Prioridade (p)"].append(np.random.random_integers(args.priority[0], args.priority[1]))
		data["Dias_espera (w)"].append(np.random.random_integers(args.waiting[0], args.waiting[1]))
		data["Especialidade (e)"].append(np.random.random_integers(1, args.specialties[0]))
		data["Cirurgião (h)"].append(np.random.random_integers(1, args.surgeons[0]))
		data["Duração (tc)"].append(np.random.random_integers(args.duration[0], args.duration[1]))

	df = pd.DataFrame(data=data)
	df.to_csv(args.output[0], sep=';', index=False)