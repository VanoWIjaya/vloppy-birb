extends Node2D

enum GameState {
	READY,
	PLAY,
	GAME_OVER
}

const PIPE_SCENE: PackedScene = preload("res://scene/pipe.tscn")
const SAVE_PATH: String = "user://vloppy_birb.cfg"

const PIPE_INTERVAL: float = 1.5
const PIPE_SPEED: float = 150.0
const BASE_SPEED: float = 100.0

@onready var bird: Bird = $Bird
@onready var pipe: Node2D = $Pipes
@onready var pipeTimer: Timer = $TimerPipa
@onready var ground: Node2D = $Ground
@onready var hud: HUDController = $HUD
@onready var pointAudio :AudioStreamPlayer = $PointAudio
@onready var hitAudio :AudioStreamPlayer = $HitAudio
@onready var swooshAudio :AudioStreamPlayer = $SwooshAudio

var gameState: GameState = GameState.READY

var score: int = 0
var best_score: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	bird.hit.connect(_on_bird_hit)
	pipeTimer.timeout.connect(_spawn_pipe)
	
	hud.play_pressed.connect(_start_game)
	hud.restart_pressed.connect(_start_game)
	hud.menu_pressed.connect(_return_to_menu)
	
	_load_best_score()
	
	bird.reset_bird()
	hud.show_ready(best_score)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("flap"):
		return
		
	if event is InputEventKey and event.echo:
		return
	
	if gameState == GameState.READY:
		_start_game()
		
	elif gameState == GameState.PLAY:
		bird.flap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if gameState != GameState.PLAY:
		return
		
	for tile in ground.get_children():
		tile.position.x -= BASE_SPEED * delta
		
		if tile.position.x <= -500:
			tile.position.x += 3955
	#if bird.global_position.y < -25.0:
		#_end_game()
	#elif bird.position.y > 430.0:
		#_end_game()

func _on_bird_hit() -> void:
	_end_game()

func _start_game() -> void:
	if gameState == GameState.PLAY:
		return
		
	bird.reset_bird()
	_clear_pipes()
	
	score = 0
	hud.set_score(score)
	
	$Ground/BaseLeft.position.x = 432.0
	$Ground/BaseCenterLeft.position.x = 1440.0
	$Ground/BaseCenterRight.position.x = 2447.0
	$Ground/BaseRight.position.x = 3455.0
	
	bird.start_flight()
	
	gameState = GameState.PLAY
	hud.show_playing()
	
	pipeTimer.start(PIPE_INTERVAL)
	
	swooshAudio.play()
	bird.flap()

func _end_game() -> void:
	if gameState != GameState.PLAY:
		return
	
	hitAudio.play()
	gameState = GameState.GAME_OVER
	var isNewBest: bool = score > best_score
	
	
	pipeTimer.stop()

	for pipes in pipe.get_children():
		pipes.set_physics_process(false)
		
	if score > best_score:
		best_score = score
		_save_best_score()
		
	hud.show_game_over(score, best_score, isNewBest)

func _spawn_pipe() -> void:
	if gameState != GameState.PLAY:
		return
	
	var pipes := PIPE_SCENE.instantiate() as PipeController
	
	pipes.position = Vector2(
		288.0 - 144.0 + 70.0,
		randf_range(-60.0, 60.0)
	)
	
	pipe.add_child(pipes)
	
	pipes.speed = PIPE_SPEED
	pipes.scored.connect(_on_pipe_scored)

func _return_to_menu() -> void:
	pipeTimer.stop()
	_clear_pipes()
	
	gameState = GameState.READY
	
	bird.reset_bird()
	hud.show_ready(best_score)

func _save_best_score() -> void:
	var config := ConfigFile.new()
	
	config.set_value("score", "best", best_score)
	
	var error := config.save(SAVE_PATH)
	
	if error != OK:
		push_warning("Best score gagal disimpan.")

func _load_best_score() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	
	if error == OK:
		best_score = int(
			config.get_value("score", "best", 0)
		)

func _clear_pipes() -> void:
	for pipes in pipe.get_children():
		pipes.queue_free()

func _on_pipe_scored() -> void:
	if gameState != GameState.PLAY:
		return
		
	score += 1
	pointAudio.play()
	hud.set_score(score)
