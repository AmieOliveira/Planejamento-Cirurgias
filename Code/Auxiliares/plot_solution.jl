# Função para imprimir solução em PDF
# 
# Entradas: 
#   1. CSV: Lista das cirurgias (com todas as infos do CSV)
#   2. Número de salas
#   3. Solução: Lista com as listas dos dias, das salas e dos 
#               horários de cada Cirurgia 
#   4. String com nome de base da saída

using Plots, Printf

days = 5
dias = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"]
cores_p = [:red, :orange, :yellow, :green]

function rectangle(w, h, x, y)
    return Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])
end

function plot_solution_2(surgeries, rooms, solution, filename="teste")
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


# Exemplo de uso:
surgeries = [[1, 1, 1, 1, 1, 5],
             [2, 1, 1, 1, 1, 13],
             [3, 1, 1, 1, 2, 8],
             [4, 1, 1, 1, 2, 11],
             [5, 2, 10, 2, 3, 10],
             [6, 3, 9, 2, 4, 14],
             [7, 2, 8, 2, 3, 11],
             [8, 3, 5, 2, 4, 5]]

salas = 1

solution = [[1, 1, 1, 1, 2, 2, 2, 2],
            [1, 1, 1, 1, 1, 1, 1, 1],
            [1, 8, 23, 33, 1, 26, 13, 42]]

plot_solution_2(surgeries, salas, solution, "toy1")