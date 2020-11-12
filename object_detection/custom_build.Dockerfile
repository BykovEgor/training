ARG CUDA="9.0"
ARG CUDNN="7"
ARG TORCH="1.0.1"

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu16.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install basics
RUN apt-get update -y \
    && apt-get install -y apt-utils \
    libglib2.0-0 \
    libsm6=2:1.2.2-1 \
    libxext6=2:1.3.3-1 \
    libxrender-dev \
    git-all \
    gcc \
    g++

RUN pip install ninja==1.8.2.post2 \
    yacs==0.1.5 \
    cython==0.29.5 \
    matplotlib==3.0.2 \
    opencv-python==4.0.0.21 \
    mlperf_compliance==0.0.10 \
    torchvision==0.2.2

# Install Miniconda
RUN curl -so /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x /miniconda.sh \
    && /miniconda.sh -b -p /miniconda \
    && rm /miniconda.sh

ENV PATH=/miniconda/bin:$PATH

# Create a Python 3.6 environment
RUN /miniconda/bin/conda install -y conda-build \
    && /miniconda/bin/conda create -y --name py36 python=3.6.7 \
    && /miniconda/bin/conda clean -ya

ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

RUN conda install -y ipython
RUN pip install ninja yacs cython matplotlib opencv-python

# Install PyTorch with correct CUDA toolkit
RUN conda install -y pytorch==${TORCH} torchvision==0.2.2 cudatoolkit=${CUDA} -c pytorch \
    && conda clean -ya

# install pycocotools
RUN git clone https://github.com/cocodataset/cocoapi.git \
    && cd cocoapi/PythonAPI \
    && git reset --hard ed842bffd41f6ff38707c4f0968d2cfd91088688 \
    && python setup.py build_ext install

COPY . /workspace

WORKDIR /workspace

RUN ./install.sh \
    && pip install ./pytorch

ENTRYPOINT ["./run_and_time.sh"]