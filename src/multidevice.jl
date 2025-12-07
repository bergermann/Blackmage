
struct MultiDevice
    mc::Dict{Int,IPv4}
    ids::Dict{Int,IPv4}

    function MultiDevice(mc,ids)
        @assert length(mc) == length(ids) && all(k->in(k,keys(ids)),keys(mc))
            "mc and ids addresses need matching keys."

        new(mc,ids)
    end

    function MultiDevice(mc::AbstractArray{IPv4},ids::AbstractArray{IPv4})
        @assert length(mc) == length(ids) "Need matching amount of mc and ids addresses."

        new(
            Dict(i=> mc[i] for i in eachindex(mc)),
            Dict(i=>ids[i] for i in eachindex(ids)),
        )
    end
end

const MD = MultiDevice

import Base.getindex
Base.getindex(md::MultiDevice,idx) = (md.mc[idx],md.ids[idx])


