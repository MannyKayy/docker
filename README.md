# Using ChainerMN via Docker

This directory contains a `Dockerfile` to quickly get up and running with
ChainerMN via [Docker](http://www.docker.com/).

## Installing Docker

General installation instructions are
[on the Docker site](https://docs.docker.com/installation/), but we give some
quick links here:

* [OSX](https://docs.docker.com/installation/mac/): [docker toolbox](https://www.docker.com/toolbox)
* [ubuntu](https://docs.docker.com/installation/ubuntulinux/)


For GPU support install NVIDIA drivers (ideally latest) and
[nvidia-docker](https://github.com/NVIDIA/nvidia-docker).


## Running the container

We are using `Makefile` to simplify docker commands within make commands.

Build the container and start a jupyter notebook

    $ make notebook

Build the container and start an iPython shell

    $ make ipython

Build the container and start a bash

    $ make bash

To run a notebook using a specific GPU, pass in the `GPU` flag

    $ make notebook GPU=0 # or [ipython, bash]


Mount a volume for external data sets

    $ make DATA=~/mydata

Prints all make tasks

    $ make help


### Default User

The default (root) username and password in this container is `chainer`.


### Notes

This container was developed for the `single-node` environment.

To use this container on amazon aws `g2.x` instances, uncomment `line 89` in the Dockerfile.
This compiles nccl for devices with cuda compute capability `3.0`.

To avoid any issues caused by user and group permissions:
 - Make sure docker/nvidia-docker permissions are correctly setup.
 - By default, the `Makefile` sets up the `Data` folder, within which code should run correctly.
