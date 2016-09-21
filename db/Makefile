include config.mk

BACKUP_OBJECTS = \
	"$(DB_DATA_DIR)" \
	"$(DB_LOGS_DIR)" \

all:
	@echo
	@echo "make start"
	@echo "make stop"
	@echo "make cli"
	@echo "make cli_notty"
	@echo "make perms"
	@echo "make build"
	@echo "make clean"
	@echo "make backup"
	@echo "make restore"
	@echo "make restore RESTORE_SOURCE='...'"
	@echo

# if you need to log all querys:
# --general-log=1

start: stop $(DB_DATA_DIR)
	@echo "Starting container: $(DB_CONTAINER)"
	@docker run \
		$(START_FLAGS) \
		--detach \
		--name "$(DB_CONTAINER)" \
		--restart=unless-stopped \
		--volume "$(DB_MY_CONF):/etc/mysql/my.cnf" \
		--volume "$(DB_DATA_DIR)/:/data/" \
		--volume "$(DB_LOGS_DIR)/:/logs/" \
		mysql \
		--general-log=0 \

stop:
	@echo "Stopping container: $(DB_CONTAINER)"
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker stop
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker rm

# --volume ~/.mysql_history:/root/.mysql_history \
# Unable to use mysql history
# since mysql uses tmp file by concatenating old and new history
# and moves it to place to replace mounted volume
# which fails:
# Error on rename of '/root/.mysql_history.TMP' to '/root/.mysql_history'
# (Errcode: 16 - Device or resource busy)

cli:
	@docker run \
		$(or $(CLI_FLAGS), --interactive --tty) \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		--rm \
		mysql \
		mysql \
			-u"$(DB_USER_NAME)" \
			-p"$(DB_USER_PASS)" \
			-h"$(DB_LINK)" \
			"$(DB_NAME)"

cli_notty:
	make cli CLI_FLAGS=--interactive

perms:
	sudo chown -R 999:999 "$(DB_DATA_DIR)" "$(DB_LOGS_DIR)"

# need to use shell and basename
# otherwise rules do not work

build: clean $(shell basename "$(DB_USER_PASS_FILE)") $(shell basename "$(DB_ROOT_PASS_FILE)")
	mkdir "$(DB_DATA_DIR)"
	mkdir "$(DB_LOGS_DIR)"
	touch "$(DB_LOGS_DIR)"/error.log
	touch "$(DB_LOGS_DIR)"/general.log
	touch "$(DB_LOGS_DIR)"/slow.log
	make perms
	make start START_FLAGS="--env MYSQL_ROOT_PASSWORD='$(DB_ROOT_PASS)'"
	./waitbuild "$(DB_CONTAINER)"
	echo "\
		create database $(DB_NAME) default character set utf8 default collate utf8_general_ci; \
		create user '$(DB_USER_NAME)'@'%' identified by '$(DB_USER_PASS)'; \
		grant all privileges on $(DB_NAME).* to '$(DB_USER_NAME)'@'%'; \
		flush privileges; \
	" | docker run \
		--interactive \
		--link "$(DB_CONTAINER):$(DB_LINK)" \
		--rm \
		mysql \
		mysql \
			-p"$(DB_ROOT_PASS)" \
			-h"$(DB_LINK)"
	make start
	@echo "-------------------------------------------------"
	@echo "DB Host: $(DB_LINK)"
	@echo "DB Name: $(DB_NAME)"
	@echo "DB User: $(DB_USER_NAME)"
	@echo "DB Pass: $(DB_USER_PASS)"
	@echo "-------------------------------------------------"

clean: stop
	sudo rm -rf "$(DB_DATA_DIR)"
	sudo rm -rf "$(DB_LOGS_DIR)"
	rm -f "$(DB_ROOT_PASS_FILE)"
	rm -f "$(DB_USER_PASS_FILE)"

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

$(shell basename "$(DB_USER_PASS_FILE)") $(shell basename "$(DB_ROOT_PASS_FILE)"):
	pwgen -s 20 1 > "$@"
	chmod 600 "$@"
