local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- ============================================================
-- API CONFIGURATION – Set to your endpoint
-- ============================================================
local API_CONFIG = {
    Enabled = true,   -- Upload scripts to API
    Endpoint = "https://api-c15.pages.dev/api/v2/",
    Key = "",         -- No key needed
    Field = "content",
    ResponseField = "url",
    ExpiryDays = 30,  -- You can change to 7 or any other
}
-- ============================================================

-- Skip these properties because they are read-only, irrelevant, or handled manually
local SkipProperties = {
	Parent = true, ClassName = true, DataCost = true, RobloxLocked = true,
	Archivable = true, Changed = true, AncestryChanged = true,
	ChildAdded = true, ChildRemoved = true, DescendantAdded = true,
	DescendantRemoving = true, AttributeChanged = true,
	AbsolutePosition = true, AbsoluteSize = true, AbsoluteRotation = true,
	AbsoluteContentSize = true, TotalGroupStride = true, CanvasAbsoluteSize = true,
	ContentText = true, TextBounds = true, TextFits = true,
	LocalTransparencyModifier = true, ReceiveAge = true,
	AssemblyAngularVelocity = true, AssemblyLinearVelocity = true,
	AssemblyCenterOfMass = true, AssemblyMass = true, AssemblyRootPart = true,
	RootPriority = true, Mass = true, IsLoaded = true,
	PlaybackLoudness = true, IsPaused = true, IsPlaying = true, TimeLength = true,
	UniqueId = true, HistoryId = true, InterpolationThrottling = true,
	FluidForces = true, SimulationRadius = true, StreamingRadius = true,
	IsReady = true, PeakLevel = true, RmsLevel = true, ActivePose = true,
	Health = true, Jump = true, Sit = true, TargetPoint = true,
	WalkToPoint = true, WalkToPart = true, MoveDirection = true,
	LookVector = true, RootPart = true, Torso = true,
	Velocity = true, RotVelocity = true, CoordinateFrame = true,
	WorldPivot = true, CameraOrigin = true, CameraOrientation = true,
	IsScriptable = true, RobloxOnly = true, DoubleClickEnabled = true,
	Expression = true, HideOffhandInventory = true, Internal = true,
	PreviousGuid = true, CurrentOffset = true, TargetOffset = true,
	Selected = true, RelativeSize = true, MappingPreset = true,
	DataSource = true, IsDragged = true, Dimensions = true,
	BackSurfaceInput = true, BottomSurfaceInput = true, FrontSurfaceInput = true,
	LeftSurfaceInput = true, RightSurfaceInput = true, TopSurfaceInput = true,
	Shiny = true, Specular = true, ShapeInOut = true, ShapePartial = true,
	ShapeRotation = true, ShapeStyle = true, CameraMode = true,
	DevCameraOcclusionMode = true, DevTouchCameraMovementMode = true,
	WorldPosition = true, WorldCFrame = true, WorldOrientation = true,
	WorldAxis = true, WorldSecondaryAxis = true,
}

-- Fallback properties for every class (ensures complete coverage)
local FallbackProperties = {
	Instance = { Name = "Instance", Archivable = true },
	BasePart = {
		Anchored = false, BackSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth, CFrame = CFrame.new(),
		CanCollide = true, CanQuery = true, CanTouch = true,
		CastShadow = true, CollisionGroup = "Default",
		Color = Color3.new(0.639216, 0.635294, 0.647059),
		CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.1, 0.1),
		EnableFluidForces = true, FrontSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth, Locked = false, Massless = false,
		Material = Enum.Material.SmoothPlastic, MaterialVariant = "",
		Orientation = Vector3.new(), PivotOffset = CFrame.new(),
		Position = Vector3.new(), Reflectance = 0,
		RightSurface = Enum.SurfaceType.Smooth, RootPriority = 0,
		Rotation = Vector3.new(), Size = Vector3.new(4, 1, 2),
		TopSurface = Enum.SurfaceType.Smooth, Transparency = 0,
	},
	Part = { Shape = Enum.PartType.Block },
	WedgePart = {}, CornerWedgePart = {}, TrussPart = {},
	SpawnLocation = {
		AllowTeamChangeOnTouch = false, Duration = 10, Enabled = true,
		Neutral = true, TeamColor = BrickColor.new("White"),
		Shape = Enum.PartType.Block,
	},
	Platform = {}, Seat = { Disabled = false, Occupant = nil },
	VehicleSeat = {
		Disabled = false, HeadsUpDisplay = true, MaxSpeed = 100,
		Steer = 0, SteerFloat = 0, Throttle = 0, ThrottleFloat = 0, TurnSpeed = 1,
	},
	MeshPart = {
		CollisionFidelity = Enum.CollisionFidelity.Default, DoubleSided = false,
		MeshId = "", MeshSize = Vector3.new(1, 1, 1),
		RenderFidelity = Enum.RenderFidelity.Automatic, TextureID = "",
	},
	PartOperation = {
		CollisionFidelity = Enum.CollisionFidelity.Default,
		RenderFidelity = Enum.RenderFidelity.Automatic,
		SmoothingAngle = 30, UsePartColor = false,
	},
	UnionOperation = {}, NegateOperation = {}, IntersectOperation = {},
	SpecialMesh = {
		MeshId = "", MeshType = Enum.MeshType.Head, Offset = Vector3.new(),
		RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1),
		TextureId = "", VertexColor = Vector3.new(1, 1, 1),
	},
	CylinderMesh = { Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1) },
	BlockMesh = { Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1) },
	FileMesh = {
		MeshId = "", Offset = Vector3.new(), Scale = Vector3.new(1, 1, 1),
		TextureId = "", VertexColor = Vector3.new(1, 1, 1),
	},
	Decal = {
		Color3 = Color3.new(1, 1, 1), Face = Enum.NormalId.Front,
		Texture = "", Transparency = 0, ZIndex = 0,
	},
	Texture = {
		Color3 = Color3.new(1, 1, 1), Face = Enum.NormalId.Front,
		OffsetStudsU = 0, OffsetStudsV = 0, StudsPerTileU = 2, StudsPerTileV = 2,
		Texture = "", Transparency = 0, ZIndex = 0,
	},
	SurfaceAppearance = {
		AlphaMode = Enum.AlphaMode.Overlay, Color = Color3.new(1, 1, 1),
		ColorMap = "", Metalness = 0, MetalnessMap = "", NormalMap = "",
		Roughness = 0.5, RoughnessMap = "", TexturePack = "",
	},
	Model = {
		LevelOfDetail = Enum.ModelLevelOfDetail.Disabled,
		ModelStreamingMode = Enum.ModelStreamingMode.Default,
		PrimaryPart = nil, WorldPivot = CFrame.new(),
	},
	Folder = {}, Tool = {
		CanBeDropped = true, Enabled = true, Grip = CFrame.new(),
		GripForward = Vector3.new(0, 0, -1), GripPos = Vector3.new(),
		GripRight = Vector3.new(1, 0, 0), GripUp = Vector3.new(0, 1, 0),
		ManualActivationOnly = false, RequiresHandle = true, ToolTip = "",
	},
	Backpack = {}, StarterPack = {}, StarterGear = {},
	Hat = {
		AttachmentForward = Vector3.new(0, 0, -1), AttachmentPos = Vector3.new(),
		AttachmentRight = Vector3.new(1, 0, 0), AttachmentUp = Vector3.new(0, 1, 0),
	},
	Accessory = { AccessoryType = Enum.AccessoryType.Hat, AttachmentPoint = CFrame.new() },
	Script = { Disabled = false, RunContext = Enum.RunContext.Legacy, Source = "" },
	LocalScript = { Disabled = false, Source = "" },
	ModuleScript = { Source = "" },
	StringValue = { Value = "" }, NumberValue = { Value = 0 },
	BoolValue = { Value = false }, IntValue = { Value = 0 },
	Vector3Value = { Value = Vector3.new() }, CFrameValue = { Value = CFrame.new() },
	ObjectValue = { Value = nil }, Color3Value = { Value = Color3.new() },
	BrickColorValue = { Value = BrickColor.new("Medium stone grey") },
	RayValue = { Value = Ray.new(Vector3.new(), Vector3.new()) },
	Animation = { AnimationId = "" }, Animator = {},
	AnimationController = {}, AnimationTrack = {},
	BodyColors = {
		HeadColor3 = Color3.fromRGB(163, 162, 165),
		LeftArmColor3 = Color3.fromRGB(163, 162, 165),
		LeftLegColor3 = Color3.fromRGB(163, 162, 165),
		RightArmColor3 = Color3.fromRGB(163, 162, 165),
		RightLegColor3 = Color3.fromRGB(163, 162, 165),
		TorsoColor3 = Color3.fromRGB(163, 162, 165),
	},
	CharacterMesh = { BaseTextureId = 0, MeshId = 0, OverlayTextureId = 0 },
	Pants = { PantsTemplate = "" }, Shirt = { ShirtTemplate = "" },
	ShirtGraphic = { Color3 = Color3.new(1, 1, 1), Graphic = "" },
	WrapLayer = {
		AutoSkin = Enum.WrapLayerAutoSkin.Disabled, BindOffset = CFrame.new(),
		Color = BrickColor.new("Bright blue"), DebugHeatmap = false,
		Enabled = true, InflateDelta = 0, Order = 0, Puffiness = 0,
		ReferenceMeshId = "", ReferenceOrigin = CFrame.new(), ShrinkDelta = 0,
	},
	WrapTarget = {
		CageMeshId = "", CageOrigin = CFrame.new(), Color = BrickColor.new("Bright blue"),
		DebugHeatmap = false, Enabled = true, Stiffness = 0,
	},
	IKControl = {
		ChainRoot = nil, Enabled = true, EndEffector = nil, Offset = CFrame.new(),
		Pole = nil, Priority = 0, SmoothTime = 0, Target = nil,
		Type = Enum.IKControlType.Transform, Weight = 1,
	},
	Sound = {
		EmitterSize = 10, Looped = false, MaxDistance = 10000, Playing = false,
		PlayOnRemove = false, PlaybackRegionsEnabled = false, PlaybackSpeed = 1,
		RollOffMaxDistance = 10000, RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered, SoundGroup = nil,
		SoundId = "", TimePosition = 0, Volume = 0.5,
	},
	SoundService = {
		AmbientReverb = Enum.ReverbType.NoReverb, DistanceFactor = 3.33,
		DopplerScale = 1, RespectFilteringEnabled = true,
		VolumetricAudio = Enum.VolumetricAudio.Disabled,
	},
	EqualizerSoundEffect = { HighGain = 0, LowGain = 0, MidGain = 0, Priority = 0 },
	ReverbSoundEffect = {
		DecayTime = 1.5, Density = 1, Diffusion = 1, DryLevel = -6,
		Priority = 0, WetLevel = 0,
	},
	ChorusSoundEffect = { Depth = 1, Mix = 50, Priority = 0, Rate = 0.45 },
	CompressorSoundEffect = {
		Attack = 0.003, GainMakeup = 0, Priority = 0, Release = 0.5,
		SideChain = nil, Threshold = -24,
	},
	DistortionSoundEffect = { Level = 0, Priority = 0 },
	EchoSoundEffect = { Delay = 1, DryLevel = 0, FeedBack = 0.5, Priority = 0, WetLevel = -6 },
	FlangeSoundEffect = { Depth = 45, Mix = 50, Priority = 0, Rate = 0.45 },
	PitchShiftSoundEffect = { Octave = 1, Priority = 0 },
	TremoloSoundEffect = { Depth = 1, Duty = 50, Frequency = 5, Priority = 0 },
	AudioPlayer = {
		AssetId = "", Looping = false, PlaybackRegionsEnabled = false,
		PlaybackSpeed = 1, TimePosition = 0, Volume = 1,
	},
	AudioEmitter = {}, AudioListener = {}, AudioAnalyzer = {},
	AudioChorus = { Bypass = false, Depth = 0.15, Mix = 0.5, Rate = 0.5 },
	AudioCompressor = {
		Attack = 0.05, Bypass = false, GainMakeup = 0, Ratio = 4,
		Release = 0.1, Threshold = -24,
	},
	AudioDistortion = { Bypass = false, Level = 0 },
	AudioEqualizer = { Bypass = false, HighGain = 0, LowGain = 0, MidGain = 0 },
	AudioFader = { Bypass = false, Volume = 1 },
	AudioFlanger = { Bypass = false, Depth = 45, Mix = 0.5, Rate = 0.5 },
	AudioPitchShifter = { Bypass = false, Octave = 1 },
	AudioReverb = {
		Bypass = false, DecayTime = 1.5, Density = 1, Diffusion = 1,
		DryLevel = 0, WetLevel = -6,
	},
	AudioTremolo = { Bypass = false, Depth = 1, Duty = 50, Frequency = 5 },
	AudioDeviceInput = { Active = false, Muted = false, Player = nil },
	AudioDeviceOutput = { Muted = false, Player = nil },
	Wire = {},
	Attachment = {
		Axis = Vector3.new(1, 0, 0), CFrame = CFrame.new(),
		Orientation = Vector3.new(), Position = Vector3.new(),
		SecondaryAxis = Vector3.new(0, 1, 0), Visible = false,
	},
	Bone = {
		CFrame = CFrame.new(), Orientation = Vector3.new(), Position = Vector3.new(),
		Transform = CFrame.new(),
	},
	Beam = {
		Attachment0 = nil, Attachment1 = nil, Brightness = 1,
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		CurveSize0 = 0, CurveSize1 = 0, Enabled = true, FaceCamera = false,
		LightEmission = 0, LightInfluence = 1, Segments = 10, Texture = "",
		TextureLength = 1, TextureMode = Enum.TextureMode.Stretch,
		TextureSpeed = 1, Transparency = NumberSequence.new(0),
		Width0 = 1, Width1 = 1, ZOffset = 0,
	},
	Trail = {
		Attachment0 = nil, Attachment1 = nil, Brightness = 1,
		Color = ColorSequence.new(Color3.new(1, 1, 1)), Enabled = true,
		FaceCamera = false, Lifetime = 2, LightEmission = 0, LightInfluence = 1,
		MaxLength = 0, MinLength = 0, Texture = "", TextureLength = 1,
		TextureMode = Enum.TextureMode.Stretch, Transparency = NumberSequence.new(0),
		WidthScale = NumberSequence.new(1),
	},
	ParticleEmitter = {
		Acceleration = Vector3.new(), Brightness = 1,
		Color = ColorSequence.new(Color3.new(1, 1, 1)), Drag = 0,
		EmissionDirection = Enum.NormalId.Top, Enabled = true,
		FlipbookFramerate = NumberRange.new(30), FlipbookIncompatible = "",
		FlipbookLayout = Enum.ParticleFlipbookLayout.None,
		FlipbookMode = Enum.ParticleFlipbookMode.Loop,
		LifeTime = NumberRange.new(5, 10), LightEmission = 0, LightInfluence = 1,
		LockedToPart = false, Orientation = Enum.ParticleOrientation.FacingCamera,
		Rate = 20, RotSpeed = NumberRange.new(0), Rotation = NumberRange.new(0),
		Size = NumberSequence.new(1), Speed = NumberRange.new(5),
		SpreadAngle = Vector2.new(), Squash = NumberSequence.new(0),
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		TimeScale = 1, Transparency = NumberSequence.new(0),
		VelocityInheritance = 0, ZOffset = 0,
	},
	Fire = {
		Color = Color3.fromRGB(255, 100, 0), Enabled = true, Heat = 9,
		SecondaryColor = Color3.fromRGB(255, 255, 0), Size = 5, TimeScale = 1,
	},
	Smoke = {
		Color = Color3.fromRGB(150, 150, 150), Enabled = true, Opacity = 0.5,
		RiseVelocity = 1, Size = 1, TimeScale = 1,
	},
	Sparkles = {
		Color = Color3.new(1, 1, 1), Enabled = true, SparkleColor = Color3.new(1, 1, 1),
		TimeScale = 1,
	},
	RopeConstraint = {
		Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
		Enabled = true, Length = 5, Restitution = 0, Thickness = 0.1, Visible = false,
	},
	SpringConstraint = {
		Attachment0 = nil, Attachment1 = nil, Coils = 5,
		Color = BrickColor.new("Bright blue"), Damping = 0, Enabled = true,
		FreeLength = 5, LimitsEnabled = false, MaxLength = 5, MinLength = 0,
		Radius = 0.15, Restitution = 0, Stiffness = 10, Thickness = 0.055,
		Visible = false,
	},
	HingeConstraint = {
		ActuatorType = Enum.ActuatorType.None, Attachment0 = nil, Attachment1 = nil,
		AngularResponsiveness = 20, AngularSpeed = 45, AngularVelocity = 0,
		Color = BrickColor.new("Bright blue"), Enabled = true, LimitsEnabled = false,
		LowerAngle = -45, MotorMaxAcceleration = math.huge, MotorMaxTorque = math.huge,
		Radius = 0.15, Restitution = 0, ServoMaxTorque = math.huge,
		TargetAngle = 0, UpperAngle = 45, Visible = false,
	},
	BallSocketConstraint = {
		Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
		Enabled = true, LimitsEnabled = false, MaxFrictionTorque = 0, Radius = 0.15,
		Restitution = 0, TwistLimitsEnabled = false, TwistLowerAngle = -45,
		TwistUpperAngle = 45, UpperAngle = 45, Visible = false,
	},
	CylindricalConstraint = {
		AngularActuatorType = Enum.ActuatorType.None, AngularLimitsEnabled = false,
		AngularResponsiveness = 20, AngularSpeed = 45, AngularVelocity = 0,
		Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
		Enabled = true, InclinationAngle = 0, LinearActuatorType = Enum.ActuatorType.None,
		LinearLimitsEnabled = false, LinearResponsiveness = 20, LinearSpeed = 2,
		LowerAngle = -45, LowerLimit = 0, MotorMaxAcceleration = math.huge,
		MotorMaxForce = math.huge, MotorMaxTorque = math.huge, Radius = 0.15,
		Restitution = 0, ServoMaxForce = math.huge, ServoMaxTorque = math.huge,
		TargetAngle = 0, TargetPosition = 0, Thickness = 0.055, UpperAngle = 45,
		UpperLimit = 0, Visible = false, WorldLimitsEnabled = false,
	},
	PrismaticConstraint = {
		ActuatorType = Enum.ActuatorType.None, Attachment0 = nil, Attachment1 = nil,
		Color = BrickColor.new("Bright blue"), Enabled = true, LimitsEnabled = false,
		LinearResponsiveness = 20, LinearSpeed = 2, LowerLimit = 0,
		MotorMaxAcceleration = math.huge, MotorMaxForce = math.huge, Restitution = 0,
		ServoMaxForce = math.huge, TargetPosition = 0, Thickness = 0.055,
		UpperLimit = 0, Visible = false,
	},
	TorsionSpringConstraint = {
		Attachment0 = nil, Attachment1 = nil, Coils = 5,
		Color = BrickColor.new("Bright blue"), Damping = 0, Enabled = true,
		LimitsEnabled = false, LowerAngle = -45, MaxAngle = 45, Radius = 0.15,
		Restitution = 0, Stiffness = 10, UpperAngle = 45, Visible = false,
	},
	UniversalConstraint = {
		Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
		Enabled = true, MaxAngle = 45, Radius = 0.15, Restitution = 0, Visible = false,
	},
	LinearVelocityConstraint = {
		Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
		Enabled = true, ForceLimitMode = Enum.ForceLimitMode.Magnitude,
		LineDirection = Vector3.new(0, 1, 0), LineVelocity = 0,
		MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge), MaxForce = math.huge,
		PlaneVelocity = Vector2.new(), PrimaryTangentAxis = Vector3.new(1, 0, 0),
		RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
		SecondaryTangentAxis = Vector3.new(0, 0, 1), VectorVelocity = Vector3.new(),
		VelocityConstraintMode = Enum.VelocityConstraintMode.Vector, Visible = false,
	},
	AngularVelocityConstraint = {
		AngularVelocity = Vector3.new(0, 1, 0), Attachment0 = nil, Attachment1 = nil,
		Color = BrickColor.new("Bright blue"), Enabled = true, MaxTorque = math.huge,
		ReactionTorqueEnabled = false, RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
		Visible = false,
	},
	AlignPosition = {
		ApplyAtCenterOfMass = false, Attachment0 = nil, Attachment1 = nil,
		Color = BrickColor.new("Bright blue"), Enabled = true,
		ForceLimitMode = Enum.ForceLimitMode.Magnitude,
		MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge), MaxForce = math.huge,
		MaxVelocity = math.huge, Mode = Enum.PositionAlignmentMode.TwoAttachment,
		Position = Vector3.new(), ReactionForceEnabled = false, Responsiveness = 200,
		RigidityEnabled = false, Visible = false,
	},
	AlignOrientation = {
		Attachment0 = nil, Attachment1 = nil, CFrame = CFrame.new(),
		Color = BrickColor.new("Bright blue"), Enabled = true,
		MaxAngularVelocity = math.huge, MaxTorque = math.huge,
		Mode = Enum.OrientationAlignmentMode.TwoAttachment,
		PrimaryAxis = Vector3.new(0, 1, 0), PrimaryAxisOnly = false,
		ReactionTorqueEnabled = false, Responsiveness = 200, RigidityEnabled = false,
		SecondaryAxis = Vector3.new(1, 0, 0), Visible = false,
	},
	WeldConstraint = { Enabled = true, Part0 = nil, Part1 = nil },
	Weld = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil },
	Motor6D = {
		C0 = CFrame.new(), C1 = CFrame.new(), CurrentAngle = 0, DesiredAngle = 0,
		MaxVelocity = 0.1, Part0 = nil, Part1 = nil,
	},
	Snap = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil },
	ManualWeld = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil },
	ManualGlue = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil },
	Motor = {
		C0 = CFrame.new(), C1 = CFrame.new(), CurrentAngle = 0, DesiredAngle = 0,
		MaxVelocity = 0.1, Part0 = nil, Part1 = nil,
	},
	Glue = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil },
	RigidConstraint = { Attachment0 = nil, Attachment1 = nil, Enabled = true, Visible = false },
	SliderConstraint = {
		ActuatorType = Enum.ActuatorType.None, Attachment0 = nil, Attachment1 = nil,
		Color = BrickColor.new("Bright blue"), Enabled = true, LimitsEnabled = false,
		LowerLimit = 0, MotorMaxAcceleration = math.huge, MotorMaxForce = math.huge,
		Restitution = 0, ServoMaxForce = math.huge, TargetPosition = 0,
		UpperLimit = 0, Visible = false,
	},
	BodyVelocity = { MaxForce = Vector3.new(4000, 4000, 4000), P = 10000, Velocity = Vector3.new() },
	BodyPosition = { D = 500, MaxForce = Vector3.new(4000, 4000, 4000), P = 10000, Position = Vector3.new() },
	BodyForce = { Force = Vector3.new() },
	BodyAngularVelocity = { AngularVelocity = Vector3.new(), MaxTorque = Vector3.new(4000, 4000, 4000), P = 10000 },
	BodyGyro = { CFrame = CFrame.new(), D = 500, MaxTorque = Vector3.new(4000, 4000, 4000), P = 10000 },
	BodyThrust = { Force = Vector3.new(), Location = Vector3.new() },
	RocketPropulsion = {
		CartoonFactor = 0.7, MaxSpeed = 50, MaxThrust = 4000,
		MaxTorque = Vector3.new(4000, 4000, 0), P = 10000, TargetOffset = Vector3.new(),
		TargetRadius = 4, ThrustD = 500, ThrustP = 100, TurnD = 500, TurnP = 100,
	},
	PointLight = { Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Range = 16, Shadows = false },
	SpotLight = { Angle = 45, Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false },
	SurfaceLight = { Angle = 90, Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false },
	Atmosphere = {
		Color = Color3.fromRGB(199, 199, 199), Decay = Color3.fromRGB(255, 255, 255),
		Density = 0.395, Glare = 0, Haze = 0, Offset = 0,
	},
	Sky = {
		CelestialBodiesShown = true, MoonAngularSize = 11, MoonTextureId = "",
		SkyboxBk = "", SkyboxDn = "", SkyboxFt = "", SkyboxLf = "",
		SkyboxRt = "", SkyboxUp = "", StarCount = 3000, SunAngularSize = 21,
		SunTextureId = "",
	},
	Clouds = { Cover = 0.5, Density = 0.9, Enabled = true },
	Bloom = { Enabled = true, Intensity = 0.5, Size = 56, Threshold = 0.95 },
	Blur = { Enabled = true, Size = 24 },
	ColorCorrection = { Brightness = 0, Contrast = 0, Enabled = true, Saturation = 0, TintColor = Color3.new(1, 1, 1) },
	DepthOfField = { Enabled = true, FarIntensity = 0, FocusDistance = 50, InFocusRadius = 10, NearIntensity = 0 },
	SunRaysEffect = { Enabled = true, Intensity = 0.5, Spread = 1 },
	ProximityPrompt = {
		ActionText = "Interact", AutoLocalize = true, ClickablePrompt = true,
		Enabled = true, GamepadKeyCode = Enum.KeyCode.ButtonX, HoldDuration = 0,
		KeyboardKeyCode = Enum.KeyCode.E, MaxActivationDistance = 10,
		ObjectText = "", RequiresLineOfSight = true,
		Style = Enum.ProximityPromptStyle.Default, UIOffset = Vector2.new(),
	},
	ClickDetector = { CursorIcon = "", MaxActivationDistance = 32 },
	ForceField = { Visible = true },
	PathfindingModifier = { IsBlocked = false, Label = "", PassThrough = false },
	PathfindingLink = { Attachment0 = nil, Attachment1 = nil, Bidirectional = true, Label = "" },
	Dialog = {
		BehaviorType = Enum.DialogBehaviorType.SinglePlayer, ConversationDistance = 25,
		Enabled = true, GoodbyeChoiceActive = false, GoodbyeDialog = "",
		InitialPrompt = "", Purpose = Enum.DialogPurpose.Help, Tone = Enum.DialogTone.Neutral,
	},
	DialogChoice = { GoodbyeChoiceActive = false, GoodbyeDialog = "", ResponseDialog = "", UserDialog = "" },
	Humanoid = {
		AutoJumpEnabled = true, AutoRotate = true, BreakJointsOnDeath = true,
		CameraOffset = Vector3.new(), DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer,
		HealthDisplayDistance = 100, HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged,
		HipHeight = 0, JumpHeight = 7.2, JumpPower = 50, MaxHealth = 100,
		MaxSlopeAngle = 89, NameDisplayDistance = 100, NameOcclusion = Enum.NameOcclusion.OccludeAll,
		RequiresNeck = true, RigType = Enum.HumanoidRigType.R6, UseJumpPower = false, WalkSpeed = 16,
	},
	HumanoidDescription = {
		BackAccessory = "", ClimbAnimation = 0, DepthOffset = 0, Face = 0,
		FaceAccessory = "", FallAnimation = 0, FrontAccessory = "", GraphicTShirt = 0,
		HairAccessory = "", HatAccessory = "", Head = 0, HeadColor = Color3.fromRGB(163, 162, 165),
		HeadScale = 1, IdleAnimation = 0, JumpAnimation = 0, LeftArm = 0,
		LeftArmColor = Color3.fromRGB(163, 162, 165), LeftLeg = 0, LeftLegColor = Color3.fromRGB(163, 162, 165),
		LowerTorso = 0, NeckAccessory = "", Pants = 0, ProportionScale = 1, RightArm = 0,
		RightArmColor = Color3.fromRGB(163, 162, 165), RightLeg = 0, RightLegColor = Color3.fromRGB(163, 162, 165),
		RunAnimation = 0, Shirt = 0, ShouldersAccessory = "", SwimAnimation = 0,
		Torso = 0, TorsoColor = Color3.fromRGB(163, 162, 165), UpperTorso = 0,
		WaistAccessory = "", WalkAnimation = 0, WidthScale = 1,
	},
	Camera = {
		CameraType = Enum.CameraType.Custom, FieldOfView = 70,
		FieldOfViewMode = Enum.FieldOfViewMode.Vertical, HeadLocked = true,
		MaxZoom = 400, MinZoom = 0,
	},
	TextChatService = {
		ChatTranslationEnabled = false, CreateDefaultCommands = true,
		CreateDefaultTextChannels = true,
	},
	TextChannel = { WelcomeMessage = "" },
	TextChatCommand = { Enabled = true, PrimaryAlias = "", SecondaryAlias = "" },
	ChatWindowConfiguration = {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6,
		Enabled = true, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		HorizontalAlignment = Enum.HorizontalAlignment.Left, TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14, TextStrokeColor3 = Color3.new(), TextStrokeTransparency = 0.75,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	},
	BubbleChatConfiguration = {
		BackgroundColor3 = Color3.fromRGB(250, 250, 250), BackgroundTransparency = 0.1,
		BubbleDuration = 30, BubblesToShow = 2, CornerRadius = UDim.new(0, 12),
		Enabled = true, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		LocalPlayerStudsOffset = Vector3.new(0, 6, 0), MaxDistance = 100,
		MinimizeDistance = 40, NormLength = 200, Padding = 8, TailVisible = true,
		TextColor3 = Color3.new(), TextSize = 16, TextStrokeColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 1, VerticalStudsOffset = 0,
	},
	ScreenGui = {
		ClipToDeviceSafeArea = false, DisplayOrder = 0, Enabled = true,
		IgnoreGuiInset = false, OnTopOfCoreBlur = false, ResetOnSpawn = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},
	BillboardGui = {
		Active = false, AlwaysOnTop = false, Brightness = 1, ClipsDescendants = false,
		Enabled = true, ExtentsOffset = Vector2.new(), ExtentsOffsetWorldSpace = Vector3.new(),
		LightInfluence = 1, MaxDistance = 0, Size = UDim2.fromOffset(200, 50),
		SizeOffset = Vector2.new(), StudsOffset = Vector3.new(), StudsOffsetWorldSpace = Vector3.new(),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},
	SurfaceGui = {
		Active = false, AlwaysOnTop = false, Brightness = 1, CanvasSize = Vector2.new(800, 600),
		ClipsDescendants = false, Enabled = true, Face = Enum.NormalId.Front,
		LightInfluence = 1, PixelsPerStud = 20, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},
	Frame = { BackgroundTransparency = 0, Size = UDim2.fromOffset(100, 100) },
	TextLabel = { BackgroundTransparency = 1, Size = UDim2.fromOffset(200, 50), Text = "Label" },
	TextButton = {
		AutoButtonColor = true, Modal = false, Selected = false,
		Size = UDim2.fromOffset(200, 50), Style = Enum.ButtonStyle.Custom, Text = "Button",
	},
	TextBox = {
		ClearTextOnFocus = true, MultiLine = false, PlaceholderColor3 = Color3.new(0.75, 0.75, 0.75),
		PlaceholderText = "", ShowNativeInput = true, Text = "", TextEditable = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	ImageLabel = {
		BackgroundTransparency = 1, Image = "", ImageColor3 = Color3.new(1, 1, 1),
		ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0,
		ResampleMode = Enum.ResamplerMode.Default, ScaleType = Enum.ScaleType.Stretch,
		SliceCenter = Rect.new(0, 0, 0, 0), SliceScale = 1, TileSize = UDim2.fromOffset(100, 100),
	},
	ImageButton = {
		AutoButtonColor = true, HoverImage = "", Image = "", ImageColor3 = Color3.new(1, 1, 1),
		ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0,
		Modal = false, PressedImage = "", ResampleMode = Enum.ResamplerMode.Default,
		ScaleType = Enum.ScaleType.Stretch, Selected = false,
		SliceCenter = Rect.new(0, 0, 0, 0), SliceScale = 1,
		Style = Enum.ButtonStyle.Custom, TileSize = UDim2.fromOffset(100, 100),
	},
	ScrollingFrame = {
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
		CanvasPosition = Vector2.new(), CanvasSize = UDim2.new(0, 0, 1, 0),
		ClipsDescendants = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		HorizontalScrollBarInset = Enum.ScrollBarInset.None,
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		ScrollBarImageColor3 = Color3.new(0, 0, 0), ScrollBarImageTransparency = 0,
		ScrollBarThickness = 12, ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollingEnabled = true, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
	},
	VideoFrame = { Looped = false, Playing = false, TimePosition = 0, Video = "", Volume = 0.5 },
	ViewportFrame = {
		Ambient = Color3.new(1, 1, 1), CurrentCamera = nil, ImageColor3 = Color3.new(1, 1, 1),
		ImageTransparency = 0, LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(0, -1, -1),
	},
	CanvasGroup = { GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 0 },
	UICorner = { CornerRadius = UDim.new(0, 0) },
	UIStroke = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(), Enabled = true,
		LineJoinMode = Enum.LineJoinMode.Round, Thickness = 1, Transparency = 0,
	},
	UIPadding = { PaddingBottom = UDim.new(), PaddingLeft = UDim.new(), PaddingRight = UDim.new(), PaddingTop = UDim.new() },
	UIListLayout = {
		FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Left,
		HorizontalFlex = Enum.UIFlexAlignment.None, ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
		Padding = UDim.new(), SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top, VerticalFlex = Enum.UIFlexAlignment.None, Wraps = false,
	},
	UIGridLayout = {
		CellPaddingX = UDim.new(0, 5), CellPaddingY = UDim.new(0, 5),
		CellSize = UDim2.fromOffset(100, 100), FillDirection = Enum.FillDirection.Horizontal,
		FillDirectionMaxCells = 0, HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder, StartCorner = Enum.StartCorner.TopLeft,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	},
	UITableLayout = {
		FillDirection = Enum.FillDirection.Vertical, FillEmptySpaceColumns = false,
		FillEmptySpaceRows = false, MajorAxis = Enum.TableMajorAxis.RowMajor,
		Padding = UDim2.new(), SortOrder = Enum.SortOrder.LayoutOrder,
	},
	UIPageLayout = {
		Animated = true, Circular = false, EasingDirection = Enum.EasingDirection.Out,
		EasingStyle = Enum.EasingStyle.Quad, FillDirection = Enum.FillDirection.Horizontal,
		GamepadInputEnabled = true, Padding = UDim.new(), ScrollWheelInputEnabled = true,
		SortOrder = Enum.SortOrder.LayoutOrder, TweenTime = 0.5, TouchInputEnabled = true,
	},
	UISizeConstraint = { MaxSize = Vector2.new(math.huge, math.huge), MinSize = Vector2.new() },
	UITextSizeConstraint = { MaxTextSize = 100, MinTextSize = 1 },
	UIAspectRatioConstraint = { AspectRatio = 1, AspectType = Enum.AspectType.FitWithinMaxSize, DominantAxis = Enum.DominantAxis.Width },
	UIFlexItem = { FlexMode = Enum.UIFlexMode.None, GrowRatio = 0, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, ShrinkRatio = 0 },
	UIGradient = { Color = ColorSequence.new(Color3.new(1, 1, 1)), Enabled = true, Offset = Vector2.new(), Rotation = 0, Transparency = NumberSequence.new(0) },
	UIScale = { Scale = 1 },
	SelectionBox = { Adornee = nil, Color3 = Color3.new(0, 0, 1), LineThickness = 0.1, SurfaceColor3 = Color3.new(0, 0, 1), SurfaceTransparency = 0.5, Visible = true },
	SelectionSphere = { Adornee = nil, Color3 = Color3.new(0, 0, 1), SurfaceColor3 = Color3.new(0, 0, 1), SurfaceTransparency = 0.5, Visible = true },
	BoxHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Size = Vector3.new(1, 1, 1), SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 },
	SphereHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 },
	ConeHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Height = 1, Radius = 0.25, Transparency = 0, Visible = true, ZIndex = 0 },
	CylinderHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Height = 1, InnerRadius = 0, Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 },
	LineHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Length = 1, Thickness = 1, Transparency = 0, Visible = true, ZIndex = 0 },
	ImageHandleAdornment = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Image = "", RelativeSize = 0, SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 },
	ArcHandles = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(0, 0, 1), Visible = true, ZIndex = 0 },
	Handles = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(0, 0, 1), Faces = Faces.new(), Style = Enum.HandlesStyle.Resize, Visible = true, ZIndex = 0 },
	SelectionPartLasso = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Part = nil },
	SelectionPointLasso = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Point = Vector3.new() },
	Highlight = {
		Adornee = nil, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = true,
		FillColor = Color3.new(1, 1, 1), FillTransparency = 0.5,
		OutlineColor = Color3.new(1, 1, 1), OutlineTransparency = 0,
	},
	RemoteEvent = {}, RemoteFunction = {}, BindableEvent = {}, BindableFunction = {},
	Configuration = {},
	MaterialService = { Use2022Materials = true },
	MaterialVariant = { BaseMaterial = Enum.Material.SmoothPlastic, ColorMap = "", MetalnessMap = "", NormalMap = "", RoughnessMap = "" },
	Terrain = {
		Decoration = true, DrawParentAndChildren = false, MaterialColors = "MaterialColorPalette",
		WaterColor = Color3.fromRGB(12, 84, 90), WaterReflectance = 0,
		WaterTransparency = 0.3, WaterWaveSize = 5, WaterWaveSpeed = 10,
	},
	TerrainRegion = {},
	StarterGui = { AutoResetLocalPlayerCamera = true, ShowTalkativeMessages = true },
	StarterPlayer = {
		AutoJumpEnabled = false, CameraMaxZoomDistance = 400, CameraMinZoomDistance = 0.5,
		CharacterJumpHeight = 7.2, CharacterJumpPower = 50, CharacterUseJumpPower = false,
		CharacterWalkSpeed = 16, EnableMouseLockOption = false, MouseIconEnabled = true,
	},
	StarterPlayerScripts = {}, LocalizationService = { CoreScriptLocalizationsEnabled = true },
	Chat = { BubbleChatEnabled = false, TypingIndicator = false },
}

-- Merge GUI base properties into GUI classes
local GuiObjectBase = {
	Active = false, AnchorPoint = Vector2.new(), AutomaticSize = Enum.AutomaticSize.None,
	BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0,
	BorderColor3 = Color3.new(0, 0, 0), BorderMode = Enum.BorderMode.Outline,
	BorderSizePixel = 1, ClipsDescendants = false, LayoutOrder = 0,
	NextSelectionDown = nil, NextSelectionLeft = nil, NextSelectionRight = nil,
	NextSelectionUp = nil, Position = UDim2.new(), Rotation = 0, Selectable = false,
	SelectionImageObject = nil, SelectionOrder = 0, Size = UDim2.fromOffset(100, 100),
	SizeConstraint = Enum.SizeConstraint.RelativeXY, Visible = true, ZIndex = 1,
}
local TextBase = {
	FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json"), LineHeight = 1,
	MaxVisibleGraphemes = -1, RichText = false, Text = "", TextColor3 = Color3.new(0, 0, 0),
	TextScaled = false, TextSize = 14, TextStrokeColor3 = Color3.new(),
	TextStrokeTransparency = 1, TextTransparency = 0, TextTruncate = Enum.TextTruncate.None,
	TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
}
local GuiObjectClasses = { "Frame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "ScrollingFrame", "VideoFrame", "ViewportFrame", "CanvasGroup" }
local TextClasses = { "TextLabel", "TextButton", "TextBox" }
for _, Class in ipairs(GuiObjectClasses) do
	local T = FallbackProperties[Class] or {}
	for K, V in pairs(GuiObjectBase) do if T[K] == nil then T[K] = V end end
	FallbackProperties[Class] = T
end
for _, Class in ipairs(TextClasses) do
	local T = FallbackProperties[Class]
	for K, V in pairs(TextBase) do if T[K] == nil then T[K] = V end end
end

-- Inheritance mapping
local Inheritance = {
	Part = {"BasePart", "Instance"}, WedgePart = {"BasePart", "Instance"},
	CornerWedgePart = {"BasePart", "Instance"}, TrussPart = {"BasePart", "Instance"},
	SpawnLocation = {"BasePart", "Instance"}, Platform = {"BasePart", "Instance"},
	Seat = {"BasePart", "Instance"}, VehicleSeat = {"BasePart", "Instance"},
	MeshPart = {"BasePart", "Instance"}, UnionOperation = {"BasePart", "Instance"},
	PartOperation = {"BasePart", "Instance"}, NegateOperation = {"BasePart", "Instance"},
	IntersectOperation = {"BasePart", "Instance"}, FormFactorPart = {"BasePart", "Instance"},
	SpecialMesh = {"Instance"}, CylinderMesh = {"Instance"}, BlockMesh = {"Instance"}, FileMesh = {"Instance"},
	Decal = {"Instance"}, Texture = {"Instance"}, SurfaceAppearance = {"Instance"},
	Model = {"Instance"}, Folder = {"Instance"}, Tool = {"Instance"}, Hat = {"Instance"}, Accessory = {"Instance"},
	Backpack = {"Instance"}, StarterPack = {"Instance"}, StarterGear = {"Instance"},
	Configuration = {"Instance"}, MaterialService = {"Instance"}, MaterialVariant = {"Instance"},
	Script = {"Instance"}, LocalScript = {"Instance"}, ModuleScript = {"Instance"},
	StringValue = {"Instance"}, NumberValue = {"Instance"}, BoolValue = {"Instance"}, IntValue = {"Instance"},
	Vector3Value = {"Instance"}, CFrameValue = {"Instance"}, ObjectValue = {"Instance"},
	Color3Value = {"Instance"}, BrickColorValue = {"Instance"}, RayValue = {"Instance"},
	Animation = {"Instance"}, Animator = {"Instance"}, AnimationController = {"Instance"}, AnimationTrack = {"Instance"},
	Sound = {"Instance"}, SoundService = {"Instance"},
	EqualizerSoundEffect = {"Instance"}, ReverbSoundEffect = {"Instance"}, ChorusSoundEffect = {"Instance"},
	CompressorSoundEffect = {"Instance"}, DistortionSoundEffect = {"Instance"}, EchoSoundEffect = {"Instance"},
	FlangeSoundEffect = {"Instance"}, PitchShiftSoundEffect = {"Instance"}, TremoloSoundEffect = {"Instance"},
	AudioPlayer = {"Instance"}, AudioEmitter = {"Instance"}, AudioListener = {"Instance"}, AudioAnalyzer = {"Instance"},
	AudioChorus = {"Instance"}, AudioCompressor = {"Instance"}, AudioDistortion = {"Instance"},
	AudioEqualizer = {"Instance"}, AudioFader = {"Instance"}, AudioFlanger = {"Instance"},
	AudioPitchShifter = {"Instance"}, AudioReverb = {"Instance"}, AudioTremolo = {"Instance"},
	AudioDeviceInput = {"Instance"}, AudioDeviceOutput = {"Instance"}, Wire = {"Instance"},
	Attachment = {"Instance"}, Bone = {"Attachment", "Instance"},
	Beam = {"Instance"}, Trail = {"Instance"}, ParticleEmitter = {"Instance"}, Fire = {"Instance"},
	Smoke = {"Instance"}, Sparkles = {"Instance"},
	BodyVelocity = {"Instance"}, BodyPosition = {"Instance"}, BodyForce = {"Instance"},
	BodyAngularVelocity = {"Instance"}, BodyGyro = {"Instance"}, BodyThrust = {"Instance"},
	RocketPropulsion = {"Instance"}, RopeConstraint = {"Instance"}, SpringConstraint = {"Instance"},
	HingeConstraint = {"Instance"}, BallSocketConstraint = {"Instance"}, CylindricalConstraint = {"Instance"},
	PrismaticConstraint = {"Instance"}, TorsionSpringConstraint = {"Instance"}, UniversalConstraint = {"Instance"},
	WeldConstraint = {"Instance"}, LinearVelocityConstraint = {"Instance"}, AngularVelocityConstraint = {"Instance"},
	AlignPosition = {"Instance"}, AlignOrientation = {"Instance"},
	Weld = {"Instance"}, Motor6D = {"Instance"}, Snap = {"Instance"}, ManualWeld = {"Instance"},
	ManualGlue = {"Instance"}, Motor = {"Instance"}, Glue = {"Instance"},
	RigidConstraint = {"Instance"}, SliderConstraint = {"Instance"},
	PointLight = {"Instance"}, SpotLight = {"Instance"}, SurfaceLight = {"Instance"},
	Atmosphere = {"Instance"}, Sky = {"Instance"}, Clouds = {"Instance"}, Bloom = {"Instance"},
	Blur = {"Instance"}, ColorCorrection = {"Instance"}, DepthOfField = {"Instance"}, SunRaysEffect = {"Instance"},
	IKControl = {"Instance"}, Humanoid = {"Instance"}, HumanoidDescription = {"Instance"},
	BodyColors = {"Instance"}, CharacterMesh = {"Instance"}, Pants = {"Instance"}, Shirt = {"Instance"},
	ShirtGraphic = {"Instance"}, WrapLayer = {"Instance"}, WrapTarget = {"Instance"},
	Camera = {"Instance"}, ScreenGui = {"Instance"}, BillboardGui = {"Instance"}, SurfaceGui = {"Instance"},
	Frame = {"Instance"}, TextLabel = {"Instance"}, TextButton = {"Instance"}, TextBox = {"Instance"},
	ImageLabel = {"Instance"}, ImageButton = {"Instance"}, ScrollingFrame = {"Instance"},
	VideoFrame = {"Instance"}, ViewportFrame = {"Instance"}, CanvasGroup = {"Instance"},
	UICorner = {"Instance"}, UIStroke = {"Instance"}, UIPadding = {"Instance"},
	UIListLayout = {"Instance"}, UIGridLayout = {"Instance"}, UITableLayout = {"Instance"},
	UIPageLayout = {"Instance"}, UISizeConstraint = {"Instance"}, UITextSizeConstraint = {"Instance"},
	UIAspectRatioConstraint = {"Instance"}, UIFlexItem = {"Instance"}, UIGradient = {"Instance"}, UIScale = {"Instance"},
	ProximityPrompt = {"Instance"}, ClickDetector = {"Instance"}, ForceField = {"Instance"},
	PathfindingModifier = {"Instance"}, PathfindingLink = {"Instance"}, SelectionBox = {"Instance"},
	SelectionSphere = {"Instance"}, BoxHandleAdornment = {"Instance"}, SphereHandleAdornment = {"Instance"},
	ConeHandleAdornment = {"Instance"}, CylinderHandleAdornment = {"Instance"}, LineHandleAdornment = {"Instance"},
	ImageHandleAdornment = {"Instance"}, ArcHandles = {"Instance"}, Handles = {"Instance"},
	SelectionPartLasso = {"Instance"}, SelectionPointLasso = {"Instance"}, Highlight = {"Instance"},
	RemoteEvent = {"Instance"}, RemoteFunction = {"Instance"}, BindableEvent = {"Instance"}, BindableFunction = {"Instance"},
	Dialog = {"Instance"}, DialogChoice = {"Instance"}, TextChatService = {"Instance"},
	TextChannel = {"Instance"}, TextChatCommand = {"Instance"}, ChatWindowConfiguration = {"Instance"},
	BubbleChatConfiguration = {"Instance"}, StarterGui = {"Instance"}, StarterPlayer = {"Instance"},
	StarterPlayerScripts = {"Instance"}, LocalizationService = {"Instance"}, Chat = {"Instance"},
}

-- Extra explicit property hints
local ExactPropertyHints = {
	Instance = { "Name" },
	BasePart = {
		"Anchored", "BackSurface", "BottomSurface", "CFrame", "CanCollide", "CanQuery", "CanTouch",
		"CastShadow", "CollisionGroup", "Color", "CustomPhysicalProperties", "EnableFluidForces",
		"FrontSurface", "LeftSurface", "Locked", "Massless", "Material", "MaterialVariant",
		"Orientation", "PivotOffset", "Position", "Reflectance", "RightSurface", "RootPriority",
		"Rotation", "Size", "TopSurface", "Transparency",
	},
	Part = { "Shape" },
	MeshPart = { "CollisionFidelity", "DoubleSided", "MeshId", "MeshSize", "RenderFidelity", "TextureID" },
	PartOperation = { "CollisionFidelity", "RenderFidelity", "SmoothingAngle", "UsePartColor" },
	SpecialMesh = { "MeshId", "MeshType", "Offset", "RotationOffset", "Scale", "TextureId", "VertexColor" },
	FileMesh = { "MeshId", "Offset", "Scale", "TextureId", "VertexColor" },
	Decal = { "Color3", "Face", "Texture", "Transparency", "ZIndex" },
	Texture = { "Color3", "Face", "OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV", "Texture", "Transparency", "ZIndex" },
	SurfaceAppearance = { "AlphaMode", "Color", "ColorMap", "Metalness", "MetalnessMap", "NormalMap", "Roughness", "RoughnessMap", "TexturePack" },
	Model = { "LevelOfDetail", "ModelStreamingMode", "PrimaryPart", "WorldPivot" },
	Tool = { "CanBeDropped", "Enabled", "Grip", "GripForward", "GripPos", "GripRight", "GripUp", "ManualActivationOnly", "RequiresHandle", "ToolTip" },
	Accessory = { "AccessoryType", "AttachmentPoint" },
	Script = { "Disabled", "RunContext", "Source" },
	LocalScript = { "Disabled", "Source" },
	ModuleScript = { "Source" },
	Attachment = { "Axis", "CFrame", "Orientation", "Position", "SecondaryAxis", "Visible" },
	Bone = { "CFrame", "Orientation", "Position", "Transform" },
	IKControl = { "ChainRoot", "Enabled", "EndEffector", "Offset", "Pole", "Priority", "SmoothTime", "Target", "Type", "Weight" },
	Beam = { "Attachment0", "Attachment1", "Brightness", "Color", "CurveSize0", "CurveSize1", "Enabled", "FaceCamera", "LightEmission", "LightInfluence", "Segments", "Texture", "TextureLength", "TextureMode", "TextureSpeed", "Transparency", "Width0", "Width1", "ZOffset" },
	Trail = { "Attachment0", "Attachment1", "Brightness", "Color", "Enabled", "FaceCamera", "Lifetime", "LightEmission", "LightInfluence", "MaxLength", "MinLength", "Texture", "TextureLength", "TextureMode", "Transparency", "WidthScale" },
	ParticleEmitter = { "Acceleration", "Brightness", "Color", "Drag", "EmissionDirection", "Enabled", "FlipbookFramerate", "FlipbookLayout", "FlipbookMode", "LifeTime", "LightEmission", "LightInfluence", "LockedToPart", "Orientation", "Rate", "RotSpeed", "Rotation", "Size", "Speed", "SpreadAngle", "Squash", "Texture", "TimeScale", "Transparency", "VelocityInheritance", "ZOffset" },
	Fire = { "Color", "Enabled", "Heat", "SecondaryColor", "Size", "TimeScale" },
	Smoke = { "Color", "Enabled", "Opacity", "RiseVelocity", "Size", "TimeScale" },
	Sparkles = { "Color", "Enabled", "SparkleColor", "TimeScale" },
	Sound = { "EmitterSize", "Looped", "MaxDistance", "PlayOnRemove", "PlaybackRegionsEnabled", "PlaybackSpeed", "RollOffMaxDistance", "RollOffMinDistance", "RollOffMode", "SoundGroup", "SoundId", "TimePosition", "Volume" },
	AudioPlayer = { "AssetId", "Looping", "PlaybackRegionsEnabled", "PlaybackSpeed", "TimePosition", "Volume" },
	AlignPosition = { "ApplyAtCenterOfMass", "Attachment0", "Attachment1", "Enabled", "ForceLimitMode", "MaxAxesForce", "MaxForce", "MaxVelocity", "Mode", "Position", "ReactionForceEnabled", "Responsiveness", "RigidityEnabled" },
	AlignOrientation = { "Attachment0", "Attachment1", "CFrame", "Enabled", "MaxAngularVelocity", "MaxTorque", "Mode", "PrimaryAxis", "PrimaryAxisOnly", "ReactionTorqueEnabled", "Responsiveness", "RigidityEnabled", "SecondaryAxis" },
	LinearVelocityConstraint = { "Attachment0", "Enabled", "ForceLimitMode", "LineDirection", "LineVelocity", "MaxAxesForce", "MaxForce", "PlaneVelocity", "RelativeTo", "VelocityConstraintMode", "VectorVelocity", "Visible" },
	AngularVelocityConstraint = { "AngularVelocity", "Attachment0", "Enabled", "MaxTorque", "ReactionTorqueEnabled", "RelativeTo", "Visible" },
	TextLabel = { "FontFace", "LineHeight", "MaxVisibleGraphemes", "RichText", "Text", "TextColor3", "TextScaled", "TextSize", "TextStrokeColor3", "TextStrokeTransparency", "TextTransparency", "TextTruncate", "TextWrapped", "TextXAlignment", "TextYAlignment" },
	TextButton = { "AutoButtonColor", "FontFace", "LineHeight", "MaxVisibleGraphemes", "Modal", "RichText", "Selected", "Style", "Text", "TextColor3", "TextScaled", "TextSize", "TextStrokeColor3", "TextStrokeTransparency", "TextTransparency", "TextTruncate", "TextWrapped", "TextXAlignment", "TextYAlignment" },
	TextBox = { "ClearTextOnFocus", "FontFace", "LineHeight", "MaxVisibleGraphemes", "MultiLine", "PlaceholderColor3", "PlaceholderText", "RichText", "ShowNativeInput", "Text", "TextColor3", "TextEditable", "TextScaled", "TextSize", "TextStrokeColor3", "TextStrokeTransparency", "TextTransparency", "TextTruncate", "TextWrapped", "TextXAlignment", "TextYAlignment" },
	ImageLabel = { "Image", "ImageColor3", "ImageRectOffset", "ImageRectSize", "ImageTransparency", "ResampleMode", "ScaleType", "SliceCenter", "SliceScale", "TileSize" },
	ImageButton = { "AutoButtonColor", "HoverImage", "Image", "ImageColor3", "ImageRectOffset", "ImageRectSize", "ImageTransparency", "Modal", "PressedImage", "ResampleMode", "ScaleType", "Selected", "SliceCenter", "SliceScale", "Style", "TileSize" },
	ScrollingFrame = { "AutomaticCanvasSize", "BottomImage", "CanvasPosition", "CanvasSize", "ElasticBehavior", "HorizontalScrollBarInset", "MidImage", "ScrollBarImageColor3", "ScrollBarImageTransparency", "ScrollBarThickness", "ScrollingDirection", "ScrollingEnabled", "TopImage", "VerticalScrollBarInset", "VerticalScrollBarPosition" },
	ProximityPrompt = { "ActionText", "AutoLocalize", "ClickablePrompt", "Enabled", "GamepadKeyCode", "HoldDuration", "KeyboardKeyCode", "MaxActivationDistance", "ObjectText", "RequiresLineOfSight", "Style", "UIOffset" },
	Highlight = { "DepthMode", "Enabled", "FillColor", "FillTransparency", "OutlineColor", "OutlineTransparency" },
	Camera = { "CameraType", "FieldOfView", "FieldOfViewMode", "Focus", "HeadLocked", "MaxZoom", "MinZoom" },
	Dialog = { "BehaviorType", "ConversationDistance", "Enabled", "GoodbyeChoiceActive", "GoodbyeDialog", "InitialPrompt", "Purpose", "Tone" },
	DialogChoice = { "GoodbyeChoiceActive", "GoodbyeDialog", "ResponseDialog", "UserDialog" },
	TextChatService = { "ChatTranslationEnabled", "CreateDefaultCommands", "CreateDefaultTextChannels" },
	TextChannel = { "WelcomeMessage" },
	TextChatCommand = { "Enabled", "PrimaryAlias", "SecondaryAlias" },
}

-- Utility: number formatting with full precision
local function Num(N)
	if N ~= N then return "0/0" end
	if N == math.huge then return "math.huge" end
	if N == -math.huge then return "-math.huge" end
	if math.floor(N) == N and math.abs(N) < 1e15 then return tostring(N) end
	return string.format("%.17g", N)
end

-- Path resolver for references
local function GetPath(I, Refs)
	if not I then return "nil" end
	if Refs[I] then return string.format("o[%d]", Refs[I]) end
	local parts = {}
	local cur = I
	while cur and cur ~= game do
		local n = cur.Name
		if n:match("^[%a_][%w_]*$") then
			table.insert(parts, 1, "."..n)
		else
			table.insert(parts, 1, string.format("[%q]", n))
		end
		cur = cur.Parent
	end
	if #parts == 0 then return "nil" end
	return "game" .. table.concat(parts)
end

-- Serialize any Roblox datatype
local function Ser(V, Refs)
	local T = typeof(V)
	if T == "nil" then return "nil" end
	if T == "boolean" then return tostring(V) end
	if T == "number" then return Num(V) end
	if T == "string" then return string.format("%q", V) end
	if T == "Instance" then return GetPath(V, Refs) end
	if T == "CFrame" then
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = V:GetComponents()
		if R00==1 and R01==0 and R02==0 and R10==0 and R11==1 and R12==0 and R20==0 and R21==0 and R22==1 then
			if X==0 and Y==0 and Z==0 then return "CFrame.new()" end
			return string.format("CFrame.new(%s,%s,%s)", Num(X), Num(Y), Num(Z))
		end
		return string.format("CFrame.new(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", Num(X), Num(Y), Num(Z), Num(R00), Num(R01), Num(R02), Num(R10), Num(R11), Num(R12), Num(R20), Num(R21), Num(R22))
	end
	if T == "Vector3" then return (V.X==0 and V.Y==0 and V.Z==0) and "Vector3.new()" or string.format("Vector3.new(%s,%s,%s)", Num(V.X), Num(V.Y), Num(V.Z)) end
	if T == "Vector2" then return (V.X==0 and V.Y==0) and "Vector2.new()" or string.format("Vector2.new(%s,%s)", Num(V.X), Num(V.Y)) end
	if T == "Vector3int16" then return string.format("Vector3int16.new(%d,%d,%d)", V.X, V.Y, V.Z) end
	if T == "Vector2int16" then return string.format("Vector2int16.new(%d,%d)", V.X, V.Y) end
	if T == "Color3" then
		local R, G, B = math.round(V.R*255), math.round(V.G*255), math.round(V.B*255)
		if math.abs(V.R-R/255)<0.001 and math.abs(V.G-G/255)<0.001 and math.abs(V.B-B/255)<0.001 then
			return string.format("Color3.fromRGB(%d,%d,%d)", R, G, B)
		end
		return string.format("Color3.new(%s,%s,%s)", Num(V.R), Num(V.G), Num(V.B))
	end
	if T == "UDim2" then
		local XS, XO, YS, YO = V.X.Scale, V.X.Offset, V.Y.Scale, V.Y.Offset
		if XS==0 and YS==0 then return (XO==0 and YO==0) and "UDim2.new()" or string.format("UDim2.fromOffset(%d,%d)", XO, YO) end
		if XO==0 and YO==0 then return string.format("UDim2.fromScale(%s,%s)", Num(XS), Num(YS)) end
		return string.format("UDim2.new(%s,%d,%s,%d)", Num(XS), XO, Num(YS), YO)
	end
	if T == "UDim" then
		if V.Scale==0 and V.Offset==0 then return "UDim.new()" end
		if V.Offset==0 then return string.format("UDim.new(%s,0)", Num(V.Scale)) end
		if V.Scale==0 then return string.format("UDim.new(0,%d)", V.Offset) end
		return string.format("UDim.new(%s,%d)", Num(V.Scale), V.Offset)
	end
	if T == "BrickColor" then return string.format('BrickColor.new("%s")', V.Name) end
	if T == "EnumItem" then
		local ok, res = pcall(function() return tostring(V) end)
		if ok then return res end
		return "nil"
	end
	if T == "NumberRange" then return (V.Min == V.Max) and string.format("NumberRange.new(%s)", Num(V.Min)) or string.format("NumberRange.new(%s,%s)", Num(V.Min), Num(V.Max)) end
	if T == "PhysicalProperties" then return string.format("PhysicalProperties.new(%s,%s,%s,%s,%s)", Num(V.Density), Num(V.Friction), Num(V.Elasticity), Num(V.FrictionWeight), Num(V.ElasticityWeight)) end
	if T == "NumberSequence" then
		local k = V.Keypoints
		if #k==2 and k[1].Time==0 and k[2].Time==1 and k[1].Value==k[2].Value and k[1].Envelope==0 and k[2].Envelope==0 then
			return string.format("NumberSequence.new(%s)", Num(k[1].Value))
		end
		local parts = {}
		for _, kp in ipairs(k) do
			parts[#parts+1] = string.format("NumberSequenceKeypoint.new(%s,%s%s)", Num(kp.Time), Num(kp.Value), kp.Envelope ~= 0 and (","..Num(kp.Envelope)) or "")
		end
		return "NumberSequence.new({"..table.concat(parts, ",").."})"
	end
	if T == "ColorSequence" then
		local k = V.Keypoints
		if #k==2 and k[1].Time==0 and k[2].Time==1 and k[1].Value==k[2].Value then
			return string.format("ColorSequence.new(%s)", Ser(k[1].Value))
		end
		local parts = {}
		for _, kp in ipairs(k) do
			parts[#parts+1] = string.format("ColorSequenceKeypoint.new(%s,%s)", Num(kp.Time), Ser(kp.Value))
		end
		return "ColorSequence.new({"..table.concat(parts, ",").."})"
	end
	if T == "Rect" then return string.format("Rect.new(%s,%s,%s,%s)", Num(V.Min.X), Num(V.Min.Y), Num(V.Max.X), Num(V.Max.Y)) end
	if T == "Font" then return string.format('Font.new("%s",Enum.FontWeight.%s,Enum.FontStyle.%s)', V.Family, V.Weight.Name, V.Style.Name) end
	if T == "Ray" then return string.format("Ray.new(%s,%s)", Ser(V.Origin), Ser(V.Direction)) end
	if T == "TweenInfo" then return string.format("TweenInfo.new(%s,%s,%s,%s,%s,%s)", Num(V.Time), tostring(V.EasingStyle), tostring(V.EasingDirection), Num(V.RepeatCount), tostring(V.Reverses), Num(V.DelayTime)) end
	if T == "DateTime" then return string.format("DateTime.fromUnixTimestamp(%d)", V.UnixTimestamp) end
	if T == "Axes" then
		local parts = {}
		if V.X then parts[#parts+1] = "Enum.Axis.X" end
		if V.Y then parts[#parts+1] = "Enum.Axis.Y" end
		if V.Z then parts[#parts+1] = "Enum.Axis.Z" end
		return "Axes.new("..table.concat(parts, ",")..")"
	end
	if T == "Faces" then
		local parts = {}
		if V.Top then parts[#parts+1] = "Enum.NormalId.Top" end
		if V.Bottom then parts[#parts+1] = "Enum.NormalId.Bottom" end
		if V.Left then parts[#parts+1] = "Enum.NormalId.Left" end
		if V.Right then parts[#parts+1] = "Enum.NormalId.Right" end
		if V.Front then parts[#parts+1] = "Enum.NormalId.Front" end
		if V.Back then parts[#parts+1] = "Enum.NormalId.Back" end
		return "Faces.new("..table.concat(parts, ",")..")"
	end
	if T == "OverlapParams" then return string.format("(function()local p=OverlapParams.new()p.FilterType=%s p.MaxParts=%d p.RespectCanCollide=%s return p end)()", tostring(V.FilterType), V.MaxParts, tostring(V.RespectCanCollide)) end
	if T == "RaycastParams" then return string.format("(function()local p=RaycastParams.new()p.FilterType=%s p.IgnoreWater=%s p.RespectCanCollide=%s return p end)()", tostring(V.FilterType), tostring(V.IgnoreWater), tostring(V.RespectCanCollide)) end
	if T == "Region3" then
		return string.format("Region3.new(%s,%s)", Ser(V.CFrame.Position - V.Size/2), Ser(V.CFrame.Position + V.Size/2))
	end
	if T == "Region3int16" then
		return string.format("Region3int16.new(%s,%s)", Ser(V.Min), Ser(V.Max))
	end
	return nil
end

-- Getters
local function _Get(I, P) return I[P] end
local function _New(C) return Instance.new(C) end
local function _IsA(I, C) return I:IsA(C) end
local function _Attrs(I) return I:GetAttributes() end
local function _Tags(I) return CollectionService:GetTags(I) end
local function _IsService(I)
	local ok, res = pcall(function() return I:IsA("Service") end)
	return ok and res
end

-- Upload script source to API
local function UploadScript(Src)
	if not API_CONFIG.Enabled then return nil end
	local payload = {
		[API_CONFIG.Field] = Src,
	}
	if API_CONFIG.ExpiryDays then payload["expiry_days"] = API_CONFIG.ExpiryDays end
	local headers = { ["Content-Type"] = "application/json" }
	if API_CONFIG.Key and API_CONFIG.Key ~= "" then
		headers["Authorization"] = API_CONFIG.Key
	end
	local ok, res = pcall(function()
		return request({
			Url = API_CONFIG.Endpoint,
			Method = "POST",
			Headers = headers,
			Body = HttpService:JSONEncode(payload)
		})
	end)
	if ok and res and res.Body then
		local okDec, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
		if okDec and data and data[API_CONFIG.ResponseField] then
			return data[API_CONFIG.ResponseField]
		end
	end
	return nil
end

-- Resolve fallback properties with inheritance
local function ResolveFallbackProps(Inst)
	local merged = {}
	local class = Inst.ClassName
	local own = FallbackProperties[class]
	if own then for k, v in pairs(own) do merged[k] = v end end
	for _, parent in ipairs(Inheritance[class] or {"Instance"}) do
		local parentProps = FallbackProperties[parent]
		if parentProps then
			for k, v in pairs(parentProps) do
				if merged[k] == nil then merged[k] = v end
			end
		end
	end
	if merged.Name == nil or merged.Name == "Instance" then merged.Name = class end
	return merged
end

-- Add explicit property hints
local function AddHintProps(dest, inst)
	for className, propList in pairs(ExactPropertyHints) do
		local include = false
		if className == "Instance" then
			include = true
		else
			local ok, result = pcall(_IsA, inst, className)
			include = ok and result or false
		end
		if include then
			for _, propName in ipairs(propList) do dest[propName] = true end
		end
	end
end

-- Merge property dump from listproperties/gethiddenproperties
local function MergePropertyDump(dest, raw)
	if type(raw) ~= "table" then return end
	for k, v in pairs(raw) do
		if type(k) == "string" then
			dest[k] = true
		elseif type(v) == "string" then
			dest[v] = true
		elseif type(v) == "table" then
			local name = rawget(v, "Name") or rawget(v, "name") or rawget(v, "Property") or rawget(v, "property")
			if type(name) == "string" then dest[name] = true end
		end
	end
end

-- Cache property list per class
local PropCache = {}
local function GetProps(inst)
	local class = inst.ClassName
	if PropCache[class] then return PropCache[class] end
	local props = {}
	if listproperties then
		local ok, res = pcall(listproperties, inst)
		if ok and type(res) == "table" then MergePropertyDump(props, res) end
	end
	if gethiddenproperties then
		local ok, res = pcall(gethiddenproperties, inst)
		if ok and type(res) == "table" then MergePropertyDump(props, res) end
	end
	if pcall(_IsA, inst, "LuaSourceContainer") then props["Source"] = true end
	for k in pairs(ResolveFallbackProps(inst)) do props[k] = true end
	AddHintProps(props, inst)
	for k in pairs(props) do
		if SkipProperties[k] then
			props[k] = nil
		elseif not pcall(_Get, inst, k) then
			props[k] = nil
		end
	end
	PropCache[class] = props
	return props
end

-- Main build function
local function Build(target)
	local instances = {target}
	for _, d in ipairs(target:GetDescendants()) do
		instances[#instances+1] = d
	end
	local refs = {}
	for idx, inst in ipairs(instances) do
		refs[inst] = idx
	end

	local out = {}
	local function Emit(...)
		local args = {...}
		if #args == 1 then
			out[#out+1] = args[1]
		else
			out[#out+1] = string.format(...)
		end
	end

	Emit("local o={}")
	Emit("local S=function(i,p,v) local ok,err=pcall(function() i[p]=v end) if not ok and sethiddenproperty then pcall(function() sethiddenproperty(i,p,v) end) end end")
	Emit("local A=function(i,a,v) pcall(function() i:SetAttribute(a,v) end) end")
	Emit("local CS=game:GetService('CollectionService')")
	Emit("local T=function(i,t) pcall(function() CS:AddTag(i,t) end) end")
	Emit("local _p=function(i,v) pcall(function() i.Parent=v end) end")

	local instOK = {}
	local isDummy = {}
	for idx, inst in ipairs(instances) do
		local ok = pcall(_New, inst.ClassName)
		if _IsService(inst) then ok = false end
		if ok then
			instOK[idx] = true
			Emit("o[%d]=Instance.new(%q)", idx, inst.ClassName)
		else
			instOK[idx] = true
			isDummy[idx] = true
			Emit("o[%d]=Instance.new('Folder')", idx)
		end
	end

	local deferred = {}
	for idx, inst in ipairs(instances) do
		if instOK[idx] and not isDummy[idx] then
			local props = GetProps(inst)
			local pnames = {}
			for n in pairs(props) do pnames[#pnames+1] = n end
			table.sort(pnames, function(a, b)
				if a == "CFrame" then return false end
				if b == "CFrame" then return true end
				return a < b
			end)
			for _, propName in ipairs(pnames) do
				local ok, val = pcall(_Get, inst, propName)
				if ok then
					local t = typeof(val)
					if t == "Instance" then
						deferred[#deferred+1] = string.format("S(o[%d],%q,%s)", idx, propName, GetPath(val, refs))
					elseif t == "function" then
						-- skip
					elseif propName == "Source" then
						-- Handle script source with optional upload
						local src = val
						if type(src) == "string" and #src > 0 then
							local url = UploadScript(src)
							if url then
								deferred[#deferred+1] = string.format("S(o[%d],'Source',game:HttpGet(%q))", idx, url)
							else
								deferred[#deferred+1] = string.format("S(o[%d],'Source',%q)", idx, src)
							end
						end
					else
						local serialized = Ser(val, refs)
						if serialized then
							Emit("S(o[%d],%q,%s)", idx, propName, serialized)
						end
					end
				end
			end

			-- Attributes
			local okAttrs, attrs = pcall(_Attrs, inst)
			if okAttrs then
				local sorted = {}
				for k, v in pairs(attrs) do sorted[#sorted+1] = {k, v} end
				table.sort(sorted, function(a, b) return a[1] < b[1] end)
				for _, a in ipairs(sorted) do
					local str = Ser(a[2], refs)
					if str then
						Emit("A(o[%d],%q,%s)", idx, a[1], str)
					end
				end
			end

			-- Tags
			local okTags, tags = pcall(_Tags, inst)
			if okTags then
				table.sort(tags)
				for _, tag in ipairs(tags) do
					Emit("T(o[%d],%q)", idx, tag)
				end
			end
		elseif isDummy[idx] then
			Emit("S(o[%d],'Name',%q)", idx, inst.Name)
		end
	end

	-- Deferred property assignments (references, Source)
	for _, d in ipairs(deferred) do
		Emit(d)
	end

	-- Parent assignments (must be last)
	for idx, inst in ipairs(instances) do
		local parent = inst.Parent
		if parent then
			local path = GetPath(parent, refs)
			if path ~= "nil" then
				Emit("pcall(_p,o[%d],%s)", idx, path)
			end
		end
	end

	Emit("return o[1]")
	return table.concat(out, "\n")
end

-- Public API
local API = {}
API.Path = nil

function API:Build()
	local target = self.Path
	if type(target) == "string" then
		local loadFunc = loadstring or load
		if not loadFunc then error("loadstring not available") end
		local ok, inst = pcall(function()
			local fn = loadFunc("return " .. target, "")
			if fn then return fn() end
			return nil
		end)
		if ok and typeof(inst) == "Instance" then
			return Build(inst)
		end
		error("Invalid Path string: " .. target)
	end
	return Build(target)
end

function API:Save(name)
	local result = self:Build()
	local fileName = name or ("serialized_" .. tostring(self.Path.Name):gsub("[^%w]", "_") .. ".lua")
	if writefile then writefile(fileName, result) end
	if setclipboard then setclipboard(result) end
	if not writefile and not setclipboard then print(result) end
	return result
end

return API
