```
apt update && apt install wget libgsl-dev vim -y 
wget -qO- https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.11
export PYTHON_VERSION=3.11 
export PYTHON_LIBRARY=/root/.local/share/uv/python/cpython-3.11-linux-x86_64-gnu/lib/libpython3.11.so
uv sync
source .venv/bin/activate
cd Examples 
swift run SimpleTest
```
