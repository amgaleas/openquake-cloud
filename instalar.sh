#!/bin/bash

# Mostrar mensaje de iniciación
echo "Comenzando instalación de Openquake"

# Actualizar la lista de paquetes e instalar las actualizaciones
sudo apt update -y
sudo apt upgrade -y

# Instalar Python 3.9 y configurar alternativas
sudo apt install -y python3.9
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Instalar paquetes adicionales de Python
sudo apt install -y python3.9-venv python3.9-dev
sudo apt install -y python3-pip

# Descargar el archivo install.py de OpenQuake
curl -L -O https://github.com/gem/oq-engine/raw/master/install.py

# Ejecutar el script de instalación de OpenQuake
sudo -H /usr/bin/python3 install.py server

# Instalar unrar y descomprimir el archivo Ejemplos.rar
sudo apt install -y unrar
unrar x -o+ Ejemplos.rar /opt/openquake/venv/demos/hazard/

# Instalar dos2unix y convertir el archivo Ejecutar.sh
sudo apt install -y dos2unix
dos2unix Ejecutar.sh

# Hacer el archivo Ejecutar.sh ejecutable
chmod +x Ejecutar.sh

# Mostrar mensaje de finalización
echo "Openquake instalado con éxito"
