# get current location
$DOCDIR = (Resolve-Path .\).Path

#7zip
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}
Set-Alias 7z $7zipPath

# Build configuration
$CONFIGURATION = "Release"

$GLEW_VERSION = "2.2.0"
$FREEGLUT_VERSION = "3.2.1"
$GLEW_PACKAGE_URL = "https://netix.dl.sourceforge.net/project/glew/glew/${GLEW_VERSION}/glew-${GLEW_VERSION}.zip"
$GLFW_GIT_URL = "https://github.com/glfw/glfw.git"
$FREEGLUT_PACKAGE_URL = "https://nav.dl.sourceforge.net/project/freeglut/freeglut/${FREEGLUT_VERSION}/freeglut-${FREEGLUT_VERSION}.tar.gz"

$GLEW_INSTALL_PATH = "${DOCDIR}\glew-${GLEW_VERSION}"
$GLFW_INSTALL_PATH = "${DOCDIR}\glfw"
$FREEGLUT_INSTALL_PATH = "${DOCDIR}\freeglut-${FREEGLUT_VERSION}"

$OPENGL_LIBS_PATH = "${DOCDIR}\.lib"
$OPENGL_BIN_PATH = "${DOCDIR}\.bin"
$INCLUDE_PATH = "${DOCDIR}\.include"

$OPENGL_INCLUDE_PATH = ${INCLUDE_PATH}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#========================================================================================
#$PLATFORM = "x64"
#$DEFAULT_BUILD_FLAGS = "/p:Configuration=${CONFIGURATION} /property:Platform=${PLATFORM}"
#function Resolve-MsBuild {
#    $msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue
#    if($msb2017) {
#        Write-Host "Found MSBuild 2017 (or later)."
#        Write-Host $msb2017
#        return $msb2017
#    }
#
#    $msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe"
#
#    if(-not (Test-Path $msBuild2015)) {
#        throw 'Could not find MSBuild 2015 or later.'
#    }
#
#    Write-Host "Found MSBuild 2015."
#    Write-Host $msBuild2015
#
#    return $msBuild2015
#}
#$msBuild = Resolve-MsBuild
#& $msBuild "glew.sln" ${DEFAULT_BUILD_FLAGS}

# ------------------ CREATE DIRECTORIES -----------------------------------
if(!(Test-Path -Path ${OPENGL_LIBS_PATH})){
    New-Item -ItemType directory -Path $OPENGL_LIBS_PATH
}

if(!(Test-Path -Path ${OPENGL_BIN_PATH})){
    New-Item -ItemType directory -Path ${OPENGL_BIN_PATH}
}

if(!(Test-Path -Path ${INCLUDE_PATH})){
    New-Item -ItemType directory -Path ${INCLUDE_PATH}
}
if(!(Test-Path -Path ${OPENGL_INCLUDE_PATH})){
    New-Item -ItemType directory -Path ${OPENGL_INCLUDE_PATH}
}

#--------- CODE STARTS HERE ---------------------------------------------------

#---------- GET GLFW  -------------------------------------------------------
if(!(Test-Path -Path ${GLFW_INSTALL_PATH})){
    git clone -q ${GLFW_GIT_URL}
}
else{
    git pull -q
}
cd glfw
if(!(Test-Path -Path "${GLFW_INSTALL_PATH}/Build")){
    New-Item -ItemType directory -Path "${GLFW_INSTALL_PATH}/Build"
}
cd Build
cmake ..
cmake --build . --config ${CONFIGURATION}
Copy-Item -Path "${GLFW_INSTALL_PATH}\Build\src\Release\glfw3.lib" -Destination "$OPENGL_LIBS_PATH\glfw3.lib"
#--------------------------------------------------------------------------------------


#--------- GET GLEW -------------------------------------------------------------------
cd $DOCDIR
if(!(Test-Path -Path $DOCDIR"\glew")){
Invoke-WebRequest ${GLEW_PACKAGE_URL} -Out glew-${GLEW_VERSION}.zip -UseBasicParsing
Expand-Archive -Path .\glew-${GLEW_VERSION}.zip -Force -DestinationPath  .
del "glew-${GLEW_VERSION}.zip" -Force
}

cd ${GLEW_INSTALL_PATH}
cd build
cd cmake
if(!(Test-Path -Path "${GLEW_INSTALL_PATH}/build/cmake/build")){
    New-Item -ItemType directory -Path "${GLEW_INSTALL_PATH}/build/cmake/build"
}
cd build
cmake ..
cmake --build . --config Release


Copy-Item -Path "${GLEW_INSTALL_PATH}\build\cmake\build\bin\Release\glew32.dll" -Destination "${OPENGL_BIN_PATH}\glew32.dll"
Copy-Item -Path "${GLEW_INSTALL_PATH}\build\cmake\build\bin\Release\glewinfo.exe" -Destination "${OPENGL_BIN_PATH}\glewinfo.exe"

Copy-Item -Path "${GLEW_INSTALL_PATH}\build\cmake\build\lib\Release\libglew32.lib" -Destination "${OPENGL_LIBS_PATH}\libglew32.lib"
Copy-Item -Path "${GLEW_INSTALL_PATH}\build\cmake\build\lib\Release\glew32.lib" -Destination "${OPENGL_LIBS_PATH}\glew32.lib"
Copy-Item -Path "${GLEW_INSTALL_PATH}\build\cmake\build\lib\Release\glew32.exp" -Destination "${OPENGL_LIBS_PATH}\glew32.exp"
#----------------------------------------------------------------------------------------

#---------GET FREE GLUT -----------------------------------------------------------------
cd $DOCDIR
if(!(Test-Path -Path "${FREEGLUT_INSTALL_PATH}")){
    Invoke-WebRequest ${FREEGLUT_PACKAGE_URL} -Out freeglut-${FREEGLUT_VERSION}.tar.gz -UseBasicParsing
    7z e .\freeglut-${FREEGLUT_VERSION}.tar.gz
    7z x .\freeglut-${FREEGLUT_VERSION}.tar
    del freeglut-${FREEGLUT_VERSION}.tar.gz -Force
    del freeglut-${FREEGLUT_VERSION}.tar -Force
}
cd "${FREEGLUT_INSTALL_PATH}"

if(!(Test-Path -Path "${FREEGLUT_INSTALL_PATH}/build")){
    New-Item -ItemType directory -Path "${FREEGLUT_INSTALL_PATH}/build"
}
cd build
cmake ..
cmake --build . --config ${CONFIGURATION}
Copy-Item -Path "${FREEGLUT_INSTALL_PATH}\build\bin\Release\freeglut.dll" -Destination "${OPENGL_BIN_PATH}\freeglut.dll"

Copy-Item -Path "${FREEGLUT_INSTALL_PATH}\build\lib\Release\freeglut.lib" -Destination $DOCDIR"\.lib\freeglut.lib"
Copy-Item -Path "${FREEGLUT_INSTALL_PATH}\build\lib\Release\freeglut.exp" -Destination $DOCDIR"\.lib\freeglut.exp"
Copy-Item -Path "${FREEGLUT_INSTALL_PATH}\build\lib\Release\freeglut_static.lib" -Destination $DOCDIR"\.lib\freeglut_static.lib"

Copy-Item -Force -Recurse -Verbose "${FREEGLUT_INSTALL_PATH}\include\GL" -Destination ${OPENGL_INCLUDE_PATH}
Copy-Item -Force -Recurse -Verbose "${GLEW_INSTALL_PATH}\include\GL" -Destination ${OPENGL_INCLUDE_PATH}
Copy-Item -Force -Recurse -Verbose "${GLFW_INSTALL_PATH}\include\GLFW" -Destination ${OPENGL_INCLUDE_PATH}
#----------------------------------------------------------------------------------------
cd $DOCDIR
# clear stuff
Remove-Item -Path ${FREEGLUT_INSTALL_PATH} -Recurse -Force
Remove-Item -Path ${GLEW_INSTALL_PATH} -Recurse -Force
Remove-Item -Path ${GLFW_INSTALL_PATH} -Recurse -Force
