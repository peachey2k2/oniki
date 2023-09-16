@tool
class_name STGPackedBulletContainer extends PackedDataContainer

@export var outer_texture:Texture2D ## Texture to be used for the lower layer of the bullet. Bullets have 2 layers of textures since that looks way cooler and doesn't impact the performance that much. 
@export var inner_texture:Texture2D ## Texture to be used for the higher layer of the bullet. Bullets have 2 layers of textures since that looks way cooler and doesn't impact the performance that much. 
@export var outer_scale:float ## Scale value of the outer texture. I know. Very descriptive.
@export var inner_scale:float ## Scale value of the inner texture. I know. Very descriptive.
@export var collision:Shape2D ## The collision box of the bullet.
@export var pool_size:int = 500 ## 
