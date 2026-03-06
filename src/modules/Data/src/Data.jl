module Data

using delimitedFiles
using Parameters

struct InstanceData
    instance_name::String
    numItems::Int64                 #número de items
    numPeriods::Int64               #número de Períodos
    capacity::Int64                 #capacidade de cada máquina
    productionCost::Int64           #custo de produção unumItemstário
    setupCost::Array{Float64}       #custo de setupCost
    inventoryCost::Array{Float64}   #custo de estoque unumItemstário
    productionTime::Array{Float64}  #tempo de produção unumItemstário
    setupTime::Array{Float64}       #tempo de setup
    demand::Array{Float64}          #tempo de demanda determinística
    bigm::Array{Int64}              # bigM_coefficients 
end

export IntanceData, readìnstance, print_instance_file

function read_instance(instance_file::String,params::ExperimentParameters)

    println("RunnumItemsng Data.readData with file $(instance_file)")

    name = instance_file

    data = readdlm(instance_file)

    numItems = data[1, 1]
    numPeriods = data[1, 2]
    productionCost = data[2, 1]
    capacity = data[3, 1]

    productionTime = Array{Float64}(undef, numItems)
    inventoryCost = Array{Float64}(undef, numItems)
    setupTime = Array{Float64}(undef, numItems)
    setupCost = Array{Float64}(undef, numItems)

    for i in 1:numItems
        productionTime[i] = data[3+i, 1]
        inventoryCost[i] = data[3+i, 2]
        setupTime[i] = data[3+i, 3]
        setupCost[i] = data[3+i, 4]
    end

    demand = Array{Int64}(undef, numItems, numPeriods)
    for i in 1:numItems
        for t in 1:numPeriods
            if i < 16
                demand[i,t] = data[3 + numItems  + t , i]
            end
            if i >= 16
                demand[i,t] = data[3 + numItems + t, i-15]
            end
        end
    end

    if params.periods_ahead >= numPeriods-1
        BigM = Array{Int64}(undef, numItems, numPeriods)
        
        fill!(BigM, 0)
        for i in 1:numItems
            for t in 1:numPeriods
                BigM[i,t] =  min(floor((capacity / productionTime[i])-setupTime[i]), sum(demand[i,j] for j=t:numPeriods))
            end

        end
    else

        periods_ahead = params.periods_ahead
        sum_demand = Array{Int64}(undef, numItems, numPeriods)
        for i in 1:numItems
            for t in 1:numPeriods
                sum_demand[i,t] = sum(demand[i,j] for j=t:min(t+periods_ahead,numPeriods))
            end
        end

        BigM = Array{Int64}(undef, numItems, numPeriods)
    
        fill!(BigM, 0)
        for i in 1:numItems
            for t in 1:numPeriods
                BigM[i,t] =  min(floor((capacity / productionTime[i])-setupTime[i]), sum_demand[i,t] )
            end

        end

    end
   
    instance = InstanceData(name, numItems, numPeriods, capacity, productionCost, setupCost, inventoryCost, productionTime, setupTime, demand, BigM)

    return instance

end

end