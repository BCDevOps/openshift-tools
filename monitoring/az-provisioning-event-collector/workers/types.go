package workers

//Reader TODO
type Reader interface {
	Fetch() <-chan ReceivedEvent
	Stop() error
}

//Writer TODO
type Writer interface {
	Process(event ReceivedEvent) error
}
