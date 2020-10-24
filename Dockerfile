FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

ENV LANG=C.UTF-8
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server  unzip curl \
    cmake gcc g++ \
    iputils-ping net-tools  iproute2  htop xauth \
    tmux wget vim git bzip2 ca-certificates  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^#X11UseLocalhost.*$/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed -i 's/^#AddressF.*$/AddressFamily inet/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd && \
    echo 'root:teslazhu' | chpasswd && \
    sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile && \
    echo "conda activate base" >> /etc/profile

WORKDIR /root/code
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U  && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.timeout 6000

ENV envname fairseq
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda create -y -n $envname python=3.6 && \
    conda activate $envname && \
    conda install pytorch=1.5.0 torchvision cudatoolkit=10.1 -c pytorch && \
    wget https://github.com/pytorch/fairseq/archive/v0.9.0.zip && \
    unzip v0.9.0.zip && rm v0.9.0.zip && \
    cd fairseq-0.9.0 && \
    pip install --editable ./ && \
    cd .. && \
    git clone https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
    --global-option="--deprecated_fused_adam" --global-option="--xentropy" \
    --global-option="--fast_multihead_attn" ./ && \
    cd .. && \
    git clone https://github.com/huggingface/transformers && \
    cd transformers && \
    pip install -e . && \
    pip install pyarrow sacremoses editdistance boto3 requests  && \
    pip cache purge && \
    conda clean -tipsy && \
    sed -i 's/conda activate base/conda activate '"$envname"'/g' /etc/profile

#chmod -R o+w /opt/conda/

ENV PATH /opt/conda/envs/${envname}/bin:$PATH
RUN echo "export LANG=C.UTF-8" >>  /etc/profile
RUN mkdir -p /root/.ssh
COPY id_rsa /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa

