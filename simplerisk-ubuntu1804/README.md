# SimpleRisk in Docker

To get started, clone the SimpleRisk Docker repo by copying the following line and running it in a terminal:
```bash
git clone https://github.com/simplerisk/docker.git simplerisk-docker && cd simplerisk-docker
```
This will clone the Docker repository and move you into the right directory.

Next, download a SimpleRisk bundle from [here](https://github.com/simplerisk/bundles) and save it as `simplerisk.tgz` in `./simplerisk`.

## Running SimpleRisk locally

You can run SimpleRisk using `docker-compose` locally in one of two ways;
 - using `docker-compose-local.yml` which will start up a MySQL database as well as the SimpleRisk application itself.
 - using `docker-compose.yml` which starts the SimpleRisk application only so will require you to specify a MySQL database to connect to. 

### Generating the `.env` file

Populate the .env file with the relevant secrets and keys (keys will need line endings to be replaced with '\n'; literally the backslash then n rather than escape-n which is a newline).

If you need help with this you can run the bootstrap Docker image at the command line thus:
```bash
docker build -t simplerisk-bootstrap:latest ./bootstrap && docker run -v `pwd`/data/bootstrap:/bootstrap simplerisk-bootstrap:latest
```
This will give you a `.env` file in `./data/bootstrap/` with generated values that can be used to run SimpleRisk locally as well as connect to a local MySQL database in Docker. 

### Running SimpleRisk and MySQL in Docker

Assuming you have generated the `.env` file successfully, start SimpleRisk and MySQL using this command: 
```bash
docker-compose -f docker-compose-local.yml --env-file ./data/bootstrap/.env up -d
``` 
This will create all of the necessary images and services to run SimpleRisk, and will start everything in daemon mode (detached shell)

Visit [https://localhost:8443](https://localhost:8443) to use SimpleRisk. NB: You'll have to accept a self-signed certificate in your browser in order to see the application.
 
To login, username is `admin` and the password is `admin`.

### Running SimpleRisk standalone

To run SimpleRisk on its own, you will need to copy the `.env.example` file in the root directory of the project, saving it as `.env`.
You will then need to specify 

- `MYSQL_HOSTNAME` - the MySQL server.
- `MYSQL_DATABASE` - the name of the database SimpleRisk will use (simplerisk is recommended).
- `MYSQL_USER` - the MySQL user that the SimpleRisk application will be connecting as.
- `MYSQL_PASSWORD` - the password of the MySQL user that the SimpleRisk application will be connecting as. 
- `MYSQL_SSL_CERTIFICATE_PATH` - (Optional) the path to the certificate that allows SSL connections to a MySQL server. Certificates should be saved in `/var/www/simplerisk/ssl`.
- `PRIVATE_KEY` - a base64 encoded private key for SSL HTTP connections to SimpleRisk's Web UI 
- `CERTIFICATE` - - a base64 encoded certificate for SSL HTTP connections to SimpleRisk's Web UI 

Start SimpleRisk using this command: 
```bash
docker-compose up -d
```

## Troubleshooting

- To wipe everything and start again `rm -Rf ./data`
- Shell into the app container with: 
```bash
docker exec -ti `docker ps | grep 'simplerisk-www' | cut -d " " -f1` /bin/bash
```
- For a completely insecure installation (because everyone knows the secrets) you can use the example env file `.env.example` by copying it: `cp .env.example .env`

## Building the images independently of `docker-compose`

- SimpleRisk:
  - Download a SimpleRisk bundle from [here](https://github.com/simplerisk/bundles).
  - Run `docker build --build-arg simplerisk_build_artifact=<PATH_TO_SIMPLERISK_BUNDLE> -t simplerisk-www:latest ./simplerisk` in a terminal
- Database: `docker build -t simplerisk-db:latest ./database`
