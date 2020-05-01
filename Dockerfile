FROM centos:7

ARG p=4
ARG TOOLCHAIN=stable
ARG CMAKE=cmake-3.17.1-Linux-x86_64
# llvm 10
ARG LLVM=llvm-project
ARG GO=go1.14.2.linux-amd64
ARG JDK=jdk-8u231-linux-x64
ARG HOME=/root

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:/usr/lib:/lib64:/lib

RUN cd /etc/yum.repos.d/ && \
    mkdir repo_bak && \
    mv *.repo repo_bak/ && \
    curl -LO http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum install -y \
    epel-release \
    centos-release-scl \
    scl-utils-build && \
    curl -LO http://mirrors.aliyun.com/repo/epel-7.repo && \
    yum clean all && yum makecache

RUN yum install -y \
    devtoolset-9-toolchain && \
    echo ". /opt/rh/devtoolset-9/enable" >> /etc/bashrc && \
    . /etc/bashrc

ENV CC=/opt/rh/devtoolset-9/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-9/root/usr/bin/c++

RUN yum -y install \
    yum-utils \
    automake \
    autoconf \
    libtool \
    make \
    kernel-devel \
    git \
    python36 \
    zlib zlib-devel \
    openssl openssl-devel \
    vim \
    lrzsz \
    pcre pcre-devel \
    bash-completion \
    unzip zip \
    wget \
    mlocate && \
    updatedb

# -----------------cmake---------------- #
ADD $CMAKE.tar.gz /usr/local/
ENV PATH=/usr/local/$CMAKE/bin:$PATH

# -----------------llvm----------------- #
ADD $LLVM.tar.xz /tmp/
RUN cd /tmp/$LLVM && \
    mkdir build && \
    cd build && \
    cmake -G "Unix Makefiles" \
    -DLLVM_ENABLE_PROJECTS="clang" \
    -DCMAKE_INSTALL_PREFIX=/usr/local/llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    ../llvm && \
    make -j$p && \
    make install && \
    rm -rf /tmp/*
ENV PATH=/usr/local/llvm/bin:$PATH

# -----------------rust----------------- #
ENV PATH=$HOME/.cargo/bin:$PATH
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN
ADD cargo-config.toml $HOME/.cargo/config
RUN mkdir -p $HOME/rust/src $HOME/rust/libs

# -----------------golang----------------- #
ADD $GO.tar.gz /usr/local/
RUN mkdir -p $HOME/go/bin $HOME/go/src
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn
ENV PATH=$GOROOT/bin:$PATH

# -----------------jdk8----------------- #
ADD $JDK.tar.gz /usr/local/
ENV JAVA_HOME=/usr/local/jdk1.8.0_231 \
    JRE_HOME=/usr/local/jdk1.8.0_231/jre \
    CLASSPATH=.:/usr/local/jdk1.8.0_231/lib:/usr/local/jdk1.8.0_231/jre/lib \
    PATH=/usr/local/jdk1.8.0_231/bin:$PATH

WORKDIR $HOME



































































































