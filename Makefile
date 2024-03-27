PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro
PLATFORM_MACOS = macOS
PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (3rd generation) (at 1080p)

default: percentage

test-ios:
	rm -rf "$(PWD)/.DerivedData-ios"
	xcodebuild test \
		-scheme Knob-iOS \
		-destination platform="$(PLATFORM_IOS)"

test-tvos:
	rm -rf "$(PWD)/.DerivedData-tvos"
	xcodebuild test \
		-scheme Knob-iOS \
		-destination platform="$(PLATFORM_TVOS)"

test-macos:
	xcodebuild clean \
		-scheme Knob-Package \
		-derivedDataPath "$(PWD)/.DerivedData-macos" \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild test \
		-scheme Knob-Package \
		-derivedDataPath "$(PWD)/.DerivedData-macos" \
		-destination platform="$(PLATFORM_MACOS)" \
		-enableCodeCoverage YES

test-macos-ui:
	xcodebuild clean \
		-project KnobDemo/KnobDemo.xcodeproj \
		-scheme KnobDemo_macOS \
		-derivedDataPath "$(PWD)/.DerivedData-macos-ui" \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild test \
		-project KnobDemo/KnobDemo.xcodeproj \
		-scheme KnobDemo_macOS \
		-derivedDataPath "$(PWD)/.DerivedData-macos-ui" \
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

COV = xcrun xccov view --report --files-for-target

coverage: test-macos
	$(COV) Knob-macOS $(PWD)/.DerivedData-macos/Logs/Test/*.xcresult > coverage.txt
	cat coverage.txt

coverage-ui: test-macos-ui
	$(COV) Knob-macOS $(PWD)/.DerivedData-macos-ui/Logs/Test/*.xcresult > coverage-ui.txt
	cat coverage-ui.txt

# Visit each line in coverage report that starts with a number, and add the coverage percentage
# (skipping the one that involves the SwiftUI containers). Print the average at the end.
AWK_CMD = 'END {print sum / count;} /^[1-9]/ { if ($$2 !~ /KnobView/) { sum+=$$4; count+=1; } }'

percentage: coverage
	awk $(AWK_CMD) coverage.txt > percentage.txt
	cat percentage.txt

percentage-ui: coverage-ui
	awk $(AWK_CMD) coverage-ui.txt > percentage-ui.txt
	cat percentage-ui.txt

test: test-ios test-tvos percentage

.PHONY: test test-ios test-macos test-tvos coverage percentage test-linux test-swift
