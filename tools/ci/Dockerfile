ARG CMAKE_VERSION=4.0.1
ARG ARCH=x86_64
ARG NINJA_VERSION=1.12.1

FROM docker.io/fedora:rawhide@sha256:64de49837325632232088e59c20518565a9d657095f9f3c2fa6033a42fb1412b

RUN dnf copr enable -y lecris/cmake-4.0 && dnf update -y && dnf install -y ninja-build clang lld git cmake
