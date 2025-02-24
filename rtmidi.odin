package rtmidi

import "core:c"

RTMIDI_SHARED :: #config(RTMIDI_SHARED, false)

when RTMIDI_SHARED {
	when ODIN_OS == .Windows {
		foreign import lib "windows/rtmidi.dll"
	} else when ODIN_OS == .Darwin && ODIN_ARCH == .arm64 {
		foreign import lib "macos/librtmidi.dylib"
	}
} else {
	when ODIN_OS == .Windows {
		foreign import lib "windows/rtmidi.lib"
	} else when ODIN_OS == .Darwin {
		foreign import lib "macos/librtmidi.a"
	}
}

@(default_calling_convention = "c")
foreign lib {
	// TODO
}