# Vuash Dockerfile
Vuash is a simple web app that lets you share plain text through a single access link.
## How to use
if you use port 8080 to visit this webapp
docker build . -t vuash
docker run -d -p 8080:3000 --name vuash_container vuash
after boot up,wait sometime for postgresql to start
## How to view log
docker logs -f vuash_container
## Vuash github url
https://github.com/current/vuash