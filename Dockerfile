FROM java:8-jdk

RUN apt-get update -y && \
    apt-get install -y wget vim openssh-server

WORKDIR /spark

RUN wget "http://mirror.bit.edu.cn/apache/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz"
# COPY spark-2.3.0-bin-hadoop2.7.tgz .

RUN tar -zxf spark-2.3.0-bin-hadoop2.7.tgz && \
    rm -rf spark-2.3.0-bin-hadoop2.7.tgz && \
    mv spark-2.3.0-bin-hadoop2.7/* .

RUN cd conf &&\ 
    cp spark-defaults.conf.template spark-defaults.conf &&\
    cp spark-env.sh.template spark-env.sh &&\
    cp slaves.template slaves &&\
    echo "spart.master=spark://localhost:7077" >> spark-defaults.conf &&\
    echo "SPARK_LOCAL_IP=localhost" >> spark-env.sh &&\
    echo "SPARK_MASTER_HOST=localhost" >> spark-env.sh &&\
    echo "SPARK_WORKER_CORES=40" >> spark-env.sh &&\
    echo "SPARK_WORKER_MEMORY=100G" >> spark-env.sh &&\
    echo "export SPART_MASTER_OPTS=\"-Dspark.deploy.defaultCores=40\"" >> spark-env.sh

ENV SPARK_HOME /spark
ENV PATH $PATH:$SPARK_HOME/bin
ENV PATH $PATH:$SPARK_HOME/sbin

RUN mkdir ~/.ssh &&\
    chmod 700 ~/.ssh &&\
    touch ~/.ssh/authorized_keys &&\
    chmod 600 ~/.ssh/authorized_keys &&\
    cd ~/.ssh &&\
    ssh-keygen -f id_rsa -t rsa -N '' &&\
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN systemctl enable ssh.socket &&\
    service ssh start

WORKDIR /spark