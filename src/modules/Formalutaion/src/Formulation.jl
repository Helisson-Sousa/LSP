module Formulation

using JuMP
using Gurobi
using Data
using OutputStatistics
using Parameters

function create_model!(data::InstanceData, model::Model)
    I = 1:data.numItems
    T = 1:data.numPeriods
    M = 1e6

    #@variable(model, 0 <= x[i in I, j in J] <= 1)
    @variable(model, x[i in I, t in T] >= 0)
    @variable(model, s[i in I, t in T] >= 0)
    @variable(model, y[i in I, t in T], Bin)

    @objective(model, Min, 
        sum(data.productionCost[i, t] * x[i, t] 
        + data.setupCost[i, t] * y[i, t]
        + data.inventoryCost[i, t] * s[i, t]
        for i in I, t in T))

    @constraint(model, constrCapacity[t in T], 
        sum(data.productionTime[i, t] * x[i, t] +
        data.setupTime[i, t] * y[i,t] 
        for i in I) <= data.capacity[t])
            
    @constraint(model, constrDemand[i in I, t in T], 
        s[i, t-1] + x[i, t] == data.demand[i, t] + s[i, t])

    @constraint(model, constrProduction[i in I, t in T], 
            x[i, t] <= M[i, t] * y[i, t])

    x_sol = Array{Float64}(undef, data.numItems, data.numPeriods)
    fill!(x_sol, 0.0)

    s_sol = Array{Float64}(undef, data.numItems, data.numPeriods)
    fill!(s_sol, 0.0)

    y_sol = Array{Float64}(undef, data.numItems, data.numPeriods)
    fill!(y_sol, 0.0)
    
    return solution
end

function solve_model!(data::InstanceData, model::Model, solution::StdFormModelSolution, stats::StatisticsData)
    
    I = 1:data.numItems
    T = 1:data.numPeriods

    optimize!(model)

    solution.status = termination_status(model)

    if has_values(model)
        solution.primal_bound = objective_value(model)
        solution.dual_bound = objective_bound(model)

        stats.total_time = solve_time(model)
        stats.best_LB = solution.dual_bound
        stats.best_UB = solution.primal_bound
        stats.gap = 100 * ((stats.best_UB - stats.best_LB) / stats.best_UB)

        for i in I
            for t in T
                solution.x[i,t] = value(model[:x][i,t])
                solution.s[i,t] = value(model[:s][i,t])
                solution.y[i,t] = value(model[:y][i,t])
            end
        end
    end
end

function print_solution(solution::StdFormModelSolution)

    println("Status: ", solution.status)
    println("Primal Bound: ", solution.primal_bound)
    println("Dual Bound: ", solution.dual_bound)
    println("Variable x values:")
    for i in 1:size(solution.x, 1)
        for t in 1:size(solution.x, 2)
            if solution.x[i,t] > 1e-6
                print("x[$i,$t] = ", solution.x[i,t], " ")
            end
        end
    end
    println("Variable s values:")
    for i in 1:size(solution.s, 1)
        for t in 1:size(solution.s, 2)
            if solution.s[i,t] > 1e-6
                print("s[$i,$t] = ", solution.s[i,t], " ")
            end
        end
    end
    println("Variable y values:")
    for i in 1:size(solution.y, 1)
        for t in 1:size(solution.y, 2)
            if solution.y[i,t] > 1e-6
                print("y[$i,$t] = ", solution.y[i,t], " ")
            end
        end
    end
end

end