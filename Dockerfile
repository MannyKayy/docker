FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu14.04
RUN apt-get update


# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive


############Install MiniConda, Java, Python and other dependencies##########
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV OPENBLAS_NUM_THREADS $(nproc)

RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \

    apt-get update -y && \
    apt-get install -y \

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

    ### Java ###
    add-apt-repository ppa:openjdk-r/ppa -y && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless && \


    ### OpenCV Dependancies###
    apt-get update -y && \
    apt-get install -y \
    
    build-essential \
    cmake \
    p7zip-full \
    pkg-config \
    python3-numpy \
    
    zlib1g-dev \
    libav-tools \
    libavformat-dev \
    libavcodec-dev \
    libavfilter-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libjasper-dev \
    libopenexr-dev \
    libeigen3-dev \
    libtbb2 \
    libtbb-dev \
    liblapacke-dev \
    
    curl \
    autoconf \
    automake \
    checkinstall \
    yasm \
    libtiff5-dev \
    libdc1394-22-dev \
    libgstreamer0.10-dev \
    libgstreamer-plugins-base0.10-dev \
    libv4l-dev \
    libgtk2.0-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libtool \
    v4l-utils \
    default-jdk \
    tmux \
    libqt4-dev \
    libphonon-dev \
    libxml2-dev \
    libxslt1-dev \
    qtmobility-dev \
    libqtwebkit-dev \
    
    frei0r-plugins && \


    rm -rf /var/lib/apt/lists/* && \

    ### Minicoda ###
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh



#################Spark dependencies################
ENV APACHE_SPARK_VERSION 2.0.1


# set default java environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# workaround for bug on ubuntu 14.04 with openjdk-8-jre-headless
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN cd /tmp && \
        wget http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7 spark


ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.3-src.zip:$PYTHONPATH
#ENV SPARK_OPTS --driver-java-options=-Xms2048M
#:--driver-memory=16g:--driver-java-options=-Dlog4j.logLevel=info


########################MPI##########################
RUN cd /tmp && \
        wget "https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.gz" && \
        tar xzf openmpi-2.1.1.tar.gz && \
        cd openmpi-2.1.1  && \
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
ARG python_version=3.5.2
ARG tensorflow_version=0.10.0-cp35-cp35m
RUN conda install -y python=${python_version} && \
    pip install -U pip && \
    pip install https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${tensorflow_version}-linux_x86_64.whl && \
    pip install git+git://github.com/Theano/Theano.git && \
    pip install pygame && \
    pip install flask-ask && \
    pip install ipdb pytest pytest-cov python-coveralls coverage==3.7.1 pytest-xdist pep8 pytest-pep8 pydot_ng graphviz networkx && \


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


    # Install  Lua, Torch, Chainer (inc. exts)
    conda install -y lua lua-science -c alexbw  && \
    pip install mpi4py && \
    pip install git+git://github.com/pfnet/chainer.git && \
    pip install chainercv chainerrl && \
    pip install chainermn && \


### Keras and Spacy ###
    pip install git+git://github.com/fchollet/keras.git && \
    pip install edward==1.1.2 && \
    pip install textacy && \

    conda clean -yt

ENV PYTHONPATH $CONDA_DIR/lib/python3.5/site-packages/:$PYTHONPATH
######################################################


#####################OpenCV############################
#USER root

#RUN cd /tmp && \
#    git clone https://github.com/opencv/opencv_contrib.git && \
#    wget https://sourceforge.net/projects/opencvlibrary/files/opencv-unix/3.2.0/opencv-3.2.0.zip && \
#    7z x opencv-3.2.0.zip && mkdir -p opencv-3.2.0/release && cd opencv-3.2.0/release && \
#
#
#    cmake \
#          -D CMAKE_BUILD_TYPE=RELEASE \
#          -D CMAKE_INSTALL_PREFIX=/usr/local \
#          -D BUILD_NEW_PYTHON_SUPPORT=ON \
#          -D BUILD_EXAMPLES=ON \
#          -D WITH_XINE=ON \
#          -D WITH_TBB=ON \
#          -D WITH_CUDA=ON \
#          -D ENABLE_FAST_MATH=1 \
#          -D CUDA_FAST_MATH=1 \
#          -D BUILD_TIFF=ON \
#          -D CUDA_GENERATION=Auto \
#          -D WITH_CUBLAS=1 \
#          -DCUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
#          
#          -D WITH_V4L=ON \
#          -D INSTALL_PYTHON_EXAMPLES=ON \
#          -D BUILD_DOCS=ON \
#          -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
#          -D WITH_XIMEA=YES \
#          -D WITH_FFMPEG=YES \
#          -D WITH_PVAPI=YES \
#          -D WITH_GSTREAMER=YES \
#          -D WITH_TIFF=YES \
#          
#          -D BUILD_opencv_python2=OFF \
#          -D BUILD_opencv_python3=ON \
#          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
#          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.5m/ \
#          -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
#          -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
#          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.5/site-packages \
#          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.5/site-packages/numpy/core/include/ \
#          .. && \
#
#    make -j $(($(nproc) + 1)) && make install && \ 
#    /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf' && ldconfig && \
#    cd /tmp && rm -rf opencv* && \
#    apt-get update
#
#
#ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
#
#
#
#USER chainer
#
#RUN pip install imutils && \
#    apt-get clean && apt-get update
#
###############################################

ENV PYTHONPATH /src/:$PYTHONPATH

WORKDIR /src

EXPOSE 8888

CMD jupyter notebook --no-browser --port=8888 --ip=0.0.0.0
