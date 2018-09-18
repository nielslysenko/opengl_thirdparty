 yes | apt-get install mesa-utils libx11-dev libxrandr-dev libxinerama1-dev libxi-dev libXxf86vm-dev libXcursor-dev libGL-dev libgl1-mesa-dev  
  echo "Installing RANDR!!!"
  yes | apt-get install xorg-dev libglu1-mesa-dev
  yes | apt-get install libpthread-stubs0-dev libm17n-dev
  git clone https://github.com/glfw/glfw \
    && cd glfw \
    && mkdir build \
    && cd build \
    && cmake .. && make -j4 \
    && sudo make install

  cd "$currentDir"

  if [ ! -d "./.include" ]; then
   mkdir ./.include
  fi

 # cp -Rv ./glfw/include/ ./.include/ 
  sudo rm -r glfw
