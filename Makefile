.PHONY: test analyze
analyze:
	flutter pub get && dart analyze

# Widget- + UI-Smoke-Tests (u. a. test/ui/, test/integration/); identisch zu CI.
test: analyze
	flutter test
