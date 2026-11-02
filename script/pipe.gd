class_name PipeController
extends Node2D

signal scored

@export var speed: float = 150.0

var score_claimed: bool = false

func _ready() -> void:
	$ScoreArea.body_entered.connect(_on_score_area_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	
	if position.x < -180:
		queue_free()

func _on_score_area_body_entered(body: Node2D) -> void:
	if not (body is Bird):
		return
		
	if score_claimed: 
		return
		
	score_claimed = true
	scored.emit()
