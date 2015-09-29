
VERSION:=$(shell grep VERSION src/jaabro.js | ruby -e "puts gets.match(/VERSION: '([\d\.]+)/)[1]")

pkg:
	mkdir -p pkg
	cp src/jaabro.js pkg/jaabro-$(VERSION).js
	java -jar tools/closure-compiler.jar --js src/jaabro.js > pkg/jaabro-$(VERSION).min.js

.PHONY: pkg

