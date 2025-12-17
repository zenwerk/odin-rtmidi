package main

import "core:fmt"
import rtmidi ".."

main :: proc() {
    fmt.println("Show RtMidi Version and API Name.")
    v := rtmidi.get_version()
    fmt.println(string(v))
    fmt.println(string(rtmidi.api_display_name(.MACOSX_CORE)))
    fmt.println(string(rtmidi.api_name(.MACOSX_CORE)))
}
