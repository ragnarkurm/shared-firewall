include ../config.mk

DB_NAME = $(ID)
DB_ROOT_NAME = root
DB_ROOT_PASS = $(shell cat "$(DB_ROOT_PASS_FILE)")
DB_USER_NAME = $(ID)
DB_USER_PASS = $(shell cat "$(DB_USER_PASS_FILE)")

DB_BASE_DIR = $(BASE_DIR)/db
DB_DATA_DIR = $(DB_BASE_DIR)/data
DB_LOGS_DIR = $(DB_BASE_DIR)/logs
DB_MY_CONF = $(DB_BASE_DIR)/my.cnf
DB_USER_PASS_FILE = $(DB_BASE_DIR)/user.pw
DB_ROOT_PASS_FILE = $(DB_BASE_DIR)/root.pw
