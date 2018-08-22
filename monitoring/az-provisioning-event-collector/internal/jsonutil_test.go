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
