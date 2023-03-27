.PHONY: build generate
generate:
	xcodegen generate
build:
	xcodebuild -project ./Einance.xcodeproj -scheme Einance -showBuildSettings | grep -m 1 "" | grep -oEi "\/.*"