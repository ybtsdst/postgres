FROM ubuntu:22.04

ARG OUTPUT_DIR
ARG postgres_uid
ARG postgres_gid

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PG_HOME=/usr/local/lib/postgresql/18
ENV PGDATA=/var/lib/postgresql/data
ENV PATH=${PG_HOME}/bin:${PATH}

RUN \
  # prepare apt
  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/1000-force-ipv4-transport && \
  echo 'Acquire::Retries "100";' >> /etc/apt/apt.conf.d/80-retries && \
  apt-get update -y && \
  # basics
  PKGS="software-properties-common" && \
  PKGS="${PKGS} vim sudo locales curl unzip wget iputils-ping iproute2 tzdata tree" && \
  # from doris
  PKGS="${PKGS} patchelf gdb binutils binutils-common \
    curl wget less vim htop iproute2 numactl jq iotop sysstat \
    tcpdump iputils-ping dnsutils strace lsof blktrace tzdata \
    bpfcc-tools linux-headers-realtime linux-tools-realtime \
    net-tools ca-certificates openssl" && \
  # pg runtime deps
  PKGS="${PKGS} gosu libreadline-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libicu-dev \
    libldap2-dev liblz4-dev libzstd-dev libnuma-dev liburing-dev uuid-dev libkrb5-dev libsystemd-dev \
    libpam0g-dev libselinux1-dev llvm-15-dev clang-15 python3-dev systemtap-sdt-dev libcurl4-openssl-dev \
    gettext tcl tcl-dev libperl-dev libipc-run-perl libtest-simple-perl" && \
  apt-get install -y ${PKGS} && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* && \
  locale-gen en_US.UTF-8 && \
  echo ${TZ} > /etc/timezone && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure tzdata

ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

COPY ${OUTPUT_DIR} ${PG_HOME}

RUN \
  # Create the user
  groupadd --gid ${postgres_gid} postgres && \
  useradd --uid ${postgres_uid} --gid ${postgres_gid} -m --shell=/bin/bash postgres && \
  #
  # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
  echo postgres ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/postgres && \
  chmod 0440 /etc/sudoers.d/postgres

RUN \
  install --verbose --directory --owner postgres --group postgres --mode 1777 ${PGDATA} && \
  chown -R postgres:postgres ${PG_HOME} && \
  echo ${PG_HOME}/lib > /etc/ld.so.conf.d/pg.conf && \
  ldconfig

WORKDIR ${PGDATA}
