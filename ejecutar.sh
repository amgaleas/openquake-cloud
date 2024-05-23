#!/bin/bash

# Verificar que se han proporcionado dos argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <corto|largo> <nuevo_region_grid_spacing>"
    exit 1
fi

# Asignar los argumentos a variables
tipo_ejecucion=$1
nuevo_grid_spacing=$2

# Definir la base del nombre del archivo según el tipo de ejecución
if [ "$tipo_ejecucion" = "corto" ]; then
    archivo_ini="/opt/openquake/venv/demos/hazard/PSHA_ejemplo_corto_Sistamas_Paralelo/Ecuador_ejemplo_corto_Sistamas_Paralelo.ini"
elif [ "$tipo_ejecucion" = "largo" ]; then
    archivo_ini="/opt/openquake/venv/demos/hazard/PSHA_ejemplo_largo_Sistamas_Paralelo/Ecuador_ejemplo_largo_Sistamas_Paralelo.ini"
else
    echo "El primer parámetro debe ser 'corto' o 'largo'."
    exit 1
fi

# Reemplazar el valor de region_grid_spacing en el archivo .ini
sed -i "s/region_grid_spacing = .*/region_grid_spacing = $nuevo_grid_spacing/" "$archivo_ini"

# Ejecutar el comando OpenQuake
oq engine --run "$archivo_ini"
