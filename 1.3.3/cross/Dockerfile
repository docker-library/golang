FROM golang:1.3.3

# see https://golang.org/doc/install/source#environment
# see also http://build.golang.org/
# and canonically, see defs_OS_ARCH.h files in src/pkg/runtime
#   https://code.google.com/p/go/source/browse?name=go1.3#hg%2Fsrc%2Fpkg%2Fruntime
ENV GOLANG_CROSSPLATFORMS \
	darwin/386 darwin/amd64 \
	dragonfly/386 dragonfly/amd64 \
	freebsd/386 freebsd/amd64 freebsd/arm \
	linux/386 linux/amd64 linux/arm \
	nacl/386 nacl/amd64p32 \
	netbsd/386 netbsd/amd64 netbsd/arm \
	openbsd/386 openbsd/amd64 \
	plan9/386 plan9/amd64 \
	solaris/amd64 \
	windows/386 windows/amd64

# ls src/pkg/runtime/defs_*_*.h | sed -r 's!^.*/defs_([^_]+)_([^_]+)[.]h$!\1/\2!'

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
