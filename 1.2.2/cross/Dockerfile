FROM golang:1.2.2

# see http://golang.org/doc/install/source#environment
# see also http://build.golang.org/
ENV GOLANG_CROSSPLATFORMS \
	darwin/386 darwin/amd64 \
	dragonfly/386 dragonfly/amd64 \
	freebsd/386 freebsd/amd64 freebsd/arm \
	linux/386 linux/amd64 linux/arm \
	netbsd/386 netbsd/amd64 netbsd/arm \
	openbsd/386 openbsd/amd64 \
	plan9/386 plan9/amd64 \
	windows/386 windows/amd64

# (set an explicit GOARM of 5 for maximum ARM compatibility)
ENV GOARM 5

RUN bash -xec '\
		cd /usr/src/go/src; \
		for platform in $GOLANG_CROSSPLATFORMS; do \
			GOOS=${platform%/*} \
			GOARCH=${platform##*/} \
			./make.bash --no-clean 2>&1; \
		done \
	'
