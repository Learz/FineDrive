extends HBoxContainer
tool

export (String) onready var prompt setget set_prompt
export (Texture) onready var glyph_xbox setget set_xbox_glyph
export (Texture) onready var glyph_pc setget set_pc_glyph

func set_glyph_mode(var mode):
	match mode:
		0:
			$PromptGlyphPC.visible = false
			$PromptGlyphXbox.visible = true
		1:
			$PromptGlyphPC.visible = true
			$PromptGlyphXbox.visible = false

func set_pc_glyph(val):
	glyph_pc = val
	$PromptGlyphPC.texture = glyph_pc

func set_xbox_glyph(val):
	glyph_xbox = val
	$PromptGlyphXbox.texture = glyph_xbox
	
func set_prompt(val):
	prompt = val
	$PromptName.text = prompt
