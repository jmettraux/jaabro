
#
# $(NAME).js Makefile


NAME != basename `pwd` '.js'
SHA != git log -1 --format="%h"
NOW != date
VERSION != awk -F"'" '/VERSION: / {print $$2}' src/$(NAME).js


name:
	@echo "$(NAME) $(VERSION)"

spec:
	bundle exec rspec

pkg_plain:
	mkdir -p pkg
	cp src/$(NAME).js pkg/$(NAME)-$(VERSION).js
	echo "/* from commit $(SHA) on $(NOW) */" >> pkg/$(NAME)-$(VERSION).js
	cp pkg/$(NAME)-$(VERSION).js pkg/$(NAME)-$(VERSION)-$(SHA).js

pkg_mini:
	mkdir -p pkg
	printf "/* $(NAME)-$(VERSION).min.js | MIT license: $(LICENSE) */" > pkg/$(NAME)-$(VERSION).min.js
	#cat src/$(NAME).js | jsmin >> pkg/$(NAME)-$(VERSION).min.js
	java -jar tools/closure-compiler.jar --language_in=ECMASCRIPT6 --js src/$(NAME).js >> pkg/$(NAME)-$(VERSION).min.js
	echo "/* minified from commit $(SHA) on $(NOW) */" >> pkg/$(NAME)-$(VERSION).min.js
	cp pkg/$(NAME)-$(VERSION).min.js pkg/$(NAME)-$(VERSION)-$(SHA).min.js

pkg_comp:
	mkdir -p pkg
	printf "/* $(NAME)-$(VERSION).com.js | MIT license: $(LICENSE) */\n" > pkg/$(NAME)-$(VERSION).com.js
	cat src/$(NAME).js | ruby tools/compactor.rb >> pkg/$(NAME)-$(VERSION).com.js
	echo "\n/* compacted from commit $(SHA) on $(NOW) */" >> pkg/$(NAME)-$(VERSION).com.js
	cp pkg/$(NAME)-$(VERSION).com.js pkg/$(NAME)-$(VERSION)-$(SHA).com.js

pkg: pkg_plain pkg_mini pkg_comp


clean-sha:
	find pkg -name "$(NAME)-*-*js" | xargs rm
clean:
	rm -fR pkg/


.PHONY: name spec pkg clean-sha clean

