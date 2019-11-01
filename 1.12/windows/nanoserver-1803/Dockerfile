FROM mcr.microsoft.com/windows/nanoserver:1803

SHELL ["cmd", "/S", "/C"]

# no Git installed (intentionally)
#  -- Nano Server is "Windows Slim"

# ideally, this would be C:\go to match Linux a bit closer, but C:\go is the recommended install path for Go itself on Windows
ENV GOPATH C:\\gopath

# PATH isn't actually set in the Docker image, so we have to set it from within the container
USER ContainerAdministrator
RUN setx /m PATH "%GOPATH%\bin;C:\go\bin;%PATH%"
USER ContainerUser
# doing this first to share cache across versions more aggressively

ENV GOLANG_VERSION 1.12.13

COPY --from=golang:1.12.13-windowsservercore-1803 C:\\go C:\\go
RUN go version

WORKDIR $GOPATH
