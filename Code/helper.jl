using Random

function print_solution(instance, solution)
    surgeries, rooms, days, penalties = instance
    sc_d, sc_r, sc_h = solution

    println("dias: ", sc_d)
    println("salas: ", sc_r)
    println("horas: ", sc_h)

    for d in 1:days
        println("")
        println("day ", d)
        print("--------")
        print("|")

        for t in 1:46
            if t < 10
                print(" ")
            end
            print(t, "|")
        end

        println("")
        for r in 1:rooms
            print("room ", r, ": ")
            
            for t in 1:46
                print("|")
                found_surgery = false
                for s in surgeries
                    idx_s, p_s, w_s, e_s, g_s, t_s = s
                    if sc_d[idx_s] == d && sc_r[idx_s] == r && t >= sc_h[idx_s] && t < (sc_h[idx_s] + t_s)
                        if idx_s < 10
                            print(" ")
                        end
                        print(idx_s)
                        found_surgery = true
                        break
                    end
                end
                if !found_surgery
                    print("  ")
                end
            end

            println("|")
        end
    end
end

function eval_surgery(surgery, rooms, penalties, sc_d, sc_r, sc_h)
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery
    scheduled = (sc_d[idx_s] != nothing)
    
    if scheduled
        return (w_s + 2 + sc_d[idx_s]) * t_s
    else
        return (w_s + 7) * penalties[p_s]
    end
end

function target_fn(instance, solution)
    surgeries, rooms, days, penalties = instance
    sc_d, sc_r, sc_h = solution

    total = 0
    for s in surgeries
        # println("f$(s) = $(eval_surgery(s, rooms, penalties, sc_d, sc_r, sc_h))")
        total += eval_surgery(s, rooms, penalties, sc_d, sc_r, sc_h)
    end
    
    total
end

function roulette(probs)
    dice = rand(Float64)

    for (idx, w) in enumerate(probs)
        dice -= w
        if dice <= 0
            return idx
        end
    end

    return length(probs)
end

# TODO: is it expensive?
function clone_sol(solution)
    (copy(solution[1]), copy(solution[2]), copy(solution[3]))
end

function get_scheduled_surgeries_list(solution)
    sc_d, sc_r, sc_h = solution
    [idx for (idx, d) in enumerate(sc_d) if d != nothing]
end

function get_surgery(instance, id)
    surgeries, rooms, days, penalties = instance
    surgeries[id]
end

function unschedule_surgery(solution, idx)
    sc_d, sc_r, sc_h = clone_sol(solution)
    sc_d[idx] = nothing
    sc_r[idx] = nothing
    sc_h[idx] = nothing
    (sc_d, sc_r, sc_h)
end

# TODO: this should be done in an internal data structure in the algorithm, for this computation is
# not trivial and could be easily avoided if we constructed the "timeslots" data structure
# during the algorithm.
function get_free_timeslots(instance, solution, room, day)
    sc_d, sc_r, sc_h = solution
    surgeries, rooms, days, penalties = instance

    timeslots = zeros(46 + 1)
    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_r[idx_s] == room && sc_d[idx_s] == day
            t_start = sc_h[idx_s]
            t_end = min(sc_h[idx_s] + t_s + 1, 46)
            
            if sum(timeslots[t_start:t_end]) > 0
                println("This should not be happening.")
                @bp
            end

            timeslots[t_start:t_end] = ones(t_end - t_start + 1) * idx_s
        end
    end
    timeslots[47] = 1 # quick hack. otherwise it never counts a final stretch of 0's 

    curr_start = nothing
    free_timeslots = []
    for t in 1:(46 + 1)
        if timeslots[t] == 0 && curr_start == nothing
            curr_start = t
        elseif timeslots[t] != 0 && curr_start != nothing
            push!(free_timeslots, (curr_start, t - 1))
            curr_start = nothing
        end
    end

    free_timeslots
end

# TODO: this should be done in an internal data structure in the algorithm, for this computation is
# not trivial and could be easily avoided if we constructed the "room specialty" data structure
# during the algorithm.
function get_room_specialty(instance, solution, room, day)
    sc_d, sc_r, sc_h = solution
    surgeries, rooms, days, penalties = instance

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_r[idx_s] == room && sc_d[idx_s] == day
            return e_s
        end
    end

    return nothing
end


# FIXME: Acrescentar numero de dias no criterio!
function most_prioritary(surgery1, surgery2)
    idx_s1, p_s1, w_s1, e_s1, g_s1, t_s1 = surgery1
    idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = surgery2

    if (p_s1 < p_s2) # || ((p_s == surgeries_ordered[1][2]) && (w_s ))
        return surgery1
    else
        return surgery2
    end
end