# docker-oclc-ezproxy

*A Docker container based on Debian that runs the OCLC EZproxy software.*

## Running the Container

> **NOTE**: For all examples shown, defining the `EZPROXY_WSKEY` variable is not required. If the variable is not defined, the container will look for a `wskey.key` file in your EZproxy config folder.

### Docker
#### Recommended

Using the Docker *host* network:

```sh
docker build -t oclc-ezproxy .
docker run -h HOSTNAME.TLD -e TZ=YOUR_TIMEZONE_HERE -e EZPROXY_WSKEY=YOUR_EZPROXY_WS_KEY_HERE -v PATH_TO_EZPROXY_CONFIG_FOLDER:/usr/local/ezproxy/config --network=host oclc-ezproxy
```

#### Not Recommended

Using the Docker *bridge* network and exposing the default port:

```sh
docker build -t oclc.ezproxy .
docker run -h HOSTNAME.TLD -e TZ=YOUR_TIMEZONE_HERE -e EZPROXY_WSKEY=YOUR_EZPROXY_WS_KEY_HERE -v PATH_TO_EZPROXY_CONFIG_FOLDER:/usr/local/ezproxy/config -p 2048:2048 oclc-ezproxy
```

### Docker Compose

```yaml
services:
  ezproxy:
    build: .
    container_name: oclc-ezproxy
    network_mode: host
    hostname: HOSTNAME.TLD
    restart: unless-stopped
    environment:
      - TZ=YOUR_TIMEZONE_HERE
      - EZPROXY_WSKEY=YOUR_EZPROXY_WSKEY_HERE
### ================================================================
### Ports commented out as network_mode is host.
### Set network_mode to bridge and uncomment the ports lines
### to use Docker bridge networking. (not recommended)
### ================================================================
#   ports:
#     - 2048:2048
### ================================================================
    volumes:
      - PATH_TO_EZPROXY_CONFIG_FOLDER:/usr/local/ezproxy/config
```

* **container_name** can be anything you'd like to name the container.
* **network_mode** is recommended to be *host*. Set to *bridge* and uncomment the *ports* config if you'd rather expose ports, but be warned that EZproxy may not function correctly if your EZproxy config is incorrect.
* **hostname** needs to be a FQDN. For most colleges, this may be something like *ezproxy.myschool.edu*, but the hostname must be applied or EZproxy will not route traffic properly.

> **NOTE**: The container runs EZproxy as a non-root user (UID/GID `999`), not `root`. Make sure `PATH_TO_EZPROXY_CONFIG_FOLDER` on the host is readable/writable by UID `999` (e.g. `chown -R 999:999 PATH_TO_EZPROXY_CONFIG_FOLDER`), especially if you're upgrading from an older image version where the config folder was written as root. The container is still able to bind to privileged ports like 80/443 despite not running as root.

## Why *Host* Networking is Recommended for this Container

Using the *host* network is recommended for OCLC EZproxy as the config.txt file within the EZproxy config handles exposed ports. Because this is a proxy software, the ports must match exactly what's exposed, and any mismatch between Docker's exposed ports and the ports exposed in config.txt will cause a redirect issue.

OCLC EZproxy is not compatible with a reverse proxy, also making the Docker *host* network more suitable. If you already use port 80/443 on your Docker host, you'll need a second IP address and configure EZproxy's config.txt to bind to that specific IP.

## OCLC EZproxy-specific Settings

This docker container contains some intermediate-to-advanced setup to function properly - most likely, copying your existing EZproxy configurations will not work as expected. Below are some additional notes pertaining to EZproxy administrators that I've come across when setting up this application.

### Binding an IP Address to EZproxy

You'll need to bind EZproxy to a specific IP on your network interfaces if you match the following predicament:

  1. Your Docker host is already using a container that binds to port 80 and 443 (or the container is using the host network and uses the same ports), AND
  2. You normally operate EZproxy under port 80 and 443.

To bind EZproxy to a specific IP, open your `config.txt` file and add the directive underneath your EZproxy `Name`:

```
Interface X.X.X.X
```

Where `X.X.X.X` is the local IP address that EZproxy should respond to. Once this is set, restart the EZproxy container and it'll only listen for requests via that local IP address.

Note that you'll also need to configure your existing 80 & 443 container to only listen on another IP address, otherwise you will run into routing issues. As I'm currently using **Caddy** for all other 80 & 443 requests, you can resolve this by inserting the following line for each host in your Caddyfile:

```
bind X.X.X.X
```

### Let's Encrypt SSL with EZproxy

There's a decent chance that you may be purchasing a wildcard certificate specifically for EZproxy, but you are able to easily use Let's Encrypt with your EZproxy instance if you have an already-configured Let's Encrypt daemon running.

My example will be for a Linux host, so change some steps as necessary if you're running Docker on Windows.

Let's set the following informaation:
  - Let's Encrypt certificates are stored in `/home/user/acme.sh/domain.com` as I use acme.sh for Let's Encrypt certificates.
  - EZproxy's certificates are expected to be in `/opt/docker/ezproxy/config/ssl` and are numbered sequentially.
      - EZproxy expects to see SSL certs in the following style:
          - `0000000#.crt` - Where `#` is any number `1-9`.
          - `0000000#.key` - Where `#` is any number `1-9` and corresponds with the adjacent `.crt`.
          - `active` - This file is used to tell EZproxy what file combo to load.

With this information, you just need to create a hard link from your Let's Encrypt certificates and rename the created hard link. For example:

```sh
ln /home/user/acme.sh/domain.com/domain.com.cer /opt/docker/ezproxy/config/ssl/00000001.crt
ln /home/user/acme.sh/domain.com/domain.com.key /opt/docker/ezproxy/config/ssl/00000001.key
```

This will create a hard link for your certificates into the EZproxy SSL directory. You'll then just need to edit the `active` file and change the number inside to the certificate number you want to load (without any leading zeroes).

Reload EZproxy, and you should be able to see your Let's Encrypt certificate applied successfully! Note that when you have this setup in place, you should never make any changes to SSL within the EZproxy administration interface as it could break the setup.
