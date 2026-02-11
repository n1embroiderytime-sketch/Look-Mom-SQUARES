extends Control

# DRAG YOUR LEVEL FILES HERE IN THE INSPECTOR
@export var all_levels: Array[Resource] = []

# [FIX] References updated to the new VBox structure recommended above.
# If you didn't change the tree, keep your old paths ($ContainerClassic/LevelRow), 
# but I strongly recommend using the %UniqueName feature for robustness.
@onready var grid_classic = $MainMargin/LayoutList/SectionClassic/ContainerClassic/LevelRow
@onready var grid_endless = $MainMargin/LayoutList/SectionEndless/ContainerEndless/LevelRow

func _ready():
	# Clean up any editor placeholders
	_clear_container(grid_classic)
	_clear_container(grid_endless)

	setup_endless_mode()
	setup_classic_mode()
	setup_mirror_mode() # Even if locked, we set up the visuals

	# --- BACK BUTTON ---
	# Uses robust finding just in case it moved
	var btn_back = find_child("BtnBack", true, false)
	if btn_back:
		if not btn_back.is_connected("pressed", _on_back_pressed):
			btn_back.pressed.connect(_on_back_pressed)

# --- 1. ENDLESS MODE (TOP PRIORITY) ---
func setup_endless_mode():
	var btn_endless = preload("res://LevelButton.gd").new()
	grid_endless.add_child(btn_endless)
	
	# Load the resource. Assuming you renamed it to Level00 per your plan.
	# If the file is still Level999, change this path back!
	var endless_data_path = "res://Gamemodes/Endless/Level00.tres"
	if not ResourceLoader.exists(endless_data_path):
		# Fallback if you haven't renamed the file yet
		endless_data_path = "res://Gamemodes/Endless/Level999.tres"
		
	var endless_data = load(endless_data_path)
	
	# Get High Score (using ID 0 as requested, or 999 if that's your save key)
	# Recommendation: Stick to one ID for saving. If you used 999 before, keep 999 
	# as the 'save_key' but display '0' on the button.
	var save_id = 999 
	var display_id = 0
	var endless_stars = Global.level_stars.get(save_id, 0)
	
	# Setup: ID 0, Data, Not Locked, Stars
	btn_endless.setup(display_id, endless_data, false, endless_stars)
	
	
	btn_endless.pressed.connect(func(): 
		Global.selected_level = save_id
		get_tree().change_scene_to_file("res://endless_game.tscn")
	)
	# This tells the BUTTON to fill the LevelRow (which fills the screen)
	btn_endless.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# This keeps the height nice and banner-like (adjust 180 to preference)
	btn_endless.custom_minimum_size = Vector2(0, 180)

# --- 2. CLASSIC MODE (MIDDLE) ---
func setup_classic_mode():
	for i in range(Global.game_levels.size()):
		var data = Global.game_levels[i]
		
		# Logic: Is this level locked?
		# (Level 0 is always open, Level 1 needs Level 0 beaten, etc.)
		var is_locked = i > Global.highest_level_reached
		var stars = Global.level_stars.get(i, 0)
		
		var btn = preload("res://LevelButton.gd").new()
		grid_classic.add_child(btn)
		
		# Classic levels usually start at 1 for display, or 0? 
		# If Global.game_levels[0] is "Level 1", pass i + 1. 
		# If it is "Level 0", pass i.
		btn.setup(i + 1, data, is_locked, stars)
		
		if not is_locked:
			btn.pressed.connect(func(): _on_level_pressed(i))

# --- 3. MIRROR MODE (LOCKED/BOTTOM) ---
func setup_mirror_mode():
	# Since it is "Coming Soon", we don't spawn buttons.
	# The "LOCKED" label should already be in the scene (in ContainerMirror).
	# But if you want to ensure it's visually greyed out via code:
	var mirror_container = $MainMargin/LayoutList/SectionMirror
	mirror_container.modulate = Color(1, 1, 1, 0.5) # Dim the whole section

# --- HELPERS ---
func _clear_container(container):
	for child in container.get_children():
		child.queue_free()

func _on_level_pressed(lvl_idx):
	Global.selected_level = lvl_idx
	get_tree().change_scene_to_file("res://main_game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
