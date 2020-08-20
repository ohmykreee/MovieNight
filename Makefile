# If a different version of Go is installed (via `go get`) set the GO_VERSION
# environment variable to that version.  For example, setting it to "1.13.7"
# will run `go1.13.7 build [...]` instead of `go build [...]`.
#
# For info on installing extra versions, see this page:
# https://golang.org/doc/install#extra_versions

# goosList = "android darwin dragonfly freebsd linux nacl netbsd openbsd plan9 solaris windows"
# goarchList = "386 amd64 amd64p32 arm arm64 ppc64 ppc64le mips mipsle mips64 mips64le mips64p32 mips64p32leppc s390 s390x sparc sparc64"

TAGS=

# Windows needs the .exe extension.
.if ${TARGET} == "windows"
EXT=.exe
.endif

.PHONY: fmt vet get clean dev setdev test ServerMovieNight

all: fmt vet test MovieNight$(EXT) static/main.wasm settings.json

# Build the server deployment
server: ServerMovieNight static/main.wasm

# Bulid used for deploying to my server.
ServerMovieNight: *.go common/*.go
	GOOS=${TARGET} GOARCH=${ARCH} go$(GO_VERSION) build -o MovieNight $(TAGS)

setdev:
	$(eval export TAGS=-tags "dev")

dev: setdev all

MovieNight$(EXT): *.go common/*.go
	go$(GO_VERSION) build -o $@ $(TAGS)

static/js/wasm_exec.js:
	cp $$(go env GOROOT)/misc/wasm/wasm_exec.js $@

static/main.wasm: static/js/wasm_exec.js wasm/*.go common/*.go
	GOOS=js GOARCH=wasm go$(GO_VERSION) build -o $@ $(TAGS) wasm/*.go

clean:
	-rm MovieNight$(EXT) ./static/main.wasm ./static/js/wasm_exec.js

fmt:
	gofmt -w .

vet:
	go$(GO_VERSION) vet $(TAGS) ./...
	GOOS=js GOARCH=wasm go$(GO_VERSION) vet $(TAGS) ./...

test:
	go$(GO_VERSION) test $(TAGS) ./...

# Do not put settings_example.json here as a prereq to avoid overwriting
# the settings if the example is updated.
settings.json:
	cp settings_example.json settings.json
