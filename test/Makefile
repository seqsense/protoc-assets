DOCKER_RUN_PROTOC_ARGS := --rm -u $(shell id -u):$(shell id -g) -v $(CURDIR):/defs ghcr.io/seqsense/protoc-assets

.PHONY: all
all: show-protobuf-version pb-generate-go pb-generate-py pb-generate-rb pb-generate-js

.PHONY: show-protobuf-version
show-protobuf-version:
	@docker run $(DOCKER_RUN_PROTOC_ARGS) apk list -I protoc \
		2> /dev/null \
		| sed -n 's/^protoc-\([0-9.]\+\)-.*$$/\1/p'

.PHONY: pb-generate-go
pb-generate-go:
	docker run $(DOCKER_RUN_PROTOC_ARGS) protoc \
		-I. \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		test.proto
	test -f test.pb.go
	test -f test_grpc.pb.go

.PHONY: pb-generate-cpp
pb-generate-cpp:
	docker run $(DOCKER_RUN_PROTOC_ARGS) protoc \
		-I. \
		--cpp_out=. \
		test.proto
	test -f test.pb.h
	test -f test.pb.cc

.PHONY: pb-generate-py
pb-generate-py:
	docker run $(DOCKER_RUN_PROTOC_ARGS) python3 -m grpc_tools.protoc \
		-I. \
		--python_out=. \
		--grpc_python_out=. \
		test.proto
	test -f test_pb2.py
	test -f test_pb2_grpc.py

.PHONY: pb-generate-rb
pb-generate-rb:
	docker run $(DOCKER_RUN_PROTOC_ARGS) grpc_tools_ruby_protoc \
		-I. \
		--ruby_out=. \
		--grpc_out=. \
		test.proto
	test -f test_pb.rb
	test -f test_services_pb.rb

.PHONY: pb-generate-js
pb-generate-js:
	docker run $(DOCKER_RUN_PROTOC_ARGS) grpc_tools_node_protoc \
		-I. \
		--js_out=import_style=commonjs,binary:. \
		--grpc_out=. \
		test.proto
	test -f test_pb.js
	test -f test_grpc_pb.js
