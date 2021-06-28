DOCKER_RUN_PROTOC_ARGS := --rm -u $(shell id -u):$(shell id -g) -v $(PWD):/defs seqsense/protoc-assets

.PHONY: all
all: pb-generate-go pb-generate-py pb-generate-rb pb-generate-js

.PHONY: pb-generate-go
pb-generate-go:
	docker run $(DOCKER_RUN_PROTOC_ARGS) protoc \
		-I. \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		test.proto

.PHONY: pb-generate-cpp
pb-generate-cpp:
	docker run $(DOCKER_RUN_PROTOC_ARGS) protoc \
		-I. \
		--cpp_out=. \
		test.proto

.PHONY: pb-generate-py
pb-generate-py:
	docker run $(DOCKER_RUN_PROTOC_ARGS) python3 -m grpc_tools.protoc \
		-I. \
		--python_out=. \
		--grpc_python_out=. \
		test.proto

.PHONY: pb-generate-rb
pb-generate-rb:
	docker run $(DOCKER_RUN_PROTOC_ARGS) grpc_tools_ruby_protoc \
		-I. \
		--ruby_out=. \
		--grpc_out=. \
		test.proto

.PHONY: pb-generate-js
pb-generate-js:
	docker run $(DOCKER_RUN_PROTOC_ARGS) grpc_tools_node_protoc \
		-I. \
		--js_out=import_style=commonjs,binary:. \
		--grpc_out=. \
		test.proto
