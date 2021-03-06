#! /bin/sh
current_user = $USER
CPWD = /home/${USER}/kontiki
ifeq ($(C),)
 C = 'updates'
endif

submqtt:
ifeq ($(c),)
	@echo "make submqtt c=300 h=1 r=10"
	@echo "make submqtt c=[message-count] h=[hop-count] r=[message-generation-rate]"
else
	@echo "Launching...\nHop: $h\nMessage Count: $c\nPacket Per Second: $r\nAddress: aaaa::c30c:0:0:$h\nTopic: emch/mqtt/sub/$(h)/$(r)\n";
	bash ./submqtt.sh c=${c} h=${h} r=${r}
	@#mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/server/5/1 -C 300 --quiet | ts '[%Y-%m-%d %H:%M:%.S]' | tee >( grep --line-buffered -v "Client" > ~/mqtt-logs/_`date +%Y_%m_%d_%H_%M`_4_h_t.txt)
	@#mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/sub/$(h)/$(r) -C $(c) --quiet | ts '[%Y-%m-%d %H:%M:%.S]' | tee >( grep --line-buffered -v "Client" > ~/mqtt-logs/_`date +%Y_%m_%d_%H_%M`_$(h)H_$(r)PPS.txt)
endif

n ?= 101
dortt:
ifeq ($(USER),root)
	@echo "root user, not allowed, try with standard user"
else
	@#	make push m="Added-some-test"
	@echo "make dortt m=2 t=0.01 d=2"
	@echo "you can connect border router now"
	@while [ -z "$$CONTINUE" ]; do \
	read -r -p "Is Border Router connected ?. [y/N]: " CONTINUE; \
	done ; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "..moving on.."
	@echo "Starting wireshark"
	@wireshark &
	@while [ -z "$$CONTINUE" ]; do \
	read -r -p "Is wireshark started and connected to TunSLIP ?. [y/N]: " CONTINUE; \
	done ; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "..moving on.."
	@echo "Current USER: $(USER)"
	@echo "tail -f ~/coap-logs/coap_$m_hop_$t_sec.txt"
	n=$(n); \
	while [ $${n} -gt 0 ] ; do \
	echo "Get Request $$n Executed."; \
	n=`expr $$n - 1`; \
	sleep $t; coap get coap://[aaaa::c30c:0:0:$m]:5683/sens/mote -T -q -t $d >> ~/coap-logs/coap_$m_hop_$t_sec.txt; \
	done; \
	true
endif
#sleep $t; coap get coap://[aaaa::c30c:0:0:$m]:5683/sens/mote -T | sed '(?<=Request took ).*?(?=\s)'; \

cooja:
	sudo service mosquitto start
	sudo gnome-terminal --tab --working-directory='/home/${USER}/kontiki/tools/cooja/' -e "ant run" --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' --tab --working-directory='/home/${USER}/nodev/e-MCH-APp/'
	echo "Starting mosquitto service....."
	service mosquitto status| grep running
	sleep 5
	firefox http://[aaaa::c30c:0:0:1]/ &

mqtt:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-mqtt-emch.pow.upload nodeid=4 nodemac=4
	@echo "you can connect border router now"
	@while [ -z "$$CONTINUE" ]; do \
	read -r -p "Is Border Router connected ?. [y/N]: " CONTINUE; \
	done ; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "..moving on.."	
	sudo gnome-terminal --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' -e "make connect-router" --tab -e "sudo wireshark" --tab --working-directory='/home/${USER}/nodev/e-MCH-APp/' -e "sudo npm start"
	sudo service mosquitto start
	echo "Starting mosquitto service....."
	service mosquitto status| grep running
	sleep 5
	firefox http://localhost:3000/mqtt >> '/home/${USER}/logs/firelog.log' &
	sleep 3
	firefox --new-tab http://[aaaa::c30c:0:0:1]/ &

coap:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-coap-emch.rtt.upload nodeid=2 nodemac=2
	@echo "you can connect border router now"
	@while [ -z "$$CONTINUE" ]; do \
	read -r -p "Is Border Router connected ?. [y/N]: " CONTINUE; \
	done ; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "..moving on.."	
	sudo gnome-terminal --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' -e "make connect-router" --tab -e "sudo wireshark" --tab --working-directory='/home/${USER}/nodev/e-MCH-APp/' -e "sudo npm start"
	sleep 5
	firefox http://localhost:3000/coap >> '/home/${USER}/logs/firelog.log' &
	sleep 3
	firefox --new-tab http://[aaaa::c30c:0:0:1]/ &

http:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-http-emch.pow.upload nodeid=3 nodemac=3
	@echo "you can connect border router now"
	@while [ -z "$$CONTINUE" ]; do \
	read -r -p "Is Border Router connected ?. [y/N]: " CONTINUE; \
	done ; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "..moving on.."	
	sudo gnome-terminal --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' -e "make connect-router" --tab -e "sudo wireshark" --tab --working-directory='/home/${USER}/nodev/e-MCH-APp/' -e "sudo npm start"
	sleep 5
	firefox http://localhost:3000/http >> '/home/${USER}/logs/firelog.log' &
	sleep 3
	firefox --new-tab http://[aaaa::c30c:0:0:1]/ &

burn-mqtt:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-mqtt-emch.pow.upload nodeid=4 nodemac=4
	sudo service mosquitto start
	echo "Starting mosquitto service....."
	service mosquitto status| grep running
	@echo "Topic: "
	@echo "iot-2/evt/status/fmt/json"

burn-mqtt-2:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-mqtt-emch.pow.2.upload nodeid=2 nodemac=2
	@echo "Topic: "
	@echo "emch/mqtt/server/2"

burn-mqtt-3:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-mqtt-emch.pow.3.upload nodeid=3 nodemac=3
	@echo "Topic: "
	@echo "emch/mqtt/server/3"

burn-mqtt-4:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-mqtt-emch.pow.4.upload nodeid=4 nodemac=4
	@echo "Topic: "
	@echo "emch/mqtt/server/4"

burn-coap:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-coap-emch.pow.upload nodeid=2 nodemac=2

burn-coap-a:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-coap-emch.pow.upload nodeid=10 nodemac=10

burn-coap-b:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-coap-emch.pow.upload nodeid=11 nodemac=11

burn-http:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-http-emch.pow.upload nodeid=3 nodemac=3

burn-http-a:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-http-emch.pow.upload nodeid=10 nodemac=10

burn-http-b:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-http-emch.pow.upload nodeid=11 nodemac=11


burn-brouter:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-border-router.upload nodeid=1 nodemac=1
	#sudo gnome-terminal --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' -e "make connect-router"
	#sleep 5
	#firefox http://[aaaa::c30c:0:0:1]/ &

burn-hop-a:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-a.hop.upload nodeid=10 nodemac=10

burn-hop-b:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-b.hop.upload nodeid=11 nodemac=11

burn-hop-mqtt-a:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-mqtt-a.hop.upload nodeid=10 nodemac=10
	@echo "Topic: "
	@echo "emch/mqtt/hop/a"

burn-hop-mqtt-b:
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-mqtt-b.hop.upload nodeid=11 nodemac=11
	@echo "Topic: "
	@echo "emch/mqtt/hop/b"

burn-hop-coap-a:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-caop-a.hop.upload nodeid=10 nodemac=10

burn-hop-coap-b:
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-caop-b.hop.upload nodeid=11 nodemac=11

burn-hop-http-a:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-http-a.hop.upload nodeid=10 nodemac=10

burn-hop-http-b:
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean && sudo make TARGET=z1 savetarget && sudo make z1-reset && sudo make z1-emch-http-b.hop.upload nodeid=11 nodemac=11

clean:
	rm -f *.exe

clean-all:
	cd ${CPWD}/examples/zolertia/z1/ && make clean all
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && make clean
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && make clean all
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && make clean all
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && make clean all
	cd ${CPWD}/examples/er-rest-example/ && make clean all

log:
	vim '/home/${USER}/logs/firelog.log'

console-mqtt:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t iot-2/evt/status/fmt/json -v

console-server-mqtt-2:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/server/2 -v
console-server-mqtt-3:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/server/3 -v

console-server-mqtt-4:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/server/4 -v

console-hop-mqtt-a:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/hop/a -v

console-hop-mqtt-b:
	mosquitto_sub -u use-token-auth -P AUTHZ -d -t emch/mqtt/hop/b -v

clean-emch:
	cd ${CPWD}/examples/zolertia/z1/ && make clean
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && make clean
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && make clean
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && make clean
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && make clean
	cd ${CPWD}/examples/ipv6/rpl-collect/ && make clean
	cd ${CPWD}/examples/er-rest-example/ && make clean
	cd ${CPWD}/examples/rime/ && make clean

clean-emch-f:
	cd ${CPWD}/examples/zolertia/z1/ && sudo make clean
	cd ${CPWD}/examples/zolertia/z1/mqtt-z1/ && sudo make clean
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean
	cd ${CPWD}/examples/zolertia/z1/ipv6/z1-websense/ && sudo make clean
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make clean
	cd ${CPWD}/examples/ipv6/rpl-collect/ && sudo make clean
	cd ${CPWD}/examples/er-rest-example/ && sudo make clean
	cd ${CPWD}/examples/rime/ && sudo make clean

ifeq ($(m),)
 m = 'updates'
endif

push:
ifeq ($(USER),root)
	@echo "root user, will not push to repository, try with standard user"
else
	@#	make push m="Added-some-test"
	@echo "Current USER: $(USER)"	
	git add -A
	git commit -m $(m)
	git push origin master
endif

pull:
	git pull origin master

run:
	sudo gnome-terminal --tab --working-directory='${CPWD}/examples/ipv6/rpl-border-router/' --tab -e "sudo wireshark" --tab --working-directory='/home/${USER}/nodev/e-MCH-APp/' -e "sudo npm start"
	firefox http://localhost:3000/coap >> '/home/${USER}/logs/firelog.log' &

list:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make z1-motelist && cd ~/kontiki/

login:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make z1-reset && sudo make login && cd ~/kontiki/

reset:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make z1-reset && cd ~/kontiki/

connect:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make z1-reset && sudo make connect-router && cd ~/kontiki/

connect-cooja:
	cd ${CPWD}/examples/ipv6/rpl-border-router/ && sudo make z1-reset && sudo make connect-router-cooja && cd ~/kontiki/

dialout-user:
	sudo adduser ${USER} dialout

reboot:
	sudo reboot

view-project:
	firefox https://github.com/kaleemullah360/kontiki &

view-profile:
	firefox https://github.com/kaleemullah360 &

open-project:
	subl ~/kontiki &

life:
	bash ./life.sh