# Práctica de Aula: Docker y Apache

**Alumno:** Iván Ruano  
**Asignatura / Módulo:** IAW  

---

## 1. Documentar los pasos en `Pasos-realizados.md`

---

## 2. Descargar la imagen del Hub de Docker de Debian
Descargamos la imagen oficial de Debian en Docker Hub:
```bash
docker pull debian
```

---

## 3. Arrancamos el contenedor con nombre, puerto, interactivo, terminal y en modo detached
Arrancamos el contenedor con:
* `--name debian-apache`: Nombre asignado al contenedor
* `-p 8080:80`: Mapeo del puerto 8080 del host al puerto 80 del contenedor
* `-i`: Modo interactivo
* `-t`: Asigna una pseudo-TTY
* `-d`: Modo detached (en segundo plano)

```bash
docker run -d -it --name debian-apache -p 8080:80 debian
```

---

## 4. Ejecutamos una shell bash en el contenedor:
Accedemos a la consola interactiva `bash` del contenedor:
```bash
docker exec -it debian-apache bash
```

---

## 5. Instalar paquete de Apache2 dentro del contenedor
Una vez dentro de la terminal de Debian:
```bash
apt update
apt install -y apache2
```

---

## 6. Arrancar el servicio Apache
Iniciamos el servicio Apache2:
```bash
service apache2 start
```
*(O `/etc/init.d/apache2 start`)*

Para comprobar que está activo:
```bash
service apache2 status
```

---

## 7. Comprobamos que el servidor web responde
Abrimos el navegador web en el equipo anfitrión y accedemos a:
```text
http://localhost:8080
```
*(Se visualiza la página por defecto "Apache2 Debian Default Page").*

---

## 8. Crear una página nueva HTML en `/var/www/html` llamada `ivan_ruano.html`
Dentro del contenedor (en la shell de bash), creamos el fichero HTML:
```bash
cat << 'EOF' > /var/www/html/ivan_ruano.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Práctica Docker - Iván Ruano</title>
</head>
<body>
    <h1>Servidor Apache en Docker</h1>
    <p>Práctica realizada por: <strong>Iván Ruano</strong></p>
</body>
</html>
EOF
```

---

## 9. Accedemos desde el navegador a la nueva página
En el navegador del host accedemos a la dirección:
```text
http://localhost:8080/ivan_ruano.html
```

---

## 10. Accedemos desde navegador de línea de comandos `elinks`
Podemos instalar y utilizar `elinks` dentro del contenedor o en el host:

**Opción A (dentro del contenedor):**
```bash
apt install -y elinks
elinks http://localhost/ivan_ruano.html
```

**Opción B (desde el host, si se tiene instalado):**
```bash
elinks http://localhost:8080/ivan_ruano.html
```

---

## 11. Crear Dockerfile para automatizar
Salimos del contenedor (`exit`) y en el directorio local del proyecto creamos el archivo `Dockerfile`:

```dockerfile
# Imagen base de Debian
FROM debian:latest

# Actualización del sistema e instalación de Apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia de la página HTML personalizada al directorio web de Apache
COPY ivan_ruano.html /var/www/html/ivan_ruano.html

# Exponer el puerto 80
EXPOSE 80

# Ejecución de Apache en primer plano (foreground)
CMD ["apachectl", "-D", "FOREGROUND"]
```

---

## 12. Creamos la imagen a partir del `Dockerfile`
Construimos la imagen personalizada con el tag `apache-ivan`:
```bash
docker build -t apache-ivan .
```

---

## 13. Ejecutamos el contenedor a partir de la nueva imagen
Arrancamos un contenedor usando nuestra imagen creada:
```bash
docker run -d --name contenedor-ivan -p 8080:80 apache-ivan
```
Comprobamos en el navegador: `http://localhost:8080/ivan_ruano.html`

---

## 14. Comando que copia un archivo local a un contenedor
Para copiar un archivo desde la máquina host hacia el contenedor:
```bash
docker cp ivan_ruano.html debian-apache:/var/www/html/ivan_ruano.html
```

---

## 15. Creamos el docker-compose.yml con volumen mapeado
Creamos el fichero `docker-compose.yml` que construye el servicio y mapea una carpeta local (`./html`) con el directorio raíz de Apache (`/var/www/html`):

```yaml
services:
  apache-servidor:
    build: .
    container_name: servidor_apache_ivan
    ports:
      - "8080:80"
    volumes:
      - ./html:/var/www/html
    restart: unless-stopped
```

Para levantar el servicio con Docker Compose:
```bash
docker compose up -d
```

Para detenerlo:
```bash
docker compose down
```

---

## Estructura final del repositorio para entrega en GitHub
```text
├── Dockerfile
├── docker-compose.yml
├── ivan_ruano.html
├── Pasos-realizados.md
└── html/
    └── ivan_ruano.html
```