help:
	@cat Makefile


DATA?="${HOME}/data"
GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
TEST=tests/
SRC=$(shell dirname `pwd`)

build:
	docker build -t chainer -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run --rm -it --net=host -v $(SRC):/src -v $(DATA):/data chainer bash

ipython: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data chainer ipython

notebook: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data --net=host chainer

test: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data chainer py.test $(TEST)

