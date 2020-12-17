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

# Paths
data_dir = "Dados/"
out_dir = "Soluções/"

# load instance parameters
data_root = "toy2"    # "fullrand_s20_p1-4_w0-15_t4-16_e5_g8"
rooms = 2
days = 5
penalties = [900, 200, 50, 10] #TODO: these priorities were tweaked. should confirm
surgeries = load_surgeries(@sprintf("%s%s.csv", data_dir, data_root)) 

# Solution set up
instance = (surgeries, rooms, days, penalties)

solution = solve(instance, verbose=false)
# TODO: criar dentro dos solvers - room_specialties = zeros(Int, (rooms, days))        # Vetor com as especialidades das salas pelos dias

print_solution(instance, solution)
println("")
println("Scheduling costs: ")
fn = target_fn(instance, solution, true)
println("Target function: ", fn)
bad = badly_scheduled(surgeries, solution)
plot_solution(instance, solution, @sprintf("%s%s-greedy", out_dir, data_root))

solution = random_removal(instance, solution)
solution = random_removal(instance, solution)
solution = random_removal(instance, solution)
print_solution(instance, solution)
fn = target_fn(instance, solution)
println("")
println("Target function: ", fn)

solution = Debugger.@run alns_solve(instance, solution, SA_max=10, α=0.9, T0=60, Tf=1, r=0.4, σ1=10, σ2=5, σ3=15)
sc_d, sc_r, sc_h = solution
println("ALNS solution:", solution)
print_solution(instance, solution)
println("")
println("Scheduling costs: ")
fn = target_fn(instance, (sc_d, sc_r, sc_h), true)
println("Target function: ", fn)
bad = badly_scheduled(surgeries, solution)
plot_solution(instance, solution, @sprintf("%s%s-alns", out_dir, data_root))
