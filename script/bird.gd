
class_name Bird
extends CharacterBody2D

signal hit

enum BirdState {
	IDLE,
	FLYING,
	FALLING,
	LANDED
}

const FLAP_SPEED := 400.0
const FALL_SPEED := 100.0
const MAX_FALL_SPEED := 900.0

@export var rotation_speed: float = 5.0
@export var min_rotation_deg: float = -30.0
@export var max_rotation_deg: float = 90.0

@onready var bird: AnimatedSprite2D = $AnimatedSprite2D
@onready var wing_audio: AudioStreamPlayer = $WingAudio

var state: BirdState = BirdState.IDLE

func _ready() -> void:
	reset_bird()

func _physics_process(delta: float) -> void:
	# Bird tidak bergerak ketika IDLE atau sudah LANDED.
	if state == BirdState.IDLE or state == BirdState.LANDED:
		return

	# Gravitasi tetap berlaku ketika FLYING maupun FALLING.
	velocity += get_gravity() * delta

	# Batasi kecepatan jatuh ketika Game Over.
	if state == BirdState.FALLING:
		velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Gerakkan Bird sekaligus tangani collision.
	move_and_slide()

	# Periksa apakah Bird menabrak sesuatu saat masih bermain.
	if state == BirdState.FLYING:
		if get_slide_collision_count() > 0:
			_handle_hit()

	# Periksa apakah Bird sudah menyentuh lantai.
	if state == BirdState.FALLING and is_on_floor():
		_land()
		return

	# Atur rotasi sesuai kondisi Bird.
	_update_rotation(delta)


func _update_rotation(delta: float) -> void:
	var target_rotation: float

	if state == BirdState.FALLING:
		# Bird menukik tajam ke bawah.
		target_rotation = 90.0

	elif velocity.y < 0.0:
		# Bird sedang terbang ke atas.
		target_rotation = min_rotation_deg

	else:
		# Bird sedang jatuh normal.
		target_rotation = clampf(
			velocity.y * 0.25,
			min_rotation_deg,
			max_rotation_deg
		)
		bird.stop()

	rotation_degrees = move_toward(
		rotation_degrees,
		target_rotation,
		rad_to_deg(rotation_speed) * delta
	)

func begin_game_over_fall() -> void:
	if state == BirdState.FALLING or state == BirdState.LANDED:
		return
	state = BirdState.FALLING

	# Hentikan gerakan horizontal.
	velocity.x = 0.0

	# Paksa Bird menukik ke bawah.
	velocity.y = FALL_SPEED

	# Hentikan animasi sayap.
	bird.stop()

func _land() -> void:
	state = BirdState.LANDED
	# Hentikan seluruh gerakan.
	velocity = Vector2.ZERO
	# Normalisasi rotasi Bird.
	rotation_degrees = 0.0
	# Pastikan animasi berhenti.
	bird.stop()

func _handle_hit() -> void:
	if state != BirdState.FLYING:
		return

	begin_game_over_fall()
	bird.stop()

	hit.emit()


func reset_bird() -> void:
	state = BirdState.IDLE
	var posisi = get_viewport().get_visible_rect().size / 2
	
	global_position = posisi
	velocity = Vector2.ZERO
	rotation_degrees = 0.0

	bird.stop()


func start_flight() -> void:
	state = BirdState.FLYING
	velocity = Vector2.ZERO


func flap() -> void:
	if state != BirdState.FLYING:
		return

	rotation_degrees = min_rotation_deg

	velocity.y = -FLAP_SPEED

	bird.play()
	wing_audio.play()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	hit.emit()
