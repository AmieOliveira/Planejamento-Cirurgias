using Plots, Printf
using DataFrames

include("helper.jl")

function print_solution(instance, solution)
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    println("dias: ", sc_d)
    println("salas: ", sc_r)
    println("horas: ", sc_h)
    println("scheduled timeslots: ")
    display(sc_ts)

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

function solution_to_csv(output_path, instance, solution)
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution
    surgeries, rooms = instance

    df = DataFrame(
        Symbol("Cirurgia (c)") => [s[1] for s in surgeries],
        Symbol("Sala (r)") => [sc_r[s[1]] for s in surgeries],
        Symbol("Dia (d)") => [sc_d[s[1]] for s in surgeries],
        Symbol("Horário (t)") => [sc_h[s[1]] for s in surgeries])

    CSV.write(output_path, df, delim=';', transform=(col, val) -> something(val, -1))
end

function rectangle(w, h, x, y)
    return Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])
end

function plot_solution(instance, solution, filename="teste")
    # TODO: Mudança de cores
    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    dayPeriods = 46

    for r in 1:rooms
    #fig = figure()
        pls = Any[]
        for d in 1:DAYS
            p = plot(1:dayPeriods, zeros(dayPeriods), color=:black, yaxis=false)
            #hline()
            yaxis!(p, DAY_NAMES[d])#, showaxis=false)
            texts = []
            for s in surgeries
                idx_s, p_s, w_s, e_s, g_s, t_s = s
                if sc_d[idx_s] == d && sc_r[idx_s] == r
                    s_label = @sprintf("Cirurgia %i", idx_s)
                    plot!(rectangle(t_s, 1, sc_h[idx_s], 0), label=s_label, color=COLORS_P[p_s])
                    annotate!(sc_h[idx_s]+.5, 0.5, Plots.text(@sprintf("Cirurgia %i", idx_s), 8, :left))
                end
            end
            if d == 1
                title!(@sprintf("Sala %i", r))
            elseif d == DAYS
                xaxis!("Tempo (períodos)")
            end
            push!(pls, p)
        end

        # TODO: Como fazer sem ter que especificar cada plot?
        plot(pls[1], pls[2], pls[3], pls[4], pls[5], layout = (DAYS, 1), legend = false)#, legend = false)
        savefig(@sprintf("%s-%isalas-sala%i.pdf",filename, rooms, r))
        #close(fig)
    end
end