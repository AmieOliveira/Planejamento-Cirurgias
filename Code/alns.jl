using Random
include("helper.jl")

function random_removal(instance, solution)
    surgeries, rooms, days, penalties = instance
    scheduled_surgeries = get_scheduled_surgeries_list(solution)

    qt_to_remove = rand(0:2)
    for _ in 1:qt_to_remove
        if length(scheduled_surgeries) == 0
            return solution
        end

        pos_to_del = rand(1:length(scheduled_surgeries))
        solution = unschedule_surgery(solution, scheduled_surgeries[pos_to_del])
        deleteat!(scheduled_surgeries, pos_to_del)
    end

    solution
end

# TODO: include this and shaw removal
function worst_removal(instance, solution)
    return random_removal(instance, solution)
end

# TODO: currently it isn't greedy! should sort surgeries by priority/waiting time
function greedy_insertion(instance, solution)
    surgeries, rooms, days, penalties = instance
    sc_d, sc_r, sc_h = solution
    verbose = false

    #surgery = nothing
    surgeries_ordered = nothing
    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_d[idx_s] ≡ nothing
            #surgery = s
            if verbose
                println("tentando agendar cirurgia $(idx_s)")
            end
            if surgeries_ordered ≡ nothing
                surgeries_ordered = [s]
            else
                # TODO: Provavelmente tem uma maneira mais rápida e eficiente de ordenar!
                # TODO: TESTAR! MAS PARA ISSO TENHO QUE CORRIGIR A 'most_prioritary'
                pushed = false
                if most_prioritary(s, surgeries_ordered[1]) === s
                    append!([s], surgeries_ordered)
                end
                lso = length(surgeries_ordered)
                for i in 1:(lso-1)
                    so1 = surgeries_ordered[i]
                    so2 = surgeries_ordered[i+1]
                    idx_so1, p_so1, w_so1, e_so1, g_so1, t_so1 = so1
                    idx_so2, p_so2, w_so2, e_so2, g_so2, t_so2 = so2

                    if most_prioritary(s, so1) == so1 && most_prioritary(s, so2) == so2
                        insert!(surgeries_ordered, i+1, s)
                    end
                end
                if pushed == false
                    push!(surgeries_ordered, s)
                end
            end
        end
    end

    if surgeries_ordered ≡ nothing #TODO: should check next surgery according to priority
        return solution
    end

    # TODO: Acrescentar loop para tentar colocar tantas quantas conseguir??
    surgery = surgeries_ordered[1]
    
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery
    for d in 1:days
        total_time_surgeon = 0
        for s2 in surgeries
            idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = s2
            if sc_d[idx_s2] == d && g_s2 == g_s
                total_time_surgeon += t_s2
            end
        end # TODO: Having to redo this all the time should also increase running time. 
        # Maybe if we organize in matrixes we can just sum strait from a given day, instead of looping over all surgeries
        if total_time_surgeon + t_s > 24
            # surgeon busy for day 'd'. try next day
            if verbose
                println("\tfalha na cirurgia $(idx_s): cirurgiao $(g_s) ocupado para o dia $(d). tentar no proximo dia")
            end
            continue
        end

        for r in 1:rooms
            free_timeslots = get_free_timeslots(instance, solution, r, d)
            room_specialty = get_room_specialty(instance, solution, r, d)

            for (timeslot_start, timeslot_end) in free_timeslots
                surgeon_busy = false
                for s2 in surgeries
                    idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = s2
                    if sc_d[idx_s2] == d
                        s2_start = sc_h[idx_s2]
                        s2_end = sc_h[idx_s2] + t_s2
                        if g_s2 == g_s && timeslot_start <= s2_end && s2_start <= timeslot_end
                            surgeon_busy = true
                            break
                        end
                    end
                end
                if surgeon_busy
                    # surgeon busy at that time. try next room
                    if verbose
                        println("\tfalha na cirurgia $(idx_s): cirurgiao $(g_s) ocupado naquele momento. tentar na proxima sala")
                    end
                    continue
                end

                if room_specialty == e_s || room_specialty === nothing
                    if verbose
                        println("\t(e_s=", e_s, ", e[", r, ", ", d, "]=", room_specialty, ")")
                    end
                    if t_s + 2 <= (timeslot_end - timeslot_start + 1)
                        if timeslot_start + t_s - 1 <= 46
                            sc_d[idx_s] = d
                            sc_r[idx_s] = r
                            sc_h[idx_s] = timeslot_start
                            
                            # schedule was successful! end insertion
                            if verbose
                                println("\ttimeslot: [$(timeslot_start), $(timeslot_end)], t_s + 2: $(t_s) + 2")
                                println("\tcirurgia $(idx_s) foi agendada no dia $(d) na sala $(r) em t = $(sc_h[idx_s])")
                            end

                            return (sc_d, sc_r, sc_h)
                        else
                            # surgery would exceed 46th timeslot. try next timeslot
                            if verbose
                                println("\tfalha na cirurgia $(idx_s): cirurgia ultrapassaria horario limite (h[r, d] + t_s - 1 = $(timeslot_start) + $(t_s) - 1")
                            end
                        end
                    else
                        # surgery would exceed current timeslot. try next timeslot
                        if verbose
                            println("\tfalha na cirurgia $(idx_s): cirurgia de tamanho $(t_s + 2) não cabe no timeslot [$(timeslot_start), $(timeslot_end)].")
                        end
                    end
                else
                    # room scheduled for another specialty. try next room
                    if verbose
                        println("\tfalha na cirurgia $(idx_s): especialidades diferem (e_s=$(e_s), e_rd=$(room_specialty))")
                    end
                end
            end
        end
    end

    return solution
end

function removal(instance, solution, weights)
    solution = clone_sol(solution)
    
    probs = map(x -> x / sum(weights), weights)
    selected_idx = roulette(probs)

    if selected_idx == 1
        return (1, random_removal(instance, solution))
    elseif selected_idx == 2
        return (2, worst_removal(instance, solution))
    else
        println("This should not be happening.")
        error
    end
end

function insertion(instance, solution, weights)
    solution = clone_sol(solution)
    
    probs = map(x -> x / sum(weights), weights)
    selected_idx = roulette(probs)

    if selected_idx == 1
        return (1, greedy_insertion(instance, solution))
    else
        println("This should not be happening.")
        error
    end
end

function alns_solve(instance, initial_solution; SA_max, α, T0, Tf, r, σ1, σ2, σ3)
    s = clone_sol(initial_solution)
    s_best = clone_sol(initial_solution)

    iter = 0
    T = T0

    rem_ops, ins_ops = 2, 1
    rem_weights, ins_weights = ones(rem_ops), ones(ins_ops)

    while T > Tf    # TODO: Aquelas coisas de criterio de parada?
        rem_scores, ins_scores = zeros(rem_ops), zeros(ins_ops)
        rem_freq, ins_freq = ones(rem_ops), ones(ins_ops)

        print("T > Tf: $(round(T, digits=3)) > $(Tf)")
        print("\t best: $(target_fn(instance, s_best)), curr: $(target_fn(instance, s))")
        println("")

        while iter < SA_max
            iter += 1

            rem_idx, s2 = removal(instance, s, rem_weights)
            ins_idx, s2 = insertion(instance, s2, ins_weights)

            rem_freq[rem_idx] += 1
            ins_freq[ins_idx] += 1

            ∆ = target_fn(instance, s2) - target_fn(instance, s)

            if ∆ < 0                
                s = clone_sol(s2)
                if target_fn(instance, s2) < target_fn(instance, s_best)
                    s_best = clone_sol(s2)
                    rem_scores[rem_idx] += σ1
                    ins_scores[ins_idx] += σ1
                else
                    rem_scores[rem_idx] += σ2
                    ins_scores[ins_idx] += σ2
                end
            elseif rand(Float64) < ℯ^(-∆/T)
                s = clone_sol(s2)
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
    end

    s_best
end