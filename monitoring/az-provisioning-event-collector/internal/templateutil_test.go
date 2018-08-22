package internal

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const jsonData = `
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

func TestBasicTemplate(t *testing.T) {

	templateSource := `two-members: {{ valueFromJSONKey "members.vocals.name" }}, {{ valueFromJSONKey "members.leadguitar" }}`

	tm := NewTemplateManager()

	data, err := tm.ParseJSONDataInTemplate(templateSource, jsonData)

	assert.NoError(t, err, "No error")
	assert.Equal(t, "two-members: Eddie, Mike", data, "Data must match")
}

func TestBasicKeyValueTemplate(t *testing.T) {

	templateSource := `data {{keyAndValueFromJSONKey "band" "="}}`

	tm := NewTemplateManager()

	data, err := tm.ParseJSONDataInTemplate(templateSource, jsonData)

	assert.NoError(t, err, "No error")
	assert.Equal(t, "data band=pearl jam", data, "Data must match")
}

func TestTwoValuesTemplate(t *testing.T) {

	templateSource := `data {{valueFromJSONKey "band"}} {{valueFromJSONKey "genre"}}`

	tm := NewTemplateManager()

	data, err := tm.ParseJSONDataInTemplate(templateSource, jsonData)

	assert.NoError(t, err, "No error")
	assert.Equal(t, "data pearl jam alternative", data, "Data must match")
}
