#!/bin/bash
### OpenCV Dependancies###

#For libfaac-dev
sudo echo 'deb http://us.archive.ubuntu.com/ubuntu trusty main multiverse' \
     >> /etc/apt/sources.list.d/multiverse.list

sudo apt-get update -y && \
     apt-get install -y \
     python-dev \
     python-numpy \
     python-pip \
     python3-dev \
     python3-numpy \
     python3-pip \
     curl \
     autoconf \
     automake \
     build-essential \
     checkinstall \
     pkg-config \
     yasm \
     libpng-dev \
     libtiff-dev \
     libtiff5-dev \
     libjpeg-dev \
     libjasper-dev \
     libavcodec-dev \
     libavformat-dev \
     libswscale-dev \
     libxine-dev \
     libgstreamer0.10-dev \
     libgstreamer-plugins-base0.10-dev \
     libv4l-dev \
     libtbb2 \
     libtbb-dev \
     libeigen3-dev \
     libqt4-dev \
     libgtk2.0-dev \
     libfaac-dev \
     libmp3lame-dev \
     libopencore-amrnb-dev \
     libopencore-amrwb-dev \
     libtheora-dev \
     libvorbis-dev \
     libxvidcore-dev \
     zlib1g-dev \
     x264 \
     v4l-utils \
     libtool \
     libav-tools \
     libavfilter-dev \
     libopenexr-dev \
     liblapacke-dev \
     libphonon-dev \
     libxml2-dev \
     libxslt1-dev \
     qtmobility-dev \
     libqtwebkit-dev \
     frei0r-plugins 

sudo ldconfig

cd /tmp/
sudo git clone https://github.com/opencv/opencv.git
sudo mkdir -p opencv/release && cd opencv/release
sudo cmake \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D CUDA_GENERATION=Auto \
      -D WITH_TBB=ON \
      -D WITH_FFMPEG=ON \
      -D ENABLE_FAST_MATH=1 \
      -D CUDA_FAST_MATH=1 \
      -D WITH_CUBLAS=1 \
      -D BUILD_opencv_python2=OFF \
      -D BUILD_opencv_python3=ON \
      -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
      -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.5m/ \
      -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
      -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
      -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
      -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.5/site-packages \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.5/site-packages/numpy/core/include/ \
      -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/ \
      -D WITH_V4L=ON \
      -D WITH_VTK=ON \
      -D WITH_OPENGL=ON \
      -D WITH_QT=ON \
      -D BUILD_EXAMPLES=OFF \
      -D WITH_IPP=OFF \
      -D WITH_GSTREAMER=YES \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D BUILD_NEW_PYTHON_SUPPORT=ON \
      -D WITH_CUDA=ON \
      -D CUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
      -D BUILD_DOCS=ON \
      -D WITH_XIMEA=YES \
      -D WITH_FFMPEG=YES \
      -D WITH_PVAPI=YES \
      -D WITH_TIFF=YES \
      -D WITH_XINE=ON \
      ..

sudo make -j $(($(nproc) + 1))
sudo make install
sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig

cd /tmp && sudo rm -rf opencv*

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH


apt-get clean && apt-get update

#https://github.com/opencv/opencv_contrib
#-D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
#pip install imutils
