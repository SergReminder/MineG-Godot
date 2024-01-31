extends RigidBody3D
var axis = Vector3(1, 0, 0)
var ycorr := 1.0000
var ang = 0.75
@onready var camera = $Camera3D
@onready var cur = $Camera3D/RayCast3D
@onready var out = $"../MeshInstance3D"
@onready var rt = $"../CanvasLayer/Control/TextEdit"
@onready var gt = $"../CanvasLayer/Control/TextEdit2"
@onready var bt = $"../CanvasLayer/Control/TextEdit3"
var colork = Vector3(255,255,255)
var focus = true
var ff = 0
var fy = 0
var colors = [[1,1,1],[1,0,0],[0,1,0]]
var gestureo = Vector2(0,0)
@onready var sensw = $"../CanvasLayer/Control/SensW"
@onready var senss = $"../CanvasLayer/Control/SensS"
@onready var sensa = $"../CanvasLayer/Control/SensA"
@onready var sensd = $"../CanvasLayer/Control/SensD"
@onready var sensshift = $"../CanvasLayer/Control/SensShift"
@onready var sensspace = $"../CanvasLayer/Control/SensSpace"

func _physics_process(delta):
	if Input.is_action_pressed("forw"):
		linear_velocity += basis.x * 30 * delta
	if Input.is_action_pressed("back"):
		linear_velocity += basis.x * -30 * delta
	if Input.is_action_pressed("right"):
		linear_velocity += basis.z * 30 * delta
	if Input.is_action_pressed("left"):
		linear_velocity += basis.z * -30 * delta
	if Input.is_action_pressed("fup"):
		linear_velocity.y += 30 * delta
	if Input.is_action_pressed("fdown"):
		linear_velocity.y += -30 * delta

	ycorr = rotation_degrees.y / 90
	rotate_object_local(Vector3(0, 1, 0), - ff * 0.002)
	camera.rotate_object_local(axis, -fy * 0.002)
	if camera.rotation_degrees.x >= 85.000:
		camera.rotation_degrees.x = 85
	if camera.rotation_degrees.x <= -85.000:
		camera.rotation_degrees.x = -85
	ff = 0
	fy = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_block(colork, 1, 1, 1)

func _process(delta):
	var obj = cur.get_collider()
	if rt.get_line(0) != "":
		colork.x = str_to_var(rt.get_line(0))
	if gt.get_line(0) != '':
		colork.y = str_to_var(gt.get_line(0))
	if bt.get_line(0) != '':
		colork.z = str_to_var(bt.get_line(0))
	out.visible = true
	var coef = Vector3(0.5,0.5,0)
	if obj != null:
		var corr = Vector3(0,0,0)
		var lpos = camera.global_position - obj.global_position
		var corrpos = round(lpos/0.5)*0.5
		print(corrpos)
		if lpos.x > ang:
			corr.x = 0.5
		if lpos.x < -ang:
			corr.x = -0.5
			
		if lpos.z > ang:
			corr.z = 0.5
		if lpos.z < -ang:
			corr.z = -0.5
		
		if lpos.y > 0.5:
			corr.y = 0.5
		if lpos.y < -0.5:
			corr.y = -0.5
		out.position = Vector3((obj.position.x + corr.x),obj.position.y + corr.y,obj.position.z + corr.z)
		var checker = [sensw.is_pressed(), senss.is_pressed(), sensa.is_pressed(),sensd.is_pressed(), sensspace.is_pressed(), sensshift.is_pressed()]
		var check = false
		if checker[0] == true or checker[1] == true or checker[2] == true or checker[3] == true or checker[4] == true or checker[5] == true:
			check = true
		if Input.is_action_just_pressed("place") and check != true:
			_block(colork, obj.position.x + corr.x, obj.position.y + corr.y, obj.position.z + corr.z)
		if Input.is_action_just_pressed("destroy"):
			obj.free()
	else:
		out.visible = false
	
	if Input.is_action_just_pressed("focus"):
		if focus == true:
			Input.set_mouse_mode(0)
			focus = false
			rt.focus_mode = true
			bt.focus_mode = true
			gt.focus_mode = true
		else:
			focus = true
			Input.set_mouse_mode(2)
			rt.focus_mode = false
			bt.focus_mode = false
			gt.focus_mode = false
func _input(event):
	if event is InputEventMouseMotion and focus == true:
		ff = event.relative.x
		fy = event.relative.y

func _block(color, posx, posy, posz):
	var block = RigidBody3D.new()
	block.freeze = true
	$"..".add_child.call_deferred(block)
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.5,0.5,0.5)
	var box = MeshInstance3D.new()
	box.mesh = mesh
	block.add_child(box)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(color.x/255, color.y/255, color.z/255)
	box.material_override = material
	
	var hitbox = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.5,0.5,0.5)
	hitbox.shape = shape
	block.add_child(hitbox)
	block.position = Vector3(posx, posy, posz)

func rp(num,places):
	return (round(num*pow(10,places))/pow(10,places))
