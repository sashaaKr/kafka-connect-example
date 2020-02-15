docker-compose up kafka-cluster elasticsearch postgres
docker run --rm -it --name=kafka-commands --net=host landoop/fast-data-dev bashs