using Random
include("helper.jl")

function random_removal_single!(instance, solution)
    surgeries, rooms = instance
    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)

    qt_to_remove = 1
    altered = []

    for _ in 1:qt_to_remove
        if length(scheduled_surgeries) == 0
            return solution
        end

        pos_to_del = rand(1:length(scheduled_surgeries))

        sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
        idx_s, p_s, w_s, e_s, g_s, t_s = scheduled_surgeries[pos_to_del]
        
        push!(altered, (sc_d[idx_s], sc_r[idx_s]))

        solution = unschedule_surgery(instance, solution, scheduled_surgeries[pos_to_del])
        deleteat!(scheduled_surgeries, pos_to_del)
    end

    for (day, room) in unique(altered)
        solution, ok = squeeze_surgeries_up!(instance, solution, day, room)
    end

    solution
end

function random_removal_multiple!(instance, solution)
    surgeries, rooms = instance
    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)

    qt_to_remove = rand(0:3)
    altered = []

    for _ in 1:qt_to_remove
        if length(scheduled_surgeries) == 0
            return solution
        end

        pos_to_del = rand(1:length(scheduled_surgeries))

        sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
        idx_s, p_s, w_s, e_s, g_s, t_s = scheduled_surgeries[pos_to_del]
        
        push!(altered, (sc_d[idx_s], sc_r[idx_s]))

        solution = unschedule_surgery(instance, solution, scheduled_surgeries[pos_to_del])
        deleteat!(scheduled_surgeries, pos_to_del)
    end

    for (day, room) in unique(altered)
        solution, ok = squeeze_surgeries_up!(instance, solution, day, room)
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
        val = eval_surgery(surgery, sc_d[surgery[IDX_S]], false)

        if val > worst_val
            worst_surgery = surgery
            worst_val = val
        end
    end

    day = sc_d[worst_surgery[IDX_S]]
    room = sc_r[worst_surgery[IDX_S]]

    solution = unschedule_surgery(instance, solution, worst_surgery)

    solution, ok = squeeze_surgeries_up!(instance, solution, day, room)

    return solution
end

function worst_removal_multiple!(instance, solution)
    # TODO: refazer para nao chamar a single! 
    #   Isso é tempo de verificacao de todas as cirurgias varias vezes
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

function shaw_removal_day_room!(instance, solution; verbose=false)
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

function shaw_removal_day!(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    scheduled_surgeries = get_scheduled_surgeries(solution, surgeries)
    random_surgery = rand(scheduled_surgeries)
    random_day = sc_d[random_surgery[IDX_S]]

    surgeries_to_remove = get_surgeries_scheduled_to_day(instance, solution, random_day)
    for surgery in surgeries_to_remove
        solution = unschedule_surgery(instance, solution, surgery)
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

    altered = []

    for s in to_delete
        sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
        idx_s, p_s, w_s, e_s, g_s, t_s = s

        push!(altered, (sc_d[idx_s], sc_r[idx_s]))

        unschedule_surgery(instance, solution, s)
    end

    for (day, room) in unique(altered)
        solution, ok = squeeze_surgeries_up!(instance, solution, day, room)
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
                                    println("DEBUG:\t\tGreedy Insertion: Scheduled surgery ", 
                                            surgery[IDX_S])
                                end
                                break
                            end
                        elseif t_s + LENGTH_INTERVAL <= (timeslot_end - timeslot_start + 1)
                            solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
                            return solution
                            scheduled = true

                            if verbose
                                println("DEBUG:\t\tGreedy Insertion: Scheduled surgery ", 
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

function regret_insertion!(instance, solution; verbose=false)
    surgeries, rooms = instance
    unsc_surgeries = get_unscheduled_surgeries(solution, surgeries)
    L = length(unsc_surgeries)
    
    if L == 0
        if verbose
            println("WARNING:\tRegret Insertion: No surgeries to add")
        end
        return solution
    end

    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    ∆f_max = 0
    s_m = nothing
    day_m = nothing
    room_m = nothing
    time_m = nothing

    for surgery in unsc_surgeries
        if !can_surgeon_fit_surgery_in_week(instance, solution, surgery)
            continue
        end

        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        best = 0
        best_2 = 0
        day = 0
        room = 0
        time = 0
        
        # TODO: get best and second best costs
        for d in 1:DAYS
            if best_2 ≠ 0
                break
            end
            if !can_surgeon_fit_surgery_in_day(instance, solution, surgery, d)
                continue
            end

            for r in 1:rooms
                if best_2 ≠ 0
                    break
                end
                if (best ≠ 0) && (d == day)
                    break
                end
                free_timeslots = get_free_timeslots(instance, solution, r, d)

                for (timeslot_start, timeslot_end) in free_timeslots
                    if best_2 ≠ 0
                        break
                    end
                    
                    if !can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, d, timeslot_start, timeslot_end)
                        continue
                    end

                    if e[d, r] == e_s || e[d, r] == 0
                        if timeslot_end == LENGTH_DAY
                            if timeslot_start + t_s - 1 <= LENGTH_DAY
                                if best == 0
                                    best = eval_surgery(surgery, d, false)
                                    day = d
                                    room = r
                                    time = timeslot_start
                                else
                                    best_2 = eval_surgery(surgery, d, false)
                                end
                                break
                            end
                        elseif t_s + LENGTH_INTERVAL <= (timeslot_end - timeslot_start + 1)
                            if best == 0
                                best = eval_surgery(surgery, d, false)
                                day = d
                                room = r
                                time = timeslot_start
                            else
                                best_2 = eval_surgery(surgery, d, false)
                            end
                            break
                        end
                    end
                end
            end
        end

        if (best ≠ 0) && (best_2 == 0)
            best_2 = eval_surgery(surgery, nothing, false)

            if verbose
                println("DEBUG:\t\tRegret Insertion: No second day to fit surgery ",
                        idx_s, ". Cost is the cost of not scheduling.")
            end
        end

        ∆f = best_2 - best
        if ∆f > ∆f_max
            ∆f_max = ∆f
            s_m = surgery
            day_m = day
            room_m = room
            time_m = time

            if verbose
                println("VERBOSE:\tRegret Insertion: Surgery ", idx_s, " has the ",
                        "highest gap: ", ∆f)
            end
        end
    end

    if !(s_m === nothing)
        if verbose
            println("DEGUBG:\t\tRegret Insertion: Scheduled surgery ", s_m[IDX_S])
        end
        return schedule_surgery(instance, solution, s_m, day_m, room_m, time_m)
    else
        if verbose
            println("WARNING:\tRegret Insertion: Cannot add any surgery")
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
    ("random single", random_removal_single!),
    ("random multiple", random_removal_multiple!),
    ("worst single", worst_removal_single!),
    ("worst multiple", worst_removal_multiple!),
    ("shaw day", shaw_removal_day!),
    ("shaw day room", shaw_removal_day_room!),
    ("shaw surgeon", shaw_removal_doc!),
    ("shaw specialty", shaw_removal_esp!)
]

INSERTION_OPERATORS = [
    ("random    ", random_insertion!),
    ("greedy single", greedy_insertion_single!),
    ("greedy multiple", greedy_insertion_multiple!),
    ("regret", regret_insertion!)
]

function maintain_history(history, target_fn_curr, target_fn_best, rem_scores, ins_scores)
    target_fns_curr, target_fns_best, rem_history, ins_history = history
    push!(target_fns_best, target_fn_best)
    push!(target_fns_curr, target_fn_curr)
    push!(rem_history, rem_scores)
    push!(ins_history, ins_scores)
    return (target_fns_curr, target_fns_best, rem_history, ins_history)
end

function plot_operator_history(history)
    target_fns_curr, target_fns_best, rem_history, ins_history = history
    x = 1:length(rem_history)

    p1, p2, p3 = [plot(legend = :outerright, legendfontsize = 5, legendtitlefontsize=5, titlefontsize=8) for _ in 1:3]
    
    plot(p1, legendtitle="Removal operators", ylabel="Scores")
    for i in 1:length(REMOVAL_OPERATORS)
        plot!(p1, x, [h[i] for h in rem_history], label=REMOVAL_OPERATORS[i][1])
    end

    plot(p2, legendtitle="Insertion operators", ylabel="Scores")
    for i in 1:length(INSERTION_OPERATORS)
        plot!(p2, x, [h[i] for h in ins_history], label=INSERTION_OPERATORS[i][1])
    end

    plot!(p3, x, target_fns_curr, xlabel="Iterations", label="target function (curr)", lw=3)
    plot!(p3, x, target_fns_best, label="target function (best)", lw=3)
    
    plot(p1, p2, p3, layout=(3, 1))
    gui()
end

function alns_solve(instance, initial_solution; 
                    SA_max, SA_max_no_improvement=nothing, 
                    α, T0, Tf, 
                    r, σ1, σ2, σ3, 
                    verbose=false,
                    reheat=false,
                    target=nothing)
    SA_max_no_improvement = something(SA_max_no_improvement, SA_max)
    
    s = clone_sol(initial_solution)
    s_best = clone_sol(initial_solution)

    fo_s = target_fn(instance, s)
    fo_best = fo_s

    iter = 0
    iter_no_improvement = 0
    T = T0

    rem_ops, ins_ops = length(REMOVAL_OPERATORS), length(INSERTION_OPERATORS)
    rem_weights, ins_weights = ones(rem_ops), ones(ins_ops)
    history = ([], [], [], [])

    while T > Tf    # TODO: Aquelas coisas de criterio de parada?
        rem_scores, ins_scores = zeros(rem_ops), zeros(ins_ops)
        rem_freq, ins_freq = ones(rem_ops), ones(ins_ops)

        if verbose
            print("T > Tf: $(round(T, digits=3)) > $(Tf)")
            print("\t best: $(fo_best), curr: $(fo_s)")
            println("")
        end

        while iter < SA_max && iter_no_improvement < SA_max_no_improvement
            iter += 1
            iter_no_improvement += 1

            rem_idx, s2 = removal(instance, clone_sol(s), rem_weights)
            ins_idx, s2 = insertion(instance, s2, ins_weights)

            rem_freq[rem_idx] += 1
            ins_freq[ins_idx] += 1

            fo_curr = target_fn(instance, s2)

            if !(target ≡ nothing)
                if fo_curr ≤ target
                    return s2, history
                end
            end

            ∆ = fo_curr - fo_s

            if ∆ < 0                
                s = clone_sol(s2)
                fo_s = fo_curr
                if fo_curr < fo_best
                    iter_no_improvement = 0

                    if reheat
                        T += 10
                    end

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
        iter_no_improvement = 0

        maintain_history(history, fo_s, fo_best, rem_scores, ins_scores)
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

    s_best, history
end