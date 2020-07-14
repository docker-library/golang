FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.13.13

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='0b8573c2335bebef53e819ab8d323456dc2b94838bebdbd8cc6623bb8a6d77b7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='621081207d4d8549d33e2bc0623e50195152f40f3132327efecaa372f080af55' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='999fcd9090b164062e166523086a54f4152549c41f627ff5ccad3c3ec2da0657' ;; \
		i386) goRelArch='linux-386'; goRelSha256='efcadf5d927558429ce1156e12943639e0f33d4b5b75919683ec2529ffb8c3e1' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='f816b5ac28322af6692fb61d6e12b11697c4927eec42226ebcf8ef32cee5bf9b' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='333a437e579f7a8e8188c6431eb13f31517d72310b6583d1df69022e09965ce8' ;; \
		*) goRelArch='src'; goRelSha256='ab7e44461e734ce1fd5f4f82c74c6d236e947194d868514d48a2b1ea73d25137'; \
			echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
# https://github.com/golang/go/issues/38536#issuecomment-616897960
	if [ "$goRelArch" = 'src' ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"; \
		eval "$goEnv"; \
		[ -n "$GOOS" ]; \
		[ -n "$GOARCH" ]; \
		( \
			cd /usr/local/go/src; \
			./make.bash; \
		); \
		\
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $savedAptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
		rm -rf /var/lib/apt/lists/*; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	fi; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
