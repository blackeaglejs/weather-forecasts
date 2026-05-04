# README

This application is a Rails application that takes an address as input, and then retrieves a weather forecast for that address. 

This application runs on Ruby 4 and Rails 8.1. 

This application is setup to run on docker compose, so ideally you have docker setup. Basic instructions for setting up Docker Desktop can be found at https://docs.docker.com/get-started/get-docker/. You could also setup using homebrew or other CLI tool if you prefer that.  

Once that's done, you can start with 
```
docker compose up --build
```

Alternately, there's an included Makefile that you can use. The commands in here are 
```
make start (builds the image and starts the application)
make build (just builds the image)
make console (runs a rails console)
make bash (creates a bash console)
make test (runs rspec tests)
make migrate (run db migrations)
```

Tests
Tests are handled using rspec. You can run them with a `bundle exec rspec`, or using the makefile command from agove. 

Design Patterns
This application uses a few different patterns. The biggest piece is the use of service objects. Isolating business logic away from controllers and models helps maintain single reponsibility principal, though we use the Locations::CreateWithForecast service as an orchestrator. The usage of a cache-aside pattern here is helpful for performance improvements. 

Scalability Considerations 
This application was built out as a basic example for how to geolocate and retrieve forecasts from an external API, with separate service objects covering each piece. If this was to build out into a much larger service, we'd need to consider a few things. First, our external provides would need to be swapped out. Nominatim restricts requests to 1/second. We solve some of this using cacheing, but for a large scale service we'd want to consider a more performant API like Google Maps. Weather requets are handled using Open-Meteo, which is a good starting point, but it might not be the worst idea to do a paid subscription to increase our requests/second.

Other than external dependencies, we'd also need to cacheing beyond the rails level cache. I chose solidcache because it's a good cache for lookups that are millisecond latency, but if we needed more latency I would consider something like Redis or Memcache, as these are dedicated cache technologies that will get results faster. We would also want to consider using something like a CDN to cache even further to reduce load on the web application. 