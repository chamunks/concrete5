# Concrete5 for Docker

Docker image of Concrete5 with Apache and PHP based on the official Debian Stretch image.

#### Fork Notes
I eventually ended up completely rewriting this whole thing it's probably justifiable to just start a new repository all together.

### To-Do:
 * [ ] Add release tags
 * [x] ~~~Add to Docker Hub~~~
 * [ ] Build containers for all php7.x supported versions of Concrete5
 * [ ] Figure out how I want to maintain this the laziest and most automated way possible
 * [x] ~~~Add environment variables for installing this without the wizard on deploy~~~
 * [ ] Document said variables so people can use this without having to think too hard.

![Concrete5](https://www.concrete5.org/themes/version_4/images/logo.png "Concrete5 logo")
#### Concrete5 is an easy to use web content management system

Concrete5 was designed for ease of use, for users with a minimum of technical skills. It features in-context editing (the ability to edit website content directly on the page, rather than in an administrative interface). Editable areas are defined in concrete5 templates which allow editors to insert 'blocks' of content. These can contain simple content (text and images) or have more complex functionality, for example image slideshows, comments systems, lists of files, maps etc. Further addons can be installed from the concrete5 Marketplace to extend the range of blocks available for insertion. Websites running concrete5 can be connected to the concrete5 website, allowing automatic upgrading of the core software and of any addons downloaded or purchased from the Marketplace.

## Quickstart:

#### Create a docker volume

If you want to have a cloud deployment in Kubernetes or something like Rancher you'll need to use Docker volumes for persistence.  This is a complex subject to cover and if you need it you should know what you're doing on your own but here's a primer.

[Creating a docker volume documentation.](https://docs.docker.com/engine/reference/commandline/volume_create/#extended-description)

#### Create a Database
This initializes one database for use with Concrete5. Remember replacing the the_root_password and the_db_user_password with real passwords.
```
docker run -d --name db \
    --restart=always \
    --volume ./data/db:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=c5db_database_root_password \
    -e MYSQL_USER=c5db_user \
    -e MYSQL_PASSWORD=c5db_database_password \
    -e MYSQL_DATABASE=c5db_database \
    mariadb
```

#### Run Concrete5
It  will be linked to the MariaDB: The link between the c5_db and the c5_web container causes the /etc/hosts file in the Concrete5 container to be continually updated with the current IP of the c5_db container.  This is a legacy feature of Docker and you should consider just using Docker-Compose or variants.

```
docker run -d --name=c5_web_1 \
    --restart=always \
    --volume ./data/html:/var/www/html \
    --link db:db \
    -p 80:80 \
    chamunks/concrete5
```

#### Docker-Compose
Alternatively to the above, using docker-compose create the data-volume, database and Concrete5 containers all in one step, as can be seen in `docker-compose.yml`. Or if you prefer, use host volumes as linked below:

[https://github.com/chamunks/concrete5/blob/master/docker-compose.yml](https://github.com/chamunks/concrete5/blob/master/docker-compose.yml)

Then you can run `docker-compose up -d` to launch your containers.

#### Docker-Compose Advanced Mode with HTTPS and other fun.

This version requires some things:

 - You'll need to know how to setup your own DNS prior to launching these containers to point at the place you'll be running this otherwise your TLS certificates won't work.
 - You'll need to know that port 443 and 80 will both be bound on all IP's on your machine unless you edit the file and specify what IP/Interface you want it bound to.
 - You understand that this is as is and YMMV it is essentially unsupported however I would like it in it's default form to work so if it doesn't please submit an issue.

[https://github.com/chamunks/concrete5/blob/master/docker-compose-advanced.yml](https://github.com/chamunks/concrete5/blob/master/docker-compose-advanced.yml)

This uses an extra container for a front end reverse proxy using an appliance called Traefik and it should automatically provision your acme.json located TLS certificates in front of your Concrete5 container.  You'll need to change variables in the docker-compose-advanced.yml file before it will run.

#### Concrete5 Setup
Visit your Concrete5 site at `https://example.org` for initial setup.

On the setup page, set your site-name and admin user password and enter the following

    Database Information:
    Server:          db
    MySQL Username:  c5db_user
    MySQL Password:  c5db_database_password
    Database Name:   c5db_database

#### Data will persist
The Concrete5 and MariaDB *application containers* can be removed (even with `docker rm -f -v`), upgraded and reinitialized without losing website or database data, as all website data is stored in the ./data/ directory. (Just do not delete the data directory;)
