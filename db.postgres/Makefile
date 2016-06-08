include ../conf/config.mk

CLI_FLAGS=-it
CONF_MAIN_HOST=$(DB_DATA_DIR)/postgresql.conf
CONF_MAIN_CONTAINER=/data/postgresql.conf
CONF_LOGGING_HOST=$(DB_BASE)/postgresql-logging.conf
CONF_LOGGING_CONTAINER=/data/postgresql-logging.conf
DB_INIT=-v "$(CONF_LOGGING_HOST):$(CONF_LOGGING_CONTAINER)"
HBA=/data/pg_hba.conf
PGPASS_HOST=$(DB_BASE)/pgpass
PGPASS_CONTAINER=/root/.pgpass

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
	sudo chown -R 999:0 "$(DB_DATA_DIR)" "$(DB_LOGS_DIR)"

start: stop $(DB_DATA_DIR)
	@echo "Starting container: $(DB_CONTAINER)"
	docker run \
		$(DB_INIT) \
		--detach \
		-e PGDATA=/data \
		-e POSTGRES_DB="$(DB_NAME)" \
		-e POSTGRES_PASSWORD='$(DB_ROOT)' \
		-e POSTGRES_USER="$(DB_USER)" \
		--hostname="$(DB_LINK)" \
		--log-driver=syslog \
		--log-opt tag=$(DB_CONTAINER) \
		--name "$(DB_CONTAINER)" \
		--restart=unless-stopped \
		-v "$(DB_DATA_DIR)/:/data/" \
		-v "$(DB_LOGS_DIR)/:/logs/" \
		postgres \
		-c config_file="$(CONF_MAIN_CONTAINER)" \
		-c log_directory="/logs" \

stop:
	@echo "Stopping container: $(DB_CONTAINER)"
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker stop
	@docker ps -a --filter name="$(DB_CONTAINER)" --format '{{.ID}}' | xargs -r docker rm

cli: $(PGPASS_HOST)
	@docker run \
		$(CLI_FLAGS) \
		--link $(DB_CONTAINER):$(DB_LINK) \
		--rm \
		-v "$(PGPASS_HOST):$(PGPASS_CONTAINER):ro" \
		postgres \
		sh -c 'exec psql -h "$(DB_LINK)" -U "$(DB_USER)" "$(DB_NAME)"'

cli_notty:
	make cli CLI_FLAGS=-i

# need to use shell and basename
# otherwise rules do not work

build: $(shell basename "$(DB_ROOT_FILE)")
	mkdir "$(DB_DATA_DIR)"
	mkdir "$(DB_LOGS_DIR)"
	make perms
	make start DB_INIT=""
	./waitbuild "$(DB_CONTAINER)"
	docker exec "$(DB_CONTAINER)" sh -c "echo \"include = '$(CONF_LOGGING_CONTAINER)'\" >> \"$(CONF_MAIN_CONTAINER)\""
	
	make start
	@echo "-------------------------------------------------"
	@echo "DB Host: $(DB_LINK)"
	@echo "DB Name: $(DB_NAME)"
	@echo "DB User: $(DB_USER)"
	@echo "DB Pass: $(shell cat $(DB_ROOT_FILE))"
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

$(shell basename "$(DB_ROOT_FILE)"):
	pwgen -s 20 1 > "$@"
	chmod 600 "$@"

$(PGPASS_HOST): $(shell basename "$(DB_ROOT_FILE)")
	sudo echo "*:5432:$(DB_NAME):$(DB_USER):$(shell cat $(DB_ROOT_FILE))" > "$@"
	sudo chmod 600 "$@"
	sudo chown root:root "$@"
