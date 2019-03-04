TAG=model01
DOCKER_FILE=Dockerfile

build:
	docker build . -f $(DOCKER_FILE) -t hongkunyoo/eks-ml:$(TAG)

login:
	docker login -u hongkunyoo

logout:
	docker logout

push:
	docker push hongkunyoo/eks-ml:$(TAG)

sync: login build push logout
