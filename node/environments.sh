#!/bin/bash

add-apt-repository -yn ppa:deadsnakes
add-apt-repository -yn ppa:pypy/ppa
apt-get update -q

PYTHON_VERSIONS="2.7 3.6 3.7"
PYPY_VERSIONS=""
EXECUTABLES="jupyterhub jupyterhub-singleuser jupyter jupyter-kernel jupyter-notebook jupyter-run"

VENV_DIR=/venvs
IPYKERNEL_VENV=${VENV_DIR}/ipykernel

VERSIONS="$PYPY_VERSIONS"
for ver in $PYTHON_VERSIONS; do
    VERSIONS="$VERSIONS python${ver}"
done

# Gather packages to add
PKG="python3-dev python3-pip python3-setuptools python3-distutils python3-venv pypy-setuptools"
# And to later clean up
REM_PKG="python3-dev"

for ver in $VERSIONS; do
    PKG="${PKG} ${ver} ${ver}-dev"
    REM_PKG="${REM_PKG} ${ver}-dev"
done

apt-get install -yq $PKG

# Create the virtualenv dir and record what versions we'll have deployed
mkdir -p ${VENV_DIR}
echo "$VERSIONS" > ${VENV_DIR}/VERSIONS

# Install the base virtualenv
python3 -m pip install --upgrade virtualenv pip
python3 -m virtualenv -q --download ${IPYKERNEL_VENV}
${IPYKERNEL_VENV}/bin/pip install -r /tmp/requirements-ipykernel.txt

${IPYKERNEL_VENV}/bin/jupyter nbextension enable --py widgetsnbextension --sys-prefix

for ver in $VERSIONS; do
    echo "Preparing ${ver^}"
    python3 -m virtualenv --python=${ver} -q --download ${VENV_DIR}/${ver}
    DISPLAY_VERSION=`${VENV_DIR}/${ver}/bin/python -c "import platform; print(platform.python_version())"`
    echo "Installing packages for ${ver^} (${DISPLAY_VERSION}). This might take a while."
    ${VENV_DIR}/${ver}/bin/pip install -r /tmp/requirements-venvs.txt

    ${VENV_DIR}/${ver}/bin/python -m ipykernel install --prefix=${IPYKERNEL_VENV} --name "${ver}" --display-name "${ver^} (${DISPLAY_VERSION})"
done

apt-get remove -yq $REM_PKG

for ex in $EXECUTABLES; do
    ln -s ${IPYKERNEL_VENV}/bin/${ex} /usr/local/bin/${ex}
done
