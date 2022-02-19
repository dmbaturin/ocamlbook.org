BUILD_DIR := build/

SOUPAULT := soupault

.PHONY: site
site:
	$(SOUPAULT)

.PHONY: all
all: site

.PHONY: clean
clean:
	rm -rf build/*

.PHONY: serve
.ONESHELL: serve
serve:
	cd build
	python3 -m http.server

