@tool
extends Control


@export var title: String = 'Title':
	set(value):
		title = value
		if title_label:
			title_label.text = value
@export_multiline() var subtitle: String = 'Subtitle':
	set(value):
		subtitle = value
		if subtitle_label:
			subtitle_label.text = value

@onready var title_label: Label = %Title
@onready var subtitle_label: Label = %Subtitle
