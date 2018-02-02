CONF = iptables.conf

all: whitelist.ipset blacklist.ipset
	sh whitelist.ipset
	sh blacklist.ipset

load:
	ipset -exist create blacklist hash:ip
	ipset -exist create whitelist hash:ip
	iptables-restore -n < "${CONF}"

blacklist.ipset: blacklist.json list2ipset
	./list2ipset blacklist < "$<" > "$@"

whitelist.ipset: whitelist.json list2ipset
	./list2ipset whitelist < "$<" > "$@"

blacklist.json: FORCE
	wget --tries=1 --timeout=5 'http://dev.blackout.local:60011/blackout/blacklist/*?_format=json' -O "$@"

whitelist.json: FORCE
	wget --tries=1 --timeout=5 'http://dev.blackout.local:60011/blackout/whitelist/*?_format=json' -O "$@"

clean:
	rm -f "whitelist.json" "blacklist.json" "whitelist.ipset" "blacklist.ipset"

FORCE:
