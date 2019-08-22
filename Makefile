all: cabal.sandbox.config
	cabal v1-install ./atlas/ ./bidi-icu/ const/ fontconfig/ freetype/ engine/ glow/ harfbuzz/ hkd/ language-server/ parsnip/ primitive-ffi/ primitive-extras/ ptrdiff/ smawk/ tabulation-hash/ ui/ watch/ watch-directory/ weak/

docs:
	@cabal new-haddock all
	@echo
	@echo "All documentation:"
	@find `pwd`/dist-newstyle -type f -name index.html -exec echo 'file://{}' \;

harfbuzz-example:
	cd harfbuzz && cabal new-run example

distclean:
	rm -rf dist-newstyle tags

tags:
	rm -f tags
	fast-tags -R . --exclude=dist-newstyle --exclude=old

.PHONY: all distclean docs tags

cabal.sandbox.config:
	cabal sandbox init
