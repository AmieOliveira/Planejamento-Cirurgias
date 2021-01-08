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
deadlines = [3, 15, 60, 365]

function eval_surgery(surgery, scd, verbose)
    idx_s, p_s, w_s, e_s, g_s, t_s = surgery
    scheduled = (scd != nothing)

    is_scheduled = (day_scheduled != nothing)
    total_days = w_s + 2 + (is_scheduled ? day_scheduled : 7)
    exceeded_deadline = (total_days > (deadlines[p_s] + 1))
    cost = 0

    if p_s == 1 && day_scheduled != 1
        cost += (10 * (w_s + 2)) ^ (is_scheduled ? day_scheduled : 7)
    end

    if is_scheduled
        cost += (w_s + 2 + day_scheduled) ^ 2
        if exceeded_deadline
            cost += (w_s + 2 + day_scheduled - deadlines[p_s]) ^ 2
        end
    else
        cost += penalidades[p_s] * (w_s + 5 + 2) ^ 2
        if exceeded_deadline
            cost += penalidades[p_s] * (w_s + 5 + 2*2 - deadlines[p_s]) ^ 2
        end
    end

    if verbose
        str = is_scheduled ? "scheduled" : "not scheduled"
        println("Surgery $(idx_s) was $(str). Cost: $(cost)")
    end

    cost
end

function target_fn(surgeries, solution, verbose=false)
    sc_d, sc_r, sc_h = solution

    total = 0
    for s in surgeries
        total += eval_surgery(s, sc_d[s[1]], verbose)
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