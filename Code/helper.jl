using Random, Plots, Printf
#Plots.pyplot()

dias = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"]
cores_p = [:red, :orange, :yellow, :green]

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
            p = plot(1:dayPeriods, zeros(dayPeriods), color=:black)
            #hline()
            yaxis!(p, dias[d], showaxis=false)
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
    
    if scheduled
        cost = (w_s + 2 + scd)# * t_s
        if verbose
            @printf("Surgery %i scheduled with cost: %f\n", idx_s, cost)
        end
        return cost
    else
        cost = (w_s + 7) * penalties[p_s]# * t_s
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


# FIXME: Acrescentar numero de dias no criterio!
function most_prioritary(surgery1, surgery2)
    idx_s1, p_s1, w_s1, e_s1, g_s1, t_s1 = surgery1
    idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = surgery2

    if (p_s1 < p_s2) # || ((p_s == surgeries_ordered[1][2]) && (w_s ))
        return surgery1
    elseif (p_s1 > p_s2)
        return surgery2
    else    #(p_s1 == p_s2)
        if (w_s1 > w_s2)
            return surgery1
        elseif (w_s2 > w_s1)
            return surgery2
        else
            if idx_s1 < idx_s2
                return surgery1
            end
            return surgery2
        end
    end
end

function is_more_prioritary(surgery1, surgery2)
    return most_prioritary(surgery1, surgery2) == surgery1
end