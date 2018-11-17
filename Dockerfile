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


#####################CMAKE########################
ARG cmake_version=3.12
ARG cmake_iter=3
RUN cd /usr/local/src && \
    wget http://www.cmake.org/files/v${cmake_version}/cmake-${cmake_version}.${cmake_iter}.tar.gz && \
    tar xf cmake-${cmake_version}.${cmake_iter}.tar.gz && \
    cd cmake-${cmake_version}.${cmake_iter} && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    ldconfig



#################Spark dependencies################
ENV APACHE_SPARK_VERSION 2.3.2


# set default java environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# workaround for bug on ubuntu 14.04 with openjdk-8-jre-headless
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN cd /tmp && \
        wget http://apache.mirror.anlx.net/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7 spark


ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH
##ENV SPARK_OPTS --driver-java-options=-Xms2048M
##:--driver-memory=16g:--driver-java-options=-Dlog4j.logLevel=info


########################MPI##########################
RUN cd /tmp && \
        wget "https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz" && \
        tar xzf openmpi-3.1.2.tar.gz && \
        cd openmpi-3.1.2  && \
        ./configure --with-cuda && make -j"$(nproc)" install && ldconfig
        #ompi_info --parsable --all | grep -q "mpi_built_with_cuda_support:value:true" # && ldconfig

########################NCCL###########################
ENV CPATH /usr/local/cuda/include:/usr/local/include:$CPATH
#RUN cd /usr/local && git clone https://github.com/NVIDIA/nccl.git && cd nccl && \
#        make CUDA_HOME=/usr/local/cuda -j"$(nproc)" && \
#        make install && ldconfig

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
RUN conda install python=3.6
RUN pip install --upgrade pip

RUN pip install --no-cache-dir  py4j==0.10.7 plotly pygame ipdb pytest pytest-cov python-coveralls coverage && \
    pip install --no-cache-dir  pytest-xdist pep8 pytest-pep8 pydot_ng graphviz networkx gizeh
RUN pip install --no-cache-dir  opencv-contrib-python
RUN pip install --no-cache-dir  imutils pipdate pythreejs 
RUN pip install --no-cache-dir  jupyter jupyterlab 



### PyTorch
RUN conda install -c pytorch -c fastai fastai pytorch-nightly torchvision-nightly magma-cuda80
RUN pip install --no-cache-dir  pyro-ppl 
RUN pip install --no-cache-dir  torchtext 
RUN pip install --no-cache-dir  gpytorch
RUN pip install --no-cache-dir  git+https://github.com/pytorch/tnt.git@master 

## TF, Keras, Mxnet and Theano
RUN conda install theano 
RUN pip install --no-cache-dir  tensorflow-gpu==1.4.1 #Due to cuda 8.0 constraint
RUN pip install --no-cache-dir  keras #libgcc 
RUN pip install --no-cache-dir  mxnet-cu80

### Edward, tensorly, allennlp, textacy
RUN pip install --no-cache-dir  edward textacy 
RUN pip install --no-cache-dir  tensorly #allennlp # causes issues during install (i.e. pip stops working)
RUN pip install --no-cache-dir  git+https://github.com/neka-nat/tensorboard-chainer.git
#RUN pip install --no-cache-dir  git+https://github.com/lanpa/tensorboard-pytorch

RUN conda install \

    'ipyparallel' \
    'bokeh' \
    'cloudpickle' \
    'cython' \
    'hdf5' \
    'numba' \
    'numexpr' \
    'pandas' \
    'patsy' \
    'pyyaml' \
    'scikit-learn' \
    'scikit-image' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy'
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
   # 'nomkl' \
#    'ipywidgets' \
#    'scipy' \
#    'dill' \

#RUN conda config --set channel_priority true
#RUN conda update --all
RUN conda clean -yt

RUN git clone https://github.com/facebookresearch/ParlAI.git ~/ParlAI && \
    cd ~/ParlAI; python setup.py develop && cd ~
######################################################
### Install Chainer (inc. exts)
RUN pip install --no-cache-dir  ideep4py
RUN pip install --no-cache-dir  mpi4py
#RUN conda install -c intel ideep4py
RUN pip install --no-cache-dir cupy-cuda80==6.0.0a1 chainer==6.0.0a1
RUN pip install --no-cache-dir  chainercv chainerrl chainerui && \
    chainerui db create && chainerui db upgrade

ENV CHAINER_USE_IDEEP 'auto'
######################################################


ENV PYTHONPATH /src/:$PYTHONPATH
ENV LD_PRELOAD $CONDA_DIR/lib/libstdc++.so.6.0.25
ENV MPLBACKEND 'agg'

WORKDIR /src

#USER root
#COPY jupyter_setup.sh /src
#RUN /src/jupyter_setup.sh
#USER chainer

CMD jupyter lab --no-browser --port=8890 --ip=0.0.0.0 --allow-root
