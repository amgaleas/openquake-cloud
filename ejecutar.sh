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

# Inicia monitoreo de CPU y RAM
echo "Iniciando monitoreo de recursos..."
vmstat 1 > vmstat.log &
VMSTAT_PID=$!

# Captura el tiempo de inicio
start_time=$(date +%s)

# Ejecutar el comando OpenQuake
oq engine --run "$archivo_ini"

# Detener el monitoreo de recursos
kill $VMSTAT_PID

# Captura el tiempo de finalización
end_time=$(date +%s)

# Calcula el tiempo total de ejecución
execution_time=$((end_time - start_time))

# Encontrar el último archivo HDF5 generado
latest_hdf5=$(ls -t /root/oqdata/calc_*.hdf5 | head -n 1)
size_kb=$(du -k "$latest_hdf5" | cut -f1)

# Cálculos de uso promedio de CPU y RAM
cpu_usage=$(awk '{total += $13} END {print total/NR}' vmstat.log)
ram_usage=$(awk '{total += $4} END {print total/NR/1024}' vmstat.log) # Convertido a GB

# Mostrar resultados
echo "Uso promedio de CPU: $cpu_usage %"
echo "Uso promedio de RAM: $ram_usage GB"
echo "Tamaño del archivo: $size_kb KB"
echo "Tiempo de ejecución: $execution_time segundos"
