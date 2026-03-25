extends Node3D
class_name LevelMP

@export var players_node:Node3D
@export var objects_node:Node3D

@export var rolling_pin_marker: Marker3D
@export var crate_dough_marker: Marker3D

const SPAWN_RANDOM := 1.0

var lobby_id:int
var players:Array
var objects:Array[Dictionary]

var _object_id := 0

func _ready() -> void:
	if not multiplayer.is_server():
		GlobalSignal.remove_object_from_level.connect(_remove_object_from_level)
		GlobalSignal.add_item_to_player.connect(_add_item_to_player)
		GlobalSignal.player_drop_item.connect(_player_drop_item)
		return
	if OS.has_feature("dedicated_server"):
		players.append(1)

func _exit_tree():
	if not multiplayer.is_server():
		return


func add_player(id: int, username:String):
	if players.has(id):
		return
	players.append(id)
	var character = preload("uid://ckmeyre76mhly").instantiate() as PlayerMP
	character.player = id
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	character.name_label.text = username
	print(username, ": ", str(id))
	for peer_id in players:
		character.server_synchronizer.set_visibility_for(peer_id, true)
	players_node.add_child(character, true)
	for player:PlayerMP in players_node.get_children():
		player.server_synchronizer.set_visibility_for(id, true)
	for peer_id in players:
		if peer_id != 1:
			_add_player_to_peers.rpc_id(peer_id, id)
	_update_held_item_late_join(id)
	for object in objects:
		if object.get("object").has_node("MultiplayerSynchronizer"):
			var sync = object.get("object").get_node("MultiplayerSynchronizer") as MultiplayerSynchronizer
			sync.set_visibility_for(id, true)
	
func del_player(id: int):
	if not players.has(id):
		return
	if not players_node.has_node(str(id)):
		return
	for player:PlayerMP in players_node.get_children():
		player.server_synchronizer.set_visibility_for(id, false)
		player.player_input_synchronizer.set_visibility_for(id, false)
	for peer_id in players:
		if peer_id != 1:
			_remove_player_from_peers.rpc_id(peer_id, id)
	players_node.get_node(str(id)).queue_free()
	players.remove_at(players.find(id))

func setup(_lobby_id:int) -> void:
	lobby_id = _lobby_id
	spawn_objects_on_server()

@rpc
func _add_player_to_peers(peer_id:int) -> void:
	for player:PlayerMP in players_node.get_children():
		player.player_input_synchronizer.set_visibility_for(peer_id, true)
		player.player_input_synchronizer.set_visibility_for(1, true)


@rpc
func _remove_player_from_peers(_peer_id:int) -> void:
	#for player:PlayerMP in players_node.get_children():
		#player.server_synchronizer.set_visibility_for(peer_id, false)
		#player.player_input_synchronizer.set_visibility_for(peer_id, false)
	pass


func spawn_objects_on_server() -> void:
	_spawn_object_on_peer("rolling_pin_mesh", rolling_pin_marker.position, rolling_pin_marker.rotation)
	_spawn_object_on_peer("crate_mesh", crate_dough_marker.position, crate_dough_marker.rotation, GlobalVar.StoreItem.Dough)


@rpc("call_local")
func _spawn_object_on_peer(mesh_name:String, object_position:Vector3, object_rotation:Vector3, item_type:GlobalVar.StoreItem = GlobalVar.StoreItem.None) -> void:
	var item = GlobalVar.get_item_from_mesh(mesh_name) as Item
	if item:
		_object_id = _object_id + 1
		
		item.name = mesh_name
		item.id = _object_id
		item.position = object_position
		item.rotation = object_rotation
		
		var interactable = item.get_node("body/Interactable")
		if interactable:
			if interactable is ObjectSpawner:
				interactable.item_type = item_type
		
		objects_node.add_child(item, true)
		
		objects.append({
			"object": item,
			"mesh_name": mesh_name,
			"id": _object_id
		})
		
		for player in players:
			if item.has_node("MultiplayerSynchronizer"):
				var sync = item.get_node("MultiplayerSynchronizer") as MultiplayerSynchronizer
				sync.set_visibility_for(player, true)


func get_object_at_id(id:int) -> Dictionary:
	for object in objects:
		if object.get("id") == id:
			return object
	return {}


func _remove_object_from_level(id:int) -> void:
	_remove_item_from_server.rpc_id(1, id)


@rpc("any_peer")
func _remove_item_from_server(id:int) -> void:
	var object_dict = get_object_at_id(id)
	if object_dict:
		var object = object_dict.get("object") as Node3D
		object.queue_free()
		objects.remove_at(objects.find(object_dict))

func _add_item_to_player(mesh_name:String, player_id:int) -> void:
	_server_add_item_to_player.rpc_id(1, mesh_name, player_id)


@rpc("any_peer")
func _server_add_item_to_player(mesh_name:String, peer_id:int):
	for player:PlayerMP in players_node.get_children():
		_update_held_item_to_peers.rpc_id(player.player, peer_id, mesh_name)
		
		if player.player == peer_id:
			var item = GlobalVar.get_mesh_from_array(mesh_name)
			player.item_slot.add_child(item, true)
			
			var child = player.item_slot.get_child(0)
			child.set_meta("name", mesh_name)


@rpc
func _update_held_item_to_peers(peer_id:int, mesh_name:String) -> void:
	for player:PlayerMP in players_node.get_children():
		if player.player != peer_id:
			continue
		var item = GlobalVar.get_mesh_from_array(mesh_name)
		player.item_slot.add_child(item, true)
		
		var child = player.item_slot.get_child(0)
		child.set_meta("name", mesh_name)
			
		#if multiplayer.get_unique_id() == peer_id:
			#var mesh = item.get_child(0) as MeshInstance3D
			#var material = StandardMaterial3D.new()
			#if mesh.get_surface_override_material_count() > 0:
				#material = mesh.get_surface_override_material(0)
			#if material is BaseMaterial3D:
				#material.use_z_clip_scale = true
				#if material.z_clip_scale == 1.0:
					#material.z_clip_scale = 0.1
				#mesh.set_surface_override_material(0, material)


func _update_held_item_late_join(new_player_id:int) -> void:
	for player:PlayerMP in players_node.get_children():
		if player.has_held_object():
			var item_node = player.item_slot.get_child(0)
			var mesh = item_node.get_child(0)
			if mesh.has_meta("name"):
				_update_held_item_to_peers.rpc_id(new_player_id, player.player, mesh.get_meta("name"))


func _player_drop_item(mesh_name:String, item_position:Vector3, item_rotation:Vector3, player_id:int) -> void:
	_server_player_drop_item.rpc_id(1, mesh_name, item_position, item_rotation, player_id)
	
	
@rpc("any_peer")
func _server_player_drop_item(mesh_name:String, item_position:Vector3, item_rotation:Vector3, player_id:int) -> void:
	_spawn_object_on_peer(mesh_name, item_position, item_rotation)
	for player in players:
		_remove_held_item_from_peers.rpc_id(player, player_id)
		
@rpc("call_local")
func _remove_held_item_from_peers(peer_id:int) -> void:
	for player:PlayerMP in players_node.get_children():
		if player.player != peer_id:
			continue
		if player.has_held_object():
			player.item_slot.get_child(0).queue_free()
