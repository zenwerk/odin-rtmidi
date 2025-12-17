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
Wrapper :: struct {
	//! The wrapped RtMidi object.
	ptr:                  rawptr,
	callback_proxy:       rawptr,
	error_callback_proxy: rawptr,

	//! True when the last function call was OK.
	ok:                   i32,

	//! If an error occurred (ok != true), set to an error message.
	msg:                  cstring,
}

//! \brief Typedef for a generic RtMidi pointer.
Ptr :: ^Wrapper

//! \brief Typedef for a generic RtMidiIn pointer.
InPtr :: ^Wrapper

//! \brief Typedef for a generic RtMidiOut pointer.
OutPtr :: ^Wrapper

//! \brief MIDI API specifier arguments.  See \ref RtMidi::Api.
Api :: enum u32 {
	UNSPECIFIED  = 0, /*!< Search for a working compiled API. */
	MACOSX_CORE  = 1, /*!< Macintosh OS-X CoreMIDI API. */
	LINUX_ALSA   = 2, /*!< The Advanced Linux Sound Architecture API. */
	UNIX_JACK    = 3, /*!< The Jack Low-Latency MIDI Server API. */
	WINDOWS_MM   = 4, /*!< The Microsoft Multimedia MIDI API. */
	RTMIDI_DUMMY = 5, /*!< A compilable but non-functional API. */
	WEB_MIDI_API = 6, /*!< W3C Web MIDI API. */
	WINDOWS_UWP  = 7, /*!< The Microsoft Universal Windows Platform MIDI API. */
	ANDROID      = 8, /*!< The Android MIDI API. */
	NUM          = 9, /*!< Number of values in this enum. */
}

//! \brief Defined RtMidiError types. See \ref RtMidiError::Type.
ErrorType :: enum u32 {
	WARNING           = 0, /*!< A non-critical error. */
	DEBUG_WARNING     = 1, /*!< A non-critical error which might be useful for debugging. */
	UNSPECIFIED       = 2, /*!< The default, unspecified error type. */
	NO_DEVICES_FOUND  = 3, /*!< No devices found on system. */
	INVALID_DEVICE    = 4, /*!< An invalid device ID was specified. */
	MEMORY_ERROR      = 5, /*!< An error occurred during memory allocation. */
	INVALID_PARAMETER = 6, /*!< An invalid parameter was specified to a function. */
	INVALID_USE       = 7, /*!< The function was called incorrectly. */
	DRIVER_ERROR      = 8, /*!< A system driver error occurred. */
	SYSTEM_ERROR      = 9, /*!< A system error occurred. */
	THREAD_ERROR      = 10, /*!< A thread error occurred. */
}

/*! \brief The type of a RtMidi callback function.
*
* \param timeStamp   The time at which the message has been received.
* \param message     The midi message.
* \param userData    Additional user data for the callback.
*
* See \ref RtMidiIn::RtMidiCallback.
*/
CCallback :: proc "c" (timeStamp: f64, message: ^u8, messageSize: i32, userData: rawptr)

/*! \brief The type of a RtMidi error callback function.
*
* \param type        Type of error
* \param message     Error description
* \param userData    Additional user data for the callback.
*
* See \ref MidiApi::setErrorCallback.
*/
ErrorCCallback :: proc "c" (type: ErrorType, errorText: cstring, userData: rawptr)

@(default_calling_convention = "c", link_prefix = "rtmidi_")
foreign lib {
	/*! \brief Return the current RtMidi version.
	 *! See \ref RtMidi::getVersion().
	 */
	get_version :: proc() -> cstring ---

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
	get_compiled_api :: proc(apis: ^Api, apis_size: u32) -> i32 ---

	//! \brief Return the name of a specified compiled MIDI API.
	//! See \ref RtMidi::getApiName().
	api_name :: proc(api: Api) -> cstring ---

	//! \brief Return the display name of a specified compiled MIDI API.
	//! See \ref RtMidi::getApiDisplayName().
	api_display_name :: proc(api: Api) -> cstring ---

	//! \brief Return the compiled MIDI API having the given name.
	//! See \ref RtMidi::getCompiledApiByName().
	compiled_api_by_name :: proc(name: cstring) -> Api ---

	/*! \brief Open a MIDI port.
	*
	* \param port      Must be greater than 0
	* \param portName  Name for the application port.
	*
	* See RtMidi::openPort().
	*/
	open_port :: proc(device: Ptr, portNumber: u32, portName: cstring) ---

	/*! \brief Creates a virtual MIDI port to which other software applications can
	* connect.
	*
	* \param portName  Name for the application port.
	*
	* See RtMidi::openVirtualPort().
	*/
	open_virtual_port :: proc(device: Ptr, portName: cstring) ---

	/*! \brief Close a MIDI connection.
	* See RtMidi::closePort().
	*/
	close_port :: proc(device: Ptr) ---

	/*! \brief Return the number of available MIDI ports.
	* See RtMidi::getPortCount().
	*/
	get_port_count :: proc(device: Ptr) -> u32 ---

	/*! \brief Access a string identifier for the specified MIDI input port number.
	*
	* To prevent memory leaks a char buffer must be passed to this function.
	* NULL can be passed as bufOut parameter, and that will write the required buffer length in the bufLen.
	*
	* See RtMidi::getPortName().
	*/
	get_port_name :: proc(device: Ptr, portNumber: u32, bufOut: cstring, bufLen: ^i32) -> i32 ---

	//! \brief Create a default RtMidiInPtr value, with no initialization.
	in_create_default :: proc() -> InPtr ---

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
	in_create :: proc(api: Api, clientName: cstring, queueSizeLimit: u32) -> InPtr ---

	//! \brief Free the given RtMidiInPtr.
	in_free :: proc(device: InPtr) ---

	//! \brief Returns the MIDI API specifier for the given instance of RtMidiIn.
	//! See \ref RtMidiIn::getCurrentApi().
	in_get_current_api :: proc(device: Ptr) -> Api ---

	//! \brief Set a callback function to be invoked for incoming MIDI messages.
	//! See \ref RtMidiIn::setCallback().
	in_set_callback :: proc(device: InPtr, callback: CCallback, userData: rawptr) ---

	//! \brief Cancel use of the current callback function (if one exists).
	//! See \ref RtMidiIn::cancelCallback().
	in_cancel_callback :: proc(device: InPtr) ---

	//! \brief Specify whether certain MIDI message types should be queued or ignored during input.
	//! See \ref RtMidiIn::ignoreTypes().
	in_ignore_types :: proc(device: InPtr, midiSysex: i32, midiTime: i32, midiSense: i32) ---

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
	in_get_message :: proc(device: InPtr, message: ^u8, size: ^i32) -> f64 ---

	//! \brief Create a default RtMidiInPtr value, with no initialization.
	out_create_default :: proc() -> OutPtr ---

	/*! \brief Create a RtMidiOutPtr value, with given and clientName.
	*
	*  \param api            An optional API id can be specified.
	*  \param clientName     An optional client name can be specified. This
	*                        will be used to group the ports that are created
	*                        by the application.
	*
	* See RtMidiOut::RtMidiOut().
	*/
	out_create :: proc(api: Api, clientName: cstring) -> OutPtr ---

	//! \brief Free the given RtMidiOutPtr.
	out_free :: proc(device: OutPtr) ---

	//! \brief Returns the MIDI API specifier for the given instance of RtMidiOut.
	//! See \ref RtMidiOut::getCurrentApi().
	out_get_current_api :: proc(device: Ptr) -> Api ---

	//! \brief Immediately send a single message out an open MIDI output port.
	//! See \ref RtMidiOut::sendMessage().
	out_send_message :: proc(device: OutPtr, message: ^u8, length: i32) -> i32 ---

	//! \brief Set error callback function on a RtMidiPtr.
	//! See \ref MidiApi::setErrorCallback().
	set_error_callback :: proc(device: Ptr, callback: ErrorCCallback, userData: rawptr) ---
}