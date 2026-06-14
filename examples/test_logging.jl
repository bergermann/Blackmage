
using Blackmage

using HDF5, Dates

ndisk = 3

file = h5open("testfile.h5","cw")

t0 = now()
file["t0"] = t0.instant.periods.value

create_dataset(file,"data",Int,dataspace((1+3ndisk,1000),(1+3ndisk,-1));
    chunk=(1+3*ndisk,1000))

create_dataset(file,"test",Int,(1,))
create_dataset(file,"test1",Int,1)
create_dataset(file,"test2",Int)

read(file["test2"])