module Data

using DelimitedFiles
using Parameters
struct InstanceData
    instance_name::String    # Instance Name
    NI::Int64           # Number of Items
    NT::Int64           # Number of Periods
    cap::Int64   # Capacity of each machine
    pc::Int64  # Unitary Production Cost
    sc::Array{Float64}  # Setup Cost
    hc::Array{Float64}  # Unitary Inventory Holding Cost
    pt::Array{Float64}  # Unitary Production Times
    st::Array{Float64}  # Setup Times
    dem::Array{Int64}   # Deterministic Demand at Time
    bigm::Array{Int64}  # bigM_coefficients
    #bigm2::Array{Int64} # bigM_coefficients2
end

export InstanceData, read_instance, print_instance_data

function read_instance(instance_file::String,params::ExperimentParameters)

    println("Running Data.readData with file $(instance_file)")

	name = instance_file
    

    # Read the data file as a matrix
    data = readdlm(instance_file)
    
    NI = data[1,1] # Get number of items
    NT = data[1,2] # Get number of periods
    pc = data[2,1] # Get unitary production cost
    cap = data[3,1] # Get capacity

    pt = Array{Float64}(undef, NI)
    hc = Array{Float64}(undef, NI)
    st = Array{Float64}(undef, NI)
    sc = Array{Float64}(undef, NI)
    

    

    for i in 1:NI
        pt[i] = data[3+i, 1]     # Get unitary resource consumptions
        hc[i] = data[3+i, 2]     # Get unitary inventory costs
        st[i] = data[3+i, 3]     # Get setup resource consumptions
        sc[i] = data[3+i, 4]     # Get setup costs
    end

   

    dem = Array{Int64}(undef, NI, NT)
    for i in 1:NI
        for t in 1:NT
            if i < 16
                dem[i,t] = data[3 + NI  + t , i]
            end
            if i >= 16
                dem[i,t] = data[3 + NI + t, i-15]
            end
        end
    end


    if params.periods_ahead >= NT-1
        if params.formulation == "clsp"

            BigM = Array{Int64}(undef, NI, NT)
            
            fill!(BigM, 0)
            for i in 1:NI
                for t in 1:NT
                    BigM[i,t] =  min(floor((cap / pt[i])-st[i]), sum(dem[i,j] for j=t:NT))
                end

            end
        else

            BigM = Array{Int64}(undef, NI, NT)
            
            fill!(BigM, 0)
            for i in 1:NI
                for t in 1:NT
                BigM[i,t] =  min(floor(cap / pt[i]), sum(dem[i,j] for j=t:NT))
                  
                end

            end
        end
    else

        periods_ahead = params.periods_ahead
        sum_dem = Array{Int64}(undef, NI, NT)
        for i in 1:NI
            for t in 1:NT
                sum_dem[i,t] = sum(dem[i,j] for j=t:min(t+periods_ahead,NT))
            end
        end
        if params.formulation == "clsp"

            BigM = Array{Int64}(undef, NI, NT)
        
            fill!(BigM, 0)
            for i in 1:NI
                for t in 1:NT
                    BigM[i,t] =  min(floor((cap / pt[i])-st[i]), sum_dem[i,t] )
                end

            end
        else

            BigM = Array{Int64}(undef, NI, NT)
            
            fill!(BigM, 0)
            for i in 1:NI
                for t in 1:NT
                    BigM[i,t] =  min(floor(cap / pt[i]), sum_dem[i,t] )
                end

            end
        end

    end
   


    instance = InstanceData(name, NI, NT, cap, pc, sc, hc, pt, st, dem, BigM)

    return instance

end

function print_instance_data(data::InstanceData)
    
    println("Number of items: ", data.NI)
    println("Number of periods: ", data.NT)
    println("\nProduction costs:", data)

    println("\nCapacity of each machine: ", data.cap)

    println("\nInventory holding costs for each item: ", data.hc)


    println("\nSetup costs:")
    for i in 1:data.numItems
        println("    Item $i: ", data.sc[i,:])
    end
    println("\nInventory holding costs")
    for i in 1:data.numItems
        println("    Item $i: ", data.hc[i,:])
    end

    println("\nProduction times:")
    for i in 1:data.numItems
        println("    Item $i: ", data.pt[i,:])
    end

    println("\nSetup times:")
    for i in 1:data.numItems
        println("    Item $i: ", data.st[i,:])
    end

 



    println("\nDemands:")
    for i in 1:data.numItems
        println("    Item $i: ", data.dem[i,:])
    end

end

end # module
