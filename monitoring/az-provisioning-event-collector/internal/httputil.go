package internal

import (
	"bytes"
	"fmt"
	"log"
	"net"
	"net/http"
	"time"
)

const retryLimit = 10                             // max retries for an operation in retriableOperation
const retrySleepDuration = time.Millisecond * 250 // Retry wait interval in retriableOperation

//ExecuteRetriablePost TODO
func ExecuteRetriablePost(body string, url string) error {
	return retriableOperation(
		func(retry int) error {
			var err error
			b := bytes.NewBufferString(body)
			r := bytes.NewReader(b.Bytes())
			var res *http.Response
			var req *http.Request

			req, err = http.NewRequest("POST", url, r)

			if err != nil {
				return err
			}

			res, err = httpClient.Do(req)

			//TODO: Specify valid codes for the retry to occurr
			if res != nil && res.StatusCode != 200 {
				return fmt.Errorf("Invalid response %s. Retrying", res.Status)
			}
			if err != nil {
				return err
			}

			return nil
		})

}

//retriableOperation executes a function, retrying up to "retryLimit" times and waiting "retrySleepDuration" between attempts
func retriableOperation(operation func(r int) error) error {
	var err error
	var retries int

	for {
		if retries >= retryLimit {
			return fmt.Errorf("The number of retries has exceeded the maximum allowed. Error: %v ", err.Error())
		}
		if err = operation(retries); err == nil {
			return nil
		}

		log.Printf("Error: %s retrying...", err)
		retries++

		time.Sleep(retrySleepDuration)
	}
}

var httpClient = newpipelineHTTPClient()

func newpipelineHTTPClient() *http.Client {

	return &http.Client{
		Transport: &http.Transport{
			Proxy: http.ProxyFromEnvironment,
			Dial: (&net.Dialer{
				Timeout:   30 * time.Second,
				KeepAlive: 30 * time.Second,
				DualStack: true,
			}).Dial,
			MaxIdleConns:           100,
			MaxIdleConnsPerHost:    100,
			IdleConnTimeout:        60 * time.Second,
			TLSHandshakeTimeout:    10 * time.Second,
			ExpectContinueTimeout:  1 * time.Second,
			DisableKeepAlives:      false,
			DisableCompression:     false,
			MaxResponseHeaderBytes: 0}}

}
