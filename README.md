ksys-idempiere-docker-eclipse
=======================

Base docker image to run iDempiere-KSYS (dev) inside Eclipse Equinox

Usage
-----

To create the image `longnan/ksys-idempiere-docker-eclipse`, execute the following command on the ksys-docker-idempiere-eclipse folder:

	docker build --rm --force-rm -t longnan/ksys-idempiere-docker-eclipse:3.1.0.20160730 .


To save/load image:

	# save image to tarball
	$ sudo docker save longnan/ksys-idempiere-docker-eclipse:3.1.0.20160730 | gzip > ksys-idempiere-docker-eclipse-3.1.0.20160730.tar.gz

	# load it back
	$ sudo gzcat ksys-idempiere-docker-eclipse-3.1.0.20160730.tar.gz | docker load
	
Download prepared images from:

	https://sourceforge.net/projects/idempiereksys/files/idempiere-ksys-docker-image/


To run the image:

	# run ksys-idempiere-pgsql
	docker volume rm ksys-idempiere-pgsql-datastore
	docker volume create --name ksys-idempiere-pgsql-datastore
	docker volume inspect ksys-idempiere-pgsql-datastore
	docker run -d --name="ksys-idempiere-pgsql" -v ksys-idempiere-pgsql-datastore:/data -p 5432:5432 -e PASS="postgres" longnan/ksys-idempiere-docker-pgsql:3.1.0.20160730
	docker logs -f ksys-idempiere-pgsql
	
	# run ksys-idempiere-eclipse
	docker run -d -t --link ksys-idempiere-pgsql:idempiere-db --name="ksys-idempiere-eclipse" -p 80:8080 -p 443:8443 longnan/ksys-idempiere-docker-eclipse:3.1.0.20160730
	docker logs -f ksys-idempiere-eclipse

	# run ksys-idempiere-eclipse in debug mode
	docker run --env KSYS_DEBUG='true' -d -t --link ksys-idempiere-pgsql:idempiere-db --name="ksys-idempiere-eclipse" -p 80:8080 -p 443:8443 -p 4554:4554 longnan/ksys-idempiere-docker-eclipse:3.1.0.20160730

To stop the container:

	docker stop ksys-idempiere-eclipse
	docker stop ksys-idempiere-pgsql

To re-start the container from last stoppage:	

	docker start ksys-idempiere-pgsql
	docker start ksys-idempiere-eclipse

To access iDempiere-KSYS web-ui:
	web-ui
	http://docker-host-ip/webui
	osgi console
	http://docker-host-ip/osgi/system/console/bundles

To SSH to container:

	# Download the insecure private key
	curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key
	chmod 600 insecure_key

	# Login to the container
	ssh -i insecure_key root@$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ksys-idempiere-eclipse)

	# sftp back to docker host for download & upload:
	sftp user@docker-host-ip

To Shell to container:

	# For debugging and maintenance purposes you may want access the containers shell. 
	docker exec -it ksys-idempiere-eclipse bash

Other Packages
----
The following packages are needed to build docker image, but too big to be committed to github
	
	jdk-8uxx-linux-x64.tar.gz
	idempiereServer.gtk.linux.x86_64.zip

Please download them from:

	https://sourceforge.net/projects/idempiereksys/files/idempiere-ksys/

TODO
----
1. Add docker volume to persistent application data