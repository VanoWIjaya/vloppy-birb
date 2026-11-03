class_name HUDController
extends CanvasLayer

signal play_pressed
signal restart_pressed
signal menu_pressed
signal quit_pressed

@onready var scoreLabel: Node2D = $ScoreDigits
@onready var readyImage: TextureRect = $ReadyImage
@onready var playButton: Button = $PlayButton
@onready var gameOverImages: TextureRect = $GameOverScreen
@onready var finalScoreLabel: Label = $FinalScoreLabel
@onready var bestScoreLabel: Label = $BestScoreLabel
@onready var restartButton: Button = $RestartButton
@onready var menuButton: Button = $MenuButton
@onready var newHighSCore: Label = $NewHighScore
@onready var quitButton: Button = $QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playButton.pressed.connect(_on_play_pressed)
	restartButton.pressed.connect(_on_restart_pressed)
	menuButton.pressed.connect(_on_menu_pressed)
	quitButton.pressed.connect(_on_quit_pressed)
	
	show_ready(0)

func set_score(value: int) -> void:
	#scoreLabel.text = str(value)
	for child in scoreLabel.get_children():
		scoreLabel.remove_child(child)
		child.queue_free()
	
	var score_text: String = str(value)
	
	var digit_width: float = 24.0
	var spacing: float = 2.0
	
	var total_width: float =  (
		score_text.length() * digit_width + 
		(score_text.length() - 1) * spacing
	)
	
	for i in range(score_text.length()):
		var digit := Sprite2D.new()
		
		var digit_path: String = (
			"res://assets/UI/Numbers/%s.png"
			% score_text.substr(i, 1)
		)
		
		digit.texture = load(digit_path) as Texture2D
		
		digit.position.x = (
			-total_width / 2.0
			+ digit_width / 2.0
			+ i * (digit_width + spacing)
		)
		
		scoreLabel.add_child(digit)

func show_ready(bestScore: int) -> void:
	scoreLabel.hide()
	readyImage.show()
	playButton.show()
	quitButton.show()
	
	gameOverImages.hide()
	finalScoreLabel.hide()
	restartButton.hide()
	menuButton.hide()
	newHighSCore.hide()
	
	bestScoreLabel.visible = bestScore > 0
	bestScoreLabel.text = "Best Score: %d" % bestScore

func show_playing() -> void:
	scoreLabel.show()
	readyImage.hide()
	playButton.hide()
	quitButton.hide()
	
	gameOverImages.hide()
	finalScoreLabel.hide()
	restartButton.hide()
	menuButton.hide()
	newHighSCore.hide()
	
	bestScoreLabel.hide()

func show_game_over(finalScore: int, bestScore: int, newBestScore: bool) -> void:
	if newBestScore:
		bestScore = finalScore
		newHighSCore.show()
		
	scoreLabel.hide()
	readyImage.hide()
	playButton.hide()
	quitButton.hide()
	
	gameOverImages.show()
	finalScoreLabel.show()
	restartButton.show()
	menuButton.show()
	
	finalScoreLabel.text = "Score: %d" % finalScore
	bestScoreLabel.text = "Best Score: %d" % bestScore
	bestScoreLabel.show()

func _on_play_pressed() -> void:
	play_pressed.emit()

func _on_menu_pressed() -> void:
	menu_pressed.emit()

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()
