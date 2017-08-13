FROM ubuntu:14.04
MAINTAINER Chase McCarthy <chase@code0100fun.com>
ENV CMAKE cmake-3.9.0

# install tools and dependencies
RUN apt-get -y update && \
        apt-get install -y --force-yes --no-install-recommends \
        software-properties-common \
        ca-certificates \
        make \
        python \
        build-essential \
        git \
        wget \
        gcc-avr \
        binutils-avr \
        avr-libc \
        gdb-avr \
        avrdude \
        python-pip \
        curl

RUN pip install docopt==0.6.2

RUN wget https://cmake.org/files/v3.9/$CMAKE.tar.gz -O /usr/src/$CMAKE.tar.gz && \
        mkdir -p /usr/src && \
        tar zxvf /usr/src/$CMAKE.tar.gz -C /usr/src && \
        cd /usr/src/$CMAKE && \
        ./configure && make -j4 && make install && \
        rm /usr/src/$CMAKE.tar.gz && rm -rf /usr/src/$CMAKE

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# rustup directory
ENV PATH /root/.cargo/bin:$PATH

RUN git clone -b avr-support https://github.com/avr-rust/rust.git /usr/src/avr-rust && \
        cd /usr/src/avr-rust && \
        ./configure && make && \
        mkdir /usr/src/avr-rust-tmp && \
        mv /usr/src/avr-rust/build/x86_64-unknown-linux-gnu/stage1/ /usr/src/avr-rust-tmp/ && \
        rm -rf /usr/src/avr-rust && \
        mv /usr/src/avr-rust-tmp /usr/src/avr-rust

RUN rustup toolchain link avr-rust /usr/src/avr-rust/stage1
RUN rustup default avr-rust

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

COPY ./entrypoint.py /usr/bin
ENTRYPOINT ["python", "/usr/bin/entrypoint.py"]
