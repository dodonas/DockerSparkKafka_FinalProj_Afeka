FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=3.1.2
ARG jupyterlab_version=2.1.5


RUN apt-get update -y && \
    apt-get install -y python3-pandas && \
    apt-get install -y python3-pip

COPY requirements.txt ./

RUN pip3 install -r requirements.txt

RUN pip3 install pyspark==${spark_version} jupyterlab && \
    pip3 install spark-nlp==3.4.2 && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/local/bin/python3 /usr/bin/python

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

