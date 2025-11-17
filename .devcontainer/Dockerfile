FROM ubuntu:22.04

ARG HTTP_PROXY
ARG DEV_USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTP_PROXY}
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTP_PROXY}
ENV ALL_PROXY=${HTTP_PROXY}
ENV CLANGD_VERSION=21.1.0
ENV CLANGD_HOME=/usr/local/lib/clangd
ENV PG_VERSION=18
ENV PG_HOME=/usr/local/lib/postgresql/${PG_VERSION}
ENV PGDATA=/var/lib/postgresql/data
ENV PATH=${CLANGD_HOME}/bin:${PG_HOME}/bin:${PATH}
ENV TZ=Asia/Shanghai

RUN \
    # prepare apt
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf.d/1000-force-ipv4-transport && \
    echo 'Acquire::Retries "100";' >> /etc/apt/apt.conf.d/80-retries && \
    # echo 'Acquire::http::Proxy "${HTTP_PROXY}";' >> /etc/apt/apt.conf.d/99-proxy && \
    # echo 'Acquire::https::Proxy "${HTTPS_PROXY}";' >> /etc/apt/apt.conf.d/99-proxy && \
    apt-get update -y && \
    # basics
    PKGS="software-properties-common build-essential ca-certificates" && \
    apt-get install -y ${PKGS} && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/ppa && \
    apt-get update -y && \
    PKGS="vim sudo locales git curl unzip wget zip iputils-ping iproute2 tzdata tree jq bear gosu" && \
    PKGS="${PKGS} gdb net-tools telnet cmake ninja-build ccache pkg-config linux-tools-common linux-tools-generic" && \
    apt-get install -y ${PKGS} && \
    locale-gen en_US.UTF-8 && \
    echo ${TZ} > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure tzdata && \
    # pg dev deps
    PKGS="flex bison libreadline-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libicu-dev \
    libldap2-dev liblz4-dev libzstd-dev libnuma-dev liburing-dev uuid-dev libkrb5-dev libsystemd-dev \
    libpam0g-dev libselinux1-dev llvm-15-dev clang-15 python3-dev systemtap-sdt-dev libcurl4-openssl-dev \
    gettext tcl tcl-dev libperl-dev libipc-run-perl libtest-simple-perl" && \
    apt-get install -y ${PKGS} && \
    apt-get autoclean

RUN \
    # clangd
    wget "https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip" -O /tmp/clangd.zip && \
    unzip /tmp/clangd.zip -d ${CLANGD_HOME} && \
    mv ${CLANGD_HOME}/clangd_${CLANGD_VERSION}/* ${CLANGD_HOME} && \
    rm -rf ${CLANGD_HOME}/clangd_${CLANGD_VERSION} && \
    rm -rf /tmp/clangd.zip

RUN \
    # proxy for wget
    echo "use_proxy = on" >> /etc/wgetrc && \
    echo "http_proxy = ${http_proxy}" >> /etc/wgetrc && \
    echo "https_proxy = ${http_proxy}" >> /etc/wgetrc && \
    # misc
    echo "* soft core unlimited" >>/etc/security/limits.conf && \
    mkdir /coredumps && \
    chmod o+rwx /coredumps

# use postgres as dev username
RUN \
    # Create the user
    groupadd --gid $USER_GID $DEV_USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $DEV_USERNAME && \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    echo $DEV_USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEV_USERNAME && \
    chmod 0440 /etc/sudoers.d/$DEV_USERNAME

RUN \
    install --verbose --directory --owner ${DEV_USERNAME} --group ${DEV_USERNAME} --mode 1777 ${PGDATA} && \
    mkdir -p /opt/transwarp/postgresql/build && \
    mkdir -p ${PG_HOME} && \
    chown -R ${DEV_USERNAME}:${DEV_USERNAME} ${PG_HOME} && \
    echo ${PG_HOME}/lib > /etc/ld.so.conf.d/pg.conf

ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

USER $DEV_USERNAME

# unset
ENV http_proxy=
ENV https_proxy=
