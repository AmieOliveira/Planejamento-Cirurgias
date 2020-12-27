using CSV, DataFrames, Printf
using Debugger

include("helper.jl")
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
# -- constants
days = 5
penalties = [90, 20, 8, 3] 
# -- paths
data_dir = "../Dados/tests/"
data_root = "4_inst"    # "fullrand_s20_p1-4_w0-15_t4-16_e5_g8"
out_dir = "Soluções/"
# -- load instance parameters
surgeries = load_surgeries("$(data_dir)$(data_root).csv") 
rooms = 2

# Solution set up
instance = (surgeries, rooms, days, penalties)
solution = solve(instance, verbose=false)
print_solution(instance, solution)
solution_to_csv("../Dados/tmp_solution.csv", instance, solution)

println("")
println("Scheduling costs: ")
fn = target_fn(instance, solution, true)
println("Target function: ", fn)

# bad = badly_scheduled(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-greedy", out_dir, data_root))

#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#solution = random_removal(instance, solution)
#print_solution(instance, solution)
#fn = target_fn(instance, solution)
#println("")
#println("Target function: ", fn)

# solution = Debugger.@run alns_solve(instance, solution, SA_max=10, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=15)
# sc_d, sc_r, sc_h = solution
# println("ALNS solution:", solution)
# print_solution(instance, solution)
# println("")
# println("Scheduling costs: ")
# fn = target_fn(instance, (sc_d, sc_r, sc_h), true)
# println("Target function: ", fn)
# bad = badly_scheduled(surgeries, solution)
# plot_solution(instance, solution, @sprintf("%s%s-alns", out_dir, data_root))

# function timeNaive()
#     @time solve(instance, verbose=false)
# end

# function timeALNS()
#     @time alns_solve(instance, solution, SA_max=10, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=15)
# end