extends Node

# --- GAME DATA ---
var game_levels: Array = []
const CLASSIC_LEVELS_PATH = "res://Gamemodes/Classic/"

func _ready():
	# Load levels dynamically before doing anything else
	game_levels = load_levels_from_folder(CLASSIC_LEVELS_PATH)
	
	load_game() # Your existing load function

func load_levels_from_folder(path: String) -> Array:
	var loaded_levels: Array = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# Temporary array to store paths so we can sort them FIRST
		var file_paths: Array = []
		
		while file_name != "":
			# Check if it is a file and has the correct extension
			if not dir.current_is_dir():
				# We check for .tres AND .remap (vital for exported builds)
				if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
					# Clean the filename for loading (remove .remap if present)
					var true_name = file_name.trim_suffix(".remap")
					file_paths.append(true_name)
			
			file_name = dir.get_next()
		
		# Sort files alphabetically (Level001 -> Level002 -> etc.)
		file_paths.sort()
		
		# Now actually load them in order
		for f_name in file_paths:
			var full_path = path + "/" + f_name
			var level_res = load(full_path)
			if level_res:
				loaded_levels.append(level_res)
				
	else:
		print("ERROR: Could not open level directory: ", path)
		
	return loaded_levels

# --- GAME STATE ---
var highest_level_reached = 0
var selected_level = 0
var level_stars = {}

# Endless progression
var endless_high_score = 0
var endless_current_score = 0

const SAVE_PATH = "user://lookmom_save.json"

func save_game():
	var data = {
		"highest_level_reached": highest_level_reached,
		"level_stars": level_stars,
		"endless_high_score": endless_high_score,
		"endless_current_score": endless_current_score
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.get_data()
			if "highest_level_reached" in data:
				highest_level_reached = int(data["highest_level_reached"])
			if "level_stars" in data:
				for key in data["level_stars"]:
					level_stars[int(key)] = int(data["level_stars"][key])
			if "endless_high_score" in data:
				endless_high_score = int(data["endless_high_score"])
			if "endless_current_score" in data:
				endless_current_score = int(data["endless_current_score"])
