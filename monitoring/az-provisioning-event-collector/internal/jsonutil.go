package internal

import (
	"encoding/json"
	"fmt"
	"io"
	"strings"
)

//ResultKeyValue TODO
type ResultKeyValue struct {
	Key, Value string
}

//ValueFromJSONKey TODO
func ValueFromJSONKey(path string, jsonData string) (string, error) {
	kv, err := ResultKeyValueFromJSONPath(path, jsonData)

	if err != nil {
		return "", err
	}

	if kv != nil {
		return kv.Value, nil
	}

	return "", nil
}

//KeyAndValueFromJSONKey TODO
func KeyAndValueFromJSONKey(path string, sep string, jsonData string) (string, error) {
	kv, err := ResultKeyValueFromJSONPath(path, jsonData)

	if err != nil {
		return "", err
	}

	if kv != nil {
		return fmt.Sprintf("%s%s%s", kv.Key, sep, kv.Value), nil
	}

	return "", nil
}

//ResultKeyValueFromJSONPath TODO
func ResultKeyValueFromJSONPath(path string, jsonData string) (*ResultKeyValue, error) {
	dec := json.NewDecoder(strings.NewReader(jsonData))
	var n map[string]interface{}

	var err error
	for {

		n, err = decodeElement(dec)

		if err != nil {
			if err == io.EOF {
				return nil, nil
			}

			return nil, err
		}

		keys := strings.Split(path, ".")

		result, _ := jsonWalker(keys, n)

		if result != nil {
			return result, nil
		}
	}
}

func decodeElement(dec *json.Decoder) (map[string]interface{}, error) {
	var obj interface{}
	err := dec.Decode(&obj)

	if err != nil {
		if err == io.EOF {
			return nil, err
		}

		return nil, err
	}

	n, ok := obj.(map[string]interface{})

	if ok {
		return n, nil
	}

	array, ok := obj.([]interface{})

	if !ok {
		return nil, fmt.Errorf("Invalid json document. %v", obj)
	}

	//TODO: assumes that if an array is received only the first one will be used.
	n, ok = array[0].(map[string]interface{})

	if !ok {
		return nil, fmt.Errorf("Invalid json document. %v", obj)
	}

	return n, nil

}
func jsonWalker(keys []string, values map[string]interface{}) (*ResultKeyValue, error) {
	if len(keys) == 0 {
		return nil, nil
	}

	if len(keys) > 1 {
		newvalues, okay := values[keys[0]].(map[string]interface{})

		if !okay {

			array, ok := values[keys[0]].([]interface{})

			if !ok {
				return nil, fmt.Errorf(" invalid value provided. Could not assert the underlying data type")
			}

			for _, item := range array {
				val := item.(map[string]interface{})
				kv, err := jsonWalker(keys[1:], val)

				if kv != nil && err == nil {
					return kv, nil
				}
			}

			return nil, nil
		}

		return jsonWalker(keys[1:], newvalues)
	}

	key := keys[0]
	if value, ok := values[key]; ok {
		v, _ := value.(string)

		return &ResultKeyValue{
			Key:   key,
			Value: v,
		}, nil
	}

	return nil, fmt.Errorf(" key %s not found", key)
}
