using Random

function print_solutions(instance, sc_d, sc_r, sc_h)
    surgeries, rooms, days, penalties = instance

    println("dias: ", sc_d)
    println("salas: ", sc_r)
    println("horas: ", sc_h)

    for d in 1:DAYS
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
        return penalties[p_s]
    end
end

function target_fn(instance, sc_d, sc_r, sc_h)
    surgeries, rooms, days, penalties = instance

    total = 0
    for s in surgeries
        println("f$(s) = $(eval_surgery(s, rooms, penalties, sc_d, sc_r, sc_h))")
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