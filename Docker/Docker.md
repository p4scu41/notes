
[Docker architecture](https://docs.docker.com/get-started/docker-overview)
![Docker architecture](./docker-architecture.webp)

image -> container

- Dockerfile
- Dockerfile.dev
- .dockerignore

docker images
docker build . -t image_name
docker build -t image_name .
docker image rm IMAGE_ID
docker container ls
docker run image_name
docker stop CONTAINER_ID
docker ps -a
docker run -p 5024:5024 image_name
docker run -d -p 5024:5024 image_name
docker run -it -d image:tag
docker run -e POSTGRES_PASSWORD=password postgres
docker exec -it CONTAINER_ID /bin/bash
docker exec -it CONTAINER_ID sh
docker stats
docker start CONTAINER_ID
docker logs -f CONTAINER_ID
docker logs --follow CONTAINER_ID
docker run -d -v path/local/directory:path/container/directory -p 3000:3000 image_name
docker tag username/image_name:version IMAGE_ID
docker push username/image_name:version

docker create --name custom_name IMAGE_NAME
docker container create IMAGE_NAME
docker start CONTAINER_ID
docker rm CONTAINER_ID

https://hub.docker.com/
docker pull ubuntu
docker images
docker run -it --entrypoint "/bin/bash" ubuntu

- namespaces (Espacios de nombre)
- cgroups (Grupos de control)
- Volumes
- Network drivers
- Docker Compose

docker network ls
docker network rm red-to-delete
docker network create todo-app
docker run -d
    --network todo-app
    --network-alias mysql
    -v todo-mysql-data:/var/lib/mysql
    -e MYSQL_ROOT_PASSWORD=secret
    -e MYSQL_DATABASE=todos
    mysql:5.7
docker exec -it CONTAINER_ID mysql -p

docker run -it --network todo-app nicolaka/netshoot
    dig mysql

docker run -dp 3000:3000
    --network todo-app
    -e MYSQL_HOST=mysql
    -e MYSQL_USER=root
    -e MYSQL_PASSWORD=secret
    -e MYSQL_DB=todos
    getting-started:v2

docker-compose.yaml
docker-compose-dev.yaml
docker compose up -d
docker compose down

docker compose -f docker-compose-dev.yaml up
