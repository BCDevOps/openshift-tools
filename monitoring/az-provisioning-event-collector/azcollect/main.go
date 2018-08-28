package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"

	"github.com/BCDevOps/openshift-tools/monitoring/az-provisioning-event-collector/workers"
)

var options workers.EventHubMultiPartitionReaderOptions
var targetURL = ""
var templateSource = ""

func init() {

	flag.StringVar(&options.EnvironmentName, "v", "AZUREPUBLICCLOUD", "Azure environment name")
	flag.StringVar(&options.SubscriptionID, "s", "", "Azure Subscription ID")
	flag.StringVar(&options.StorageContainerName, "c", "eventhublease", "Storage Container name")
	flag.StringVar(&options.StorageAccountName, "a", "", "Lease Storage Account name")
	flag.StringVar(&options.ResourceGroup, "g", "", "Lease Storage Account Resource Group name")
	flag.IntVar(&options.NumOfHosts, "h", 1, "Number of Azure Event Hub readers")
	flag.StringVar(&targetURL, "u", "", "Target URL")
	flag.StringVar(&templateSource, "t", "", "Template Source")

}

func main() {
	flag.Parse()

	err := validate()

	if err != nil {
		log.Fatal(err)
	}

	reader, err := workers.NewEventHubMultiPartitionReader(options)

	if err != nil {
		log.Fatal(err)
	}

	writer, err := workers.NewInfluxDBEventWriter(targetURL, templateSource)

	if err != nil {
		log.Fatal(err)
	}

	processor := workers.NewProcessor()

	processor.ProcessEvents(reader, writer)

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for {
			select {
			case <-c:
				fmt.Printf("Stopping...\n")
				err := processor.Stop()
				if err != nil {
					log.Fatal(err)
				}

			}
		}
	}()

	fmt.Printf("Press ctrl+c to stop.\nWaiting for events from the Azure Event Hub: %s...", options.EventHubName)
	err = processor.Wait()

	if err != nil {
		log.Fatal(err)
	}
}

func validate() error {
	format := " %s is required"
	const envVarNsName = "EVENTHUB_NAMESPACE"
	const envVarHubName = "EVENTHUB_NAME"
	options.EventHubName = os.Getenv(envVarHubName)
	options.NsName = os.Getenv(envVarNsName)

	if options.EventHubName == "" {
		return fmt.Errorf(format, "Azure Event Hub name. Set env variable: %s", envVarHubName)
	}
	if options.NsName == "" {
		return fmt.Errorf(format, "Namespace name. Set env variable:%s", envVarNsName)
	}
	if options.SubscriptionID == "" {
		return fmt.Errorf(format, "Subscription ID")
	}
	if options.StorageContainerName == "" {
		return fmt.Errorf(format, "Storage Container name")
	}
	if options.StorageAccountName == "" {
		return fmt.Errorf(format, "Storage Account name")
	}
	if options.ResourceGroup == "" {
		return fmt.Errorf(format, "Resource Group name")
	}

	if templateSource == "" {
		return fmt.Errorf("Template is missing")
	}

	if targetURL == "" {
		return fmt.Errorf("Target URL is missing")
	}

	if options.NumOfHosts < 1 {
		return fmt.Errorf("Invalid number of hosts, value must be greater than 1. Value: %d", options.NumOfHosts)
	}
	return nil
}
