FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=2.4.5
ARG jupyterlab_version=2.1.5


RUN apt-get update -y && \
    apt-get install -y python3-pandas && \
    apt-get install -y python3-pip

COPY requirements.txt ./

RUN pip3 install -r requirements.txt

RUN pip3 install pyspark==${spark_version} jupyterlab==${jupyterlab_version} && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/local/bin/python3 /usr/bin/python

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

