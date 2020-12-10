function solve(instance; verbose=true)
    surgeries, rooms, days, penalties = instance
    
    h = ones(Int, rooms, days) # h[i, j] stores the first available hour in room 'i' and day 'j'
    e = zeros(Int, rooms, days) # e[i, j] stores the specialty in room 'i' and day 'j'
    
    # solution vectors
    sc_d = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule days
    sc_h = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule hours
    sc_r = Vector{Union{Nothing, Int64}}(nothing, length(surgeries)) # schedule rooms

    for s in surgeries
        idx_s, p_s, w_s, e_s, g_s, t_s = s
        if verbose
            println("tentando agendar cirurgia ", idx_s)
        end
        
        for d in 1:days
            if sc_r[idx_s] != nothing
                # cirurgia já agendada. passar pra próxima
                if verbose
                    println("\tcirurgia ", idx_s, " já agendada. passar pra próxima")
                end
                break
            end

            total_time_surgeon = 0
            for s2 in surgeries
                idx_s2, p_s2, w_s2, e_s2, g_s2, t_s2 = s2
                if sc_d[idx_s2] == d && g_s2 == g_s
                    total_time_surgeon += t_s2
                end
            end
            if total_time_surgeon + t_s > 24
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
                        if g_s2 == g_s && h[r, d] >= sc_h[idx_s2] && h[r, d] <= sc_h[idx_s2] + t_s2
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

                if e[r, d] == e_s || e[r, d] == 0
                    if verbose
                        println("\t(e_s=", e_s, ", e[", r, ", ", d, "]=", e[r, d], ")")
                    end
                    if h[r, d] + t_s - 1 <= 46
                        sc_d[idx_s] = d
                        sc_r[idx_s] = r
                        sc_h[idx_s] = h[r, d]
                        
                        e[r, d] = e_s
                        h[r, d] = min(h[r, d] + t_s + 2, 46)
                        # cirurgia foi agendada. passar pra proxima cirurgia
                        if verbose
                            println("\tcirurgia ", idx_s, " foi agendada no dia ", d, " na sala ", r, " em t = ", sc_h[idx_s])
                        end
                        break
                    else
                        # cirurgia ultrapassaria horario limite
                        if verbose
                            println("\tfalha na cirurgia ", idx_s, ": cirurgia ultrapassaria horario limite (h[r, d] + t_s - 1 = ", h[r, d], " + ", t_s, " - 1)")
                        end
                    end
                else
                    # sala 's' agendada pra especialidade 'e'.
                    if verbose
                        println("\tfalha na cirurgia ", idx_s, ": especialidades diferem (e_s=", e_s, ", e_rd=", e[r, d], ")")
                    end
                end
            end
        end
    end

    sc_d, sc_r, sc_h
end