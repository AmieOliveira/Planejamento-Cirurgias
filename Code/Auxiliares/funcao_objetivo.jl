# Sugestao de F.O.
#   target_fn calcula o total da solucao, e chama eval_surgery para 
#       calcular o custo de cada agendamento
#
# Entradas:
#   surgeries: Lista das cirurgias (com todas as infos do CSV)
#   solution: Lista com as listas dos dias, das salas e dos horários
#               de cada Cirurgia 
#   verbose: colocar true se quiser printar o custo de cada cirurgia

using Printf

penalidades = [90, 20, 8, 3]

function eval_surgery(surgery, penalties, scd, verbose)
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

function target_fn(surgeries, solution, verbose=false)
    sc_d, sc_r, sc_h = solution

    total = 0
    for s in surgeries
        # println("f$(s) = $(eval_surgery(s, penalties, sc_d, sc_r, sc_h))")
        total += eval_surgery(s, penalidades, sc_d[s[1]], verbose)
    end
    
    total
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

solution = [[1, 1, 1, 1, 2, 2, 2, 2],
            [1, 1, 1, 1, 1, 1, 1, 1],
            [1, 8, 23, 33, 1, 26, 13, 42]]

target_fn(surgeries, solution, true)