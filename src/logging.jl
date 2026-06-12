


function extend_write_to(dset::HDF5.Dataset,data::AbstractArray,extension::Tuple,
        inds::Union{Colon,Integer}...)

    dims = HDF5.get_extent_dims(dset)

    @assert length(dims) == length(extension) == length(inds) "Dimension mismatch for dataset or extension size."

    if all(@. ifelse(inds isa Integer,inds,0) <= dims[1])
        dset[inds...] = data
    else
        @assert all(@. sign(dims[2])*(dims[1]+extension) <= dims[2]) "Maximum dataset size is exceeded."

        if all(@. ifelse(inds isa Integer,inds,0) <= dims[1]+extension)
            HDF5.set_extent_dims(ds,dims[1].+extension)
            dset[inds...] = data
        else
            throw(HDF5.API.H5Error("Error extending dataset. Indices are out of extension bounds."))
        end
    end

    return
end

function extend_write_to(dset::HDF5.Dataset,data::AbstractArray,extension::Tuple,
        inds::Union{Colon,AbstractRange{<:Integer}}...)

    dims = HDF5.get_extent_dims(dset)

    @assert length(dims) == length(extension) == length(inds) "Dimension mismatch for dataset or extension size."

    if all([(inds[i] isa Colon ? 0 : maximum(inds[i])) <= dims[1][i] for i in eachindex(inds)])
        dset[inds...] = data
    else
        @assert all(@. sign(dims[2])*(dims[1]+extension) <= dims[2]) "Maximum dataset size is exceeded."

        if all([(inds[i] isa Colon ? 0 : maximum(inds[i])) <= dims[1][i]+extension[i] for i in eachindex(inds)])
            HDF5.set_extent_dims(ds,dims[1].+extension)
            dset[inds...] = data
        else
            throw(HDF5.API.H5Error("Error extending dataset. Indices are out of extension bounds."))
        end
    end

    return
end

function log_booster_state(md::MultiDevice,filepath::String; timeout::Int=0)
    
end