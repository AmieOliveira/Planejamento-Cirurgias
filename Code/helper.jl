using Random

LENGTH_INTERVAL = 2
LENGTH_DAY = 46

DEADLINES = [3, 15, 60, 365]
PENALTIES = [90, 20, 8, 1]
COLORS_P = [:red, :orange, :yellow, :green]

DAYS = 5
WEEKEND = 2
DAY_NAMES = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"]

function eval_surgery(surgery, rooms, day_scheduled, verbose)
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

    total = 0
    for s in surgeries
        # println("f$(s) = $(eval_surgery(s, rooms, PENALTIES, sc_d, sc_r, sc_h, e, sg_tt, sc_ts))")
        total += eval_surgery(s, rooms, sc_d[s[1]], verbose)
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
    surgeries[id]
end

function get_number_of_surgeons(instance)
    surgeries, rooms = instance
    maximum([g_s for (_, _, _, _, g_s, _) in surgeries])
end

function can_surgeon_fit_surgery_in_week(instance, solution, surgery)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    sum(sg_tt[:, g_s]) + t_s <= 100 # TODO: tempo de limpeza????
end

function can_surgeon_fit_surgery_in_day(instance, solution, surgery, day)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery

    sg_tt[day, g_s] + t_s <= 24
end

function can_surgeon_fit_surgery_in_timeslot(instance, solution, surgery, day, timeslot_start, timeslot_end)
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
    sg_tt[day, g_s] += t_s + 2
    e[day, room] = e_s

    if length(filter(ts -> ts[3] == idx_s, sc_ts[day, room])) > 0
        println("Same surgery counting more than once! This should not be happening!!")
    end

    push!(sc_ts[day, room], [sc_h[idx_s], sc_h[idx_s] + t_s - 1 + 2, idx_s, g_s])
    sort!(sc_ts[day, room], by = ts -> ts[1][1])

    (sc_d, sc_r, sc_h, e, sg_tt, sc_ts)
end

function get_free_timeslots(instance, solution, room, day)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    surgeries, rooms = instance

    timeslots = sc_ts[day, room]
    free_timeslots = []

    if length(timeslots) == 0
        return [(1, 46)]
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
    if last_f < 46
        push!(free_timeslots, (last_f + 1, 46))
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

# TODO: Fix shuffle function
TIMESLOTS = 1
IDX = 2
SURGEON = 3
function surgeries_per_day(instance, solution, n_docs)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    surgeries, rooms = instance

    # TODO: Fazer array
    c_dias = Dict(i => 
                Dict(j => [Array{Int64}[], Int64[], Int64[]] for j in 1:rooms) 
                for i in 1:DAYS)
    docs = Dict(i => Dict(doc => Array{Int64}[] for doc in 1:n_docs) for i in 1:DAYS)

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s

        if !(sc_d[idx_s] === nothing)

            dia_s = sc_d[idx_s]
            sala_s = sc_r[idx_s]
            hora_s = sc_h[idx_s]

            s_slot = [hora_s, hora_s + t_s - 1]

            push!(c_dias[dia_s][sala_s][TIMESLOTS], s_slot)
            push!(c_dias[dia_s][sala_s][IDX], idx_s)
            push!(c_dias[dia_s][sala_s][SURGEON], g_s)
            
            d_slot = [hora_s,  hora_s + t_s - 1 + LENGTH_INTERVAL]
            push!(docs[sc_d][g_s], d_slot)
        end

    end

    for d in 1:DAYS
        for r in 1:rooms
            permutacao = sortperm( c_dias[d][r][TIMESLOTS], by = x -> x[1] )

            for i in 1:3
                c_dias[d][r][i] = c_dias[d][r][i][permutacao]
            end

        end

        for doc in 1:n_docs
            sort!(docs[d][doc], by = x -> x[1])
        end
    end

    return c_dias, docs
end

function perDay_to_initialFormat(s_daily, n_surgeries)
    # Função inversa de surgeries_per_day (retorna a 'solution' equivalente)
    surgs, docs = s_daily

    sc_d = zeros(Int, n_surgeries)
    sc_r = zeros(Int, n_surgeries)
    sc_h = zeros(Int, n_surgeries)

    for d in 1:DAYS
        for r in keys(s_daily[d])
            for i in 1:length(s_daily[d][r][IDX])
                idx = s_daily[d][r][IDX][i]

                sc_d[idx] = d
                sc_r[idx] = r
                sc_h[idx] = s_daily[d][r][TIMESLOTS][i][1]
            end
        end
    end

    return sc_d, sc_r, sc_h, e, sg_tt, sc_ts
end

function shuffle_day(dict_cirurgias)
    surgs, docs = dict_cirurgias
    rooms =  keys(surgs)
    ret = copy(surgs)
    ret_doc = copy(docs)

    for r in rooms
        if ret[r][TIMESLOTS][1][1] > 1
            # TODO: deslocar para 1
        end

        nslots = length(ret[r][IDX])
        for slot_idx in 2:nslots
            if ret[r][TIMESLOTS][slot_idx][1] - ret[r][TIMESLOTS][slot_idx-1][2] > LENGTH_INTERVAL
                # check surgeon availability. if available, bring closer
                surgeon = ret[r][SURGEON][slot_idx]

                clash = false

                duration = ret[r][TIMESLOTS][slot_idx][2]-ret[r][TIMESLOTS][slot_idx][1]
                init = ret[r][TIMESLOTS][slot_idx-1][2] + LENGTH_INTERVAL
                fim = min( ret[r][TIMESLOTS][slot_idx][1] - 1, 
                           init + ret[r][TIMESLOTS][slot_idx][2]-ret[r][TIMESLOTS][slot_idx][1] )

                doctor_slot = nothing
                last = nothing

                for (i_ds, d_slot) in enumerate(ret_doc[surgeon])
                    if d_slot[1] == ret[r][TIMESLOTS][slot_idx][1] &&
                        d_slot[2] == ret[r][TIMESLOTS][slot_idx][2]
                        doctor_slot = i_ds
                    end
                    last = i_ds

                    if d_slot[1] > fim
                        break
                    end

                    clash = intervalClash(d_slot, [init, fim])
                    if clash
                        break
                    end
                end
                
                if !( clash )
                    ret[r][TIMESLOTS][slot_idx] = [init, init + duration]
                    
                    # TODO: Acho que esqueci de considerar o tempo de limpeza aqui

                    if doctor_slot === nothing
                        for i in last+1:length(ret_doc[surgeon])
                            if d_slot[1] == ret[r][TIMESLOTS][slot_idx][1] &&
                                d_slot[2] == ret[r][TIMESLOTS][slot_idx][2]
                                doctor_slot = i_ds
                                break
                            end
                        end
                    end
                    ret_doc[surgeon][doctor_slot] = [init, init + duration]
                end

                # Por enquanto so estou ajustando por trazer as cirurgias mais para o inicio do dia
                # TODO: Na real tenho que discutir o algoritmo... tem muitas possibilidades, 
                # como fazer de maneira eficiente?
            end
        end
    end

    return ret
end

function shuffle_schedule(instance, solution, n_doctors)
    c_dias, docs = surgeries_per_day(instance, solution, n_doctors)

    for d in 1:DAYS
        c_dias[d] = shuffle_day(c_dias[d], docs[d])
    end
    
    sol = perDay_to_initialFormat(c_dias, length(solution[1]))
    return sol
end