FROM golang:1.4.1

# see https://golang.org/doc/install/source#environment
# see also http://build.golang.org/
# and canonically, see defs_OS_ARCH.h files in src/runtime
#   https://go.googlesource.com/go/+/go1.4.1/src/runtime/
ENV GOLANG_CROSSPLATFORMS \
	darwin/386 darwin/amd64 \
	dragonfly/386 dragonfly/amd64 \
	freebsd/386 freebsd/amd64 freebsd/arm \
	linux/386 linux/amd64 linux/arm \
	nacl/386 nacl/amd64p32 nacl/arm \
	netbsd/386 netbsd/amd64 netbsd/arm \
	openbsd/386 openbsd/amd64 \
	plan9/386 plan9/amd64 \
	solaris/amd64 \
	windows/386 windows/amd64

# TODO gcc: error: unrecognized command line option '-marm'
#	android/arm \

# ls src/runtime/defs_*_*.h | sed -r 's!^.*/defs_([^_]+)_([^_]+)[.]h$!\1/\2!'

# (set an explicit GOARM of 5 for maximum ARM compatibility)
ENV GOARM 5

RUN cd /usr/src/go/src \
	&& set -ex \
	&& for platform in $GOLANG_CROSSPLATFORMS; do \
		GOOS=${platform%/*} \
		GOARCH=${platform##*/} \
		./make.bash --no-clean 2>&1; \
	done
