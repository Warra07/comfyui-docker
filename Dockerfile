# FROM nvidia/cuda:11.8.0-base-ubuntu20.04 as minimal
FROM pytorch/pytorch:2.5.1-cuda11.8-cudnn9-runtime as minimal
COPY entrypoint.sh /app/entrypoint.sh

RUN apt update && \
    apt install -y git && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 1000 comfyui && \
    useradd -m -s /bin/bash -u 1000 -g 1000 --home /app comfyui && \
    ln -s /app /home/comfyui && \
    chown -R comfyui:comfyui /app && \
    chmod +x /app/entrypoint.sh

USER comfyui
WORKDIR /app

RUN git clone https://github.com/comfyanonymous/ComfyUI.git comfyui 

WORKDIR /app/comfyui


FROM minimal as pytorch

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt


RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager

VOLUME /app/comfyui

EXPOSE 8188

ENTRYPOINT ["/app/entrypoint.sh", "--listen", "0.0.0.0", "--port", "8188", "--preview-method", "auto"]