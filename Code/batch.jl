using CSV, DataFrames, Printf
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

data_dir = "../Dados/"
files = [
	("toy1", 1),
	("toy2", 1),
	("toy4", 1),
	("fullrand_s50_p1-4_w20_t2-10_e5_g10", 4),
	("fullrand_s50_p1-4_w20_t2-10_e5_g20", 4),
	("fullrand_s50_p1-4_w20_t2-10_e5_g20", 5),
	("fullrand_s50_p1-4_w40_t2-20_e10_g20", 6),
	("fullrand_s70_p1-4_w40_t2-10_e10_g10", 10),
	("fullrand_s70_p1-4_w40_t2-10_e20_g20", 10),
	("fullrand_s100_p1-4_w40_t2-10_e20_g20", 10),
]

results = []

for (filename, rooms) in files
	println("$filename:")

	local surgeries = load_surgeries("$(data_dir)$(filename).csv") 
	local instance = (surgeries, rooms)

	local solution = solve(instance, verbose=false)
	local naive_fn = target_fn(instance, solution, false)
	println("\tNaive target function: $naive_fn")

	local solution, history = alns_solve(instance, solution, 
			                             SA_max=1000, α=0.95, T0=60, Tf=1, r=0.1, σ1=1, σ2=0, σ3=5,
			                             verbose=false)
	local alns_fn = target_fn(instance, solution, false)

	println("\tALNS target function:  $alns_fn")

	push!(results, "$naive_fn\t$alns_fn")
end

println(results)