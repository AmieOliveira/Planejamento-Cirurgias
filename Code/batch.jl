using CSV, DataFrames, Printf
using Debugger
using Statistics

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

data_dir = "../Dados/"
files = [
	# ("toy1", 1),
	# ("toy2", 1),
	# ("toy4", 1),
	("fullrand_s50_p1-4_w20_t2-10_e5_g10", 4),
	("fullrand_s50_p1-4_w20_t2-10_e5_g20", 4),
	("fullrand_s50_p1-4_w20_t2-10_e5_g20", 5),
	("fullrand_s50_p1-4_w40_t2-20_e10_g20", 6),
	("fullrand_s70_p1-4_w40_t2-10_e10_g10", 10),
	("fullrand_s70_p1-4_w40_t2-10_e20_g20", 10),
	("fullrand_s100_p1-4_w40_t2-10_e20_g20", 10),
]

results = [[] for _ in 1:length(files)]
SAMPLES = 10

for (idx, (filename, rooms)) in enumerate(files)
	println("$filename:")

	surgeries = load_surgeries("$(data_dir)$(filename).csv") 
	instance = (surgeries, rooms)
	instance_results = []

	for i in 1:SAMPLES
		solution = solve(instance, verbose=false)
		naive_fn = target_fn(instance, solution, false)

		# solution, _ = alns_solve(instance, solution, SA_max=1000, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=1, verbose=false)
		solution, _ = alns_solve(instance, solution, SA_max=1000, SA_max_no_improvement=500,
			α=0.95, T0=60, Tf=0.1, r=0.1, σ1=1, σ2=0, σ3=5, verbose=false)
		alns_fn = target_fn(instance, solution, false)
		
		println("\tNaive target function: $naive_fn")
		println("\tALNS target function: $alns_fn")
		
		push!(results[idx], alns_fn)
	end
end

[println("$(mean(r))\t$(std(r))") for r in results]