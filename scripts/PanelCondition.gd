class_name PanelCondition
extends RefCounted
enum Type { HAS_ROLE, HAS_ITEM, HAS_ROLE_AND_CHAR_HOLDS }
var type: Type
var role: String = ""
var item: String = ""
# When set, the matching character must have this exact item_id (e.g. "megan").
var character: String = ""

static func has_role(r: String, char_id: String = "") -> PanelCondition:
	var c := PanelCondition.new()
	c.type = Type.HAS_ROLE
	c.role = r
	c.character = char_id
	return c

static func has_item(i: String) -> PanelCondition:
	var c := PanelCondition.new()
	c.type = Type.HAS_ITEM
	c.item = i
	return c

static func has_role_and_char_holds(r: String, i: String, char_id: String = "") -> PanelCondition:
	var c := PanelCondition.new()
	c.type = Type.HAS_ROLE_AND_CHAR_HOLDS
	c.role = r
	c.item = i
	c.character = char_id
	return c
