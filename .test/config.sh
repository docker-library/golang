#!/usr/bin/env bash

# https://github.com/docker-library/official-images/blob/3bc6a70175d4e1da2080b86415e6f3c8eb2c6af3/test/config.sh

imageTests[golang]+='
	go-dist-test
'
