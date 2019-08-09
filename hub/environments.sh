#!/bin/bash

python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt

npm install -g configurable-http-proxy

wget https://raw.githubusercontent.com/jupyterhub/jupyterhub/master/examples/cull-idle/cull_idle_servers.py -O /etc/jupyterhub/cull_idle_servers.py
