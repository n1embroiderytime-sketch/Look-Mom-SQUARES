extends "res://main_game.gd"

# 1. OVERRIDE DRAWING
func _draw():
	super._draw()
	
	# FIX: Calculate the exact boundary line between the left (-1) and right (0) columns
	# Previously we subtracted (GRID_SIZE/2) which moved it left. Now it is dead center.
	var center_screen_x = OFFSET_X + (CENTER_X * GRID_SIZE)
	var vp_size = get_viewport_rect().size
	
	# Draw a vertical red line
	draw_line(Vector2(center_screen_x, 0), Vector2(center_screen_x, vp_size.y), Color.RED, 2.0)


# 2. OVERRIDE LANDING
func land_piece():
	if level_completed: return 

	var gy = round(falling_piece.y)
	
	# --- 1. COPY-PASTE THE SMART FILTER CHECKS FROM MAIN GAME ---
	# (We have to repeat this because we are injecting logic inside the success block)
	
	# Check Connectivity
	var connected = false
	for r in range(falling_piece.matrix.size()):
		for c in range(falling_piece.matrix[r].size()):
			if falling_piece.matrix[r][c] == 1:
				var ax = falling_piece.x + c
				var ay = gy + r
				if is_occupied(ax+1, ay) or is_occupied(ax-1, ay) or is_occupied(ax, ay+1) or is_occupied(ax, ay-1):
					connected = true
	
	if not connected:
		print("REJECT: Missed Core.")
		shake_intensity = 15.0 
		falling_piece = null
		spawn_piece() 
		return

	# Check Height
	if gy < 0:
		print("REJECT: Too High.")
		shake_intensity = 15.0
		falling_piece = null
		spawn_piece()
		return
		
	# Check Targets
	var fits_ghost = true
	for r in range(falling_piece.matrix.size()):
		for c in range(falling_piece.matrix[r].size()):
			if falling_piece.matrix[r][c] == 1:
				var rel_x = (falling_piece.x + c) - CENTER_X
				var rel_y = (gy + r) - CENTER_Y
				var is_target = false
				for t in current_level_targets:
					if t.x == rel_x and t.y == rel_y:
						is_target = true
						break
				if not is_target:
					fits_ghost = false
	
	if not fits_ghost:
		print("REJECT: Doesn't fit solution.")
		shake_intensity = 15.0
		falling_piece = null
		spawn_piece() 
		return

	# --- 2. SUCCESS: ADD NORMAL + MIRROR BLOCKS ---
	for r in range(falling_piece.matrix.size()):
		for c in range(falling_piece.matrix[r].size()):
			if falling_piece.matrix[r][c] == 1:
				var normal_pos = { 
					"x": (falling_piece.x + c) - CENTER_X, 
					"y": (gy + r) - CENTER_Y 
				}
				cluster.append(normal_pos)
				
				# MIRROR LOGIC:
				# Axis is between -1 and 0. Formula: -x - 1
				var mirror_pos = {
					"x": -normal_pos.x - 1,
					"y": normal_pos.y
				}
				
				# Only add if it doesn't overlap an existing block
				if not is_occupied(CENTER_X + mirror_pos.x, CENTER_Y + mirror_pos.y):
					cluster.append(mirror_pos)

	shake_intensity = 10.0
	falling_piece = null
	sequence_index += 1
	
	check_victory()
	spawn_piece()
