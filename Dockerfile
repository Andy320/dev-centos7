FROM centos:7

ARG p=4
ARG TOOLCHAIN=stable
ARG CMAKE=cmake-3.17.1-Linux-x86_64
# llvm 10
ARG LLVM=llvm-project
ARG GO=go1.14.2.linux-amd64
ARG HOME=/root

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:/usr/lib:/lib64:/lib

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
    echo "source /opt/rh/devtoolset-9/enable" >> /etc/profile && \
    source /etc/profile

ENV CC=/opt/rh/devtoolset-9/root/usr/bin/gcc
ENV CXX=/opt/rh/devtoolset-9/root/usr/bin/c++

RUN yum -y install \
    yum-utils \
    automake \
    autoconf \
    libtool \
    make \
    kernel-devel \
    gmp gmp-devel \
    mpfr mpfr-devel \
    libmpc libmpc-devel \
    git \
    python36 \
    zlib zlib-devel \
    openssl openssl-devel \
    vim \
<<<<<<< HEAD
    mlocate && updatedb
=======
    mlocate && \
    updatedb

ADD $GCC.tar.xz /tmp/
RUN cd /tmp/$GCC && mkdir build && cd build && \
    ../configure --prefix=/usr/local/gcc9 --enable-checking=release --enable-languages=c,c++ --disable-multilib && \
    make -j$p && \
    make install && \
    echo "/usr/local/gcc9/lib" > /etc/ld.so.conf.d/gcc9lib.conf && \
    echo "/usr/local/gcc9/lib64" > /etc/ld.so.conf.d/gcc9lib64.conf && \
    /sbin/ldconfig && \
    rm -rf /tmp/$GCC

RUN echo "alias cc=/usr/local/gcc9/bin/gcc" >> /root/.bash_profile && \
    echo "alias gcc=/usr/local/gcc9/bin/gcc" >> /root/.bash_profile && \
    echo "alias c++=/usr/local/gcc9/bin/c++" >> /root/.bash_profile && \
    echo "alias g++=/usr/local/gcc9/bin/g++" >> /root/.bash_profile && \
    echo "alias cpp=/usr/local/gcc9/bin/cpp"

ENV CC=/usr/local/gcc9/bin/gcc
ENV CXX=/usr/local/gcc9/bin/c++
# same as ldconfig
ENV LD_LIBRARY_PATH=/usr/local/gcc9/lib64:/usr/local/gcc9/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/gcc9/bin:$PATH
>>>>>>> a3c9e322e2d1fbbf41f5c765dd766aee2732caa0

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

WORKDIR $HOME



































































































