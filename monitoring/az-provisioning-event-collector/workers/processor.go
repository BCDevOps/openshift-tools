package workers

import (
	"log"
	"sync"
)

//Processor TODO
type Processor struct {
	wg        *sync.WaitGroup
	procError chan error
	reader    *Reader
	writer    *Writer
}

//NewProcessor TODO
func NewProcessor() *Processor {
	return &Processor{
		wg:        &sync.WaitGroup{},
		procError: make(chan error, 1),
	}
}

//ProcessEvents TODO
func (p *Processor) ProcessEvents(reader Reader, writer Writer) {
	p.wg.Add(1)
	go func() {
		defer p.wg.Done()
		for event := range reader.Fetch() {

			if event.Err != nil {
				log.Fatal(event.Err)
			}

			log.Printf("Event fetched. Event ID: %s\n", event.Event.ID)
			log.Printf("Event Data: %s\n", string(event.Event.Data))
			if err := writer.Process(event); err != nil {
				p.procError <- err
				return

			}
			log.Printf("Event proccessed. Event ID: %s\n", event.Event.ID)

		}
	}()

	p.reader = &reader
	p.writer = &writer
}

//Stop TODO
func (p *Processor) Stop() error {
	if p.reader != nil {
		if err := (*p.reader).Stop(); err != nil {
			return err
		}
	}
	return nil
}

//Wait TODO
func (p *Processor) Wait() error {
	p.wg.Wait()
	select {
	case err := <-p.procError:
		return err
	default:
		return nil
	}
}
