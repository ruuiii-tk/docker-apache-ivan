# Imagen base de Debian
FROM debian:latest

# Actualización del sistema e instalación de Apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia de la página HTML personalizada al directorio web de Apache
COPY ivan_ruano.html /var/www/html/ivan_ruano.html

# Exponer el puerto 80 del contenedor
EXPOSE 80

# Ejecución de Apache en primer plano (foreground) para mantener el contenedor activo
CMD ["apachectl", "-D", "FOREGROUND"]
