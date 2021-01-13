using DataFrames, Printf, PyCall
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

# setup
# -- paths
data_dir = "Dados/"
# data_dir = "../Dados/"

# data_root = "randomFit_r2_s15_t8-4"
# data_root = "randomFit_r2_s15_t16-4"
# data_root = "randomFit_r2_s50_t8-4"
# data_root = "randomFit_r2_s50_t16-4"
# data_root = "randomFit_r5_s100_t8-4"
# data_root = "randomFit_r5_s100_t16-4"
# data_root = "fullrand_s50_p1-4_w20_t6-20_e4_g12"
# data_root = "Indefinidas - i8"
# data_root = "Indefinidas - i9"
data_root = "Indefinidas - i10"
# data_root = "Indefinidas - i11"
# data_root = "fullrand_s70_p1-4_w20_t5-20_e5_g20"
# data_root = "fullrand_s70_p1-4_w30_t5-20_e3_g15"
# data_root = "fullrand_s90_p1-4_w20_t6-20_e5_g20"

out_dir = "Soluções/"
# out_dir = "../Soluções/"

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
#bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-greedy", out_dir, data_root))
solution_to_csv("$(data_dir)sol-greedy_$(data_root).csv", instance, solution)

solution, history = @time alns_solve(instance, solution, SA_max=1000, α=0.95, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=1, verbose=true)
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

# bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, "$(out_dir)$(data_root)-alns")

# try
# 	cd("./Code")
# catch IOError
# end
# pushfirst!(PyVector(pyimport("sys")["path"]), pwd())
# myploter = pyimport("plot_maker")
# # TODO: Function not finished
# myploter.plot_per_day(instance, solution, naive_fn)