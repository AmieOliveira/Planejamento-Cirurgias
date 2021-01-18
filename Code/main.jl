using DataFrames, Printf, PyCall
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

# setup
# -- paths
data_dir = "Dados/"
data_root, rooms = "fullrand_s70_p1-4_w20_t5-20_e5_g20", 3
out_dir = "Soluções/"

# -- load instance parameters
surgeries = load_surgeries("$(data_dir)$(data_root).csv")

# Solution set up
instance = (surgeries, rooms)
solution = solve(instance, verbose=false)
print_solution(instance, solution)

println("")
println("Scheduling costs: ")
naive_fn = target_fn(instance, solution, true)
println("Target function: ", naive_fn)
solution_to_csv("$(data_dir)sol-greedy_$(data_root).csv", instance, solution)

solution, history = @time alns_solve(instance, solution, SA_max=1000, α=0.95, T0=60, Tf=1, r=0.1, σ1=10, σ2=5, σ3=1, verbose=true)
print_solution(instance, solution)
solution_to_csv("$(data_dir)sol-alns_$(data_root).csv", instance, solution)

println("")
println("Scheduling costs: ")
alns_fn = target_fn(instance, solution, true)
println("Target function: ", alns_fn)

println("")
println("Naive target function: $naive_fn")
println("ALNS target function:  $alns_fn")

println("history: $history")
plot_operator_history(history)