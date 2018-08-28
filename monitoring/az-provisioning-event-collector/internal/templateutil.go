package internal

import (
	"text/template"
	"strings"
)

//TemplateManager TODO
type TemplateManager struct {
	templ *template.Template
	wr    *strings.Builder
}

const templateName = "JSON Handler"

//NewTemplateManager TODO
func NewTemplateManager() *TemplateManager {
	t := template.New(templateName)
	wr := &strings.Builder{}
	return &TemplateManager{templ: t, wr: wr}
}

//ParseJSONDataInTemplate TODO
func (t *TemplateManager) ParseJSONDataInTemplate(templateSource string, jsonData string) (string, error) {

	t.wr.Reset()
	rt, err := t.templ.Funcs(template.FuncMap{
		"valueFromJSONKey": func(key string) (string, error) {

			return ValueFromJSONKey(key, jsonData)
		},
		"keyAndValueFromJSONKey": func(key string, sep string) (string, error) {

			return KeyAndValueFromJSONKey(key, sep, jsonData)
		},
	}).Parse(templateSource)

	if err != nil {
		return "", err
	}

	err = rt.Execute(t.wr, nil)

	if err != nil {
		return "", err
	}

	return t.wr.String(), nil
}
