# Introduction 
Custom NGINX image with Lua support based on Bitnami's NGINX as a base image.

Can be used as a substitute for Openresty.

# Build and Test
Only prerequisite is to have Docker installed.

To build and run the image locally:
```
docker build -t nginx-lua .
docker run nginx-lua
```

Or use docker-compose:
```
docker-compose up --build
```