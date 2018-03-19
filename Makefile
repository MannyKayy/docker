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
	xhost +local:root
	$(DOCKER) run --rm -it -e DISPLAY -e QT_X11_NO_MITSHM=1 --privileged --net=host -v $(SRC):/src -v $(DATA):/data chainer bash
	xhost -local:root

ipython: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data chainer ipython

notebook: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data --net=host chainer

test: build
	$(DOCKER) run --rm -it -v $(SRC):/src -v $(DATA):/data chainer py.test $(TEST)

