module MasterProblem

using JuMP
using Gurobi
using Data
using OutputStatistics
using Parameters

mutable struct MasterSolution
    numItems::Int64
    numPeriods::Int64
    primal_bound::Float64
    dual_bound::Float64
    lambda::Array{Float64}
    duals_capacity::Array{Float64}
    duals_conv::Array{Float64}
    columns::Array{ColumnData}
    status
end

export MasterSolution, create_master, solve_master

function create_master(data::InstanceData, model::Model)
    I = 1:data.numItems
    T = 1:data.numPeriods

    num_cols = data.numItems

    columns = Array{columnData}(undef, num_cols)

    production = Array{Int64}(undef, data.numPeriods)
    setups = Array{Int64}(undef, data.numPeriods)
    inventory = Array{Int64}(undef, data.numPeriods)
    capacity_cons = Array{Int64}(undef, data.numPeriods)
    conv_coeffs = Array{Int64}(undef, data.numPeriods)

    for i in I
        fill!(production, 0)
        fill!(setups, 0)
        fill!(inventory, 0)
        fill!(capacity_cons, 0)
        fill!(conv_coeffs, 0)

        name = "art_$i"
        cost = 1000000
        conv_coeffs[i] = 1

        columns[i] = ColumnData(i, name, cost, setups, production, inventory, capacity_cons, conv_coeffs)
    end

    #====================== model =====================#
    @variable(model, 0 <= lambda[1:num_cols] <= 1)

    @objective(model, Min, sum(columns[col].cost * lambda[col] for col in 1:num_cols))

    @constraint(model, cap_constrs[t in T], sum(columns[col].capacity_cons * lambda[col] for col in 1:num_cols) <= data.cap)

    @constraint(model, conv_constrs[i in I], lambda[i] >= 1)

    status = 0

    lambda_val = Array{Folat64}(undef, num_cols)
    xDualCosts = Array{Folat64}(undef, data.numItems, data.numPeriods)
    yDualCosts = Array{Folat64}(undef, data.numItems, data.numPeriods)
    conv_duals = Array{Float64}(undef, data.numItems)

    fill!(lambda_val, 0.0)
    fill!(xDualCosts, 0.0)
    fill!(yDualCosts, 0.0)
    fill!(conv_duals, 0.0)

    master_sol = MasterModelSolution(
        1000000,
        1000000,
        lambda_val,
        xDualCosts,
        yDualCosts,
        conv_duals,
        status,
        columns)

    return master_sol
end

function solve_master_model!(model, sol::MasterModelSolution, data::instance_data)
    optimize!(model)

    sol.status = termination_status(model)
    if has_values(model) == true
        sol.obj = objective_value(model)
        integer_sol = true

        num_cols = length(sol.columns)
        sol.lambda = Array{Float64}(undef, num_cols)
        fill!(sol.lambda, 0.0)

        for col = 1:num_cols
            if value(model[:lambda][col]) > 0.00001
                sol.lambda[col] = value(model[:lambda][col])

                if value(model[:lambda][col]) > 0.00001 && value(model[:lambda][col]) < 0.99999
                    integer_sol = false
                end
            end
        end
    end

    if has_duals(model) == true
        for item = 1:data.NI
            for per = 1:data.NT
                sol.xDualCosts[item, per] = data.productionCost - (data.productionTime[item] * dual(model[:cap_constrs][per]))
                sol.yDualCosts[item, per] = data.setupCost[item] - (data.setupTime[item] * dual(model[:cap_constrs][per]))
            end
            
            sol.conv_duals[item] = dual(model[:conv_constrs][item])
        end
    end

    if integer_sol
        sol.primal_bound = sol.obj
        println("New integer solution found: ", sol.primal_bound)
    end
    
    return integer_sol

end


end