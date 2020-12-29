using Random
include("helper.jl")

function random_removal(instance, solution)
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

function worst_removal(instance, solution)
    surgeries, rooms = instance
    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)
    
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    # qt_to_remove ?

    wIdx = 1
    wValue = eval_surgery(scheduled_surgeries[1], rooms, sc_d[scheduled_surgeries[1][IDX_S]], false)
    
    for i in 2:length(scheduled_surgeries)
        v = eval_surgery(scheduled_surgeries[i], rooms, sc_d[scheduled_surgeries[i][IDX_S]], false)

        if v > wValue
            wIdx = i
            wValue = v
        end
    end

    ret = unschedule_surgery(instance, solution, scheduled_surgeries[wIdx])
    # addedValue = eval_surgery(scheduled_surgeries[wIdx], rooms, 
    #                           sc_d[scheduled_surgeries[wIdx][IDX_S]], false)

    return ret
end

function shaw_removal_day(instance, solution; verbose=false)
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

function shaw_removal_doc(instance, solution; verbose=false)
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

function shaw_removal_esp(instance, solution; verbose=false)
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

# TODO: insert as many as possible?
function greedy_insertion(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    unscheduled_surgeries = get_unscheduled_surgeries(solution, surgeries)
    sort!(unscheduled_surgeries, lt = (x, y) -> !is_more_prioritary(x, y))

    if verbose
        println("Unscheduled surgeries: ", unscheduled_surgeries)
    end

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
                        if t_s + 2 <= (timeslot_end - timeslot_start + 1)
                            if timeslot_start + t_s - 1 <= 46
                                solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                                scheduled = true

                                if verbose
                                    println("Scheduled surgery ", surgery[IDX_S])
                                end
                                break
                                #return solution
                            end
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

    if selected_idx == 1
        return (1, random_removal(instance, solution))
    elseif selected_idx == 2
        return (2, worst_removal(instance, solution))
    elseif selected_idx == 3
        return (3, shaw_removal_day(instance, solution))
    elseif selected_idx == 4
        return (4, shaw_removal_doc(instance, solution))
    elseif selected_idx == 5
        return (5, shaw_removal_esp(instance, solution))
    else
        println("This should not be happening.")
        error
    end

    print("Removal ", selected_idx, " used")
end

function insertion(instance, solution, weights)
    solution = solution
    
    probs = map(x -> x / sum(weights), weights)
    selected_idx = roulette(probs)

    if selected_idx == 1
        return (1, greedy_insertion(instance, solution))
    else
        println("This should not be happening.")
        error
    end
end

function alns_solve(instance, initial_solution; SA_max, α, T0, Tf, r, σ1, σ2, σ3, verbose=false)
    s = clone_sol(initial_solution)
    s_best = clone_sol(initial_solution)

    fo_s = target_fn(instance, s)
    fo_best = fo_s

    iter = 0
    T = T0

    rem_ops, ins_ops = 5, 1
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
            println("Uso dos operadores de remoção: ")
            println("\tVezes: ", rem_freq)
            println("\tPontuação: ", rem_scores)
            println("Uso dos operadores de inserção: ")
            println("\tVezes: ", ins_freq)
            println("\tPontuação: ", ins_scores)
            println("")
        end
    end

    s_best
end