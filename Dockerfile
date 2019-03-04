FROM python:3.6.8-stretch

RUN pip install tensorflow==1.5
RUN pip install keras==2.0.8
RUN pip install h5py==2.7.1
RUN pip install tqdm

ADD train.py .
ADD train-oom.py .
