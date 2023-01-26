.PHONY: build-image
build-image:
	docker build -t ghcr.io/seqsense/protoc-assets .

.PHONY: test
test: build-image
	$(MAKE) -C $@
