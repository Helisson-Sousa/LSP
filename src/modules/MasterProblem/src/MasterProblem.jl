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

    num_cols = data.numItems

    columns = Array{columnData}(undef, num_cols)

    capacity = Array{Float64}(undef, data.numPeriods)
    conv_coeffs = Array{Int64}(undef, data.numItems)

    #====================== model =====================#
    @variable(model, 0 <= lambda[1:num_cols] <= 1)
    @variable(model, Min, sum())
    
    


end

end