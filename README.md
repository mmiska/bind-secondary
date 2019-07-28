# bind-secondary
A small secondary DNS Server as Docker Image

This Image can be used to create a Secondary DNS Service within a Docker
Host or even Swarm.

It is completely controlled via Enviroment Variables to set the Primary
Server and the Domains.

## Environmental Variables

- PRIMARY_SERVER => Which Primary Server should be contacted for zone
  transfer
- SECONDARY_DOMAINS => Which Domains should be transferred and served. This
is a comma-separated list e.g. example.com,example.org,example.net
- FORWARDER => Which forwarder should be used for recursion? This is a
comma-separated list e.g. 8.8.8.8,8.8.4.4
- RECURSION => Which IP-Ranges are allowed to do recursion. This is a
comma-separated list e.g. 10/8,172.16.0.0/24. If this is empty, recursion
will be disabled 
- QUERY => Which IP-Ranges are allowed to query this DNS Server. This is a
comma-separated list e.g. 10/8,172.16.0.0/24. If this is empty, query is
possible from RFC1918 Networks

## Todo
This image is not ready.....
Many things will be implemented in further version.

