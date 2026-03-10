push!(LOAD_PATH, "src/modules/")

__precompile__

using Pkg 
Pkg.activate(".")

using JuMP
using Gurobi
using CPUTime
using DelimitedFiles
using Dates

import Data 
import OutputStatistics
import Parameters
import Formulation
import MasterProblem
import Pricing

# To run the code: julia clsp_colgen.jl <inputListFile> <parametersFile> <outputFile> 
#                                         [1]              [2]               [4]
# EXAMP
# julia src/LSP.jl src/input_files/inputList_test.txt src/parameters_file/parameters

function main(ARGS)
    date = string(Dates.today())
    date_time = Dates.now()
    hour = Dates.hour(date_time)
    minute = Dates.minute(date_time)
    second = Dates.second(date_time)

    # Read input list file
    inputlist_file = String(ARGS[1])
    input = readdlm(inputlist_file)

    # Read parameters file
    parameters_file = String(ARGS[2])
    params = Parameters.read_parameters(parameters_file)
    
    #Set Gurobi environment
    GRB_ENV = Gurobi.Env()
    
    if parameters.approach == "MIP_solver"
        output_file = OutputStatistics.setup_MIP_stats_file(parameters)
    elseif parameters.approach == "col_gen"
        output_file = OutputStatistics.setup_col_gen_stats_file(parameters)
    end


end