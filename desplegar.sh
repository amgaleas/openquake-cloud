#!/bin/bash

# Actualizar la lista de paquetes e instalar nginx
sudo apt update -y
sudo apt install -y nginx

# Configurar nginx para servir la aplicación web en el puerto 8800
sudo bash -c 'cat > /etc/nginx/sites-available/openquake <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8800;
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

# Crear un entorno virtual para la aplicación (si no está creado)
if [ ! -d "/opt/openquake/venv" ]; then
    python3.9 -m venv /opt/openquake/venv
fi

# Activar el entorno virtual
source /opt/openquake/venv/bin/activate

# Instalar gunicorn (si no está instalado)
pip install gunicorn

# Iniciar la aplicación web usando gunicorn en el puerto 8800
sudo bash -c 'cat > /etc/systemd/system/openquake.service <<EOL
[Unit]
Description=Gunicorn instance to serve OpenQuake
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/opt/openquake
Environment="PATH=/opt/openquake/venv/bin"
ExecStart=/opt/openquake/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8800 wsgi:app

[Install]
WantedBy=multi-user.target
EOL'

# Recargar systemd y habilitar el servicio
sudo systemctl daemon-reload
sudo systemctl start openquake
sudo systemctl enable openquake

# Mostrar mensaje de finalización con la IP pública
echo "Setup completado con éxito y el WebUI está disponible en http://$(curl -s ifconfig.me)"
