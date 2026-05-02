extends Node

var achievements: Dictionary[String, bool] = {
	"TEST_ACHIEVEMENT": false
	}
var statistics: Dictionary[String, int] = {
	"TEST_STAT": 0
	}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_steam()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s " % initialize_response)
	
	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam")
		return
		
	print("Steam App Id: %s" % Steam.getAppID())
	load_steam_stats()
	load_steam_achievements()


func load_steam_stats() -> void:
	for this_stat in statistics.keys():
		var stat_value: int = Steam.getStatInt(this_stat)
		print("Retrieved %s stat: %s" % [this_stat, stat_value])

		# Store the value in our dictionary
		statistics[this_stat] = stat_value
	print("Steam statistics loaded")


# Process achievements
func load_steam_achievements() -> void:
	for this_achievement in achievements.keys():
		var steam_achievement: Dictionary = Steam.getAchievement(this_achievement)
		print("Retrieved %s achievement: %s" % [this_achievement, steam_achievement])
		
		# Does the achievement actually exist in the Steamworks back-end?
		if not steam_achievement.get("ret"):
			print("Steam does not have this achievement, ignoring it")
			continue
		achievements[this_achievement] = steam_achievement.get("achieved")
	print("Steam achievements loaded")


func set_achievement(this_achievement: String) -> void:
	if not achievements.has(this_achievement):
		print("This achievement does not exist locally: %s" % this_achievement)
		return
	achievements[this_achievement] = true

	if not Steam.setAchievement(this_achievement):
		print("Failed to set achievement: %s" % this_achievement)
		return

	print("Set acheivement: %s" % this_achievement)
	store_steam_data()


func store_steam_data() -> void:
	if not Steam.storeStats():
		print("Failed to store data on Steam, should be stored locally")
		return
	print("Data successfully sent to Steam")


func set_statistic(this_stat: String, new_value: int = 1) -> void:
	if not statistics.has(this_stat):
		print("This statistic does not exist locally: %s" % this_stat)
		return
	# Set our local version
	statistics[this_stat] += new_value

	# Set Steam's version
	if not Steam.setStatInt(this_stat, new_value):
		print("Failed to set stat %s to: %s" % [this_stat, new_value])
		return

	print("Set statistics %s succesfully: %s" % [this_stat, new_value])
	store_steam_data()


func reset_statistics() -> void:
	print("Resetting all statistics and achievements for local user")
	if not Steam.resetAllStats(true):
		print("Failed to reset statistics and achievements")


func reset_achievement(this_achievement: String) -> void:
	print("Resetting achievement %s" % this_achievement)
	if not Steam.clearAchievement(this_achievement):
		print("Failed to reset achievement: %s" % this_achievement)
