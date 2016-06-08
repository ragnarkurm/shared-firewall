include ../conf/config.mk

BACKUP_OBJECTS = \
	"$(WEB_CACHE_DIR)" \
	"$(WEB_DATA_DIR)" \
	"$(WEB_FILES_DIR)" \
	"$(WEB_LOGS_DIR)" \
	"$(WEB_PRIVATE_DIR)" \

all:
	@echo
	@echo "make perms"
	@echo "make start_rw"
	@echo "make start"
	@echo "make stop"
	@echo "make backup"
	@echo "make restore"
	@echo "make restore RESTORE_SOURCE='...'"
	@echo

perms:
	sudo chown -R www-data:www-data "$(WEB_CACHE_DIR)"
	sudo find "$(WEB_CACHE_DIR)" -type d -print0 | sudo xargs -0 -r chmod 2775
	sudo find "$(WEB_CACHE_DIR)" -type f -print0 | sudo xargs -0 -r chmod 0664
	true
	sudo chown -R "`id -u`:`id -g`" "$(WEB_DATA_DIR)"
	sudo find "$(WEB_DATA_DIR)" -type d -print0 | sudo xargs -0 -r chmod 0755
	sudo find "$(WEB_DATA_DIR)" -type f -print0 | sudo xargs -0 -r chmod 0644
	sudo install -o www-data -g www-data -m 2775 -d "$(WEB_DATA_DIR)/cache"
	sudo install -o www-data -g www-data -m 2775 -d "$(WEB_DATA_DIR)/sites/default/files"
	true
	sudo chown -R www-data:www-data "$(WEB_FILES_DIR)"
	sudo find "$(WEB_FILES_DIR)" -type d -print0 | sudo xargs -0 -r chmod 2775
	sudo find "$(WEB_FILES_DIR)" -type f -print0 | sudo xargs -0 -r chmod 0664
	true
	sudo chown -R root:root "$(WEB_LOGS_DIR)"
	sudo find "$(WEB_LOGS_DIR)" -type d -print0 | sudo xargs -0 -r chmod 0755
	sudo find "$(WEB_LOGS_DIR)" -type f -print0 | sudo xargs -0 -r chmod 0644
	true
	sudo chown -R www-data:www-data "$(WEB_PRIVATE_DIR)"
	sudo find "$(WEB_PRIVATE_DIR)" -type d -print0 | sudo xargs -0 -r chmod 2775
	sudo find "$(WEB_PRIVATE_DIR)" -type f -print0 | sudo xargs -0 -r chmod 0664

start_rw:
	make start WEB_DATA_ACCESS=rw

# ports - internal and external must be same
# for drupal internal access, drush and rev proxy

start: stop $(WEB_DATA_DIR)
	@echo "Starting container: $(WEB_CONTAINER)"
	@docker run \
		--detach \
		-e APACHE_LOG_DIR="/logs" \
		-e APACHE_PORT="$(WEB_PORT)" \
		-e APACHE_SERVERNAME="$(WEB_DOMAIN)" \
		-e TERM=xterm \
		--hostname="$(WEB_CONTAINER)" \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		--log-driver=syslog \
		--log-opt tag=$(DB_CONTAINER) \
		--name "$(WEB_CONTAINER)" \
		-p "$(WEB_IP):$(WEB_PORT):$(WEB_PORT)" \
		--restart=unless-stopped \
		--tmpfs=/tmp \
		-v ~/.bash_history:/root/.bash_history \
		-v "$(WEB_CONF):/etc/apache2/sites-enabled/default.conf" \
		-v "$(WEB_DATA_DIR)/:/data/:$(WEB_DATA_ACCESS)" \
		-v "$(WEB_CACHE_DIR)/:/data/cache/" \
		-v "$(WEB_FILES_DIR)/:/data/sites/default/files/" \
		-v "$(WEB_LOGS_DIR)/:/logs/" \
		-v "$(WEB_PRIVATE_DIR)/:/private/" \
		-v "$(WEB_SSMTP):/etc/ssmtp/ssmtp.conf" \
		apache2-php5

stop:
	@echo "Stopping container: $(WEB_CONTAINER)"
	@docker ps -a --filter name="$(WEB_CONTAINER)" --format '{{.ID}}' | xargs -r docker stop
	@docker ps -a --filter name="$(WEB_CONTAINER)" --format '{{.ID}}' | xargs -r docker rm

console:
	@docker logs -f "$(WEB_CONTAINER)"

shell:
	@docker exec -it `docker ps -a --filter name="$(WEB_CONTAINER)" --filter status=running --format '{{.ID}}'` /bin/bash

#
#	backup & restore
#

backup:
	test ! -z "$(BACKUP_DESTINATION)"
	mkdir -p "$(BACKUP_DESTINATION)"
	for dir in $(BACKUP_OBJECTS) \
	; do true \
		; echo "* $$dir" \
		; sudo cp -pr "$$dir" "$(BACKUP_DESTINATION)/`basename $$dir`" \
	; done

restore:
	test ! -z "$(RESTORE_SOURCE)"
	for dir in $(BACKUP_OBJECTS) \
	; do true \
		; echo "* $$dir" \
		; sudo rsync -rlpEogtW --delete "$(RESTORE_SOURCE)/`basename $$dir`/" "$$dir" \
	; done
