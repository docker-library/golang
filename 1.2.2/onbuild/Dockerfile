FROM golang:1.2.2

RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# this will ideally be built by the ONBUILD below ;)
CMD ["/go/bin/app"]

ONBUILD COPY . /go/src/app
ONBUILD RUN go get -d -v ./...
ONBUILD RUN go build -v ./...
