CONTAINER = secure-nginx

start: stop
	docker \
		run \
		--detach \
		--tty \
		--name "$(CONTAINER)" \
		--publish 8888:80 \
		--volume /home/ragnar/blackout/nginx/data:/var/www/html:ro \
		--volume /home/ragnar/blackout/nginx/conf:/opt/spider/conf:ro \
		--volume /home/ragnar/blackout/nginx/logs:/opt/spider/logs:rw \
		fooinha/nginx-modsecurity
	tail -f \
		logs/violations.log

#		--volume /home/ragnar/blackout/nginx/nginx.conf:/opt/spider/nginx.conf:ro \

stop:
	@echo "Stopping container: $(CONTAINER)"
	@docker ps -a --filter name="$(CONTAINER)" --format '{{.ID}}' | xargs -r docker stop
	@docker ps -a --filter name="$(CONTAINER)" --format '{{.ID}}' | xargs -r docker rm

cli:
	docker \
		exec \
		--interactive \
		--tty \
		"$(CONTAINER)" \
		/bin/bash
