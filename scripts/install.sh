# fix the locale stuff 

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8

echo "Installing packages..."

# update apt-get lists
sudo apt-get -q update

# install all required packages
sudo apt-get install -qy build-essential cmake git pkg-config libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk2.0-dev python-dev  \
python3-dev python3-tk libopenblas-dev liblapack-dev python3-pip
  
# install and configure virtualenv
pip3 install virtualenv virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs

# add the conf script of virtualenv to bashrc
echo -e "\n# virtualenv and virtualenvwrapper" >> ~/.bashrc
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.bashrc
echo "source ~/.local/bin/virtualenvwrapper.sh" >> ~/.bashrc

# load virtualenv stuff
source ~/.local/bin/virtualenvwrapper.sh

# create a virtual env
mkvirtualenv cv -p python3
workon cv

# upgrade pip, possibly
python -m pip install --upgrade pip

# install useful python packages within the cv virtual env
pip install numpy scipy scikit-learn scikit-image matplotlib ipython jupyter pandas sympy nose

# clone opencv repo's if not done
if [ ! -d "opencv" ]; then 
    git clone --depth 1 https://github.com/opencv/opencv.git
    git clone --depth 1 https://github.com/opencv/opencv_contrib.git
else
   cd ~/opencv
   git pull
   cd ~/opencv_contrib
   git pull    
fi 

# about to build opencv
cd ~/opencv
mkdir -p build
cd build/

# configure opencv
cmake -D CMAKE_BUILD_TYPE=RELEASE \
 -D CMAKE_INSTALL_PREFIX=/usr/local \
 -D INSTALL_C_EXAMPLES=OFF \
 -D INSTALL_PYTHON_EXAMPLES=OFF \
 -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
 -D BUILD_EXAMPLES=OFF \
 -D BUILD_opencv_freetype=OFF  ..

# compile and install
make && sudo make install 

# link the opencv lib into the virtualenv as cv2
cd ~/.virtualenvs/cv/lib/python3.5/site-packages
ln -s /usr/local/lib/python3.5/site-packages/cv2.cpython-35m-x86_64-linux-gnu.so cv2.so

# create jupyter configuration file
mkdir -p ~/.jupyter
cd ~/.jupyter
cat > jupyter_notebook_config.py << EOF
# Configuration file for jupyter-notebook.
c.NotebookApp.allow_origin = '*'
c.NotebookApp.enable_mathjax = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'sha1:3fa9b12ce4f9:4a2561e19114afae58e5b836b212b6cdc4387472'
EOF

echo "All set!"
