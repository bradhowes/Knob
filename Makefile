PLATFORM_IOS = iOS Simulator,name=iPad mini (A17 Pro)
PLATFORM_MACOS = macOS
XCCOV = xcrun xccov view --report --only-targets
SCHEME = Knob-Package
BUILD_FLAGS = -skipMacroValidation -skipPackagePluginValidation -enableCodeCoverage YES -scheme $(SCHEME)

default: report

test-iOS:
	rm -rf "$(PWD)/.DerivedData-iOS"
	set -o pipefail && xcodebuild test \
		$(BUILD_FLAGS) \
		-derivedDataPath "$(PWD)/.DerivedData-iOS" \
		-destination platform="$(PLATFORM_IOS)" \
		| xcbeautify --renderer github-actions

coverage-iOS: test-iOS
	$(XCCOV) $(PWD)/.DerivedData-iOS/Logs/Test/*.xcresult > coverage_iOS.txt
	echo "iOS Coverage:"
	cat coverage_iOS.txt

percentage-iOS: coverage-iOS
	awk $(AWK_CMD) coverage_iOS.txt > percentage_iOS.txt
	echo "iOS Coverage Pct:"
	cat percentage_iOS.txt

test-macOS:
	rm -rf "$(PWD)/.DerivedData-macOS"
	USE_UNSAFE_FLAGS="1" set -o pipefail && xcodebuild test \
		$(BUILD_FLAGS) \
		-derivedDataPath "$(PWD)/.DerivedData-macOS" \
		-destination platform="$(PLATFORM_MACOS)" \
		| xcbeautify --renderer github-actions

coverage-macOS: test-macOS
	$(XCCOV) $(PWD)/.DerivedData-macOS/Logs/Test/*.xcresult > coverage_macOS.txt
	echo "macOS Coverage:"
	cat coverage_macOS.txt

percentage-macOS: coverage-macOS
	awk '/ Knob-macOS / { print $$4 }' coverage_macOS.txt > percentage_macOS.txt
	echo "macOS Coverage Pct:"
	cat percentage_macOS.txt

report: percentage-macOS # percentage-macOS
	@if [[ -n "$$GITHUB_ENV" ]]; then \
        echo "PERCENTAGE=$$(< percentage_macOS.txt)" >> $$GITHUB_ENV; \
    fi

.PHONY: report test-iOS test-macOS coverage-iOS coverage-macOS percentage-iOS percentage-macOS
