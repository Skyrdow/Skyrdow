#!/bin/bash

MODE_FILE="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"

# Verifica que el archivo exista
if [ ! -f "$MODE_FILE" ]; then
    echo "No se encontró conservation_mode. ¿Está cargado el módulo ideapad_laptop?"
    exit 1
fi

# Leer estado actual
current=$(cat "$MODE_FILE")

if [ "$current" -eq 1 ]; then
    echo "Desactivando modo de conservación (permitir carga completa)"
    echo 0 | sudo tee "$MODE_FILE" > /dev/null
else
    echo "Activando modo de conservación (limitar al 60%)"
    echo 1 | sudo tee "$MODE_FILE" > /dev/null
fi
