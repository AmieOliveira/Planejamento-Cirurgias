using CSV, DataFrames
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

# load instance parameters
days = 5
penalties = [900, 200, 50, 10] #TODO: these priorities were tweaked. should confirm
surgeries = load_surgeries("Dados/toy1.csv") # ("../Dados/toy1.csv")
rooms = 1

instance = (surgeries, rooms, days, penalties)

solution = solve(instance, verbose=false)

print_solution(instance, solution)
fn = target_fn(instance, solution)
println("")
println("Target function: ", fn)

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
fn = target_fn(instance, (sc_d, sc_r, sc_h))
println("")
println("Target function: ", fn)