.PHONY: macos_example

macos_example:
	odin build example/basic.odin -file -out:build/basic -extra-linker-flags:"-lc++ -framework CoreMIDI -framework CoreFoundation -framework CoreAudio"