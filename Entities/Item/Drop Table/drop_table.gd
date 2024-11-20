extends Resource

class_name DropTable

enum Rarity { COMMON, RARE, ULTRA_RARE, UNIQUE }

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var common_chance: float = 0.6
@export var rare_chance: float = 0.25
@export var ultra_rare_chance: float = 0.1
@export var unique_chance: float = 0.05

@export var common_drops: CommonDrops
@export var rare_drops: RareDrops
@export var ultra_rare_drops: UltraRareDrops
@export var unique_drops: UniqueDrops

# Dictionaries for items by rarity and probabilities
var items_by_rarity: Dictionary = {}
var rarity_probabilities: Dictionary = {}

func setup() -> void:
	# Dictionary to map rarity to its corresponding drop resource and probability
	var drop_resources: Dictionary = {
		Rarity.COMMON: [common_drops, common_chance],
		Rarity.RARE: [rare_drops, rare_chance],
		Rarity.ULTRA_RARE: [ultra_rare_drops, ultra_rare_chance],
		Rarity.UNIQUE: [unique_drops, unique_chance]
	}

	# Iterate over the dictionary to initialize items_by_rarity and rarity_probabilities
	for rarity: int in drop_resources.keys():
		var drops_resource: Resource = drop_resources[rarity][0] as Resource
		var chance: float = drop_resources[rarity][1] as float
		if drops_resource:
			items_by_rarity[rarity] = drops_resource.slot_datas
			rarity_probabilities[rarity] = chance

	# Normalize probabilities (optional but recommended)
	_normalize_probabilities()

# Adds an item to the list of a given rarity
func add_item(item: SlotData, rarity: int) -> void:
	if items_by_rarity.has(rarity):
		items_by_rarity[rarity].append(item)
	else:
		push_error("Invalid rarity specified")

# Normalizes the rarity probabilities to sum to 1.0
func _normalize_probabilities() -> void:
	var total: float = common_chance + rare_chance + ultra_rare_chance + unique_chance
	for rarity: int in rarity_probabilities.keys():
		rarity_probabilities[rarity] /= total

# Private function to get a random rarity based on probabilities
func _get_random_rarity() -> int:
	var roll: float = rng.randf()
	var cumulative: float = 0.0
	for rarity: int in rarity_probabilities.keys():
		cumulative += rarity_probabilities[rarity]
		if roll < cumulative:
			return rarity
	return Rarity.COMMON  # Fallback to common if none selected

func get_random_drop() -> SlotData:
	# Get a random rarity based on probabilities
	var rarity: int = _get_random_rarity()
	#print("Selected rarity:", rarity)  # For debugging

	# Check if there are items in the initially selected rarity
	if items_by_rarity.has(rarity) and items_by_rarity[rarity].size() > 0:
		var drops: Array = items_by_rarity[rarity]
		return drops[rng.randi_range(0, drops.size() - 1)]

	# Define a fallback order for rarities: Unique, Ultra Rare, Rare, Common
	var fallback_rarities: Array = []
	match rarity:
		Rarity.UNIQUE:
			fallback_rarities = [Rarity.ULTRA_RARE, Rarity.RARE, Rarity.COMMON]
		Rarity.ULTRA_RARE:
			fallback_rarities = [Rarity.RARE, Rarity.COMMON]
		Rarity.RARE:
			fallback_rarities = [Rarity.COMMON]
		Rarity.COMMON:
			# No fallback if COMMON is selected since it's the lowest rarity
			return null  # No items available

	# Look for the first rarity with available items in fallback rarities
	for current_rarity: int in fallback_rarities:
		if items_by_rarity.has(current_rarity) and items_by_rarity[current_rarity].size() > 0:
			var drops: Array = items_by_rarity[current_rarity]
			return drops[rng.randi_range(0, drops.size() - 1)]

	# If no items are found in any rarity, return null and push an error
	push_error("No items available in the specified rarities")
	return null

func simulate_drops(num_drops: int = 1000) -> void:
	var drop_counts: Dictionary = {
		Rarity.COMMON: 0,
		Rarity.RARE: 0,
		Rarity.ULTRA_RARE: 0,
		Rarity.UNIQUE: 0
	}

	for i in range(num_drops):
		var dropped_item: SlotData = get_random_drop()
		if dropped_item:
			# Check the rarity based on the drop's source in items_by_rarity
			for rarity: int in items_by_rarity.keys():
				if dropped_item in items_by_rarity[rarity]:
					drop_counts[rarity] += 1
					break  # Exit once the rarity is found

	print("Drop simulation results after ", num_drops, " drops:")
	print("Common drops: ", drop_counts[Rarity.COMMON])
	print("Rare drops: ", drop_counts[Rarity.RARE])
	print("Ultra rare drops: ", drop_counts[Rarity.ULTRA_RARE])
	print("Unique drops: ", drop_counts[Rarity.UNIQUE])
