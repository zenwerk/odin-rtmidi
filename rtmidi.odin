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

//! \brief Wraps an RtMidi object for C function return statuses.
RtMidiWrapper :: struct {
	//! The wrapped RtMidi object.
	ptr:  rawptr,
	data: rawptr,

	//! True when the last function call was OK.
	ok:   bool,

	//! If an error occurred (ok != true), set to an error message.
	msg:  cstring,
}

//! \brief Typedef for a generic RtMidi pointer.
RtMidiPtr :: ^RtMidiWrapper

//! \brief Typedef for a generic RtMidiIn pointer.
RtMidiInPtr :: ^RtMidiWrapper

//! \brief Typedef for a generic RtMidiOut pointer.
RtMidiOutPtr :: ^RtMidiWrapper

//! \brief MIDI API specifier arguments.  See \ref
RtMidiApi :: enum c.int {
	UNSPECIFIED, /*!< Search for a working compiled API. */
	MACOSX_CORE, /*!< Macintosh OS-X CoreMIDI API. */
	LINUX_ALSA, /*!< The Advanced Linux Sound Architecture API. */
	UNIX_JACK, /*!< The Jack Low-Latency MIDI Server API. */
	WINDOWS_MM, /*!< The Microsoft Multimedia MIDI API. */
	RTMIDI_DUMMY, /*!< A compilable but non-functional API. */
	WEB_MIDI_API, /*!< W3C Web MIDI API. */
	WINDOWS_UWP, /*!< The Microsoft Universal Windows Platform MIDI API. */
	ANDROID, /*!< The Android MIDI API. */
	NUM, /*!< Number of values in this enum. */
}

//! \brief Defined RtMidiError types. See \ref
RtMidiErrorType :: enum c.int {
	WARNING, /*!< A non-critical error. */
	DEBUG_WARNING, /*!< A non-critical error which might be useful for debugging. */
	UNSPECIFIED, /*!< The default, unspecified error type. */
	NO_DEVICES_FOUND, /*!< No devices found on system. */
	INVALID_DEVICE, /*!< An invalid device ID was specified. */
	MEMORY_ERROR, /*!< An error occurred during memory allocation. */
	INVALID_PARAMETER, /*!< An invalid parameter was specified to a function. */
	INVALID_USE, /*!< The function was called incorrectly. */
	DRIVER_ERROR, /*!< A system driver error occurred. */
	SYSTEM_ERROR, /*!< A system error occurred. */
	THREAD_ERROR, /*!< A thread error occurred. */
}

/*! \brief The type of a RtMidi callback function.
*
* \param timeStamp   The time at which the message has been received.
* \param message     The midi message.
* \param userData    Additional user data for the callback.
*
* See \ref RtMidiIn::RtMidiCallback.
*/
RtMidiCCallback :: proc "c" (_: f64, _: ^u8, _: uint, _: rawptr)

@(default_calling_convention = "c", link_prefix = "")
foreign lib {
	/*! \brief Return the current RtMidi version.
*! See \ref RtMidi::getVersion().
*/
	rtmidi_get_version :: proc() -> cstring ---

	/*! \brief Determine the available compiled MIDI APIs.
	*
	* If the given `apis` parameter is null, returns the number of available APIs.
	* Otherwise, fill the given apis array with the RtMidi::Api values.
	*
	* \param apis  An array or a null value.
	* \param apis_size  Number of elements pointed to by apis
	* \return number of items needed for apis array if apis==NULL, or
	*         number of items written to apis array otherwise.  A negative
	*         return value indicates an error.
	*
	* See \ref RtMidi::getCompiledApi().
	*/
	rtmidi_get_compiled_api :: proc(apis: ^RtMidiApi, apis_size: u32) -> i32 ---

	//! \brief Return the name of a specified compiled MIDI API.
	//! See \ref
	rtmidi_api_name :: proc(api: RtMidiApi) -> cstring ---

	//! \brief Return the display name of a specified compiled MIDI API.
	//! See \ref
	rtmidi_api_display_name :: proc(api: RtMidiApi) -> cstring ---

	//! \brief Return the compiled MIDI API having the given name.
	//! See \ref
	rtmidi_compiled_api_by_name :: proc(name: cstring) -> RtMidiApi ---

	//! \internal
	rtmidi_error :: proc(type: RtMidiErrorType, errorString: cstring) ---

	/*! \brief Open a MIDI port.
	*
	* \param port      Must be greater than 0
	* \param portName  Name for the application port.
	*
	* See RtMidi::openPort().
	*/
	rtmidi_open_port :: proc(device: RtMidiPtr, portNumber: u32, portName: cstring) ---

	/*! \brief Creates a virtual MIDI port to which other software applications can
	* connect.
	*
	* \param portName  Name for the application port.
	*
	* See RtMidi::openVirtualPort().
	*/
	rtmidi_open_virtual_port :: proc(device: RtMidiPtr, portName: cstring) ---

	/*! \brief Close a MIDI connection.
	* See RtMidi::closePort().
	*/
	rtmidi_close_port :: proc(device: RtMidiPtr) ---

	/*! \brief Return the number of available MIDI ports.
	* See RtMidi::getPortCount().
	*/
	rtmidi_get_port_count :: proc(device: RtMidiPtr) -> u32 ---

	/*! \brief Access a string identifier for the specified MIDI input port number.
	*
	* To prevent memory leaks a char buffer must be passed to this function.
	* NULL can be passed as bufOut parameter, and that will write the required buffer length in the bufLen.
	*
	* See RtMidi::getPortName().
	*/
	rtmidi_get_port_name :: proc(device: RtMidiPtr, portNumber: u32, bufOut: cstring, bufLen: ^i32) -> i32 ---

	//! \brief Create a default RtMidiInPtr value, with no initialization.
	rtmidi_in_create_default :: proc() -> RtMidiInPtr ---

	/*! \brief Create a  RtMidiInPtr value, with given api, clientName and queueSizeLimit.
	*
	*  \param api            An optional API id can be specified.
	*  \param clientName     An optional client name can be specified. This
	*                        will be used to group the ports that are created
	*                        by the application.
	*  \param queueSizeLimit An optional size of the MIDI input queue can be
	*                        specified.
	*
	* See RtMidiIn::RtMidiIn().
	*/
	rtmidi_in_create :: proc(api: RtMidiApi, clientName: cstring, queueSizeLimit: u32) -> RtMidiInPtr ---

	//! \brief Free the given RtMidiInPtr.
	rtmidi_in_free :: proc(device: RtMidiInPtr) ---

	//! \brief Returns the MIDI API specifier for the given instance of RtMidiIn.
	//! See \ref
	rtmidi_in_get_current_api :: proc(device: RtMidiPtr) -> RtMidiApi ---

	//! \brief Set a callback function to be invoked for incoming MIDI messages.
	//! See \ref
	rtmidi_in_set_callback :: proc(device: RtMidiInPtr, callback: RtMidiCCallback, userData: rawptr) ---

	//! \brief Cancel use of the current callback function (if one exists).
	//! See \ref
	rtmidi_in_cancel_callback :: proc(device: RtMidiInPtr) ---

	//! \brief Specify whether certain MIDI message types should be queued or ignored during input.
	//! See \ref
	rtmidi_in_ignore_types :: proc(device: RtMidiInPtr, midiSysex: bool, midiTime: bool, midiSense: bool) ---

	/*! Fill the user-provided array with the data bytes for the next available
	* MIDI message in the input queue and return the event delta-time in seconds.
	*
	* \param message   Must point to a char* that is already allocated.
	*                  SYSEX messages maximum size being 1024, a statically
	*                  allocated array could
	*                  be sufficient.
	* \param size      Is used to return the size of the message obtained.
	*                  Must be set to the size of \ref message when calling.
	*
	* See RtMidiIn::getMessage().
	*/
	rtmidi_in_get_message :: proc(device: RtMidiInPtr, message: ^u8, size: ^uint) -> f64 ---

	//! \brief Create a default RtMidiInPtr value, with no initialization.
	rtmidi_out_create_default :: proc() -> RtMidiOutPtr ---

	/*! \brief Create a RtMidiOutPtr value, with given and clientName.
	*
	*  \param api            An optional API id can be specified.
	*  \param clientName     An optional client name can be specified. This
	*                        will be used to group the ports that are created
	*                        by the application.
	*
	* See RtMidiOut::RtMidiOut().
	*/
	rtmidi_out_create :: proc(api: RtMidiApi, clientName: cstring) -> RtMidiOutPtr ---

	//! \brief Free the given RtMidiOutPtr.
	rtmidi_out_free :: proc(device: RtMidiOutPtr) ---

	//! \brief Returns the MIDI API specifier for the given instance of RtMidiOut.
	//! See \ref
	rtmidi_out_get_current_api :: proc(device: RtMidiPtr) -> RtMidiApi ---

	//! \brief Immediately send a single message out an open MIDI output port.
	//! See \ref
	rtmidi_out_send_message :: proc(device: RtMidiOutPtr, message: ^u8, length: i32) -> i32 ---
}