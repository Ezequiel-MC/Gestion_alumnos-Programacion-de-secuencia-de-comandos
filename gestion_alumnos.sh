#!/bin/bash

DIR_BASE="gestion_alumnos"
DIR_DOCS="$DIR_BASE/documentos"
DIR_RESPALDOS="$DIR_BASE/respaldos"
DIR_REPORTES="$DIR_BASE/reportes"
DIR_LOGS="$DIR_BASE/logs"
ARCHIVO_ALUMNOS="$DIR_DOCS/alumnos.txt"

if [ $# -gt 0 ]; then 
    echo "Buscando al alumno: $1"

    [ -f "$ARCHIVO_ALUMNOS" ] && grep -i "$1" "$ARCHIVO_ALUMNOS" || echo "Archivo no encontrado."
    exit 0
fi

preparar_entorno() {
    if [ ! -d "$DIR_BASE" ]; then
        mkdir -p "$DIR_DOCS" "$DIR_RESPALDOS" "$DIR_REPORTES" "$DIR_LOGS"
        touch "$ARCHIVO_ALUMNOS"
        echo "Entorno de directorios creado correctamente."
    fi
  
    echo "Usuario: $USER | Equipo: $HOSTNAME | Fecha: $(date +%F)"
    echo "Directorio de trabajo actual: $(pwd)"
}

preparar_entorno

registrar_alumno() {
    local nombre=""
    local edad carrera calificacion
  
    until [ "${#nombre}" -gt 0 ]; do
        read -p "Nombre del alumno: " nombre
    done

    read -p "Edad: " edad
    read -p "Carrera: " carrera

    calificacion=-1
    until [[ "$calificacion" -ge 0 && "$calificacion" -le 100 ]]; do
        read -p "Calificación (0-100): " calificacion
    done

    echo "$nombre, $edad, $carrera, $calificacion" >> "$ARCHIVO_ALUMNOS"
    echo "Alumno registrado correctamente."
}

mostrar_alumnos() {
    echo "=== Lista de Alumnos Registrados ==="
  
    if [ -s "$ARCHIVO_ALUMNOS" ]; then
        cat "$ARCHIVO_ALUMNOS" | sort
    else
        echo "No hay alumnos registrados aún."
    fi
}

generar_reporte() {
    local total=0
    local suma_calif=0
    local aprobados=0
    local reprobados=0

    declare -A carreras
    declare -a lista_nombres

    while IFS=',' read -r nombre edad carrera calificacion; do
        ((total++))
        suma_calif=$((suma_calif + calificacion))

        lista_nombres+=("$nombre")

        if [ "$calificacion" -ge 70 ]; then
            ((aprobados++))
        else
            ((reprobados++))
        fi

        carrera="${carrera# }"
        ((carreras["$carrera"]++))
       
    done < "$ARCHIVO_ALUMNOS"


if [ "$total" -eq 0 ]; then
        echo "No hay datos para generar el reporte."
        return
    fi

    local promedio=$((suma_calif / total))
    local archivo_salida="$DIR_REPORTES/reporte.txt"

    echo "=== Reporte de Alumnos ===" > "$archivo_salida"
    echo "Total de alumnos: $total" >> "$archivo_salida"
    echo "Promedio de calificaciones: $promedio" >> "$archivo_salida"
    echo "Alumnos aprobados: $aprobados | Alumnos reprobados: $reprobados" >> "$archivo_salida"
    echo "Total de alumnos por carrera:" >> "$archivo_salida"

    for carrera in "${!carreras[@]}"; do
        echo "  $carrera: ${carreras[$carrera]}" >> "$archivo_salida"
    done

    echo "Reporte generado en: $archivo_salida"
}

realizar_respaldo() {
    local fecha_hora=$(date +%Y%m%d_%H%M%S)
    local destino="$DIR_RESPALDOS/alumno_$fecha_hora.txt"

    [ -f "$ARCHIVO_ALUMNOS" ] && cp "$ARCHIVO_ALUMNOS" "$destino" && echo "Respaldo exitoso en: $destino" || echo "Fallo al respaldar"

    echo "$(date): Respaldo generado en: $destino" >> "$DIR_LOGS/actividad.txt"

    echo -e "\nDemostracion tecnica"
    set -x

    (cd "$DIR_DOCS" && echo "Directorio dentro de subshell (): $(pwd)")
    { echo "Directorio en la agrupacion {}: $(pwd)"; }
    set +x

    cat archivo_inexistente.txt 2>> "$DIR_LOGS/errores.txt"
    echo "Se ha enviado un error intencional al archivo logs/errores.txt"
}

while true; do
    echo -e "\n=== Menu de Gestion de Alumnos ==="
    echo "1. Registrar Alumno"
    echo "2. Mostrar Alumnos registrados"
    echo "3. Buscar Alumno"
    echo "4. Generar Reporte de alumnos"
    echo "5. Realizar Respaldo"
    echo "6. Salir"
    read -p "Seleccione una opcion (1-6): " opcion

    case $opcion in
        1) registrar_alumno ;;
        2) mostrar_alumnos ;;
        3) read -p "Ingrese nombre del alumno a buscar: " nombre_buscar
           grep -i "$nombre_buscar" "$ARCHIVO_ALUMNOS" || echo "No se encontró el alumno." ;;
        4) generar_reporte ;;
        5) realizar_respaldo ;;
        6) echo "Saliendo del sistema. ¡Hasta luego!"
           exit 0 ;;
        *) echo "Opción inválida. Intente nuevamente." ;;
    esac
done
    