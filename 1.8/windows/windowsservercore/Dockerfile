FROM microsoft/windowsservercore

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# install Git (especially for "go get")
ENV GIT_VERSION 2.11.0
ENV GIT_TAG v${GIT_VERSION}.windows.1
ENV GIT_DOWNLOAD_URL https://github.com/git-for-windows/git/releases/download/${GIT_TAG}/Git-${GIT_VERSION}-64-bit.exe
ENV GIT_DOWNLOAD_SHA256 fd1937ea8468461d35d9cabfcdd2daa3a74509dc9213c43c2b9615e8f0b85086
# steps inspired by "chcolateyInstall.ps1" from "git.install" (https://chocolatey.org/packages/git.install)
RUN Write-Host ('Downloading {0} ...' -f $env:GIT_DOWNLOAD_URL); \
	Invoke-WebRequest -Uri $env:GIT_DOWNLOAD_URL -OutFile 'git.exe'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:GIT_DOWNLOAD_SHA256); \
	if ((Get-FileHash git.exe -Algorithm sha256).Hash -ne $env:GIT_DOWNLOAD_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Installing ...'; \
	Start-Process \
		-Wait \
		-FilePath ./git.exe \
# http://www.jrsoftware.org/ishelp/topic_setupcmdline.htm
		-ArgumentList @( \
			'/VERYSILENT', \
			'/NORESTART', \
			'/NOCANCEL', \
			'/SP-', \
			'/SUPPRESSMSGBOXES', \
			\
# https://github.com/git-for-windows/build-extra/blob/353f965e0e2af3e8c993930796975f9ce512c028/installer/install.iss#L87-L96
			'/COMPONENTS=assoc_sh', \
			\
# set "/DIR" so we can set "PATH" afterwards
# see https://disqus.com/home/discussion/chocolatey/chocolatey_gallery_git_install_1710/#comment-2834659433 for why we don't use "/LOADINF=..." to let the installer set PATH
			'/DIR=C:\git' \
		); \
	\
	Write-Host 'Updating PATH ...'; \
	$env:PATH = 'C:\git\bin;C:\git\mingw64\bin;C:\git\usr\bin;' + $env:PATH; \
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  git --version'; git --version; \
	Write-Host '  bash --version'; bash --version; \
	Write-Host '  curl --version'; curl.exe --version; \
	\
	Write-Host 'Removing installer ...'; \
	Remove-Item git.exe -Force; \
	\
	Write-Host 'Complete.';

# ideally, this would be C:\go to match Linux a bit closer, but C:\go is the recommended install path for Go itself on Windows
ENV GOPATH C:\\gopath

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0}\bin;C:\go\bin;{1}' -f $env:GOPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

ENV GOLANG_VERSION 1.8rc2
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.windows-amd64.zip
ENV GOLANG_DOWNLOAD_SHA256 c5eadaec783fd01bbaf8e81aef1add83a7e5c125f50f6976ac31ab763bd0b49f

RUN Write-Host ('Downloading {0} ...' -f $env:GOLANG_DOWNLOAD_URL); \
	Invoke-WebRequest -Uri $env:GOLANG_DOWNLOAD_URL -OutFile 'go.zip'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:GOLANG_DOWNLOAD_SHA256); \
	if ((Get-FileHash go.zip -Algorithm sha256).Hash -ne $env:GOLANG_DOWNLOAD_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive go.zip -DestinationPath C:\; \
	\
	Write-Host 'Verifying install ("go version") ...'; \
	go version; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item go.zip -Force; \
	\
	Write-Host 'Complete.';

WORKDIR $GOPATH
