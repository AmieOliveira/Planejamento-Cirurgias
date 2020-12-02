include("dynamic.jl")
include("alns.jl")

# elements are in (profit, weight) tuples
problems = [
    Dict(
        :capacity => 6,
        :elements => [(1, 2), (3, 3), (5, 1), (2, 5), (6, 3), (10, 5)],
        :optimal_profit => 15
    ),
    Dict(
        :capacity => 170,
        :elements => [(442, 41), (525, 50), (511, 49), (593, 59), 
            (546, 55), (564, 57), (617, 60)],
        :optimal_profit => 1735
    ),
    Dict(
        :capacity => 750,
        :elements => [(135, 70), (139, 73), (149, 77), (150, 80), (156, 82),
            (163, 87), (173, 90), (184, 94), (192, 98), (201, 106), (210, 110),
            (214, 113), (221, 115), (229, 118), (24, 120)],
        :optimal_profit => 1458
    ),
    Dict(
        :capacity => 6404180,
        :elements => [(825594, 382745), (1677009, 799601), (1676628, 909247),
            (1523970, 729069), (943972, 467902), (97426, 44328), (69666, 34610),
            (1296457, 698150), (1679693, 823460), (1902996, 903959), (1844992, 853665),
            (1049289, 551830), (1252836, 610856), (1319836, 670702), (953277, 488960),
            (2067538, 951111), (675367, 323046), (853655, 446298), (1826027, 931161),
            (65731, 31385), (901489, 496951), (577243, 264724), (466257, 224916),
            (369261, 169684)],
        :optimal_profit => 13549094
    )
]

for problem in problems
    println("problem: ", problem)
    println("----------")
    # println("> dynamic:")
    # local S, m = solve_dynamic(problem[:elements], problem[:capacity])
    # println("\tsolution: ", map((x) -> problem[:elements][x], S[findmax(m)[2]]))
    # println("\ttarget fn: ", findmax(m)[1])

    println("> alns:")
    solution = []
    weight = 0
    for (i, element) in enumerate(problem[:elements])
        p, w = element
        if weight + w < problem[:capacity]
            push!(solution, i)
            weight += w
        end
    end
    println("\tinitial solution:", solution)
    println("\tinitial target fn: ", reduce(+, map((x) -> problem[:elements][x][1], solution)))
    
    solution = solve_alns(problem[:elements], problem[:capacity],
        SA_max=1000, α=0.99, T0=60, Tf=10e-6, r=0.4, σ1=10, σ2=5, σ3=15, s=solution)
    println("\tsolution: ", map((x) -> problem[:elements][x], solution))
    println("\ttarget fn: ", reduce(+, map((x) -> problem[:elements][x][1], solution)))
    println("\toptimal profit: ", problem[:optimal_profit])

    println("")
end