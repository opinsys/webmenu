
prefix ?= /usr/local

install:
	mkdir -p $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)/opt/webmenu
	cp -r lib node_modules bin routes content *.js *.coffee *.json *.md $(DESTDIR)/opt/webmenu
	install -o root -g root -m 755 bin/hack-start \
		$(DESTDIR)$(prefix)/bin/webmenu
