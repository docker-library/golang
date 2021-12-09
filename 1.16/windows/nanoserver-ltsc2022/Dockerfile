#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

SHELL ["cmd", "/S", "/C"]

# no Git installed (intentionally)
#  -- Nano Server is "Windows Slim"

# ideally, this would be C:\go to match Linux a bit closer, but C:\go was the default install path for Go itself on Windows
ENV GOPATH C:\\gopath
# (https://golang.org/cl/283600)

# PATH isn't actually set in the Docker image, so we have to set it from within the container
USER ContainerAdministrator
RUN setx /m PATH "%GOPATH%\bin;C:\go\bin;%PATH%"
USER ContainerUser
# doing this first to share cache across versions more aggressively

ENV GOLANG_VERSION 1.16.12

# Docker's Windows path parsing is absolutely *cursed*; please just trust me on this one -Tianon
COPY --from=golang:1.16.12-windowsservercore-ltsc2022 ["C:\\\\go","C:\\\\go"]
RUN go version

WORKDIR $GOPATH
