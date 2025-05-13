#!/bin/bash
for container in $(docker ps --format '{{.Names}}'); do
    name=$(docker exec "$container" hostname)
    if [[ "$name" == *"router"* ]]; then
        if ! [[ "$name" == *"1"* ]]; then
            docker exec -i "$container" ip link add br0 type bridge
            docker exec -i "$container" ip link set dev br0 up
            docker exec -i "$container" ip link add vxlan10 type vxlan id 10 dstport 4789
            docker exec -i "$container" ip link set dev vxlan10 up
            docker exec -i "$container" brctl addif br0 vxlan10
            docker exec -i "$container" brctl addif br0 eth0
        fi
        
        if [[ "$name" == *"1"* ]]; then
            docker exec -i "$container" vtysh < ./frr.txt
            echo -e "\e[32mContainer $name set\e[0m"
        fi
        if [[ "$name" == *"2"* ]]; then
            docker exec -i "$container" vtysh < ./leaf1.txt
            echo -e "\e[32mContainer $name set\e[0m"
        fi
        if [[ "$name" == *"3"* ]]; then
            docker exec -i "$container" vtysh < ./leaf2.txt
            echo -e "\e[32mContainer $name set\e[0m"
        fi
        if [[ "$name" == *"4"* ]]; then
            docker exec -i "$container" vtysh < ./leaf3.txt
	   echo -e "\e[32mContainer $name set\e[0m"
        fi
    else
    	if [[ "$name" == *"1"* ]]; then
    	    docker exec -i "$container" ip addr add 20.1.1.1/24 dev eth0
        fi
        if [[ "$name" == *"2"* ]]; then
            docker exec -i "$container" ip addr add 20.1.1.2/24 dev eth0
        fi
        if [[ "$name" == *"3"* ]]; then
	    docker exec -i "$container" ip addr add 20.1.1.3/24 dev eth0
        fi
	echo -e "\e[32mContainer $name set\e[0m"
    fi
done
