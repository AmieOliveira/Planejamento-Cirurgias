using Random, Plots, Printf
#Plots.pyplot()

intervalo_cirurgias = 2
n_slots = 46

janelas_tempo = [3, 15, 60, 365]
penalidades = [90, 20, 8, 3]
cores_p = [:red, :orange, :yellow, :green]

#penalty_timeout = 2

n_dias = 5
dias = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"]

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

function rectangle(w, h, x, y)
    return Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])
end

function plot_solution(instance, solution, filename="teste")
    # TODO: Mudança de cores
    surgeries, rooms, days, penalties = instance
    sc_d, sc_r, sc_h = solution

    dayPeriods = 46

    for r in 1:rooms
    #fig = figure()
        pls = Any[]
        for d in 1:days
            p = plot(1:dayPeriods, zeros(dayPeriods), color=:black, yaxis=false)
            #hline()
            yaxis!(p, dias[d])#, showaxis=false)
            texts = []
            for s in surgeries
                idx_s, p_s, w_s, e_s, g_s, t_s = s
                if sc_d[idx_s] == d && sc_r[idx_s] == r
                    s_label = @sprintf("Cirurgia %i", idx_s)
                    plot!(rectangle(t_s, 1, sc_h[idx_s], 0), label=s_label, color=cores_p[p_s])
                    annotate!(sc_h[idx_s]+.5, 0.5, Plots.text(@sprintf("Cirurgia %i", idx_s), 8, :left))
                end
            end
            if d == 1
                title!(@sprintf("Sala %i", r))
            elseif d == days
                xaxis!("Tempo (períodos)")
            end
            push!(pls, p)
        end

        # TODO: Como fazer sem ter que especificar cada plot?
        plot(pls[1], pls[2], pls[3], pls[4], pls[5], layout = (days, 1), legend = false)#, legend = false)
        savefig(@sprintf("%s-%isalas-sala%i.pdf",filename, rooms, r))
        #close(fig)
    end
end

function eval_surgery(surgery, rooms, penalties, scd, verbose)
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery
    scheduled = (scd != nothing)

    alpha = 10
    
    if scheduled
        wait = w_s + 2 + scd
        cost = wait^2 # wait/t_s

        if wait > janelas_tempo[p_s] + 1
            # Penalidade por passar do prazo
            cost = cost + (wait-janelas_tempo[p_s])^alpha    #penalties[ min(p_s, penalty_timeout) ]
        end
        
        if verbose
            @printf("Surgery %i scheduled with cost: %f\n", idx_s, cost)
        end
        return cost
    else
        wait = w_s + 7
        cost = wait^2 * penalties[p_s]# wait/t_s

        if wait + 2 > janelas_tempo[p_s] + 1 
            # Penalidade por passar do prazo
            # Somo 2 do proximo final de semana. Ja tenho 
            # que saber agora que vou passar do prazo
            cost = cost + (wait + 2 - janelas_tempo[p_s])^alpha    #penalties[ min(p_s, penalty_timeout) ]
        end

        if verbose
            @printf("Surgery %i not scheduled. Cost: %f\n", idx_s, cost)
        end
        return cost
    end
end

function target_fn(instance, solution, verbose=false)
    surgeries, rooms, days, penalties = instance
    sc_d, sc_r, sc_h = solution

    total = 0
    for s in surgeries
        # println("f$(s) = $(eval_surgery(s, rooms, penalties, sc_d, sc_r, sc_h))")
        total += eval_surgery(s, rooms, penalties, sc_d[s[1]], verbose)
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
    sc_d, sc_r, sc_h = solution
    bad = []

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if sc_d[idx_s] != nothing
            if sc_d[idx_s] + w_s + 2 > janelas_tempo[p_s] + 1
                # NOTE: Coloco +1 na janela devido à forma como 
                #   está implementado o wait-time. Se não fizer 
                #   isso todas as urgências ficam fora do prazo, 
                #   mesmo feitas nas segundas
                @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        else
            if w_s + 7 + 2 > janelas_tempo[p_s] + 1
                # NOTE: Coloco +2 dias para contar com o proximo fds
                @printf("Cirurgia %s fora de prazo!\n", idx_s)
                push!(bad, idx_s)
            end
        end
    end

    return bad
end

TIMESLOTS = 1
IDX = 2
SURGEON = 3
function surgeries_per_day(instance, solution, n_docs)
    sc_d, sc_r, sc_h = solution
    surgeries, rooms, days, penalties = instance

    c_dias = Dict(i => 
                Dict(j => [Array{Int64}[], Int64[], Int64[]] for j in 1:rooms) 
                for i in 1:n_dias)
    docs = Dict( i => Dict(doc => Array{Int64}[] for doc in 1:n_docs) for i in 1:n_dias )

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
            
            d_slot = [hora_s,  hora_s + t_s - 1 + intervalo_cirurgias]
            push!(docs[sc_d][g_s], d_slot)
        end

    end

    for d in 1:n_dias
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

    for d in 1:n_dias
        for r in keys(s_daily[d])
            for i in 1:length(s_daily[d][r][IDX])
                idx = s_daily[d][r][IDX][i]

                sc_d[idx] = d
                sc_r[idx] = r
                sc_h[idx] = s_daily[d][r][TIMESLOTS][i][1]
            end
        end
    end

    return sc_d, sc_r, sc_h
end

function intervalClash(interval1, interval2)
    if interval1[1] > interval2[2]
        return false
    elseif interval2[1] > interval2[2]
        return false
    end
    return true
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
            if ret[r][TIMESLOTS][slot_idx][1] - ret[r][TIMESLOTS][slot_idx-1][2] > intervalo_cirurgias
                # check surgeon availability. if available, bring closer
                surgeon = ret[r][SURGEON][slot_idx]

                clash = false

                duration = ret[r][TIMESLOTS][slot_idx][2]-ret[r][TIMESLOTS][slot_idx][1]
                init = ret[r][TIMESLOTS][slot_idx-1][2] + intervalo_cirurgias
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

    for d in 1:n_dias
        c_dias[d] = shuffle_day(c_dias[d], docs[d])
    end
    
    sol = perDay_to_initialFormat(c_dias, length(solution[1]))
    return sol
end