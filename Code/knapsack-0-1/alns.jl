using Random

function target_fn(solution, elements)
    reduce(+, map((x) -> elements[x][1], solution))
end

function get_weight(solution, elements)
    if length(solution) == 0
        return 0
    end
    
    reduce(+, map((x) -> elements[x][2], solution))
end

function random_removal(solution, elements, capacity)
    qt_to_remove = rand(0:min(2, length(solution)))
    for _ in 1:qt_to_remove        
        pos_to_del = rand(1:length(solution))
        deleteat!(solution, pos_to_del)
    end

    solution
end

function worst_removal(solution, elements, capacity)
    weights = map((x) -> elements[x][2], solution)
    largest_weight_pos = findmax(weights)[2]
    deleteat!(solution, largest_weight_pos)
    
    solution
end

# TODO
# function shaw_removal(solution, elements, capacity)
#     weights = map((x) -> elements[x][1], solution)
#     largest_weight_pos = findmax(weights)[2]
#     deleteat!(solution, largest_weight_pos)
    
#     solution
# end

function removal(solution, elements, capacity, weights)
    solution = copy(solution)
    
    roulette = map(x -> x / sum(weights), weights)
    dice = rand(Float64)

    if dice < roulette[1]
        return (1, random_removal(solution, elements, capacity))
    else
        return (2, worst_removal(solution, elements, capacity))
    end
end

function greedy_insertion(solution, elements, capacity)
    curr_weight = get_weight(solution, elements)
    candidates = filter(i -> i ∉ solution, 1:length(elements))
    sort!(candidates, by = x -> elements[x][1], rev=true)

    for candidate in candidates
        p, w = elements[candidate]

        if (curr_weight + w) <= capacity
            push!(solution, candidate)
            curr_weight += w
        end
    end
    
    solution
end

function insertion(solution, elements, capacity, weights)
    solution = copy(solution)
    
    solution = greedy_insertion(solution, elements, capacity)

    (1, solution)
end

function solve_alns(elements, capacity; SA_max, α, T0, Tf, r, σ1, σ2, σ3, s)
    s_best = copy(s)
    iter = 0
    T = T0
    
    op_rem_w = [1.0, 1.0]
    op_ins_w = [1.0]

    while T > Tf
        op_rem_s = [0, 0]
        op_ins_s = [0]
        op_rem_freq = [1, 1]
        op_ins_freq = [1]

        # println("T > Tf: ", T, " > ", Tf)
        # println("----")

        while iter < SA_max
            # println("iter < SA_max: ", iter, " < ", SA_max)
            iter += 1

            # println("\ts: \t\t\t", s)
            rem_idx, s2 = removal(s, elements, capacity, op_rem_w)
            # println("\t-> removal: \t", s2)
            ins_idx, s2 = insertion(s2, elements, capacity, op_ins_w)
            # println("\t-> insertion: \t", s2)

            op_rem_freq[rem_idx] += 1
            op_ins_freq[ins_idx] += 1

            ∆ = target_fn(s2, elements) - target_fn(s, elements)
            # println("s2: ", map((x) -> elements[x], s2), ", target_fn: ", target_fn(s2, elements))
            # println("s: ", map((x) -> elements[x], s), ", target_fn: ", target_fn(s, elements))

            if ∆ > 0 # se s2 é melhor que s, sempre aceita
                s = copy(s2)
                if target_fn(s2, elements) > target_fn(s_best, elements) # se s2 é a melhor solução já vista
                    # println("\t\ts2: ", map((x) -> elements[x], s2), ", target_fn: ", target_fn(s2, elements))
                    # println("\t\ts_best: ", map((x) -> elements[x], s_best), ", target_fn: ", target_fn(s_best, elements))
                    # println("\t\t---")
                    s_best = copy(s2)
                    op_rem_s[rem_idx] += σ1
                    op_ins_s[ins_idx] += σ1
                else
                    op_rem_s[rem_idx] += σ2
                    op_ins_s[ins_idx] += σ2
                end
            elseif rand(Float64) < ℯ^(-∆/T) # se s2 não é melhor que s, aceita aleatoriamente
                s = copy(s2)
                op_rem_s[rem_idx] += σ3
                op_ins_s[ins_idx] += σ3
            end
        end

        T = α * T
        iter = 0

        for i in 1:length(op_rem_w)
            op_rem_w[i] = (1 - r) * op_rem_w[i] + r * (op_rem_s[i] / op_rem_freq[i])
        end
        for i in 1:length(op_ins_w)
            op_ins_w[i] = (1 - r) * op_ins_w[i] + r * (op_ins_s[i] / op_ins_freq[i])
        end
    end

    return s_best
end