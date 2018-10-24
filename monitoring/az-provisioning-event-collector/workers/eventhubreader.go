package workers

import (
	"context"
	"fmt"
	"log"

	"github.com/Azure/azure-amqp-common-go/sas"

	"sync"

	eventhubs "github.com/Azure/azure-event-hubs-go"
	eph "github.com/Azure/azure-event-hubs-go/eph"
	storageLeaser "github.com/Azure/azure-event-hubs-go/storage"
	azure "github.com/Azure/go-autorest/autorest/azure"
)

//EventHubMultiPartitionReader TODO
type EventHubMultiPartitionReader struct {
	hub                *eventhubs.Hub
	wg                 *sync.WaitGroup
	done               chan bool
	tokenProvider      *sas.TokenProvider
	azureEnv           azure.Environment
	leaserCheckpointer *storageLeaser.LeaserCheckpointer
	creds              *storageLeaser.AADSASCredential
	nsName             string
	hubName            string
	hosts              []*eph.EventProcessorHost
	receivedEvents     chan ReceivedEvent
	numOfHosts         int
}

//EventHubMultiPartitionReaderOptions TODO
type EventHubMultiPartitionReaderOptions struct {
	SubscriptionID       string
	EnvironmentName      string
	ResourceGroup        string
	StorageAccountName   string
	StorageContainerName string
	NsName               string
	EventHubName         string
	NumOfHosts           int
}

//NewEventHubMultiPartitionReader TODO
func NewEventHubMultiPartitionReader(options EventHubMultiPartitionReaderOptions) (*EventHubMultiPartitionReader, error) {
	h := &EventHubMultiPartitionReader{
		nsName:     options.NsName,
		hubName:    options.EventHubName,
		numOfHosts: options.NumOfHosts,
	}

	tokenProvider, err := sas.NewTokenProvider(sas.TokenProviderWithEnvironmentVars())
	if err != nil {
		return nil, fmt.Errorf("failed to configure AAD JWT provider: %s", err)
	}

	azureEnv, err := azure.EnvironmentFromName(options.EnvironmentName)
	if err != nil {
		return nil, fmt.Errorf("could not get azure.Environment struct: %s", err)
	}

	creds, err := storageLeaser.NewAADSASCredential(
		options.SubscriptionID,
		options.ResourceGroup,
		options.StorageAccountName,
		options.StorageContainerName,
		storageLeaser.AADSASCredentialWithEnvironmentVars())

	if err != nil {
		return nil, fmt.Errorf("could not prepare a storage credential: %s", err)
	}

	leaserCheckpointer, err := storageLeaser.NewStorageLeaserCheckpointer(
		creds,
		options.StorageAccountName,
		options.StorageContainerName,
		azureEnv)
	if err != nil {
		return nil, fmt.Errorf("could not prepare a storage leaserCheckpointer: %s", err)
	}

	h.done = make(chan bool, 1)
	h.wg = &sync.WaitGroup{}
	h.tokenProvider = tokenProvider
	h.leaserCheckpointer = leaserCheckpointer
	h.creds = creds
	return h, nil
}

//ReceivedEvent TODO
type ReceivedEvent struct {
	Event        *eventhubs.Event
	Err          error
	CheckPointer eph.Checkpointer
}

//Fetch TODO
func (h *EventHubMultiPartitionReader) Fetch() <-chan ReceivedEvent {
	//add some room in case the writers can't keep up...
	h.receivedEvents = make(chan ReceivedEvent, h.numOfHosts+5)
	h.hosts = make([]*eph.EventProcessorHost, h.numOfHosts)

	delegate := func(ctx context.Context, event *eventhubs.Event) error {
		select {
		case h.receivedEvents <- ReceivedEvent{Event: event, Err: nil, CheckPointer: h.leaserCheckpointer}:
			return nil
		default:
			return fmt.Errorf("Could not handle event. Channel is closed: %v+d", (*event))
		}
	}

	for i := 0; i < h.numOfHosts; i++ {
		ctx := context.Background()
		p, err := eph.New(
			ctx,
			h.nsName,
			h.hubName,
			h.tokenProvider,
			h.leaserCheckpointer,
			h.leaserCheckpointer,
			eph.WithNoBanner(),
		)

		if err != nil {
			log.Fatal(err)
		}

		_, err = p.RegisterHandler(ctx, delegate)

		if err != nil {
			log.Fatal(err)
		}
		ctx = context.Background()

		err = p.StartNonBlocking(ctx)

		if err != nil {
			log.Fatal(err)
		}

		h.hosts[i] = p
	}

	return h.receivedEvents
}

func (h *EventHubMultiPartitionReader) closeOnError(err error) {
	h.receivedEvents <- ReceivedEvent{Err: err}
	h.Stop()
}

//Stop TODO
func (h *EventHubMultiPartitionReader) Stop() error {
	for _, host := range h.hosts {
		if host != nil {
			ctx := context.Background()
			if err := host.Close(ctx); err != nil {
			return err
			}
		}
	}

	close(h.receivedEvents)
	return nil
}
