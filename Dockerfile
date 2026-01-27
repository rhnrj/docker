FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Kolkata

# Install dependencies and configure locale/timezone
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    adb apt-utils aria2 bash bc binutils-dev bison build-essential \
    ca-certificates ccache cmake cpio curl default-jre fastboot file flex g++ gcc \
    gh git git-lfs gperf jq kmod lib32ncurses-dev lib32z1-dev libelf-dev \
    libexpat1-dev libncurses5-dev libssl-dev libtinfo6 libxml2 libxml2-utils \
    locales lz4 make nano ninja-build openssh-client p7zip pigz pipx \
    pngcrush pngquant python3 python3-dev python3-pip python3-venv python3.12-venv \
    rclone rsync schedtool software-properties-common squashfs-tools sudo \
    texinfo tzdata u-boot-tools unzip wget xsltproc xz-utils zlib1g-dev zip zstd && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 && \
    ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Download and extract AOSP Clang
RUN mkdir -p /opt/clang && \
    wget -O clang.tar.gz \
      https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/mirror-goog-main-llvm-toolchain-source/clang-r584948.tar.gz && \
    tar -xzf clang.tar.gz -C /opt/clang && \
    find /opt/clang -mindepth 1 -maxdepth 1 \
        ! -name bin ! -name lib -exec rm -rf {} + && \
    rm -f clang.tar.gz /opt/clang/lib/*.a /opt/clang/lib/*.la

# Strip clang binaries
RUN find /opt/clang -type f -exec file {} \; | \
    grep 'ELF' | grep 'not stripped' | cut -d: -f1 | \
    xargs -r /opt/clang/bin/llvm-strip --strip-all

ENV PATH="/opt/clang/bin:$PATH"

# Install repo tool
RUN curl -L https://storage.googleapis.com/git-repo-downloads/repo \
      -o /usr/local/bin/repo && \
    chmod +x /usr/local/bin/repo

# Final cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /usr/share/info/* /tmp/*

ENTRYPOINT ["/bin/bash"]
