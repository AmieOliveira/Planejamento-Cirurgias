using CSV, DataFrames
using Debugger

include("naive_1.jl")
include("helper.jl")

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
penalties = [90, 20, 5, 1]
surgeries = load_surgeries("../Dados/toy1.csv")
rooms = 1
instance = (surgeries, rooms, days, penalties)
# println("SURGERIES")
# display(surgeries)
# println("ROOMS: ", rooms)

# solve instance
sc_d, sc_r, sc_h = solve(instance, verbose=false)
println("")
print_solutions(instance, sc_d, sc_r, sc_h)

# evaluate target function
fn = target_fn(instance, sc_d, sc_r, sc_h)
println("")
println("Target function: ", fn)

# solve_alns(problem[:elements], problem[:capacity], SA_max=1000, α=0.99, T0=60, Tf=10e-6, r=0.4, σ1=10, σ2=5, σ3=15, s=solution)