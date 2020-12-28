using CSV, DataFrames, Printf
using Debugger

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

function load_surgeries(filepath)
    surgeries = []
    for row in CSV.File(filepath)
        surgery = (row[1], row[2], row[3], row[4], row[5], row[6])
        push!(surgeries, surgery)
    end
    surgeries
end

# setup
# -- paths
data_dir = "Dados/"
# data_dir = "../Dados/"
data_root = "toy1"    # "fullrand_1000cirurgias"

out_dir = "Soluções/"

# -- load instance parameters
surgeries = load_surgeries("$(data_dir)$(data_root).csv") 
rooms = 2

# Solution set up
instance = (surgeries, rooms)
solution = solve(instance, verbose=false)
print_solution(instance, solution)

println("")
println("Scheduling costs: ")
fn = target_fn(instance, solution, true)
println("Target function: ", fn)
# bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-greedy", out_dir, data_root))

#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#print_solution(instance, solution)
#fn = target_fn(instance, solution)
#println("")
#println("Target function: ", fn)

solution = @time alns_solve(instance, solution, SA_max=10, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=15)
print_solution(instance, solution)
solution_to_csv("../Dados/tmp_solution.csv", instance, solution)

println("")
println("Scheduling costs: ")
fn = target_fn(instance, solution, true)
println("Target function: ", fn)
# bad = get_badly_scheduled_surgeries(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-alns", out_dir, data_root))