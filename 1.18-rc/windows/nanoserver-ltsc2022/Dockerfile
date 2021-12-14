#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

SHELL ["cmd", "/S", "/C"]

# no Git installed (intentionally)
#  -- Nano Server is "Windows Slim"

# for 1.17+, we'll follow the (new) Go upstream default for install (https://golang.org/cl/283600), which frees up C:\go to be the default GOPATH and thus match the Linux images more closely (https://github.com/docker-library/golang/issues/288)
ENV GOPATH C:\\go
# HOWEVER, please note that it is the Go upstream intention to remove GOPATH support entirely: https://blog.golang.org/go116-module-changes

# PATH isn't actually set in the Docker image, so we have to set it from within the container
USER ContainerAdministrator
RUN setx /m PATH "%GOPATH%\bin;C:\Program Files\Go\bin;%PATH%"
USER ContainerUser
# doing this first to share cache across versions more aggressively

ENV GOLANG_VERSION 1.18beta1

# Docker's Windows path parsing is absolutely *cursed*; please just trust me on this one -Tianon
COPY --from=golang:1.18beta1-windowsservercore-ltsc2022 ["C:\\\\Program Files\\\\Go","C:\\\\Program Files\\\\Go"]
RUN go version

WORKDIR $GOPATH
