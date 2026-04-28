INTERACTION PIPELINE

IMPORTANT: 
	- interaction_zones and validations follow 16px-tile logic
	- GridObjects subdivide donward into interaction cell space
	- interaction validation uses interaction_zone (tile occupancy)

NOTES:
	- Player detects proximity targets and registers them to TargetingSystem
	- TargetingSystem dependencies: TargetResolver, InteractionTargetBuilder
	- InteractionSystem dependencies: TargetingSystem, InteractionEvaluator
	- Interaction behavior and validity is known and queried from object
	
PHASES

1. Acquisition
	- TargetingSystem gathers candidates

2. Resolution
	- TargetResolver selects best target

3. Packaging
	- InteractionTargetBuilder normalizes target data

4. Validation
	- InteractionEvaluator validates request + target

5. Execution
	- InteractionSystem executes interaction
	
INTERACTABLES
	- make sure every interactable object has the following methods:
		- get_interaction_zone
		- can_accept_item
		- get_interaction_score
		- is_currently_interactable
		- interact

CURRENT ASSUMPTIONS:
	- interaction happens immediately after validation
	- target lookup occurs at request handling time
	- proximity interactions do not use range validation
	
FUTURE PLANS
	- Add InteractionExecutor when execution is eventually needed
	- Let player send resolved target in request instead of InteractionSystem fetching it
	- Player MIGHT need normalized world_pos to 16px grid
