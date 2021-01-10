using CSV, DataFrames, Printf
using Debugger
using Statistics

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

# data_dir = "Dados/"
data_dir = "../Dados/"
files = [
	# ("randomFit_r2_s15_t8-4", 2),
	# ("randomFit_r2_s15_t16-4", 2),
	# ("randomFit_r2_s50_t8-4", 2),
	# ("randomFit_r2_s50_t16-4", 2),
	# ("randomFit_r5_s100_t8-4", 6),
	# ("randomFit_r5_s100_t16-4", 8),
	# ("fullrand_s50_p1-4_w20_t6-20_e4_g12", 3),
	# ("fullrand_s70_p1-4_w20_t5-20_e5_g20", 3),
	# ("fullrand_s70_p1-4_w30_t5-20_e3_g15", 4),
	# ("fullrand_s90_p1-4_w20_t6-20_e5_g20", 7),
	("Indefinidas - i8", 7),
	("Indefinidas - i9", 6),
	("Indefinidas - i10", 10),
	("Indefinidas - i11", 15),
]

# Número de repetições
SAMPLES = 5

# ALNS variables:
SA_MAX = 1000
SA_MAX_NO_IMP = 500
ALPHA = 0.95
T_INI = 60
T_FIM = 0.1
R = 0.1
SIGMA1 = 1
SIGMA2 = 0
SIGMA3 = 5

function processALNS(instance)
	solution = solve(instance, verbose=false)
	naive_fn = target_fn(instance, solution, false)

	solution, _ = alns_solve(instance, solution, 
					SA_max=SA_MAX, SA_max_no_improvement=SA_MAX_NO_IMP, 
					α=ALPHA, 
					T0=T_INI, Tf=T_FIM, 
					r=R, σ1=SIGMA1, σ2=SIGMA2, σ3=SIGMA3, 
					verbose=false)

	alns_fn = target_fn(instance, solution, false)

	println("\tNaive target function: $naive_fn")
	println("\tALNS target function: $alns_fn")

	return alns_fn
end

results = [[] for _ in 1:length(files)]
rTimes = [[] for _ in 1:length(files)]

for (idx, (filename, rooms)) in enumerate(files)
	println("$filename:")

	surgeries = load_surgeries("$(data_dir)$(filename).csv") 
	instance = (surgeries, rooms)
	instance_results = []

	for i in 1:SAMPLES
		output = @timed processALNS(instance)
		alns_fn = output[1]
		ctime = output[2]
		
		push!(results[idx], alns_fn)
		push!(rTimes[idx], ctime)
	end
end

for (i, r) in enumerate(results)
	println(files[i])
	println("Tempo médio: $(mean(rTimes[i]))")
	println("Resultado: $(mean(r))\t±\t$(std(r))")
	println("\t\tMínimo: $(min(r...))")
	println("\t\tMáximo: $(maximum(r))")
	println("\t\tMediana: $(median(r))")
end
