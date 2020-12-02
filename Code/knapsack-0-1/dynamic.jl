function solve_dynamic(objs, capacity)
    n = length(objs)
    m = zeros(n+1, capacity+1)
    S = Matrix{Array{Int32}}(undef, n+1, capacity+1)

    for i = 1:(n+1)
        for j = 1:(capacity+1)
            S[i, j] = []
        end
    end

    for i = 2:(n+1)
        for j = 1:(capacity+1)
            p, w = objs[i - 1]
            if w > (j - 1)
                m[i, j] = m[i-1, j]
                S[i, j] = S[i-1, j]
            else
                # m[i, j] = max(m[i-1, j], m[i-1, j-w] + p)
                if m[i-1, j-w] + p > m[i-1, j]
                    m[i, j] = m[i-1, j-w] + p
                    S[i, j] = [S[i-1, j-w] ; i-1]
                else
                    m[i, j] = m[i-1, j]
                    S[i, j] = S[i-1, j]
                end
            end
        end
    end

    S, m
end