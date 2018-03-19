#!/bin/bash
## Development Environment
sudo mkdir /usr/local/share/jupyter
sudo mkdir /usr/local/etc/jupyter
sudo chown chainer /usr/local/share/jupyter
sudo chown chainer /usr/local/etc/jupyter
ipcluster nbextension enable

jupyter nbextension install --sys-prefix --py ipyparallel
jupyter nbextension enable --sys-prefix --py ipyparallel
jupyter serverextension enable --sys-prefix --py ipyparallel

jupyter nbextension install --py --symlink --sys-prefix pythreejs
jupyter nbextension enable --py --sys-prefix pythreejs

jupyter notebook --generate-config

key=$(python -c "from notebook.auth import passwd; print(passwd())")

cd ~
mkdir certs
cd certs
certdir=$(pwd)
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem

cd ~
sed -i "1 a\
c = get_config()\\
c.NotebookApp.certfile = u'$certdir/mycert.pem'\\
c.NotebookApp.ip = '*'\\
c.NotebookApp.open_browser = False\\
c.NotebookApp.password = u'$key'\\
c.NotebookApp.port = 8888" .jupyter/jupyter_notebook_config.py

