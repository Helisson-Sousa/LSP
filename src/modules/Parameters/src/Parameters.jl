module Parameters

using JuMP
using DelimitedFiles

Base.@kwdef mutable struct ExperimentParameters
    approach::String = MIP_solver # {MIP_solver, col_gen}
    total_time_limit::Float64 = 600 # Total time limit for approach in seconds
    MIP_gap_tolerance::Float64 = 1e8
    integer_feasibility_tolerance::Float64 = 1e6
    number_of_threads::Int64 = 1
    screen_output::Int64 = 1
    periods_ahead::Int64 = 20  # number of periods ahead to consider in the BigM formulation. If periods_ahead == 0, then BigM is not used
end

export ExperimentParameters, read_parameters, set_solver_parameters

function read_parameters(parameters_file::String)
    param_data = readdlm(parameters_file)

    approach = param_data[1,2]
    total_time_limit = param_data[2,2]
    MIP_gap_tolerance = param_data[3,2]
    integer_feasibility_tolerance = param_data[4,2]
    number_of_threads = param_data[5,2]
    screen_output = param_data[6,2]
    periods_ahead = param_data[7,2] 

    parameters = ExperimentParameters(
        approach,
        total_time_limit,
        MIP_gap_tolerance,
        integer_feasibility_tolerance,
        number_of_threads,
        screen_output,
        periods_ahead
    )

    return parameters
end

function set_solver_parameters(model::Model, parameters::ExperimentParameters)
    
    set_optimizer_attributes(model,
                            "TimeLimit" => parameters.total_time_limit,
                            "MIPGap" => parameters.MIP_gap_tolerance,
                            "IntFeasTol" => parameters.integer_feasibility_tolerance,
                            "Threads" => parameters.number_of_threads,
                            "LogToConsole" => parameters.screen_output)

end

end
