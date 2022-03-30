FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=3.1.2
ARG jupyterlab_version=2.1.5


RUN apt-get update -y && \
    apt-get install -y python3-pandas && \
    apt-get install -y python3-pip && \
    apt-get install -y git

COPY requirements.txt ./

RUN pip3 install -r requirements.txt

RUN pip3 install pyspark==3.1.2 spark-nlp==3.4.2 jupyterlab confluent-kafka sklearn && \
    pip3 install transformers tokenizers pytorch-lightning==1.2.10 && \
    git clone https://github.com/davidtvs/pytorch-lr-finder.git && cd pytorch-lr-finder && python3 setup.py install && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/local/bin/python3 /usr/bin/python

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

