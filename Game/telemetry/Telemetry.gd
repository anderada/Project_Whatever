extends Node

signal authenticated(success:bool, info:int)

enum State {UNINITIALIZED, WAKING, AUTHENTICATING, READY, DISCONNECTED}

@export var url:String = "https://telemetry-js-792bae8f0c9a.herokuapp.com/"
@export var user_name:String  = "Your SLATE user name or team name"
@export var secret:String  = "Your student # or team passphrase"
@export var version:String  = "test"
@export var default_section:String  = "default"
@export var log_to_server:bool  = false
@export var debug_print:bool = true

@onready var _http:HTTPRequest = $HTTPRequest

var _state:State = State.UNINITIALIZED
var _log_queue:Array = []
var _network_in_use:bool = true
var _session_key:String = ''
var _session_index:int = -42
var _current_section:String
var _message_count:int = 0
var _queue_warn_thresh:int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_http.request_completed.connect(_on_request_completed)
	_state = State.WAKING
	_current_section = default_section
	if log_to_server:
		_try_wake_server()
	else:
		print("Telemetry session started - local logging only.")
		_state = State.READY
		
		authenticated.emit(true, _session_index)
		_pump_queue()


func has_authenticated() -> bool:
	return _state == State.READY or _state == State.DISCONNECTED

func log_event(section: String, event_type: String, data) -> void:
	if section == "":
		section = _current_section
	
	var event = {
		sessionKey = "",
		sequence = -1,
		section = section,
		eventType = event_type,
		timecode = _get_time_utc(),
		data = data
	}
	
	_log_queue.append(event)
	
	if _log_queue.size() > _queue_warn_thresh:
		var formatString = "Logging telemetry too fast: %d events in queue"
		print(formatString % _log_queue.size())
		_queue_warn_thresh += 20
	
	if !_network_in_use:
		_pump_queue()


func get_session_id() -> int:
	return _session_index


func set_section(label : String) -> void:
	if _current_section != label:
		log_event(_current_section, "ChangeSection", label)
		_current_section = label


func _get_time_utc() -> int:
	return roundi(Time.get_unix_time_from_system() * 1000)


func _try_wake_server() -> void:
	_message_count += 1
	if debug_print:
		print("Attempting to wake server, attempt ", _message_count)
	_http.request(url + "awake")


func _make_post_request(endpoint, data_to_send):
	var json:String = JSON.stringify(data_to_send)
	var headers:PackedStringArray = ["Content-Type: application/json"]
	#print(json)
	_http.request(url + endpoint, headers, HTTPClient.METHOD_POST, json)


func _pump_queue() -> void:
	if _log_queue.size() < 1:
		_network_in_use = false;
		_queue_warn_thresh = 20;
		return
		
	_network_in_use = true
	var event = _log_queue.pop_front()
	event.sessionKey = _session_key
	_message_count += 1
	event.sequence = _message_count
	if debug_print:
		print("logging: ", event)
		
	if log_to_server:
		_make_post_request("log", event)
	else:
		_pump_queue()


func _on_request_completed(_result, response_code, _headers, body) -> void:
	match _state:
		State.WAKING:
			if response_code == 200: #awake
				if debug_print:
					print("Server is awake - connecting...")
				_state = State.AUTHENTICATING
				var auth = {
					userName = user_name,
					secret = secret,
					version = version,
					section = default_section,
					timecode = _get_time_utc()
				}
				_make_post_request("connect", auth)
			else:					#fail / timeout (server still booting)
				_try_wake_server()
		State.AUTHENTICATING:
			if response_code == 200: #authenticated
				var auth = JSON.parse_string(body.get_string_from_utf8())
				_session_key = auth.sessionKey
				_session_index = auth.sessionIndex
				_state = State.READY
				print(auth.message)
				emit_signal("authenticated", true, auth.sessionIndex)
				_pump_queue()
			else:					#fail - revert to offline mode
				_state = State.DISCONNECTED
				log_to_server = false
				var error = body.get_string_from_utf8()
				emit_signal("authenticated", false, error)
				print("Failed to authenticate: ", error)
				_pump_queue()
				
		State.READY:
			if response_code != 200:
				print("Error logging: ", body.get_string_from_utf8())
			_pump_queue()
