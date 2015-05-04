# docker-gocd-server
ThoughtWorks go-cd server

```
export SSH_KEY=${HOME}/.ssh/id_bitbucket
docker run -d \
	-p 443:443 \
	--volume ${SSH_KEY}:/root/.ssh/id_rsa:ro \
	--volume /var/lib/containers/gocd/var/lib/go-server:/var/lib/go-server \
	--volume /var/lib/containers/gocd/var/log/go-server:/var/log/go-server \
	--name gocd \
	savaki/gocd-server:latest 
```

