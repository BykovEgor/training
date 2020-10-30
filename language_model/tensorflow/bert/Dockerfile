FROM tensorflow/tensorflow:2.3.1-gpu

RUN apt-get update -y

COPY . /bert

WORKDIR /bert

CMD ["./run_and_time.sh"]