FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu14.04
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
    apt-get install -y \

    tmux \
    htop \

    wget \
    vim \
    git \
    g++ \
    graphviz \

    software-properties-common \
    python-software-properties \
    python3-dev \

    libhdf5-dev \
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    gfortran && \

    ### ffmpeg
    add-apt-repository ppa:mc3man/trusty-media -y \
    apt-get update -y \
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
ARG cmake_version=3.10
ARG cmake_iter=1
RUN cd /usr/local/src && \
    wget http://www.cmake.org/files/v${cmake_version}/cmake-${cmake_version}.${cmake_iter}.tar.gz && \
    tar xf cmake-${cmake_version}.${cmake_iter}.tar.gz && \
    cd cmake-${cmake_version}.${cmake_iter} && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    ldconfig



#################Spark dependencies################
ENV APACHE_SPARK_VERSION 2.2.1


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
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$PYTHONPATH
##ENV SPARK_OPTS --driver-java-options=-Xms2048M
##:--driver-memory=16g:--driver-java-options=-Dlog4j.logLevel=info


########################MPI##########################
RUN cd /tmp && \
        wget "https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.0.tar.gz" && \
        tar xzf openmpi-3.0.0.tar.gz && \
        cd openmpi-3.0.0  && \
        ./configure --with-cuda && make -j"$(nproc)" install # && ldconfig



#######################NCCL###########################
ENV CPATH /usr/local/cuda/include:/usr/local/include:$CPATH
RUN cd /usr/local && git clone https://github.com/NVIDIA/nccl.git && cd nccl && \

######### Compile for devices with cuda compute compatibility 3 (e.g. GRID K520 on aws)
# UNCOMMENT line below to compile for GPUs with cuda compute compatibility 3.0
#        sed -i '/NVCC_GENCODE ?=/a \                -gencode=arch=compute_30,code=sm_30 \\' Makefile && \
##########

        make CUDA_HOME=/usr/local/cuda -j"$(nproc)" && \
        make install && ldconfig


###################Setup User##########################
ENV NB_USER chainer
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER -g sudo -p $(perl -e'print crypt("chainer", "aa")') && \
    mkdir -p $CONDA_DIR && \
    chown chainer $CONDA_DIR -R && \
    mkdir -p /src && \
    chown -R chainer /src

USER chainer


#######################Python 3#########################
#ARG python_version=3.5.2
#ARG tensorflow_version=0.10.0-cp35-cp35m
RUN pip install tensorflow-gpu && \ 
    pip install git+git://github.com/Theano/Theano.git && \
    pip install pygame && \
    pip install flask-ask && \
    pip install ipdb pytest pytest-cov python-coveralls coverage==3.7.1 pytest-xdist pep8 pytest-pep8 pydot_ng graphviz networkx gizeh && \
    pip install git+git://github.com/mila-udem/fuel.git && \

    conda install \

    'Pillow' \
    'scikit-learn' \
    'notebook' \
    'pandas' \
    'matplotlib' \
    'nose' \
    'pyyaml' \
    'six' \
    'h5py' \

    'numpy' \
    'mock' \

    'jsonschema' \
    'boto' \

    'nomkl' \
    'ipywidgets' \
    'pandas' \
    'numexpr' \
    'scipy' \
    'seaborn' \
    'scikit-learn' \
    'scikit-image' \
    'sympy' \
    'cython' \
    'patsy' \
    'statsmodels' \
    'cloudpickle' \
    'dill' \
    'numba' \
    'bokeh' \
    'sqlalchemy' \
    'hdf5' &&\

    conda install -y -c conda-forge pythreejs ipyparallel && \
    conda clean -yt


### Install OpenCV
USER root
COPY *.sh ./
RUN ./opencv3.sh
USER chainer




### Install  Lua, Torch, Chainer (inc. exts)
RUN conda install -y lua lua-science -c alexbw  && \
    pip install mpi4py cupy imutils && \
    pip install git+git://github.com/pfnet/chainer.git && \
    pip install chainercv chainerrl && \
    pip install chainermn chainerui && \
    chainerui db create && chainerui db upgrade && \


### Keras and Spacy ###
    pip install git+git://github.com/fchollet/keras.git && \
    pip install edward && \
    pip install textacy && \

### PyTorch
    conda install pytorch torchvision cuda80 -c soumith && \
    pip install pyro-ppl torchtext && \
    pip install git+https://github.com/pytorch/tnt.git@master && \
    pip install git+https://github.com/lanpa/tensorboard-pytorch && \
    conda clean -yt


RUN git clone https://github.com/facebookresearch/ParlAI.git ~/ParlAI && \
    cd ~/ParlAI; python setup.py develop && cd ~
######################################################


ENV PYTHONPATH /src/:$PYTHONPATH

WORKDIR /src

#COPY jupyter_setup.sh /src
#RUN /src/jupyter_setup.sh

CMD jupyter notebook --no-browser --port=8888 --ip=0.0.0.0
