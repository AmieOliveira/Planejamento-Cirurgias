using CSV, DataFrames, Printf
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

# setup
# -- paths
# data_dir = "Dados/"
# data_root = "toy1"    # "fullrand_1000cirurgias"
data_dir = "../Dados/"
# data_root = "fullrand_1000cirurgias"
data_root = "fullrand_s50_p1-4_w40_t2-20_e10_g20"
# data_root = "fullrand_s70_p1-4_w1-20_t2-20_e4_g10"
# data_root = "fullrand_s100_p1-4_w40_t2-10_e20_g20"

out_dir = "../Soluções/"

# -- load instance parameters
surgeries = load_surgeries("$(data_dir)$(data_root).csv") 
rooms = 10

# Solution set up
instance = (surgeries, rooms)
solution = solve(instance, verbose=false)
print_solution(instance, solution)

println("")
println("Scheduling costs: ")
naive_fn = target_fn(instance, solution, true)
println("Target function: ", naive_fn)
# bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-greedy", out_dir, data_root))
solution_to_csv("../Dados/tmp_solution.csv", instance, solution)

#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#print_solution(instance, solution)
#fn = target_fn(instance, solution)
#println("")
#println("Target function: ", fn)

solution, history = @time alns_solve(instance, solution, 
		                             SA_max=1000, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=1,
		                             verbose=true)
print_solution(instance, solution)
solution_to_csv("../Dados/tmp_solution.csv", instance, solution)

println("")
println("Scheduling costs: ")
alns_fn = target_fn(instance, solution, true)
println("Target function: ", alns_fn)

println("")
println("Naive target function: $naive_fn")
println("ALNS target function:  $alns_fn")

println("history: $history")
plot_operator_history(history)

# bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-alns", out_dir, data_root))