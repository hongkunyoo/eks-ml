import os, sys, json, time
from tqdm import tqdm

import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import RMSprop


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
for i in tqdm(range(1000)):
    a = bytearray(12000000)
    time.sleep(0.1)
    arr.append(a)

