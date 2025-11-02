ARG CMAKE_VERSION=4.0.1
ARG ARCH=x86_64
ARG NINJA_VERSION=1.12.1

FROM docker.io/fedora:rawhide@sha256:8a396124f358d2922f1b1c40aee2e7f1dd016b26b3d525d4338e7da12c1cd9a5

RUN dnf copr enable -y lecris/cmake-4.0 && dnf update -y && dnf install -y ninja-build clang lld git cmake
