using Random
include("helper.jl")

function random_removal!(instance, solution)
    surgeries, rooms = instance
    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)

    qt_to_remove = rand(0:2)
    for _ in 1:qt_to_remove
        if length(scheduled_surgeries) == 0
            return solution
        end

        pos_to_del = rand(1:length(scheduled_surgeries))

        sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

        solution = unschedule_surgery(instance, solution, scheduled_surgeries[pos_to_del])
        deleteat!(scheduled_surgeries, pos_to_del)
    end

    solution
end

function worst_removal_single!(instance, solution)
    surgeries, rooms = instance
    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)
    
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    worst_surgery = first(scheduled_surgeries)
    worst_val = 0
        
    for surgery in scheduled_surgeries
        val = eval_surgery(surgery, rooms, sc_d[surgery[IDX_S]], false)

        if val > worst_val
            worst_surgery = surgery
            worst_val = val
        end
    end

    solution = unschedule_surgery(instance, solution, worst_surgery)

    return solution
end

function worst_removal_multiple!(instance, solution)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)
    max_qt = length(scheduled_surgeries) / 5
    qt_to_remove = rand(0:max_qt)

    for _ in 1:qt_to_remove
        solution = worst_removal_single!(instance, solution)
    end

    return solution
end

function shaw_removal_day!(instance, solution; verbose=false)
    # Por enquanto estou fazendo totalmente aleatorio, mas poderia utilizar o valor da 
    # FO na escolha
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    # Sortiar um dia e uma sala
    dia = rand(1:DAYS)
    sala = rand(1:rooms)
    if verbose
        println("Removendo cirurgias do dia ", dia, " na sala ", sala)
        #println("Slots em sc_ts: ", sc_ts[dia, sala])
    end

    slots = copy(sc_ts[dia, sala])
    
    # NOTE: Talvez eu queira deixar de uma maneira que nao dependesse da 
    #   estrutura de dados?
    for slot in slots
        #println(slot)
        s = filter(x -> x[IDX_S] == slot[SLOT_S], surgeries)[1]
        unschedule_surgery(instance, solution, s)
    end

    return solution
end

function shaw_removal_doc!(instance, solution; verbose=false)
    # Por enquanto estou fazendo totalmente aleatorio, mas poderia utilizar o valor da 
    # FO na escolha
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)

    i = rand(1:length(scheduled_surgeries))

    # NOTE: Talvez eu queira deixar de uma maneira que nao dependesse da 
    #   estrutura de dados?
    doc = scheduled_surgeries[i][SURGEON_S]

    to_delete = filter(x -> x[SURGEON_S] == doc, scheduled_surgeries)
    if verbose
        println("Removing surgeries from doctor ", doc)
        #println("\tSet of surgeries: ")
    end

    for s in to_delete
        unschedule_surgery(instance, solution, s)
    end

    # FIXME: Será que seria melhor fazer pelo proprio numero de cirurgioes? 
    #   (Funcao get_number_of_surgeons)
    #   Da forma implementada introduzo uma tendencia (cirurgioes com mais 
    #   cirurgias sao mais selecionados), mas talvez seja uma tendencia boa

    return solution
end

function shaw_removal_esp!(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    # Sortiar um dia e uma sala
    dia = rand(1:DAYS)
    sala = rand(1:rooms)
    if verbose
        println("Removendo cirurgias do dia ", dia, " na sala ", sala)
        #println("Slots em sc_ts: ", sc_ts[dia, sala])
    end

    slots = copy(sc_ts[dia, sala])

    # NOTE: Talvez eu queira deixar de uma maneira que nao dependesse da 
    #   estrutura de dados?
    for slot in slots
        #println(slot)
        s = filter(x -> x[IDX_S] == slot[SLOT_S], surgeries)[1]
        unschedule_surgery(instance, solution, s)
    end

    esp = e[dia, sala]

    # Get another day/room with same specialty
    same = []
    L = 0
    for d in 1:DAYS
        for r in 1:rooms
            if e[d,r] == esp && (d ≠ dia || r ≠ sala)
                push!(same, [d, r])
                L += 1
            end
        end
    end

    if L ≠ 0
        rIdx = rand(1:L)

        ndia, nsala = same[rIdx]
        if verbose
            println("Removendo cirurgias do dia ", ndia, " na sala ", nsala)
        end
    

        slots = copy(sc_ts[ndia, nsala])

        for slot in slots
            #println(slot)
            s = filter(x -> x[IDX_S] == slot[SLOT_S], surgeries)[1]
            unschedule_surgery(instance, solution, s)
        end
    else
        if verbose
            println("Apenas um dia com especialidada. Comportamento como shaw_day")
        end
    end

    return solution
end

# o Que mais?

function greedy_insertion_single!(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    unscheduled_surgeries = get_unscheduled_surgeries(solution, surgeries)
    sort!(unscheduled_surgeries, lt = (x, y) -> is_more_prioritary(x, y))

    for surgery in unscheduled_surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        if !can_surgeon_fit_surgery_in_week(instance, solution, surgery)
            continue
        end

        scheduled = false

        for d in 1:DAYS
            if scheduled
                break
            end
            if !can_surgeon_fit_surgery_in_day(instance, solution, surgery, d)
                continue
            end

            for r in 1:rooms
                if scheduled
                    break
                end
                free_timeslots = get_free_timeslots(instance, solution, r, d)

                for (timeslot_start, timeslot_end) in free_timeslots
                    if scheduled
                        break
                    end
                    if !can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, d, timeslot_start, timeslot_end)
                        continue
                    end

                    if e[d, r] == e_s || e[d, r] == 0
                        if timeslot_end == LENGTH_DAY
                            if timeslot_start + t_s - 1 <= LENGTH_DAY
                                solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                                return solution
                                scheduled = true

                                if verbose
                                    println("DEGUB:\t\tGreedy Insertion: Scheduled surgery ", 
                                            surgery[IDX_S])
                                end
                                break
                            end
                        elseif t_s + LENGTH_INTERVAL <= (timeslot_end - timeslot_start + 1)
                            solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                            return solution
                            scheduled = true

                            if verbose
                                println("DEGUB:\t\tGreedy Insertion: Scheduled surgery ", 
                                        surgery[IDX_S])
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    return solution
end

function greedy_insertion_multiple!(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    unscheduled_surgeries = get_unscheduled_surgeries(solution, surgeries)
    max_qt = length(unscheduled_surgeries) / 5
    qt_to_insert = rand(0:max_qt)

    for _ in 1:qt_to_insert
        solution = greedy_insertion_single!(instance, solution)
    end

    return solution
end

function random_insertion!(instance, solution; verbose=false)
    surgeries, rooms = instance
    unsc_surgeries = get_unscheduled_surgeries(solution, surgeries)
    L = length(unsc_surgeries)
    
    if L == 0
        if verbose
            println("WARNING:\tRandom Insertion: No surgeries to add")
        end
        return solution
    end

    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    shuffle!(unsc_surgeries)    # order array randomly

    for surgery in unsc_surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        if !can_surgeon_fit_surgery_in_week(instance, solution, surgery)
            continue
        end

        scheduled = false

        for d in 1:DAYS
            if scheduled
                break
            end
            if !can_surgeon_fit_surgery_in_day(instance, solution, surgery, d)
                continue
            end

            for r in 1:rooms
                if scheduled
                    break
                end
                free_timeslots = get_free_timeslots(instance, solution, r, d)

                for (timeslot_start, timeslot_end) in free_timeslots
                    if scheduled
                        break
                    end
                    if !can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, d, timeslot_start, timeslot_end)
                        continue
                    end

                    if e[d, r] == e_s || e[d, r] == 0
                        if timeslot_end == LENGTH_DAY
                            if timeslot_start + t_s - 1 <= LENGTH_DAY
                                solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                                scheduled = true

                                if verbose
                                    println("DEGUBG:\t\tRandom Insertion: Scheduled surgery ", 
                                            surgery[IDX_S])
                                end
                                break
                            end
                        elseif t_s + LENGTH_INTERVAL <= (timeslot_end - timeslot_start + 1)
                            solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                            scheduled = true

                            if verbose
                                println("DEGUBG:\t\tRandom Insertion: Scheduled surgery ", 
                                        surgery[IDX_S])
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    return solution
end

# TODO: insercao por arrependimento
# o que mais?

function removal(instance, solution, weights)
    solution = solution
    
    probs = map(x -> x / sum(weights), weights)
    selected_idx = roulette(probs)

    _, fn = REMOVAL_OPERATORS[selected_idx]
    return (selected_idx, fn(instance, solution))
end

function insertion(instance, solution, weights)
    solution = solution
    
    probs = map(x -> x / sum(weights), weights)
    selected_idx = roulette(probs)

    _, fn = INSERTION_OPERATORS[selected_idx]
    return (selected_idx, fn(instance, solution))
end

REMOVAL_OPERATORS = [
    ("random   ", random_removal!),
    ("worst single", worst_removal_single!),
    ("worst multiple", worst_removal_multiple!),
    ("shaw_day", shaw_removal_day!),
    ("shaw_surgeon", shaw_removal_doc!),
    ("shaw_specialty", shaw_removal_esp!)
]

INSERTION_OPERATORS = [
    ("random    ", random_insertion!),
    ("greedy single", greedy_insertion_single!),
    ("greedy multiple", greedy_insertion_multiple!)
]

function alns_solve(instance, initial_solution; SA_max, α, T0, Tf, r, σ1, σ2, σ3, verbose=false)
    s = clone_sol(initial_solution)
    s_best = clone_sol(initial_solution)

    fo_s = target_fn(instance, s)
    fo_best = fo_s

    iter = 0
    T = T0

    rem_ops, ins_ops = length(REMOVAL_OPERATORS), length(INSERTION_OPERATORS)
    rem_weights, ins_weights = ones(rem_ops), ones(ins_ops)

    while T > Tf    # TODO: Aquelas coisas de criterio de parada?
        rem_scores, ins_scores = zeros(rem_ops), zeros(ins_ops)
        rem_freq, ins_freq = ones(rem_ops), ones(ins_ops)

        print("T > Tf: $(round(T, digits=3)) > $(Tf)")
        print("\t best: $(fo_best), curr: $(fo_s)")
        println("")

        while iter < SA_max
            iter += 1

            rem_idx, s2 = removal(instance, clone_sol(s), rem_weights)
            ins_idx, s2 = insertion(instance, s2, ins_weights)

            rem_freq[rem_idx] += 1
            ins_freq[ins_idx] += 1

            fo_curr = target_fn(instance, s2)

            ∆ = fo_curr - fo_s

            if ∆ < 0                
                s = clone_sol(s2)
                fo_s = fo_curr
                if fo_curr < fo_best
                    s_best = clone_sol(s2)
                    fo_best = fo_curr
                    rem_scores[rem_idx] += σ1
                    ins_scores[ins_idx] += σ1
                else
                    rem_scores[rem_idx] += σ2
                    ins_scores[ins_idx] += σ2
                end
            elseif rand(Float64) < ℯ^(-∆/T)
                s = clone_sol(s2)
                fo_s = fo_curr
                rem_scores[rem_idx] += σ3
                ins_scores[ins_idx] += σ3
            end
        end

        T = α * T
        iter = 0

        for i in 1:length(rem_weights)
            rem_weights[i] = (1 - r) * rem_weights[i] + r * (rem_scores[i] / rem_freq[i])
        end
        for i in 1:length(ins_weights)
            ins_weights[i] = (1 - r) * ins_weights[i] + r * (ins_scores[i] / ins_freq[i])
        end

        if verbose
            println("REMOVALS\t\tfreq\tscores")
            for (idx, r_op) in enumerate(REMOVAL_OPERATORS)
                name, fn = r_op
                println("\t$name\t$(rem_freq[idx])\t$(rem_scores[idx])") 
            end

            println("INSERTIONS\t\tfreq\tscores")
            for (idx, i_op) in enumerate(INSERTION_OPERATORS)
                name, fn = i_op
                println("\t$name\t$(ins_freq[idx])\t$(ins_scores[idx])") 
            end
        end
    end

    s_best
end