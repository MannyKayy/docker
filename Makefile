help:
	@cat Makefile


DATA?="${HOME}/Data"
GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
TEST=tests/
SRC=$(shell dirname `pwd`)

build:
	docker build -t chainer --build-arg python_version=3.5 -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -p 8888:8888 -it -v $(SRC):/src -v $(DATA):/data chainer bash

ipython: build
	$(DOCKER) run -it -v $(SRC):/src -v $(DATA):/data chainer ipython

notebook: build
	$(DOCKER) run -it -v $(SRC):/src -v $(DATA):/data --net=host chainer

test: build
	$(DOCKER) run -it -v $(SRC):/src -v $(DATA):/data chainer py.test $(TEST)

