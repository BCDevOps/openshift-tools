package internal

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

const jsonDoc = `
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
`

//TestBasicJson TODO
func TestBasicJson(t *testing.T) {

	kv, err := ResultKeyValueFromJSONPath("band", jsonDoc)

	assert.NoError(t, err, "No error")
	assert.Equal(t, "band", kv.Key, "Name must be present")
	assert.Equal(t, "pearl jam", kv.Value)
}
func TestKeyInArray(t *testing.T) {

	kv, err := ResultKeyValueFromJSONPath("members.drums", jsonDoc)

	assert.NoError(t, err, "No error")
	if assert.NotNil(t, kv, "The KV must be a valid reference") {
		assert.Equal(t, "drums", kv.Key, "Name must be present")
		assert.Equal(t, "Matt", kv.Value)
	}
}
func TestChildKeyInArray(t *testing.T) {

	kv, err := ResultKeyValueFromJSONPath("members.vocals.lastname", jsonDoc)

	assert.NoError(t, err, "No error")
	if assert.NotNil(t, kv, "The KV must be a valid reference") {
		assert.Equal(t, "lastname", kv.Key, "Name must be present")
		assert.Equal(t, "Vedder", kv.Value)
	}
}

func TestInArray(t *testing.T) {

	arrayJson := fmt.Sprintf("[%s]", jsonDoc)
	kv, err := ResultKeyValueFromJSONPath("members.vocals.lastname", arrayJson)

	assert.NoError(t, err, "No error")
	if assert.NotNil(t, kv, "The KV must be a valid reference") {
		assert.Equal(t, "lastname", kv.Key, "Name must be present")
		assert.Equal(t, "Vedder", kv.Value)
	}
}

func TestInvalidKey(t *testing.T) {

	kv, err := ResultKeyValueFromJSONPath("bandx", jsonDoc)

	assert.NoError(t, err, "No error")
	assert.Nil(t, kv, "Must be nil")
}
func TestInvalidChildKey(t *testing.T) {

	kv, err := ResultKeyValueFromJSONPath("members.vocalist", jsonDoc)

	assert.NoError(t, err, "No error")
	assert.Nil(t, kv, "Must be nil")
}

func TestEventHubDoc(t *testing.T){
	const event = `
	[{
		"topic": "/subscriptions/sub123/resourceGroups/blobporter/providers/Microsoft.Storage/storageAccounts/foobar",
		"subject": "/blobServices/default/containers/test/blobs/1KB_10000957462500.dat",
		"eventType": "Microsoft.Storage.BlobCreated",
		"eventTime": "2018-08-22T03:17:25.5904001Z",
		"id": "29de4281-601e-010a-5dc6-399a53060603",
		"data": {
		  "api": "PutBlob",
		  "clientRequestId": "3a9a37d8-37f0-4d33-473c-d5384eaa9cd6",
		  "requestId": "29de4281-601e-010a-5dc6-399a53000000",
		  "eTag": "0x8D607DDC8B3E701",
		  "contentType": "application/octet-stream",
		  "contentLength": 1024,
		  "blobType": "BlockBlob",
		  "url": "https://foobar.blob.core.windows.net/test/1KB_10000957462500.dat",
		  "sequencer": "00000000000000000000000000000322000000000078690d",
		  "storageDiagnostics": {
			"batchId": "00e45fff-fae3-46aa-bd83-3399054158b1"
		  }
		},
		"dataVersion": "",
		"metadataVersion": "1"
	  }]
	`

	kv, err := ResultKeyValueFromJSONPath("subject", event)

	assert.NoError(t, err, "No error")
	if assert.NotNil(t, kv, "The KV must be a valid reference") {
		assert.Equal(t, "subject", kv.Key, "key must be present")
		assert.Equal(t, "/blobServices/default/containers/test/blobs/1KB_10000957462500.dat", kv.Value)
	}

	data, err := KeyAndValueFromJSONKey("eventType", "=", event)
	assert.NoError(t, err, "No error")
	assert.Equal(t, "eventType=Microsoft.Storage.BlobCreated", data, "value must match")
		
}