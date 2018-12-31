FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu14.04
RUN apt-get update

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

### Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

############Install MiniConda, Java, Python and other dependencies##########
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV OPENBLAS_NUM_THREADS $(nproc)

RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \

    apt-get update -y && \
    apt-get install -y --no-install-recommends \

    tmux \
    htop \

    wget \
    vim \
    git \
    g++ \
    graphviz \

    sshfs \

    software-properties-common \
    python-software-properties \
    python3-dev \

    libffi-dev \
    libssl-dev \
    openssh-client \

    libhdf5-dev \
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    gfortran && \

    ### ffmpeg
    add-apt-repository ppa:mc3man/trusty-media -y && \
    apt-get update -y && \
    apt-get install ffmpeg gstreamer0.10-ffmpeg -y && \

    ### Java ###
    add-apt-repository ppa:openjdk-r/ppa -y && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless && \

    rm -rf /var/lib/apt/lists/* && \

    ### Minicoda ###
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh

########################MPI##########################
RUN cd /tmp && \
        wget "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz" && \
        tar xzf openmpi-3.1.2.tar.gz && \
        cd openmpi-3.1.2  && \
        ./configure --with-cuda && make -j"$(nproc)" install && ldconfig
        #ompi_info --parsable --all | grep -q "mpi_built_with_cuda_support:value:true" # && ldconfig

########################NCCL###########################
ENV CPATH /usr/local/cuda/include:/usr/local/include:$CPATH

####################Setup User##########################
ENV NB_USER chainer
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER -g sudo -p $(perl -e'print crypt("chainer", "aa")') && \
    mkdir -p $CONDA_DIR && \
    chown chainer $CONDA_DIR -R && \
    mkdir -p /src && \
    chown -R chainer /src

USER chainer

#######################Python 3#########################
#RUN conda config --set channel_priority false
RUN conda install -y python=3.6 cudatoolkit=8 tensorflow-gpu=1.4 tensorboard
RUN pip install --upgrade pip

RUN pip install --no-cache-dir  plotly pygame pydot_ng graphviz networkx gizeh
RUN pip install --no-cache-dir  opencv-contrib-python
RUN pip install --no-cache-dir  imutils pipdate pythreejs 
RUN pip install --no-cache-dir  jupyter jupyterlab 

### PyTorch
RUN conda install -c pytorch -c fastai fastai pytorch-nightly torchvision magma-cuda80
RUN pip install --no-cache-dir  pyro-ppl 
RUN pip install --no-cache-dir  torchtext 
RUN pip install --no-cache-dir  gpytorch
RUN pip install --no-cache-dir  git+https://github.com/pytorch/tnt.git@master 

## TF, Keras, Mxnet and Theano
RUN conda install theano 
RUN pip install --no-cache-dir  keras #libgcc 
RUN pip install --no-cache-dir  mxnet-cu80

### Edward, tensorly, allennlp, textacy
RUN pip install --no-cache-dir  edward textacy 
RUN pip install --no-cache-dir  tensorly
RUN pip install --no-cache-dir  git+https://github.com/neka-nat/tensorboard-chainer.git

RUN conda install \
    'ipyparallel' \
    'bokeh' \
    'cloudpickle' \
    'cython' \
    'hdf5' \
    'numba' \
    'patsy' \
    'scikit-image' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy'
#    'numexpr' \
#    'pandas' \
#    'pyyaml' \
#    'scikit-learn' \
#    'pillow' \
#    'notebook' \
#    'matplotlib' \
#    'nose' \
#    'six' \
#    'h5py' \
#    'numpy' \
#    'mock' \
#    'jsonschema' \
#    'boto' \
#   #'nomkl' \
#    'ipywidgets' \
#    'scipy' \
#    'dill' \

##RUN conda config --set channel_priority true
##RUN conda update --all
RUN conda clean -ypt

RUN git clone https://github.com/facebookresearch/ParlAI.git ~/ParlAI && \
    cd ~/ParlAI; python setup.py develop && cd ~
######################################################
### Install Chainer (inc. exts)
RUN pip install --no-cache-dir  ideep4py optuna pex
RUN pip install --no-cache-dir  mpi4py einops
RUN pip install --no-cache-dir cupy-cuda80==6.0.0b1 chainer==6.0.0b1
RUN pip install --no-cache-dir  chainercv chainerrl chainerui && \
    chainerui db create && chainerui db upgrade

ENV CHAINER_USE_IDEEP 'auto'
######################################################


ENV PYTHONPATH /src/:$PYTHONPATH
#ENV LD_PRELOAD $CONDA_DIR/lib/libstdc++.so.6.0.25
ENV MPLBACKEND 'agg'

WORKDIR /src

#USER root
#COPY jupyter_setup.sh /src
#RUN /src/jupyter_setup.sh
#USER chainer

CMD jupyter lab --no-browser --port=8888 --ip=0.0.0.0 --allow-root
