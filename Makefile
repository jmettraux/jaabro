
VERSION:=$(shell grep VERSION src/jaabro.js | ruby -e "puts gets.match(/VERSION: '([\d\.]+)/)[1]")

#SHA:=$(shell git log -1 --format="%H")
SHA:=$(shell git log -1 --format="%h")
NOW:=$(shell date)


spec:
	bundle exec rspec

pkg_plain:
	mkdir -p pkg
	cp src/jaabro.js pkg/jaabro-$(VERSION).js
	echo "/* from commit $(SHA) on $(NOW) */" >> pkg/jaabro-$(VERSION).js

pkg_mini:
	mkdir -p pkg
	printf "/* jaabro-$(VERSION).min.js | MIT license: http://github.com/jmettraux/jaabro/LICENSE.txt */" > pkg/jaabro-$(VERSION).min.js
	#cat src/jaabro.js | jsmin >> pkg/jaabro-$(VERSION).min.js
	java -jar tools/closure-compiler.jar --js src/jaabro.js >> pkg/jaabro-$(VERSION).min.js
	echo "/* minified from commit $(SHA) on $(NOW) */" >> pkg/jaabro-$(VERSION).min.js

pkg: pkg_plain pkg_mini


.PHONY: spec pkg

