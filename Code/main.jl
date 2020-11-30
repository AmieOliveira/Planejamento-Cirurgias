using CSV, DataFrames
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
DAYS = 5
PENALTIES = [90, 20, 5, 1]
surgeries = load_surgeries("../Dados/toy1.csv")
rooms = 2
# println("SURGERIES")
# display(surgeries)
# println("ROOMS: ", rooms)

# solve instance
sc_d, sc_r, sc_h = solve(surgeries, rooms, DAYS, verbose=false)
println("")
print_solutions(surgeries, rooms, sc_d, sc_r, sc_h)

# evaluate target function
target_fn = eval_solution(surgeries, rooms, PENALTIES, sc_d, sc_r, sc_h)
println("")
println("Target function: ", target_fn)