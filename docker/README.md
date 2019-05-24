# Using Docker with Spring Boot and React

## Docker Example Run

Docker allows you to run and image as if it is a full VM. The image functions just like a 
self contained VM and will provide the data needed.

* Backend 
```bash
docker run -p 8180:8180  softvisionlvcp/spring-react-qatest-be:latest
```

* Frontend UI 
```bash
docker run -p 9000:80   softvisionlvcp/spring-react-qatest-ui:latest
```
 
## Docker Compose Example
Docker Compose provides an orchestrated run of all the containers that need to interact 
with each other such as a UI that needs to talk to a backend system API. This is useful for 
full end to end integration testing.
 ```bash
 cd $projectDir/docker
 docker compose up
 
 ctl C to quit
 
 OR to run in background mode
 
 docker compose up -d
 
 docker compose down  (to quit)  
 ```
 
 ## Maven Build Docker Images
 
 This will rebuild the docker images and push them up to the docker hub repo
 ```bash
 cd $ProjectDir
 mvn clean install -P build-docker-image
 ```
