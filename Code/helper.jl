function print_solutions(surgeries, rooms, sc_d, sc_r, sc_h)
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
                        print(" ", idx_s)
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