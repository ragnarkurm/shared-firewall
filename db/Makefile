include ../conf/config.mk

TIMEOUT = 30
CLI_FLAGS=-it

BACKUP_OBJECTS = \
	"$(DB_DATA_DIR)" \
	"$(DB_LOGS_DIR)" \

all:
	@echo
	@echo "make perms"
	@echo "make start"
	@echo "make stop"
	@echo "make cli"
	@echo "make cli_notty"
	@echo "make build"
	@echo "make backup"
	@echo "make restore"
	@echo "make restore RESTORE_SOURCE='...'"
	@echo

perms:
	sudo chown -R 999:999 "$(DB_DATA_DIR)" "$(DB_LOGS_DIR)"

# if you need to log all querys:
# --general-log=1

start: stop $(DB_DATA_DIR)
	@echo "Starting Db server"
	@docker run \
		-d \
		--name "$(DB_CONTAINER)" \
		$(DB_INIT) \
		-v "$(DB_CONF):/etc/mysql/my.cnf" \
		-v "$(DB_DATA_DIR)/:/data/" \
		-v "$(DB_LOGS_DIR)/:/logs/" \
		--restart=unless-stopped \
		mysql \
		--general-log=0 \

stop:
	@echo "Stopping Db server"
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker stop
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker rm

cli:
	docker run \
		$(CLI_FLAGS) \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		--rm \
		mysql \
		sh -c 'exec mysql -h"$$MYSQL_PORT_3306_TCP_ADDR" -u"$(DB_USER)" -p"$(DB_PASS)" "$(DB_NAME)"'

cli_notty:
	make cli CLI_FLAGS=-i

# need to use shell and basename
# otherwise rules do not work

build: $(shell basename "$(DB_PASS_FILE)") $(shell basename "$(DB_ROOT_FILE)")
	mkdir "$(DB_DATA_DIR)"
	mkdir "$(DB_LOGS_DIR)"
	touch "$(DB_LOGS_DIR)"/error.log
	touch "$(DB_LOGS_DIR)"/general.log
	touch "$(DB_LOGS_DIR)"/slow.log
	make perms
	make start DB_INIT="-e MYSQL_ROOT_PASSWORD='$(DB_ROOT)'"
	@echo "Sleeping $(TIMEOUT) sec while initializing database"
	docker logs -f -t "$(DB_CONTAINER)" &
	@sleep $(TIMEOUT)
	echo "\
		create database $(DB_NAME) default character set utf8 default collate utf8_general_ci; \
		create user '$(DB_USER)'@'%' identified by '$(DB_PASS)'; \
		grant all privileges on $(DB_NAME).* to '$(DB_USER)'@'%'; \
		flush privileges; \
	" | docker run \
		-i \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		--rm \
		mysql \
		sh -c 'exec mysql -h"$$MYSQL_PORT_3306_TCP_ADDR" -uroot -p"$$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
	make start
	@echo "-------------------------------------------------"
	@echo "DB Host: $(DB_LINK)"
	@echo "DB Name: $(DB_NAME)"
	@echo "DB User: $(DB_USER)"
	@echo "DB Pass: $(DB_PASS)"
	@echo "-------------------------------------------------"

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

# need to use shell and basename
# otherwise rules do not work

$(shell basename "$(DB_PASS_FILE)") $(shell basename "$(DB_ROOT_FILE)"):
	pwgen -s 20 1 > "$@"
	chmod 600 "$@"
