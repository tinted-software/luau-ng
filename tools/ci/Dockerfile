ARG CMAKE_VERSION=4.0.1
ARG ARCH=x86_64
ARG NINJA_VERSION=1.12.1

FROM docker.io/fedora:rawhide@sha256:af8cdc432037f5e8e288bbc26c2b55b96000a911ec5b37959cd464d830f6cc5b

RUN dnf copr enable -y lecris/cmake-4.0 && dnf update -y && dnf install -y ninja-build clang lld git cmake
