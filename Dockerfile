# Use nvidia/cuda image
FROM --platform=linux/amd64 nvidia/cuda:12.0.0-devel-ubuntu22.04

# set bash as current shell
RUN chsh -s /bin/bash
SHELL ["/bin/bash", "-c"]

# install miniconda
RUN apt-get update
RUN apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 \ 
        git mercurial subversion gcc make apt-transport-https build-essential && \
        apt-get clean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
        /bin/bash ~/miniconda.sh -b -p /opt/conda && \
        rm ~/miniconda.sh && \
        ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
        echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
        find /opt/conda/ -follow -type f -name '*.a' -delete && \
        find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
        /opt/conda/bin/conda clean -afy

# set path to conda
ENV PATH /opt/conda/bin:$PATH

# setup conda virtual environment
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.yaml /tmp/requirements.yaml
RUN conda update conda \
    && conda env create --name speedi-seg -f /tmp/requirements.yaml

RUN echo "conda activate speedi-seg" >> ~/.bashrc
ENV PATH /opt/conda/envs/speedi-seg/bin:$PATH
ENV CONDA_DEFAULT_ENV $speedi-seg

#for getting all the prerained embeddings
RUN cd src/pre_train && \
gdown https://drive.google.com/uc?id=1n1sPXvT34yXFLT47QZA6FIRGrwMeSsZc && \
unzip pretrained.zip

# # Base OS
# FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

# # Install Build Utilities
# RUN apt-get update && \
# apt-get install -y gcc make apt-transport-https ca-certificates build-essential

# # set the working directory for containers
# WORKDIR /app

# # Copy Files
# COPY requirements.txt /app

# # Install Dependencies
# RUN pip install -q -r requirements.txt
# RUN apt-get install -qq libportaudio2

# #for getting all the prerained embeddings
# RUN cd src/pre_train && \
# gdown https://drive.google.com/uc?id=1n1sPXvT34yXFLT47QZA6FIRGrwMeSsZc && \
# unzip pretrained.zip

# # Test Env
# RUN python3 demo_cli.py
