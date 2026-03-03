module Data

using delimitedFiles

struct InstanceData
    instance_name::String
    numItems::Int64 #número de items
    numPeriods::Int64 #número de Períodos
    capacity::Int64 #capacidade das máquinas
    productionCost::Matrix{Int64} #custo de produção
    setupCost::Matrix{Int64} #custo de setupCost
    inventoryCost::Matrix{Int64} #custo de estoque
    productionTime::Matrix{Int64} #tempo de produção
    setupTime::Matrix{Int64} #tempo de setup
    demand::Matrix{Int64} #demanda por período
end

export IntanceData

end