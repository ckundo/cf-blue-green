#!/bin/bash
cf unmap-route blue-app cfapps.io -n cf-blue-green          # make the app unavailable to requests
cf push blue-app -c 'bundle exec rackup config.ru -p $PORT' # deploy the code changes to CF

# wait for the blue app to start
while true; do
  RESP=`curl -sIL -w "%{http_code}" "blue-app.cfapps.io" -o /dev/null`
  if [[ $RESP == "200" ]]
    then break
    else sleep 3 && echo "Waiting for 200 response"
  fi
done

# make the blue app available to the router
cf map-route blue-app cfapps.io -n cf-blue-green

# deploy to the green app
cf unmap-route green-app cfapps.io -n cf-blue-green
cf push green-app -c 'bundle exec rackup config.ru -p $PORT'
cf app green-app
cf map-route green-app cfapps.io -n cf-blue-green
