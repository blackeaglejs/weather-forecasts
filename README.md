# README

This application is a Rails application that takes an address as input, and then retrieves a weather forecast for that address. 

This application runs on Ruby 4 and Rails 8.1. 

This application is setup to run on docker compose, so ideally you have docker setup. Basic instructions for setting up Docker Desktop can be found at https://docs.docker.com/get-started/get-docker/. You could also setup using homebrew or other CLI tool if you prefer that.  

Once that's done, you can start with 
```
docker compose up --build
```

Alternately, there's an included Makefile that you can use. The command for starting it is 
```
make start
```
This will build the image and start it. 
