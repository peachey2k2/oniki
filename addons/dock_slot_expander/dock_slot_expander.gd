@tool
extends EditorPlugin

var use_ctrl_space := true
var use_middle_mouse_click := true

var _dock_slot_wrappers : Array[DockSlotWrapper]
var _columns : Array[Node]
var _expanded_dock_slot : TabContainer


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	
	_fetch_dock_slots()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		return
	
	_reset_dock_slots()


func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		return
	
	if use_ctrl_space and event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and event.ctrl_pressed:
			var dock_slot := _get_dock_slot_at_position(get_viewport().get_mouse_position())
			_toggle_dock_slot(dock_slot, event)
			return
		
	if use_middle_mouse_click and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed and not event.ctrl_pressed:
			var dock_slot := _get_dock_slot_at_position(get_viewport().get_mouse_position())
			_toggle_dock_slot(dock_slot, event)
			return


func _toggle_dock_slot(dock_slot : TabContainer, event : InputEvent) -> void:
	# if no dock to toggle
	if not dock_slot:
		# we dont want the dock group to retract when user moving or pivoting in the scene view
		if event and not event is InputEventMouseButton:
			_reset_dock_slots()
		return
	
	# if no dock selected before this, expanding toggled dock
	if not _expanded_dock_slot:
		_expand_dock_slot(dock_slot)
		return
	
	# if dock toggled is same as currently expanded one, reset
	if _expanded_dock_slot and dock_slot == _expanded_dock_slot:
		_reset_dock_slots()
		return
	
	# if different dock toggled than one currently expanded, reset then expand new one
	if _expanded_dock_slot and not dock_slot == _expanded_dock_slot:
		_reset_dock_slots()
		_expand_dock_slot(dock_slot)
		return


# hides vertical neighbor and opposing column of dock slot
func _expand_dock_slot(dock_slot : TabContainer) -> void:
	_expanded_dock_slot = dock_slot
	
	var dock_slot_wrapper := _find_wrapper_for_dock_slot(dock_slot)
	if dock_slot_wrapper.opposing_column:
		dock_slot_wrapper.opposing_column.hide()
	if dock_slot_wrapper.vertical_neighbor:
		dock_slot_wrapper.vertical_neighbor.hide()


# resets visibility of slots/columns to what it should be depending on content
func _reset_dock_slots() -> void:
	_expanded_dock_slot = null
	
	for col in _columns:
		var at_least_one_dock_found := false
		for dock_slot in col.get_children():
			if dock_slot is TabContainer:
				if dock_slot.get_child_count() > 0:
					at_least_one_dock_found = true
					dock_slot.show()
				else:
					dock_slot.hide()
		col.visible = at_least_one_dock_found


# call expand or reset depending on state of _expanded_dock_slot
# this plugin is literally fighting with the editor for dock control
func _refresh() -> void:
	if _expanded_dock_slot:
		_expand_dock_slot(_expanded_dock_slot)
	else:
		_reset_dock_slots()


func _fetch_dock_slots() -> void:
	# find dock slots
	for dock_slot_index in DOCK_SLOT_MAX:
		var dummy_control := Control.new()
		add_control_to_dock(dock_slot_index, dummy_control)
		
		var dock_slot := dummy_control.get_parent()
		if dock_slot is TabContainer:
			
			# create wrapper for it with reference to parent column (vsplit)
			var wrapper : DockSlotWrapper = DockSlotWrapper.new(dock_slot)
			wrapper.column = dock_slot.get_parent()
			_dock_slot_wrappers.append(wrapper)
			
			# add column to array
			if not _columns.has(wrapper.column):
				_columns.append(wrapper.column)
				wrapper.column.child_order_changed.connect(_refresh)
				
			# signals that trigger a refresh
			dock_slot.active_tab_rearranged.connect(_refresh.unbind(1))
			dock_slot.tab_changed.connect(_refresh.unbind(1))
		
		remove_control_from_docks(dummy_control)
		dummy_control.free()
	
	# assign opposing column (the vsplit to hide when that slot is expanded)
	_dock_slot_wrappers[DOCK_SLOT_LEFT_UL].opposing_column = _dock_slot_wrappers[DOCK_SLOT_LEFT_UR].column
	_dock_slot_wrappers[DOCK_SLOT_LEFT_BL].opposing_column = _dock_slot_wrappers[DOCK_SLOT_LEFT_BR].column
	_dock_slot_wrappers[DOCK_SLOT_LEFT_UR].opposing_column = _dock_slot_wrappers[DOCK_SLOT_LEFT_UL].column
	_dock_slot_wrappers[DOCK_SLOT_LEFT_BR].opposing_column = _dock_slot_wrappers[DOCK_SLOT_LEFT_BL].column
	_dock_slot_wrappers[DOCK_SLOT_RIGHT_UL].opposing_column = _dock_slot_wrappers[DOCK_SLOT_RIGHT_UR].column
	_dock_slot_wrappers[DOCK_SLOT_RIGHT_BL].opposing_column = _dock_slot_wrappers[DOCK_SLOT_RIGHT_BR].column
	_dock_slot_wrappers[DOCK_SLOT_RIGHT_UR].opposing_column = _dock_slot_wrappers[DOCK_SLOT_RIGHT_UL].column
	_dock_slot_wrappers[DOCK_SLOT_RIGHT_BR].opposing_column = _dock_slot_wrappers[DOCK_SLOT_RIGHT_BL].column
	
	# assign neighbor
	for d in _dock_slot_wrappers:
		var neighbors := d.dock_slot.get_parent().get_children()
		neighbors.erase(d.dock_slot)
		var neighbor : TabContainer
		for n in neighbors:
			if n is TabContainer:
				neighbor = n
		if neighbor:
			d.vertical_neighbor = neighbor


func _find_wrapper_for_dock_slot(dock_slot : TabContainer) -> DockSlotWrapper:
	if not dock_slot:
		return null
	
	for dock_slot_wrapper in _dock_slot_wrappers:
		if dock_slot_wrapper.dock_slot == dock_slot:
			return dock_slot_wrapper
	return null


func _get_dock_slot_at_position(pos : Vector2) -> TabContainer:
	var dock_slot : TabContainer
	
	for d in _dock_slot_wrappers:
		if d.dock_slot.get_global_rect().has_point(pos) and d.dock_slot.is_visible_in_tree():
			return d.dock_slot
	return null


class DockSlotWrapper:
	var dock_slot : TabContainer
	var vertical_neighbor : TabContainer
	var column : Node
	var opposing_column : Node
	
	func _init(p_node_reference : TabContainer = null) -> void:
		dock_slot = p_node_reference
