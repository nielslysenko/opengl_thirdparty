  echo "Installing RANDR!!!"
  apt-get update
  yes | apt-get install xorg-dev libglu1-mesa-dev libgl1-mesa-dev freeglut3-dev
  git clone https://github.com/glfw/glfw \
    && cd glfw \
    && mkdir build \
    && cd build \
    && cmake .. && make -j4 \
    && make install

  cd "$currentDir"

  if [ ! -d "./include" ]; then
   mkdir ./include
  fi

  cp -Rv ./glfw/include/ ./include/ 
  rm -r glfw
