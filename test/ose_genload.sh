## A simple application to generate a set amount of projects, builderapps, ad instantapps. Use external monitoring tools while the script executes. 
#!/bin/bash
Projects=10
BuilderApps=5
InstantApps=10
NOW=$(date +"%m-%d-%Y-%H-%M-%S")

## Create projects and applications
for ((i=0; i<=Projects; i++)); do
   oc new-project "loadtest-00"$NOW-$i
   for ((n=0; n<=BuilderApps; n++)); do
   	oc new-app https://github.com/openshift/rails-ex.git --name=rails00$n
   done
   for ((l=0; l<=InstantApps; l++)); do
   	oc new-app --image-stream=php:latest --name=php-00$l
   done
done

sleep 60

## Cleanup
for ((i=0; i<=Projects; i++)); do
   oc delete project "loadtest-00"$NOW-$i
done
