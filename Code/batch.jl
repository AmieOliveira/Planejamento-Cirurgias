using CSV, DataFrames, Printf
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

data_dir = "../Dados/"
files = [
	("fullrand_s50_p1-4_w20_t2-10_e5_g10", 4),
	("fullrand_s50_p1-4_w40_t2-20_e10_g20", 4),
	("fullrand_s50_p1-4_w40_t2-20_e10_g20", 5)
]

for (filename, rooms) in files
	println("$filename:")

	surgeries = load_surgeries("$(data_dir)$(filename).csv") 
	instance = (surgeries, rooms)

	solution = solve(instance, verbose=false)
	naive_fn = target_fn(instance, solution, false)

	solution = @time alns_solve(instance, solution, 
                            SA_max=1000, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=1,
                            verbose=false)
	alns_fn = target_fn(instance, solution, false)

	solution_to_csv("../Dados/$(filename)_solution.csv", instance, solution)

	println("\tNaive target function: $naive_fn")
	println("\tALNS target function:  $alns_fn")
end