include("helper.jl")

function solve(instance; verbose=true)
    surgeries, rooms = instance

    sort!(surgeries, lt = (x, y) -> !is_more_prioritary(x, y))

    h = ones(Int, DAYS, rooms) # h[i, j] stores the first available hour in room 'i' and day 'j'

    # solution vectors
    sc_d = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule days
    sc_h = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule hours
    sc_r = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule rooms
    e = zeros(Int, DAYS, rooms) # e[i, j] stores the specialty in room 'i' and day 'j'
    sg_tt = zeros(Int, DAYS, get_number_of_surgeons(instance)) # sg_tt[i, j] stores the total time scheduled for the surgeon 'j' at day 'i'
    sc_ts = [[] for i=1:DAYS, j=1:rooms] # scheduled timeslots

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if verbose
            println("tentando agendar cirurgia ", idx_s)
        end
        
        for d in 1:DAYS
            if sc_r[idx_s] != nothing
                # cirurgia já agendada. passar pra próxima
                if verbose
                    println("\tcirurgia ", idx_s, " já agendada. passar pra próxima")
                end
                break
            end

            if sg_tt[d, g_s] + t_s > 24
                # cirurgiao ocupado para o dia 'd'. tentar no proximo dia
                if verbose
                    println("\tfalha na cirurgia ", idx_s, ": cirurgiao ", g_s, " ocupado para o dia ", d, ". tentar no proximo dia")
                end
                continue
            end

            for r in 1:rooms
                surgeon_busy = false
                for s2 in surgeries
                    idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = s2
                    if sc_d[idx_s2] == d
                        if g_s2 == g_s && h[d, r] >= sc_h[idx_s2] && h[d, r] <= sc_h[idx_s2] + t_s2
                            surgeon_busy = true
                            break
                        end
                    end
                end
                if surgeon_busy
                    # cirurgiao ocupado naquele momento. tentar na proxima sala
                    if verbose
                        println("\tfalha na cirurgia ", idx_s, ": cirurgiao ", g_s, " ocupado naquele momento. tentar na proxima sala")
                    end
                    continue
                end

                if e[d, r] == e_s || e[d, r] == 0
                    if verbose
                        println("\t(e_s=", e_s, ", e[", r, ", ", d, "]=", e[d, r], ")")
                    end
                    if h[d, r] + t_s - 1 <= 46
                        sc_d[idx_s] = d
                        sc_r[idx_s] = r
                        sc_h[idx_s] = h[d, r]
                        sg_tt[d, g_s] += t_s + 2
                        e[d, r] = e_s
                        push!(sc_ts[d, r], [sc_h[idx_s], sc_h[idx_s] + t_s - 1 + 2, idx_s, g_s])
                        
                        h[d, r] = min(h[d, r] + t_s + 2, 46)

                        # cirurgia foi agendada. passar pra proxima cirurgia
                        if verbose
                            println("\tcirurgia ", idx_s, " foi agendada no dia ", d, " na sala ", r, " em t = ", sc_h[idx_s])
                        end
                        break
                    else
                        # cirurgia ultrapassaria horario limite
                        if verbose
                            println("\tfalha na cirurgia ", idx_s, ": cirurgia ultrapassaria horario limite (h[d, r] + t_s - 1 = ", h[d, r], " + ", t_s, " - 1)")
                        end
                    end
                else
                    # sala 's' agendada pra especialidade 'e'.
                    if verbose
                        println("\tfalha na cirurgia ", idx_s, ": especialidades diferem (e_s=", e_s, ", e_rd=", e[d, r], ")")
                    end
                end
            end
        end
    end

    sc_d, sc_r, sc_h, e, sg_tt, sc_ts
end