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

RUN git clone -b avr-support https://github.com/avr-rust/rust.git /usr/src/avr-rust

WORKDIR /usr/src/avr-rust
RUN ls -la
RUN mkdir build
RUN cd build && ../configure
RUN cd build && make

RUN mkdir /usr/src/app

COPY ./entrypoint.py /usr/bin
ENTRYPOINT ["python", "/usr/bin/entrypoint.py"]
