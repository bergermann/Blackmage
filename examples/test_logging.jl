
# using Blackmage

# using HDF5, Dates

# ndisk = 3

# file = h5open("testfile.h5","cw")

# t0 = now()
# file["t0"] = t0.instant.periods.value
# create_dataset(file,"t",Int)

# create_dataset(file,"data",Int,dataspace((1+6ndisk,1000),(1+6ndisk,-1));
#     chunk=(1+6*ndisk,1000))

# read(file["test2"])