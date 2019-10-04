tag=$1
docker build --force-rm=true --no-cache=true -t weblogic12c:$tag .
