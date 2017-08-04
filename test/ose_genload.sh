## A simple application to generate a set amount of projects, builderapps, ad instantapps. Use external monitoring tools while the script executes.
#!/bin/bash
Projects=1
BuilderApps=1
InstantApps=1
NOW=$(date +"%m-%d-%Y-%H-%M-%S")
start=`date +%s`
## Create projects and applications
for ((i=0; i<=Projects; i++)); do
   oc new-project "loadtest-00"$NOW-$i
   for ((n=0; n<=BuilderApps; n++)); do
   	oc new-app rails-postgresql-example --name=rails00$n
   done
   for ((l=0; l<=InstantApps; l++)); do
   	oc new-app https://github.com/openshift/cakephp-ex/ --name=php-00$l
   done
done
for ((i=0; i<=Projects; i++)); do
   oc project "loadtest-00"$NOW-$i
   oc get pods
done

sleep 600

end=`date +%s`
runtime=$((end-start))

echo "Total runtime = "$runtime
## Cleanup
for ((i=0; i<=Projects; i++)); do
   oc delete project "loadtest-00"$NOW-$i
done
