
# Getting Started

Set up environment variables:

```bash
export AZURE_CLIENT_ID=...
export AZURE_TENANT_ID=...
export AZURE_CLIENT_SECRET=...
export EVENTHUB_NAMESPACE=...
export EVENTHUB_NAME=...
export EVENTHUB_KEY_VALUE=...
export EVENTHUB_KEY_NAME=...
```

Build the Dockerfile and run the image

```bash
azcollect -s <SUBSCRIPTION ID> -a <LEASE STORAGE ACCOUNT NAME> -g <RESOURCE GROUP> -u <TELEGRAF URL> -t <TEMPLATE>
```


*Note:* ```<RESOURCE GROUP>``` must be the name of the resource group containing the lease storage account.

## Templates

The event collector uses Go's template library (text/template) to parse the provided template. The result is the payload sent to Telegraf using a POST operation.

The events are expected in JSON format. Two custom functions that are provided to faciliate the extraction of data from the event regardless of its JSON schema:  ```keyAndValueFromJSONKey``` and ```valueFromJSONKey```. 

Given the following JSON payload:

```json
{
    "band":"pearl jam",
    "genre":"alternative",
    "members":[
        {"vocals": {
            "name":"Eddie",
            "lastname":"Vedder"
            }},
        {"leadguitar":"Mike"},
        {"guitar":"Stone"},
        {"drums":"Matt"}
    ]
}
```

And the template:

 ```bash
 two-members: {{ valueFromJSONKey "members.vocals.name" }}, {{ valueFromJSONKey "members.leadguitar" }}
 ```

The resulting payload would be:

```bash
two-members: Eddie, Mike
```

If the field name is needed to create a key value list, you can use ```keyAndValueFromJSONKey```.


```bash
 two-members: {{ keyAndValueFromJSONKey "members.guitar" "=" }}, {{ keyAndValueFromJSONKey "members.drums" "=" }}

```

Will result on:

```bash
two-members: guitar=Stone, drums=Matt
```
