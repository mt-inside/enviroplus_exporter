set dotenv-load

CGR_ARCHS := "aarch64,amd64"
DH_USER := "mtinside"

default:
	@just --list

build-and-push:
	# linux/arm/v7,linux/arm64/v8
	docker buildx build --platform linux/arm64 --tag docker.io/mtinside/enviroplus-exporter:latest --push .

melange:
	melange keygen
	melange build --arch {{CGR_ARCHS}} --signing-key melange.rsa melange.yaml
	
apko-local:
	apko build --keyring-append melange.rsa.pub --arch {{CGR_ARCHS}} apko.yaml docker.io/mtinside/enviroplus-exporter:cgr oci.tar
	docker load < oci.tar

apko-publish:
	apko login docker.io -u {{DH_USER}} --password "${DH_TOKEN}"
	apko publish --keyring-append melange.rsa.pub --arch {{CGR_ARCHS}} apko.yaml docker.io/mtinside/enviroplus-exporter:cgr

# to build
# docker run --privileged --rm tonistiigi/binfmt --install all
# or
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --name multiarch --driver docker-container --use
# docker buildx inspect --bootstrap
