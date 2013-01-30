
# Kommentar

test: diagram build
	open test.app

build:
	faust2caqt test.dsp

diagram:
	faust2svg test.dsp

clean:
	rm -rf test.app
	rm -rf test-svg
