package main

import "core:fmt"
import rtmidi ".."

main :: proc() {
    version := rtmidi.rtmidi_get_version()
    fmt.println(string(version))

    fmt.println(string(rtmidi.rtmidi_api_display_name(.MACOSX_CORE)))
    fmt.println(string(rtmidi.rtmidi_api_name(.MACOSX_CORE)))
}
