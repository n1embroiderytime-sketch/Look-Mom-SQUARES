extends Button

var level_index = 0
var level_data = null
var is_locked = false
var stars_earned = 0

# Settings
const BUTTON_SIZE = Vector2(150, 150)
const PREVIEW_GRID_SIZE = 12.0 

func setup(idx, data, locked, stars):
	level_index = idx
	level_data = data
	is_locked = locked
	stars_earned = stars
	
	# 1. SQUARE SIZE
	custom_minimum_size = BUTTON_SIZE
	size = BUTTON_SIZE
	
	# 2. ALLOW SWIPING (Crucial!)
	# MOUSE_FILTER_PASS lets the ScrollContainer see the drag event
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# 3. CENTER PIVOT (For nice zooming)
	pivot_offset = BUTTON_SIZE / 2
	
	disabled = is_locked
	
	# Connect hover signals for the zoom effect
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_hover_exit)
	
	queue_redraw()

func _draw():
	var center = size / 2
	
	# --- A. BACKGROUND ---
	var bg_col = Color("2e3440") 
	if is_locked: bg_col = Color("15171c")
	
	draw_rect(Rect2(Vector2.ZERO, size), bg_col, true)
	
	# Border
	var border_col = Color("4c566a")
	if is_locked: border_col = Color("2e3440")
	draw_rect(Rect2(Vector2.ZERO, size), border_col, false, 2.0)
	
	# --- B. CENTERED LEVEL PREVIEW ---
	if level_data and "target_slots" in level_data and not level_data.target_slots.is_empty():
		var targets = level_data.target_slots
		
		# Calculate Bounding Box to center perfectly
		var min_x = 999; var max_x = -999
		var min_y = 999; var max_y = -999
		
		for t in targets:
			if t.x < min_x: min_x = t.x
			if t.x > max_x: max_x = t.x
			if t.y < min_y: min_y = t.y
			if t.y > max_y: max_y = t.y
			
		var shape_w = (max_x - min_x + 1) * PREVIEW_GRID_SIZE
		var shape_h = (max_y - min_y + 1) * PREVIEW_GRID_SIZE
		
		# Determine where to start drawing so the SHAPE is centered
		# (ButtonCenter) - (HalfShapeSize) - (OffsetToFirstBlock)
		var start_pos = center - Vector2(shape_w/2, shape_h/2) - Vector2(min_x * PREVIEW_GRID_SIZE, min_y * PREVIEW_GRID_SIZE)
		
		for t in targets:
			var draw_pos = start_pos + Vector2(t.x, t.y) * PREVIEW_GRID_SIZE
			var rect = Rect2(draw_pos, Vector2(PREVIEW_GRID_SIZE - 1, PREVIEW_GRID_SIZE - 1))
			
			if is_locked:
				draw_rect(rect, Color(1, 1, 1, 0.1), false, 1.0)
			else:
				draw_rect(rect, Color.WHITE, true)

	# --- C. STARS DISPLAY ---
	if not is_locked:
		var star_size = 12
		var gap = 4
		var total_w = (star_size * 3) + (gap * 2)
		var start_x = (size.x - total_w) / 2
		var start_y = size.y - 25 # Near bottom
		
		for i in range(3):
			var s_rect = Rect2(start_x + i * (star_size + gap), start_y, star_size, star_size)
			var color = Color("ebcb8b") if i < stars_earned else Color("434c5e") # Gold vs Grey
			draw_rect(s_rect, color, true)
	
	# --- D. LOCKED TEXT ---
	if is_locked:
		draw_string(ThemeDB.fallback_font, center + Vector2(0, 5), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(1, 1, 1, 0.4))
		
	# --- E. LEVEL NUMBER ---
	# Move number to top-left to make room for stars
	var num_col = Color(1, 1, 1, 0.2) if is_locked else Color(1, 1, 1, 0.5)
	draw_string(ThemeDB.fallback_font, Vector2(8, 24), str(level_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, num_col)

# --- HOVER ANIMATION ---
func _on_hover():
	if is_locked: return
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE)

func _on_hover_exit():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
