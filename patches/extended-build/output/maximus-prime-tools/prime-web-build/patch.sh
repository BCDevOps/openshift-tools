#!/usr/bin/env bash

oc export bc/prime-web-build -o json -n maximus-prime-tools > prime-web-build-backup.json
oc patch --local=true -n maximus-prime-tools -f prime-web-build-backup.json --type="json" -o json --patch='[   {     "op": "replace",     "path": "/spec/source",     "value": {       "type": "Dockerfile",       "dockerfile": "FROM prime-web-build-angular-app:latest\nCOPY * /tmp/app/dist/\nCMD  /usr/libexec/s2i/run",       "images": [         {           "from": {             "kind": "ImageStreamTag",             "name": "prime-web-build-angular-app:latest"           },           "paths": [             {               "sourcePath": "/opt/app-root/src/dist/.",               "destinationDir": "tmp"             }           ]         }       ]     }   },   {     "op": "replace",     "path": "/spec/strategy",     "value": {       "type": "Docker",       "dockerStrategy": {         "from": {           "kind": "ImageStreamTag",             "name": "nginx-runtime:latest"         }       }     }   } ]' > prime-web-build-patched.json