package workers

import (
	"fmt"
	"net/url"

	"github.com/BCDevOps/openshift-tools/monitoring/az-provisioning-event-collector/internal"
)

//InfluxDBEventWriter TODO
type InfluxDBEventWriter struct {
	url            *url.URL
	templateSource string
	templateMan    *internal.TemplateManager
}

//NewInfluxDBEventWriter TODO
func NewInfluxDBEventWriter(influxDBURL string, templateSource string) (*InfluxDBEventWriter, error) {
	u, err := url.Parse(influxDBURL)

	if err != nil {
		return nil, err
	}

	return &InfluxDBEventWriter{
		url:            u,
		templateSource: templateSource,
		templateMan:    internal.NewTemplateManager(),
	}, nil
}

//Process TODO
func (c *InfluxDBEventWriter) Process(event ReceivedEvent) error {

	data := string(event.Event.Data)
	pdata, err := c.templateMan.ParseJSONDataInTemplate(c.templateSource, data)

	if err != nil {
		return err
	}

	fmt.Printf("Sending event... ID: %s\n", event.Event.ID)
	err = internal.ExecuteRetriablePost(pdata, c.url.String())

	if err != nil {
		return err
	}

	return nil
}
