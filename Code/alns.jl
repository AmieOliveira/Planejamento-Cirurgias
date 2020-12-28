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

# TODO
IDX_S = 1
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
    # addedValue = eval_surgery(scheduled_surgeries[wIdx], rooms, sc_d[scheduled_surgeries[wIdx][IDX_S]], false)

    return ret
end

# TODO: Shaw removal
# o Que mais?

# TODO: insert as many as possible?
function greedy_insertion(instance, solution; verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    unscheduled_surgeries = get_unscheduled_surgeries(solution)
    sort!(unscheduled_surgeries, lt = (x, y) -> !is_more_prioritary(x, y))

    for surgery in unscheduled_surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        if !can_surgeon_fit_surgery_in_week(instance, solution, surgery)
            continue
        end

        for d in 1:DAYS
            if !can_surgeon_fit_surgery_in_day(instance, solution, surgery, d)
                continue
            end

            for r in 1:rooms
                free_timeslots = get_free_timeslots(instance, solution, r, d)

                for (timeslot_start, timeslot_end) in free_timeslots
                    if !can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, d, timeslot_start, timeslot_end)
                        continue
                    end

                    if e[d, r] == e_s || e[d, r] == 0
                        if t_s + 2 <= (timeslot_end - timeslot_start + 1)
                            if timeslot_start + t_s - 1 <= 46
                                solution = schedule_surgery(instance, solution, surgery, d, r, timeslot_start)
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
    else
        println("This should not be happening.")
        error
    end
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

            rem_idx, s2 = removal(instance, clone_sol(s), rem_weights)
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