@tool
extends TileMapLayer

# Drag your Level00.tres, Level01.tres, etc. here in the Inspector!
@export var game_levels: Array[Resource] = []

# --- CONTROLS ---
@export var load_level_index: int = 0

# These are "Fake Buttons". Click the checkbox to trigger the action.
@export var _LOAD_LEVEL_NOW: bool = false:
	set(val):
		if val:
			_LOAD_LEVEL_NOW = false # Reset the checkbox immediately
			load_level_from_disk()

@export var _SAVE_LEVEL_NOW: bool = false:
	set(val):
		if val:
			_SAVE_LEVEL_NOW = false # Reset the checkbox immediately
			save_level_to_disk()

# --- LOGIC ---
func load_level_from_disk():
	if game_levels.is_empty():
		print("Designer Error: No levels in the 'Game Levels' array!")
		return
		
	if load_level_index < 0 or load_level_index >= game_levels.size():
		print("Designer Error: Invalid Level Index!")
		return
	
	print("--- DEBUG LOADING LEVEL ", load_level_index, " ---")
	clear() # Clear current tiles
	
	var data = game_levels[load_level_index]
	
	# DEBUG: Tell us exactly what is in the file
	if data and "target_slots" in data:
		print("Found ", data.target_slots.size(), " blocks in file.")
		
		if data.target_slots.size() == 0:
			print("WARNING: Level file is valid but EMPTY.")
		
		for coord in data.target_slots:
			# FIX: We use Source 0, Atlas (0,0). 
			# If this draws invisible tiles, your tile might be at a different atlas coord.
			set_cell(Vector2i(coord.x, coord.y), 0, Vector2i(0,0))
	else:
		print("ERROR: Level Data is null or missing 'target_slots'")
	
	print("Finished Loading.")

func save_level_to_disk():
	if game_levels.is_empty(): return
	
	print("--- SAVING LEVEL ", load_level_index, " ---")
	var data = game_levels[load_level_index]
	
	# 1. Get all tiles currently drawn on screen
	var used_cells = get_used_cells()
	var new_targets = []
	
	# 2. Convert them to Vector2 (which is what your game uses)
	for cell in used_cells:
		new_targets.append(Vector2(cell.x, cell.y))
	
	# 3. Save to the Resource file
	data.target_slots = new_targets
	ResourceSaver.save(data, data.resource_path)
	
	print("Saved ", new_targets.size(), " blocks to ", data.resource_path)
