@tool

class_name Wheel
extends Control

## The overall size of the wheel
@export var outer_radius := 250
## The size of the inner ring of the wheel
@export var inner_radius := 75

## The width of the lines
@export var line_width := 4

## The background colour of the wheel
@export var background_colour := Color.DIM_GRAY
## The foreground colour of the wheel.
## Used for the lines.
@export var foreground_colour := Color.GRAY
## Colour to use when highlighting selection
@export var highlight_colour := Color.LIGHT_SLATE_GRAY

## The options available on the wheel
@export var options : Array[WheelOption]

var selected: int

func _draw() -> void:
	# Set up the circles
	draw_circle(Vector2.ZERO, outer_radius, background_colour)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 100, foreground_colour, line_width)
	draw_arc(Vector2.ZERO, outer_radius, 0, TAU, 100, foreground_colour, line_width)
	
	# If there are no options, bail out
	if !options:
		return
	
	if selected == 0:
		draw_circle(Vector2.ZERO, inner_radius, highlight_colour)
		
	# Draw the first option in the center
	draw_option(options[0], Vector2.ZERO)
	
	var option_radius = (outer_radius + inner_radius)/2.0
	
	# Special case for when there's only one option on the outside of the wheel
	if options.size() == 2:
		if selected == 2:
			draw_highlight_slice(0, TAU)
		draw_option(options[1], option_radius * Vector2.UP)
	else:
		# Draw the lines and options around the circle
		var slice_angle := -TAU/(options.size() - 1)
		
		for i in options.size() - 1:
			if selected == i + 1:
				draw_highlight_slice(i * slice_angle, (i+1) * slice_angle)
		
			var line_vector := Vector2.from_angle(i * slice_angle)
			var option_vector := Vector2.from_angle((i + 0.5) * slice_angle)

			draw_line(inner_radius * line_vector, outer_radius * line_vector, foreground_colour, line_width)
			draw_option(options[i + 1],  option_radius * option_vector)


func draw_highlight_slice(start: float, end: float) -> void:
	var thickness := outer_radius - inner_radius
	var radius := (outer_radius + inner_radius)/2.0
	draw_arc(Vector2.ZERO, radius, start, end, 50, highlight_colour, thickness)

# Just doing this because the artwork I used is small
const ICON_SCALE = 2.0

func get_option() -> WheelOption:
	return options[selected]

## Draw a single option at this position.
## This implementation uses a AtlasTexture
func draw_option(option: WheelOption, pos: Vector2) -> void:
	draw_set_transform(Vector2.ZERO, 0, ICON_SCALE * Vector2.ONE)
	var bounds := Rect2(pos/ICON_SCALE + WheelOption.SIZE/-2, WheelOption.SIZE)
	draw_texture_rect_region(option.atlas, bounds, option.region)
	draw_set_transform(Vector2.ZERO)
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length() 
	
	var previous_selected = selected
	
	if mouse_radius < inner_radius:
		selected = 0
	elif mouse_radius < outer_radius:
		var mouse_angle = fposmod(mouse_pos.angle() * -1, TAU)
		var slice_angle = TAU/(options.size() - 1)
		selected = ceil(mouse_angle/slice_angle)
		
	#print(selected)
	
	if selected != previous_selected:
		queue_redraw()
