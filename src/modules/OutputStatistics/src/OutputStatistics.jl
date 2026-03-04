module OutputStatistics

using Data
using Parameters
using Dates

Base.@kwdef mutable struct StatisticsData

    date::String = string(Dates.today())
    approach::String = ""
    best_LB::Float64 = -1e12
    best_UB::Float64 = 1e12
    cg_iters::Int64 = 0
    cg_cols::Int64 = 0
    gap::Float64 = 100
    total_time::Float64 = 0.0
    sol_status = 0

end

mutable struct StdFormModelSolution
    primal_bound::Float64
    dual_bound::Float64 
    x::Array{Float64}
    s::Array{Float64}
    y::Array{Float64}
    status
end

export StatisticsData, setup_MIP_stats_file, setup_col_gen_stats_file, init_std_form_solution, StdFormModelSolution

function init_std_form_solution(data::InstanceData)
    
    primal_bound = 1e8
    dual_bound = -1e8
    x = Array{Float64}(undef, data.numItems,  data.numPeriods)
    fill!(x, 0.0)
    s = Array{Float64}(undef, data.numItems,  data.numPeriods)
    fill!(s, 0.0)
    y = Array{Float64}(undef, data.numItems,  data.numPeriods)
    fill!(y, 0.0)
    status = 0

    solution = StdFormModelSolution(primal_bound, dual_bound, x, s, y, status)
            
    return solution
end

function setup_MIP_stats_file(parameters::ExperimentParameters)
  
    output_file_path = "src/outputFiles/tables/"

    output_file_path = output_file_path * "/$(Int64(parameters.total_time_limit))s/"

    mkpath(output_file_path)

    date_time = Dates.now()
    time_stamp = string(Dates.today(), "-",
        Dates.hour(date_time), "h",
        Dates.minute(date_time), "m",
        Dates.second(date_time), "s")
    output_file = output_file_path * time_stamp

    out = open(output_file,"w")

    println(out, "Statistics for LSP")
    println(out, "Date: ", string(Dates.today()))

    println(out, "Approach: MIP solver")

    println(out, "Time limit: ", parameters.total_time_limit)
    println(out, "MIP gap tolerance: ", parameters.MIP_gap_tolerance)
    println(out, "Integer feasibility tolerance: ", parameters.integer_feasibility_tolerance)
    println(out, "Number of threads: ", parameters.number_of_threads)
    println(out, "Screen output: ", parameters.screen_output)

    print(out, "\nInstance & numItems & numPeriods & LB & UB & gap & status & total_time \\\\")

    close(out)

    return output_file
end

function print_MIP_stats!(data::InstanceData, parameters::ExperimentParameters, stats::StatisticsData, stats_file::String)
    out = open(stats_file,"a")

    print(out, "\n", data.instance_name, " & ",
        data.numItems, " & ",
        data.numPeriods, " & ",

        round(stats.best_LB, digits = 4), " & ",
        round(stats.best_UB, digits = 4), " & ",
        round(stats.gap, digits = 4), " & ",
        stats.sol_status, " & ",
        round(stats.total_time, digits = 2), " \\\\")   

    close(out)

    return
end

function setup_col_gen_stats_file(parameters::ExperimentParameters)
  
    output_file_path = "src/outputFiles/tables/"

    output_file_path = output_file_path * "/$(Int64(parameters.total_time_limit))s/"

    mkpath(output_file_path)

    date_time = Dates.now()
    time_stamp = string(Dates.today(), "-",
        Dates.hour(date_time), "h",
        Dates.minute(date_time), "m",
        Dates.second(date_time), "s")
    output_file = output_file_path * time_stamp

    out = open(output_file,"w")

    println(out, "Statistics for GAP")
    println(out, "Date: ", string(Dates.today()))

    println(out, "Approach: Column generation")

    println(out, "General parameters:")
    println(out, "Time limit: ", parameters.total_time_limit)
    println(out, "MIP gap tolerance: ", parameters.MIP_gap_tolerance)
    println(out, "Integer feasibility tolerance: ", parameters.integer_feasibility_tolerance)
    println(out, "Number of threads: ", parameters.number_of_threads)
    println(out, "Screen output: ", parameters.screen_output)

    print(out, "\nInstance & numItems & numPeriods  & LB & Iter & Cols & status & total_time \\\\")

    close(out)

    return output_file
end

function print_col_gen_stats!(data::InstanceData, parameters::ExperimentParameters, stats::StatisticsData, stats_file::String)
    out = open(stats_file,"a")

    print(out, "\n", data.instance_name, " & ",
        data.numItems, " & ",
        data.numPeriods, " & ",

        round(stats.best_LB, digits = 4), " & ",
        round(stats.best_UB, digits = 4), " & ",
        stats.cg_iters, " & ",
        stats.cg_cols, " & ",
        round(stats.total_time, digits = 2), " \\\\")   

    close(out)

    return
end

end
