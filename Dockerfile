FROM docker.io/library/swift:latest

RUN apt-get update && apt-get install vim libgsl-dev curl -y 

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /workdir
