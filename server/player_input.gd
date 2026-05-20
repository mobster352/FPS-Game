# player_input.gd
extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2()

@export var mouse_input := Vector2()

@onready var ui: MultiplayerUI = get_node("/root/Game/Multiplayer/ConnectionRegistry/UI")

var is_paused := false

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc
func jump():
	jumping = true


func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not is_paused:
		direction = Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
		if Input.is_action_just_pressed("jump"):
			if multiplayer.is_server():
				jump()
			else:
				jump.rpc()
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		if is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_input = Vector2.ZERO
			ui.show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			ui.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_paused:
		mouse_input = event.relative
