#!/bin/bash

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

# Instalar nginx
sudo apt install -y nginx

# Configurar nginx para servir la aplicación web
sudo bash -c 'cat > /etc/nginx/sites-available/openquake <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL'

# Enlazar la configuración y eliminar el archivo de configuración por defecto
sudo ln -s /etc/nginx/sites-available/openquake /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Reiniciar nginx para aplicar los cambios
sudo systemctl restart nginx

# Crear un entorno virtual para la aplicación
python3.9 -m venv /opt/openquake/venv

# Activar el entorno virtual
source /opt/openquake/venv/bin/activate

# Instalar gunicorn
pip install gunicorn

# Iniciar la aplicación web usando gunicorn
sudo bash -c 'cat > /etc/systemd/system/openquake.service <<EOL
[Unit]
Description=Gunicorn instance to serve OpenQuake
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/opt/openquake
Environment="PATH=/opt/openquake/venv/bin"
ExecStart=/opt/openquake/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 wsgi:app

[Install]
WantedBy=multi-user.target
EOL'

# Recargar systemd y habilitar el servicio
sudo systemctl daemon-reload
sudo systemctl start openquake
sudo systemctl enable openquake

# Mostrar mensaje de finalización con la IP pública
echo "Setup completado con éxito y el WebUI está disponible en http://$(curl -s ifconfig.me)"
