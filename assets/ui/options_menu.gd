extends Control

const SETTINGS_PATH = "user://settings.tres"

@export var callback_menu: Control
@export var menu_audio: AudioStreamPlayer

enum QualityPreset { LOW, MEDIUM, HIGH }

var window_mode:int = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
	set(value):
		window_mode = value
		match value:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowSizeButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowSizeButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowSizeButton.selected = 2
		DisplayServer.window_set_mode(value)

var is_bg_audio_on:bool = false:
	set(value):
		is_bg_audio_on = value
		if BackgroundMusic:
			if value:
				%BackgroundAudioCheckBox.button_pressed = true
				BackgroundMusic.bg_music_node.play()
			else:
				%BackgroundAudioCheckBox.button_pressed = false
				BackgroundMusic.bg_music_node.stop()

var quality_preset:int = QualityPreset.LOW:
	set(value):
		quality_preset = value
		%QualityPresetButton.selected = value
		apply_preset(value)

var settings_data:Settings

func _ready() -> void:
	if ResourceLoader.exists(SETTINGS_PATH):
		load_settings()
	else:
		settings_data = Settings.new()
		auto_detect_tier()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		hide()
		callback_menu.show()

func _on_window_size_button_item_selected(index: int) -> void:
	if index == 0:
		window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	elif index == 1:
		window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	elif index == 2:
		window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
	else:
		window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	save_settings()


func _on_back_button_pressed() -> void:
	hide()
	callback_menu.show()


func _on_show_tips_check_box_pressed() -> void:
	GlobalSignal.toggle_pointer_ui.emit()


func _on_back_button_mouse_entered() -> void:
	menu_audio.play()


func _on_background_audio_check_box_pressed() -> void:
	is_bg_audio_on = not is_bg_audio_on
	save_settings()


func save_settings() -> void:
	settings_data.quality_preset = quality_preset
	settings_data.window_mode = window_mode
	settings_data.bg_music_on = is_bg_audio_on
	var error_code := ResourceSaver.save(settings_data, SETTINGS_PATH)
	if error_code != OK:
		push_error("Failed to save game: " + error_string(error_code))
	
func load_settings() -> void:
	settings_data = ResourceLoader.load(SETTINGS_PATH)
	if not settings_data:
		return
	if settings_data.quality_preset:
		quality_preset = settings_data.quality_preset
	else:
		quality_preset = QualityPreset.LOW
	if settings_data.window_mode:
		window_mode = settings_data.window_mode
	if settings_data.bg_music_on:
		is_bg_audio_on = settings_data.bg_music_on


func apply_preset(preset: QualityPreset):
	var root_viewport = get_viewport()
	
	match preset:
		QualityPreset.LOW:
			# Resolution Scaling (FSR 1.0) - massive performance boost
			root_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			root_viewport.scaling_3d_scale = 0.5 # Renders at 50% res
			
			# Shadows
			RenderingServer.directional_shadow_atlas_set_size(512, true)
			
			# Anti-Aliasing
			root_viewport.msaa_3d = Viewport.MSAA_DISABLED
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			#print("low quality")
		QualityPreset.MEDIUM:
			root_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			root_viewport.scaling_3d_scale = 0.75
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			root_viewport.msaa_3d = Viewport.MSAA_2X
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			#print("medium quality")
		QualityPreset.HIGH:
			root_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
			root_viewport.scaling_3d_scale = 1.0
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			root_viewport.msaa_3d = Viewport.MSAA_4X
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			#print("high quality")

func auto_detect_tier():
	var gpu = RenderingServer.get_video_adapter_name().to_lower()
	
	if "intel" in gpu or "vega" in gpu or "mobile" in gpu:
		quality_preset = QualityPreset.LOW
	elif "rtx" in gpu or "rx 6" in gpu or "rx 7" in gpu:
		quality_preset = QualityPreset.HIGH
	else:
		quality_preset = QualityPreset.MEDIUM


func _on_quality_preset_button_item_selected(index: int) -> void:
	quality_preset = index
	save_settings()
