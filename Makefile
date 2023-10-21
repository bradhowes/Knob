PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro
PLATFORM_MACOS = macOS
PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (3rd generation) (at 1080p)

default: percentage

test-ios:
	rm -rf "$(PWD)/DerivedData-ios"
	xcodebuild test \
		-scheme Knob-iOS \
		-destination platform="$(PLATFORM_IOS)"

test-tvos:
	rm -rf "$(PWD)/DerivedData-tvos"
	xcodebuild test \
		-scheme Knob-iOS \
		-destination platform="$(PLATFORM_TVOS)"

test-macos:
	xcodebuild clean \
		-scheme Knob-Package \
		-derivedDataPath "$(PWD)/DerivedData-macos" \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild test \
		-scheme Knob-Package \
		-derivedDataPath "$(PWD)/DerivedData-macos" \
		-destination platform="$(PLATFORM_MACOS)" \
		-enableCodeCoverage YES

test-linux:
	docker build -t swiftlang -f swiftlang.dockerfile .
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift57 \
		bash -c 'make test-swift'

test-swift:
	swift test --parallel

coverage: test-macos
# xcrun xccov view --report --only-targets $(PWD)/DerivedData-macos/Logs/Test/*.xcresult > coverage.txt
	xcrun xccov view --report --files-for-target Knob-macOS $(PWD)/DerivedData-macos/Logs/Test/*.xcresult > coverage.txt
	cat coverage.txt

percentage: coverage
# awk '/ Knob / { if ($$3 > 0) print $$4; }' coverage.txt > percentage.txt
	awk 'END {print sum / count;} /^[1-9]/ { if ($$2 !~ /KnobView/) { sum+=$$4; count+=1; } }' coverage.txt > percentage.txt
	cat percentage.txt

test: test-ios test-tvos percentage

.PHONY: test test-ios test-macos test-tvos coverage percentage test-linux test-swift
