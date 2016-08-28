FROM mysql

RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  libmysqlclient-dev \
  mysql-client

RUN mkdir build && \
    cd build && \
    git clone https://github.com/infusion/udf_infusion.git && \
    cd udf_infusion && \
    ./configure && \
    make && \
    make install
