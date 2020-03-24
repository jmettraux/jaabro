
N:=jaabro
GITHUB:=https://github.com/jmettraux/$(N)

VERSION:=$(shell grep VERSION src/$(N).js | ruby -e "puts gets.match(/VERSION: '([\d\.]+)/)[1]")

#SHA:=$(shell git log -1 --format="%H")
SHA:=$(shell git log -1 --format="%h")
NOW:=$(shell date)


v:
	@echo $(VERSION)

spec:
	bundle exec rspec

pkg_plain:
	mkdir -p pkg
	cp src/$(N).js pkg/$(N)-$(VERSION).js
	echo "/* from commit $(SHA) on $(NOW) */" >> pkg/$(N)-$(VERSION).js
	cp pkg/$(N)-$(VERSION).js pkg/$(N)-$(VERSION)-$(SHA).js

pkg_mini:
	mkdir -p pkg
	printf "/* $(N)-$(VERSION).min.js | MIT license: $(GITHUB)/LICENSE.txt */" > pkg/$(N)-$(VERSION).min.js
	#cat src/$(N).js | jsmin >> pkg/$(N)-$(VERSION).min.js
	java -jar tools/closure-compiler.jar --js src/$(N).js >> pkg/$(N)-$(VERSION).min.js
	echo "/* minified from commit $(SHA) on $(NOW) */" >> pkg/$(N)-$(VERSION).min.js
	cp pkg/$(N)-$(VERSION).min.js pkg/$(N)-$(VERSION)-$(SHA).min.js

pkg_comp:
	mkdir -p pkg
	printf "/* $(N)-$(VERSION).com.js | MIT license: $(GITHUB)/LICENSE.txt */\n" > pkg/$(N)-$(VERSION).com.js
	cat src/$(N).js | ruby tools/compactor.rb >> pkg/$(N)-$(VERSION).com.js
	echo "\n/* compacted from commit $(SHA) on $(NOW) */" >> pkg/$(N)-$(VERSION).com.js
	cp pkg/$(N)-$(VERSION).com.js pkg/$(N)-$(VERSION)-$(SHA).com.js

pkg: pkg_plain pkg_mini pkg_comp


.PHONY: spec pkg

