FROM golang:1.3.3-cross

# For a list of supported platforms, see:
# https://wiki.debian.org/CrossToolchains#For_jessie.2Ftesting
# Some platforms are skipped due to missing dependencies:
# - mips: missing crossbuild-essential-mips
# - powerpc: buggy libc6_2.19-13_powerpc.deb
# - ppc64el: missing g{cc,++}-powerpc64le-linux-gnu
ENV DEBIAN_CROSSPLATFORMS \
	arm64 armel armhf mipsel

# NOTE: We need to add the Cross-Toolchains repo.
# This is only necessary as long as the base image is based on Jessie.

# TODO: verify the fingerprint:
## 084C 6C6F 3915 9EDB 6796 9AA8 7DE0 8967 1804 772E

RUN set -ex \
	&& echo "deb http://emdebian.org/tools/debian/ jessie main" \
		>/etc/apt/sources.list.d/crosstools.list \
	&& curl -s http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
	&& for platform in $DEBIAN_CROSSPLATFORMS; do \
		dpkg --add-architecture ${platform}; \
	done \
	&& apt-get update \
	&& apt-get install -y build-essential \
	&& for platform in $DEBIAN_CROSSPLATFORMS; do \
		apt-get install -y crossbuild-essential-${platform}; \
	done
