extends Control

const SETTINGS_PATH = "user://settings.tres"
const PROJECT_SETTINGS_PATH = "user://project_settings.cfg"

@export var callback_menu: Control
@export var menu_audio: AudioStreamPlayer
@export var tabs:TabContainer

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
				BackgroundMusic.bg_music_node.stream_paused = false
				if not BackgroundMusic.bg_music_node.playing:
					BackgroundMusic.bg_music_node.play()
			else:
				%BackgroundAudioCheckBox.button_pressed = false
				BackgroundMusic.bg_music_node.stream_paused = true

var quality_preset:int = QualityPreset.LOW:
	set(value):
		quality_preset = value
		%QualityPresetButton.selected = value
		apply_preset(value)
		
var previous_rendering_method:String
var rendering_method:String = "forward_plus":
	set(value):
		previous_rendering_method = rendering_method
		rendering_method = value
		match value:
			"forward_plus":
				%RendererButton.selected = 0
			"gl_compatibility":
				%RendererButton.selected = 1
			"mobile":
				%RendererButton.selected = 2
		set_renderer_for_next_launch()

var fov:int:
	set(value):
		fov = value
		%FovValue.text = str(value)
		%FovSlider.value = value
		
var bg_music_audio_level:float:
	set(value):
		bg_music_audio_level = value
		%BackgroundMusicHSlider.value = value
		BackgroundMusic.bg_music_node.volume_db = value

var settings_data:Settings
var player:Player
var worldEnvironment:WorldEnvironment

func _ready() -> void:
	worldEnvironment = get_tree().get_first_node_in_group("world_environment")
	set_world_environment_properties(false)
	if ResourceLoader.exists(SETTINGS_PATH):
		load_settings()
	else:
		settings_data = Settings.new()
		auto_detect_tier()
	#print("Renderer: ", RenderingServer.get_current_rendering_method())
	GlobalSignal.init_player.connect(_init_player)
 
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
	settings_data.rendering_method = rendering_method
	settings_data.fov = fov
	settings_data.bg_music_audio_level = bg_music_audio_level
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
	if settings_data.rendering_method:
		rendering_method = settings_data.rendering_method
	if settings_data.mouse_sensitivity:
		if player:
			player.mouse_sensitivity = Settings.update_mouse_sensitivity(settings_data.mouse_sensitivity)
		%MouseSensitivitySpinBox.set_value_no_signal(settings_data.mouse_sensitivity)
	if settings_data.controller_sensitivity:
		if player:
			player.controller_sensitivity = Settings.update_controller_sensitivity(settings_data.controller_sensitivity)
		%ControllerSensitivitySpinBox.set_value_no_signal(settings_data.controller_sensitivity)
	if settings_data.deadzone:
		if player:
			player.controller_deadzone = Settings.update_deadzone(settings_data.deadzone)
		%DeadzoneSpinBox.set_value_no_signal(settings_data.deadzone)
	if settings_data.fov:
		fov = settings_data.fov
	if settings_data.bg_music_audio_level:
		bg_music_audio_level = settings_data.bg_music_audio_level


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
			set_world_environment_properties(false)
			#print("low quality")
		QualityPreset.MEDIUM:
			root_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			root_viewport.scaling_3d_scale = 0.75
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			root_viewport.msaa_3d = Viewport.MSAA_2X
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			set_world_environment_properties(false)
			#print("medium quality")
		QualityPreset.HIGH:
			root_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
			root_viewport.scaling_3d_scale = 1.0
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			root_viewport.msaa_3d = Viewport.MSAA_4X
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			set_world_environment_properties(true)
			#print("high quality")

func auto_detect_tier():
	var gpu = RenderingServer.get_video_adapter_name().to_lower()
	
	if "intel" in gpu or "vega" in gpu or "mobile" in gpu:
		quality_preset = QualityPreset.LOW
	elif "rtx" in gpu or "rx 6" in gpu or "rx 7" in gpu:
		quality_preset = QualityPreset.HIGH
	else:
		quality_preset = QualityPreset.MEDIUM


func set_world_environment_properties(is_enabled:bool) -> void:
	if worldEnvironment:
		worldEnvironment.environment.sdfgi_enabled = is_enabled
		worldEnvironment.environment.ssil_enabled = is_enabled
		worldEnvironment.environment.ssao_enabled = is_enabled
		worldEnvironment.environment.ssr_enabled = is_enabled
		worldEnvironment.environment.volumetric_fog_enabled = is_enabled


func _on_quality_preset_button_item_selected(index: int) -> void:
	quality_preset = index
	save_settings()


func set_renderer_for_next_launch():
	if settings_data:
		if rendering_method == settings_data.rendering_method:
			return
	%Settings.hide()
	%GraphicsRestartPopup.show()


func set_renderer_and_restart():
	var config = ConfigFile.new()
	config.set_value("rendering", "renderer/rendering_method", rendering_method)
	config.save(PROJECT_SETTINGS_PATH)

	OS.set_restart_on_exit(true, ["--rendering-method", rendering_method])
	get_tree().quit()


func _on_renderer_button_item_selected(index: int) -> void:
	match index:
		0:
			rendering_method = "forward_plus"
		1:
			rendering_method = "gl_compatibility"
		2:
			rendering_method = "mobile"


func _on_restart_button_pressed() -> void:
	save_settings()
	set_renderer_and_restart()


func _on_cancel_button_pressed() -> void:
	rendering_method = previous_rendering_method
	%Settings.show()
	%GraphicsRestartPopup.hide()


func _on_visibility_changed() -> void:
	if visible:
		%QualityPresetButton.grab_focus()


func _on_mouse_sensitivity_spin_box_value_changed(value: float) -> void:
	settings_data.mouse_sensitivity = value
	save_settings()
	if player:
		player.mouse_sensitivity = Settings.update_mouse_sensitivity(value)


func _init_player(_player:Player) -> void:
	player = _player


func _on_controller_sensitivity_spin_box_value_changed(value: float) -> void:
	settings_data.controller_sensitivity = value
	save_settings()
	if player:
		player.controller_sensitivity = Settings.update_controller_sensitivity(value)


func _on_deadzone_spin_box_value_changed(value: float) -> void:
	settings_data.deadzone = value
	save_settings()
	if player:
		player.controller_deadzone = Settings.update_deadzone(value)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tab_left"):
		tabs.current_tab = wrapi(tabs.current_tab - 1, 0, tabs.get_tab_count())
		if tabs.current_tab == 0:
			%QualityPresetButton.grab_focus()
		elif tabs.current_tab == 1:
			%MouseSensitivitySpinBox.get_line_edit().grab_focus()
		elif tabs.current_tab == 2:
			%ControllerSensitivitySpinBox.get_line_edit().grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tab_right"):
		tabs.current_tab = wrapi(tabs.current_tab + 1, 0, tabs.get_tab_count())
		if tabs.current_tab == 0:
			%QualityPresetButton.grab_focus()
		elif tabs.current_tab == 1:
			%MouseSensitivitySpinBox.get_line_edit().grab_focus()
		elif tabs.current_tab == 2:
			%ControllerSensitivitySpinBox.get_line_edit().grab_focus()
		get_viewport().set_input_as_handled()


func _on_fov_slider_value_changed(value: float) -> void:
	fov = int(value)
	save_settings()
	if player:
		player.fov = fov


func _on_background_music_h_slider_value_changed(value: float) -> void:
	bg_music_audio_level = value
	save_settings()
