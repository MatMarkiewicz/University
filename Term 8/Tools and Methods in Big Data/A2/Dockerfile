FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    build-essential \
    python3.7 \
    python3-pip \
    python3-dev \
    && pip3 -q install pip --upgrade
WORKDIR src/
COPY . .
RUN pip3 install -r requirements.txt
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]