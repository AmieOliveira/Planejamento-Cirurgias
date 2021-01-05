using CSV, Random

LENGTH_INTERVAL = 2
LENGTH_DAY = 46

DEADLINES = [3, 15, 60, 365]
PENALTIES = [90, 20, 8, 1]
COLORS_P = [:red, :orange, :yellow, :green]

DAYS = 5
WEEKEND = 2
DAY_NAMES = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"]

# Surgery input data content order
IDX_S = 1           # idx_s
PRIORITY_S = 2      # p_s
WAIT_S = 3          # w_s
ESPECIALTY_S = 4    # e_s
SURGEON_S = 5       # g_s
LENGTH_S = 6        # t_s

# Interval slots content order
SLOT_INIT = 1
SLOT_END = 2
SLOT_S = 3
SLOT_DOC = 4

function load_surgeries(filepath)
    surgeries = []
    for row in CSV.File(filepath, comment="#")
        println(row)
        
        surgery = Int64[]
        # (row[1], row[2], row[3], row[4], row[5], row[6])
        for i in 1:6
            val = row[i]
            if typeof(val) == String
                val = parse(Int64, val)
            end
            push!(surgery, val)
        end
            
        push!(surgeries, surgery)
    end
    surgeries
end

function emptySolution(instance)
    urgeries, rooms = instance

    sc_d = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule days
    sc_h = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule hours
    sc_r = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule rooms
    e = zeros(Int, DAYS, rooms) # e[i, j] stores the specialty in room 'i' and day 'j'
    sg_tt = zeros(Int, DAYS, get_number_of_surgeons(instance)) # sg_tt[i, j] stores the total time scheduled for the surgeon 'j' at day 'i'
    sc_ts = [[] for i=1:DAYS, j=1:rooms] # scheduled timeslots

    return (sc_d, sc_h, sc_r, e, sg_tt, sc_ts)
end

function eval_surgery(surgery, day_scheduled, verbose)
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    is_scheduled = (day_scheduled != nothing)
    total_days = w_s + WEEKEND + (is_scheduled ? day_scheduled : 7)
    exceeded_deadline = (total_days > (DEADLINES[p_s] + 1))
    cost = 0

    if p_s == 1 && day_scheduled != 1
        cost += (10 * (w_s + WEEKEND)) ^ (is_scheduled ? day_scheduled : 7)
    end

    if is_scheduled
        cost += (w_s + WEEKEND + day_scheduled) ^ 2
        if exceeded_deadline
            cost += (w_s + WEEKEND + day_scheduled - DEADLINES[p_s]) ^ 2
        end
    else
        cost += PENALTIES[p_s] * (w_s + DAYS + WEEKEND) ^ 2
        if exceeded_deadline
            cost += PENALTIES[p_s] * (w_s + DAYS + 2*WEEKEND - DEADLINES[p_s]) ^ 2
        end
    end

    if verbose
        str = is_scheduled ? "scheduled" : "not scheduled"
        println("Surgery $(idx_s) was $(str). Cost: $(cost)")
    end

    cost
end

function target_fn(instance, solution, verbose=false)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    # if verbose
        # sort!(by = x -> x[1], surgeries)
    # end
    sort!(by = x -> x[1], surgeries)

    total = 0
    for s in surgeries
        # println("f$(s) = $(eval_surgery(s, rooms, PENALTIES, sc_d, sc_r, sc_h, e, sg_tt, sc_ts))")
        total += eval_surgery(s, sc_d[s[1]], verbose)
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

function clone_sol(solution)
    (copy(solution[1]), copy(solution[2]), copy(solution[3]), copy(solution[4]), copy(solution[5]), deepcopy(solution[6]))
end

function get_scheduled_surgeries(solution, surgeries)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    filter(s -> sc_d[s[1]] != nothing, surgeries)
end

function get_unscheduled_surgeries(solution, surgeries)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    filter(s -> sc_d[s[1]] == nothing, surgeries)
end

function get_badly_scheduled_surgeries(surgeries, solution)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    bad = []

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_d[idx_s] != nothing
            if sc_d[idx_s] + w_s + 2 > DEADLINES[p_s] + 1
                # NOTE: Coloco +1 na janela devido à forma como 
                #   está implementado o wait-time. Se não fizer 
                #   isso todas as urgências ficam fora do prazo, 
                #   mesmo feitas nas segundas
                # @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        else
            if w_s + 7 + 2 > DEADLINES[p_s] + 1
                # NOTE: Coloco +2 dias para contar com o proximo fds
                # @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        end
    end

    return bad
end

function get_surgery(instance, id)
    surgeries, rooms = instance
    
    return filter(s -> s[1] == id, surgeries)[1]
end

function get_number_of_surgeons(instance)
    surgeries, rooms = instance
    maximum([g_s for (_, _, _, _, g_s, _) in surgeries])
end

function get_surgeries_scheduled_to_day(instance, solution, day)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    slots = collect(Iterators.flatten(sc_ts[day, :]))
    [get_surgery(instance, slot[SLOT_S]) for slot in slots]
end

function can_surgeon_fit_surgery_in_week(instance, solution, surgery)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    sum(sg_tt[:, g_s]) + t_s <= 100
end

function can_surgeon_fit_surgery_in_day(instance, solution, surgery, day)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    sg_tt[day, g_s] + t_s <= 24
end

function can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, day, timeslot_start, timeslot_end)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    for s2 in surgeries
        idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = s2
        if sc_d[idx_s2] == day
            s2_start = sc_h[idx_s2]
            s2_end = sc_h[idx_s2] + t_s2
            if g_s2 == g_s && timeslot_start <= s2_end && s2_start <= timeslot_end
                return false
            end
        end
    end

    return true
end

function unschedule_surgery(instance, solution, surgery)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    r, d = sc_r[idx_s], sc_d[idx_s]

    filter!(ts -> ts[3] != idx_s, sc_ts[d, r])
    sg_tt[d, g_s] -= t_s + 2
    sc_d[idx_s] = nothing
    sc_r[idx_s] = nothing
    sc_h[idx_s] = nothing

    if length(sc_ts[d, r]) == 0
        e[d, r] = 0
    end

    (sc_d, sc_r, sc_h, e, sg_tt, sc_ts)
end

function schedule_surgery(instance, solution, surgery, day, room, timeslot)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    sc_d[idx_s] = day
    sc_r[idx_s] = room
    sc_h[idx_s] = timeslot
    sg_tt[day, g_s] += t_s + LENGTH_INTERVAL
    e[day, room] = e_s

    if length(filter(ts -> ts[3] == idx_s, sc_ts[day, room])) > 0
        println("Same surgery counting more than once! This should not be happening!!")
    end

    push!(sc_ts[day, room], [sc_h[idx_s], sc_h[idx_s] + t_s - 1 + LENGTH_INTERVAL, idx_s, g_s])
    sort!(sc_ts[day, room], by = ts -> ts[1][1])

    (sc_d, sc_r, sc_h, e, sg_tt, sc_ts)
end

function get_free_timeslots(instance, solution, room, day)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    surgeries, rooms = instance

    timeslots = sc_ts[day, room]
    free_timeslots = []

    if length(timeslots) == 0
        return [(1, LENGTH_DAY)]
    end

    if timeslots[1][SLOT_INIT] ≠ 1
        push!(free_timeslots, (1, timeslots[1][SLOT_INIT]-1))
    end

    for i in 1:(length(timeslots) - 1)
        curr_i, curr_f, idx_s1, g_s1 = timeslots[i]
        next_i, next_f, idx_s2, g_s2 = timeslots[i + 1]

        if next_i - curr_f == 1
            continue # no free time here
        elseif next_i - curr_f < 0
            println("This should not be happening! Check overlap in surgeries $(idx_s1) and $(idx_s2)")
        end

        push!(free_timeslots, (curr_f + 1, next_i - 1))
    end

    last_i, last_f, _, _ = last(timeslots)
    if last_f < LENGTH_DAY
        push!(free_timeslots, (last_f + 1, LENGTH_DAY))
    end

    free_timeslots
end

function most_prioritary(surgery1, surgery2)
    idx_s1, p_s1, w_s1, e_s1, g_s1, t_s1 = surgery1
    idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = surgery2

    if (p_s1 < p_s2) # || ((p_s == surgeries_ordered[1][2]) && (w_s ))
        return surgery1
    elseif (p_s1 > p_s2)
        return surgery2
    else    #(p_s1 == p_s2)
        # Mesma prioridade: compara-se o tempo de espera
        if (w_s1 > w_s2)
            return surgery1
        elseif (w_s2 > w_s1)
            return surgery2
        else
            # Mesma prioridade e tempo de espera: compara-se a duração 
            #   da cirurgia (cirurgias mais curtas permitem realizar 
            #   mais cirurgias)

            if t_s1 < t_s2
                return surgery1
            elseif t_s1 > t_s2
                return surgery2
            else 
                # Tudo igual, desempata pelo ID
                if idx_s1 < idx_s2
                    return surgery1
                end
                return surgery2
            end
        end
    end
end

function is_more_prioritary(surgery1, surgery2)
    return most_prioritary(surgery1, surgery2) == surgery1
end

function badly_scheduled(surgeries, solution)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    bad = []

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_d[idx_s] != nothing
            if sc_d[idx_s] + w_s + 2 > DEADLINES[p_s] + 1
                # NOTE: Coloco +1 na janela devido à forma como 
                #   está implementado o wait-time. Se não fizer 
                #   isso todas as urgências ficam fora do prazo, 
                #   mesmo feitas nas segundas
                # @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        else
            if w_s + 7 + 2 > DEADLINES[p_s] + 1
                # NOTE: Coloco +2 dias para contar com o proximo fds
                # @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        end
    end

    return bad
end

function intervalClash(interval1, interval2)
    if interval1[1] > interval2[2]
        return false
    elseif interval2[1] > interval2[2]
        return false
    end
    return true
end

function squeeze_surgeries_up!(instance, solution, day, room)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    surgeries, rooms = instance

    fixed = true

    timeslots = sc_ts[day, room]

    println("Timeslots: ", timeslots)

    i = 1
    init_i = timeslots[i][SLOT_INIT]
    if init_i > 1
        idx_s = timeslots[i][SLOT_S]
        println("Cirurgia: ", idx_s)
        surgery = get_surgery(instance, idx_s)
        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        slot_end = min(t_s+LENGTH_INTERVAL, init_i-1)

        if can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, day, 
                                               1, slot_end)
            solution = unschedule_surgery(instance, solution, surgery)
            solution = schedule_surgery(instance, solution, surgery, day, room, 1)
            println("scheduling ", idx_s, " for time ", 1)
        else
            fixed = false
            # TODO: Check if I want to say it is false in all cases this happens
        end
    end

    while i < length(timeslots)
        i += 1
        slot_init = timeslots[i-1][SLOT_END] + 1
        init_i = timeslots[i][SLOT_INIT]

        if init_i == slot_init
            continue    # Already squeezed
        end

        idx_s = timeslots[i][SLOT_S]
        surgery = get_surgery(instance, idx_s)
        idx_s, p_s, w_s, e_s, g_s, t_s = surgery

        slot_end = min(slot_init + t_s + LENGTH_INTERVAL - 1, init_i - 1)

        if can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, day, 
                                               slot_init, slot_end)
            solution = unschedule_surgery(instance, solution, surgery)
            solution = schedule_surgery(instance, solution, surgery, day, room, slot_init)
            println("scheduling ", idx_s, " for time ", slot_init)
        else
            fixed = false
        end
    end

    return solution, fixed
end