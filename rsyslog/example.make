all:
	curl --include \
		--request POST \
		--header 'Content-type: application/hal+json' \
		--header 'X-CSRF-Token: oymUgG9pPpRgmDKvyIFiISaD8IbHtQ-vi3Phk01ySq4' \
		http://local.blackout.dev:60011/entity/node?_format=hal_json \
		--data-binary '{"_links":{"type":{"href":"http://local.blackout.dev:60011/rest/type/node/item"}},"title":[{"value":"Example node title"}],"type":[{"target_id":"item"}],"field_source_ip":[{"value":"1.2.3.5"}]}'
	@echo
