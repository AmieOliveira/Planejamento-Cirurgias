using Random

n_s = 50 # total number of surgeries to generate
p_min = 1 # minimum priority (warning: should be between [1;4])
p_max = 4 # maximum priority (warning: should be between [1;4])
w_min = 1 # minimum waiting time of a surgery
w_max = 20 # maximum waiting time of a surgery
n_e = 4 # total number of specialties
n_g = 4 # total number of surgeons
t_min = 2 # minimum duration of a surgery
t_max = 20 # maximum duration of a surgery

function generate_uniform_instances(n_s, p_min, p_max, w_min, w_max, n_e, n_g, t_min, t_max)
    surgeries = DataFrame(
        Symbol("Cirurgia (c)") => [],
        Symbol("Prioridade (p)") => [],
        Symbol("Dias_espera (w)") => [],
        Symbol("Especialidade (e)") => [],
        Symbol("Cirurgião (h)") => [],
        Symbol("Duração (tc)") => [])
        
    for i in 1:n_s
        surgery = [i, rand(p_min:p_max), rand(w_min:w_max), 
            rand(1:n_e), rand(1:n_g), rand(t_min:t_max)]
        push!(surgeries, surgery)
    end

    surgeries
end

if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) == 1
        using CSV, DataFrames
        filepath = ARGS[1]

        surgeries = generate_uniform_instances(n_s, p_min, p_max, 
            w_min, w_max, n_e, n_g, t_min, t_max)
        CSV.write(filepath, surgeries)
    end
end