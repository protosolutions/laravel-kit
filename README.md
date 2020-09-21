# Laravel-Kit

The Laravel and composer commands are available in this container. Installing Laravel in your present directory can be done with either of these two commands.
```
docker run -v $PWD:/var/www/html -it --rm protosolutions/laravel-kit laravel new blog
docker run -v $PWD:/var/www/html -it --rm protosolutions/laravel-kit composer create-project --prefer-dist laravel/laravel blog 
```

Some options for this container.
```
-e WWW_DATA_ID=UID:GID - nginx and php-fpm will use this UID and GID if specified
-e WWW_DIR=/path/here/ - set the web directory to something other than /var/www/html/
```

Quickstart, create an app and begin running it.
```
docker run -v $PWD:/var/www/html -it --rm protosolutions/laravel-kit laravel new myapp-here
docker run -v $PWD:/var/www/html -p 80:80 -e WWW_DATA_ID=$(id -u):$(id -g) -e WWW_DIR=/var/www/html/myapp-here/public/ --rm -d protosolutions/laravel-kit:latest
```

If you need to do some debugging with bash.
```
docker run -v $PWD:/var/www/html -it --rm protosolutions/laravel-kit bash
```
