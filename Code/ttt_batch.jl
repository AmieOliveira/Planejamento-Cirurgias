using CSV, DelimitedFiles, DataFrames, Printf
using Debugger
using Statistics

include("helper.jl")
include("io.jl")
include("naive_1.jl")
include("alns.jl")

# data_dir = "Dados/"
data_dir = "../Dados/"
fileData = ("randomFit_r5_s100_t16-4", 8, 1939500, 1000) # I6
           #("randomFit_r2_s15_t8-4", 2, 260870, 30)                   # I1
           #("randomFit_r2_s15_t16-4", 2, 427778, 30)                  # I2
           #("randomFit_r2_s50_t8-4", 2, 383300, 1000)                 # I3
           #("randomFit_r2_s50_t16-4", 2, 1497200, 1000)               # I4
           #("randomFit_r5_s100_t8-4", 6, 1526900, 1000)               # I5
           #("randomFit_r5_s100_t16-4", 8, 1939500, 1000)              # I6
           #("fullrand_s50_p1-4_w20_t6-20_e4_g12", 3, 9680, 200)       # I7
           #("Indefinidas - i8", 7, 47200, 1000)                       # I8
           #("Indefinidas - i9", 6, 40800, 200)                        # I9
           #("Indefinidas - i10", 10, 98400, 1000)                     # I10
           #("Indefinidas - i11", 15, 139500, 1000)                    # I11
           #("fullrand_s70_p1-4_w20_t5-20_e5_g20", 3, 19825*1.1, 1000) # I12
           #("fullrand_s70_p1-4_w30_t5-20_e3_g15", 4, 20100, 1000)     # I13
           #("fullrand_s90_p1-4_w20_t6-20_e5_g20", 7, 15750, 500)      # I14

out = "allOps_10-5-15_"
# randOnly
# rand+greedy
# rand+greedy+worst
# rand+greedy+worst+shaw
# allOps
out_dir = "../TTTplots/"

	# ("randomFit_r2_s15_t8-4", 2)
	# ("randomFit_r2_s15_t16-4", 2)
	# ("randomFit_r2_s50_t8-4", 2)
	# ("randomFit_r2_s50_t16-4", 2)
	# ("randomFit_r5_s100_t8-4", 6)
	# ("randomFit_r5_s100_t16-4", 8)
	# ("fullrand_s50_p1-4_w20_t6-20_e4_g12", 3)
	# ("fullrand_s70_p1-4_w20_t5-20_e5_g20", 3, 19825, 1000) # 19468*1.2
	# ("fullrand_s70_p1-4_w30_t5-20_e3_g15", 4)
	# ("fullrand_s90_p1-4_w20_t6-20_e5_g20", 7)
	# ("Indefinidas - i8", 7)
	# ("Indefinidas - i9", 6)
	# ("Indefinidas - i10", 10), 98400
	# ("Indefinidas - i11", 15)

# Número de repetições
N = 50

# ALNS variables:
SA_MAX = 1000
SA_MAX_NO_IMP = 500
ALPHA = 0.95
T_INI = 60
T_FIM = 0.1
R = 0.1
SIGMA1 = 10
SIGMA2 = 5
SIGMA3 = 15

function processALNS(instance, targt)
	solution = solve(instance, verbose=false)
	naive_fn = target_fn(instance, solution, false)

	solution, _ = alns_solve(instance, solution, 
					SA_max=SA_MAX, SA_max_no_improvement=SA_MAX_NO_IMP, 
					α=ALPHA, 
					T0=T_INI, Tf=T_FIM, 
					r=R, σ1=SIGMA1, σ2=SIGMA2, σ3=SIGMA3, 
					verbose=false,
					target = targt
	)

	alns_fn = target_fn(instance, solution, false)

	println("\tNaive target function: $naive_fn")
	println("\tALNS target function: $alns_fn")

	return alns_fn
end


rTimes = []

filename = fileData[1]
rooms = fileData[2]
targetValue = fileData[3]
t_teto = fileData[4]

println("$filename:")

surgeries = load_surgeries("$(data_dir)$(filename).csv") 
instance = (surgeries, rooms)
instance_results = []

open("$(out_dir)ttt_$(out)_N$(N)_t$(trunc(Int, targetValue))_$(filename).dat", "w") do io
	for i in 1:N
		output = @timed processALNS(instance, targetValue)
		alns_fn = output[1]
		ctime = output[2]

		if alns_fn > targetValue
			ctime = t_teto
		end

		push!(rTimes, ctime)

		writedlm(io, ctime)
	end
end