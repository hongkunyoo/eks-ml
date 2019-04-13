import os, sys, json, time
from tqdm import tqdm


#######################
# parameters
#######################
epochs = int(sys.argv[1])
activate = sys.argv[2]
dropout = float(sys.argv[3])

print(sys.argv)

#######################
# Out of memory Error
#######################
arr = []
pbar = tqdm(range(1000))
pbar.set_description("Training")
for i in pbar:
    a = bytearray(10000000)
    time.sleep(0.1)
    arr.append(a)


