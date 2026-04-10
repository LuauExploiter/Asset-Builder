--[[
	Hiklo Serializer v4.0
	- Fixed Enum.Style error.
	- Characters (models containing Humanoid) are rejected.
]]

local CollectionService = game:GetService("CollectionService")
local VERSION = "4.0.0"

local SkipProperties = {
	Parent                = true,
	ClassName             = true,
	DataCost              = true,
	RobloxLocked          = true,
	Archivable            = true,
	Changed               = true,
	AncestryChanged       = true,
	ChildAdded            = true,
	ChildRemoved          = true,
	DescendantAdded       = true,
	DescendantRemoving    = true,
	AttributeChanged      = true,
	AbsolutePosition      = true,
	AbsoluteSize          = true,
	AbsoluteRotation      = true,
	AbsoluteContentSize   = true,
	TotalGroupStride      = true,
	CanvasAbsoluteSize    = true,
	ContentText           = true,
	TextBounds            = true,
	TextFits              = true,
	LocalTransparencyModifier = true,
	ReceiveAge            = true,
	AssemblyAngularVelocity = true,
	AssemblyLinearVelocity = true,
	AssemblyCenterOfMass  = true,
	AssemblyMass          = true,
	AssemblyRootPart      = true,
	RootPriority          = true,
	Mass                  = true,
	IsLoaded              = true,
	PlaybackLoudness      = true,
	IsPaused              = true,
	IsPlaying             = true,
	TimeLength            = true,
	SoundId               = true,
}

local ClassSkipProperties = {
	Humanoid = {
		Health         = true,
		Jump           = true,
		Sit            = true,
		TargetPoint    = true,
		WalkToPoint    = true,
		WalkToPart     = true,
		MoveDirection  = true,
		LookVector     = true,
		RootPart       = true,
		Torso          = true,
	},
	BasePart = {
		Velocity              = true,
		RotVelocity           = true,
		AssemblyAngularVelocity = true,
		AssemblyLinearVelocity = true,
	},
}

local FallbackProperties = {}

FallbackProperties["Instance"] = {
	Name       = "Instance",
	Archivable = true,
}

FallbackProperties["BasePart"] = {
	Anchored                 = false,
	CanCollide               = true,
	CanTouch                 = true,
	CanQuery                 = true,
	CastShadow               = true,
	CFrame                   = CFrame.new(),
	Color                    = Color3.new(0.639216, 0.635294, 0.647059),
	CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.1, 0.1),
	EnableFluidForces        = true,
	Locked                   = false,
	Massless                 = false,
	Material                 = Enum.Material.SmoothPlastic,
	MaterialVariant          = "",
	Position                 = Vector3.new(),
	Reflectance              = 0,
	RenderFidelity           = Enum.RenderFidelity.Automatic,
	Rotation                 = Vector3.new(),
	Size                     = Vector3.new(4, 1, 2),
	Transparency             = 0,
}

FallbackProperties["Part"] = {
	Shape = Enum.PartType.Block,
}

FallbackProperties["WedgePart"]         = {}
FallbackProperties["CornerWedgePart"]   = {}
-- FIXED: Removed invalid Enum.Style reference
FallbackProperties["TrussPart"]         = {}
FallbackProperties["SpawnLocation"]     = { AllowTeamChangeOnTouch = false, Duration = 10, Enabled = true, Neutral = true, TeamColor = BrickColor.new("White") }
FallbackProperties["Platform"]          = {}
FallbackProperties["Seat"]              = { Disabled = false }
FallbackProperties["VehicleSeat"]       = { Disabled = false, HeadsUpDisplay = true, MaxSpeed = 100, Steer = 0, SteerFloat = 0, Throttle = 0, ThrottleFloat = 0, TurnSpeed = 1 }

FallbackProperties["MeshPart"] = {
	DoubleSided    = false,
	MeshId         = "",
	MeshSize       = Vector3.new(1, 1, 1),
	RenderFidelity = Enum.RenderFidelity.Automatic,
	TextureID      = "",
}

FallbackProperties["SpecialMesh"] = {
	MeshId         = "",
	TextureId      = "",
	MeshType       = Enum.MeshType.Head,
	Offset         = Vector3.new(),
	RotationOffset = Vector3.new(),
	Scale          = Vector3.new(1, 1, 1),
	VertexColor    = Vector3.new(1, 1, 1),
}

FallbackProperties["CylinderMesh"] = {
	Offset         = Vector3.new(),
	RotationOffset = Vector3.new(),
	Scale          = Vector3.new(1, 1, 1),
}

FallbackProperties["BlockMesh"] = {
	Offset         = Vector3.new(),
	RotationOffset = Vector3.new(),
	Scale          = Vector3.new(1, 1, 1),
}

FallbackProperties["Decal"] = {
	Color3       = Color3.new(1, 1, 1),
	Face         = Enum.NormalId.Front,
	Texture      = "",
	Transparency = 0,
	ZIndex       = 0,
}

FallbackProperties["Texture"] = {
	Color3        = Color3.new(1, 1, 1),
	Face          = Enum.NormalId.Front,
	OffsetStudsU  = 0,
	OffsetStudsV  = 0,
	StudsPerTileU = 2,
	StudsPerTileV = 2,
	Texture       = "",
	Transparency  = 0,
}

FallbackProperties["Model"] = {
	LevelOfDetail = Enum.ModelLevelOfDetail.Disabled,
	WorldPivot    = CFrame.new(),
}

FallbackProperties["Folder"]       = {}
FallbackProperties["Tool"]         = { CanBeDropped = true, Enabled = true, Grip = CFrame.new(), GripForward = Vector3.new(0,0,-1), GripPos = Vector3.new(), GripRight = Vector3.new(1,0,0), GripUp = Vector3.new(0,1,0), ManualActivationOnly = false, RequiresHandle = true, ToolTip = "" }
FallbackProperties["Backpack"]     = {}
FallbackProperties["StarterPack"]  = {}
FallbackProperties["StarterGear"]  = {}

FallbackProperties["Script"]       = { Disabled = false, RunContext = Enum.RunContext.Legacy, Source = "" }
FallbackProperties["LocalScript"]  = { Disabled = false, Source = "" }
FallbackProperties["ModuleScript"] = { Source = "" }

FallbackProperties["StringValue"]   = { Value = "" }
FallbackProperties["NumberValue"]   = { Value = 0 }
FallbackProperties["BoolValue"]     = { Value = false }
FallbackProperties["IntValue"]      = { Value = 0 }
FallbackProperties["Vector3Value"]  = { Value = Vector3.new() }
FallbackProperties["CFrameValue"]   = { Value = CFrame.new() }
FallbackProperties["ObjectValue"]   = { Value = nil }
FallbackProperties["Color3Value"]   = { Value = Color3.new() }
FallbackProperties["BrickColorValue"] = { Value = BrickColor.new("Medium stone grey") }
FallbackProperties["RayValue"]      = { Value = Ray.new(Vector3.new(), Vector3.new()) }

FallbackProperties["Animation"] = { AnimationId = "" }

FallbackProperties["Animator"] = {}

FallbackProperties["Sound"] = {
	EmitterSize        = 10,
	Looped             = false,
	MaxDistance        = 10000,
	Playing            = false,
	PlayOnRemove       = false,
	PlaybackRegionsEnabled = false,
	PlaybackSpeed      = 1,
	RollOffMaxDistance = 10000,
	RollOffMinDistance = 10,
	RollOffMode        = Enum.RollOffMode.InverseTapered,
	SoundGroup         = nil,
	SoundId            = "",
	TimePosition       = 0,
	Volume             = 0.5,
}

FallbackProperties["SoundService"] = { AmbientReverb = Enum.ReverbType.NoReverb, DistanceFactor = 3.33, DopplerScale = 1, RespectFilteringEnabled = true, VolumetricAudio = Enum.VolumetricAudio.Disabled }

FallbackProperties["EqualizerSoundEffect"]  = { HighGain = 0, LowGain = 0, MidGain = 0, Priority = 0 }
FallbackProperties["ReverbSoundEffect"]     = { DecayTime = 1.5, Density = 1, Diffusion = 1, DryLevel = -6, Priority = 0, WetLevel = 0 }
FallbackProperties["ChorusSoundEffect"]     = { Depth = 1, Priority = 0, Rate = 0.45, Mix = 50 }
FallbackProperties["CompressorSoundEffect"] = { Attack = 0.003, GainMakeup = 0, Priority = 0, Release = 0.5, SideChain = nil, Threshold = -24 }
FallbackProperties["DistortionSoundEffect"] = { Level = 0, Priority = 0 }
FallbackProperties["EchoSoundEffect"]       = { Delay = 1, DryLevel = 0, FeedBack = 0.5, Priority = 0, WetLevel = -6 }
FallbackProperties["FlangeSoundEffect"]     = { Depth = 45, Mix = 50, Priority = 0, Rate = 0.45 }
FallbackProperties["PitchShiftSoundEffect"] = { Octave = 1, Priority = 0 }
FallbackProperties["TremoloSoundEffect"]    = { Depth = 1, Duty = 50, Frequency = 5, Priority = 0 }

FallbackProperties["Attachment"] = {
	Axis            = Vector3.new(1, 0, 0),
	CFrame          = CFrame.new(),
	Orientation     = Vector3.new(),
	Position        = Vector3.new(),
	SecondaryAxis   = Vector3.new(0, 1, 0),
	Visible         = false,
	WorldAxis       = Vector3.new(1, 0, 0),
	WorldCFrame     = CFrame.new(),
	WorldOrientation = Vector3.new(),
	WorldPosition   = Vector3.new(),
	WorldSecondaryAxis = Vector3.new(0, 1, 0),
}

FallbackProperties["Bone"] = {
	CFrame       = CFrame.new(),
	Orientation  = Vector3.new(),
	Position     = Vector3.new(),
	Transform    = CFrame.new(),
	WorldCFrame  = CFrame.new(),
	WorldPosition = Vector3.new(),
}

FallbackProperties["Beam"] = {
	Attachment0       = nil,
	Attachment1       = nil,
	Brightness        = 1,
	Color             = ColorSequence.new(Color3.new(1,1,1)),
	CurveSize0        = 0,
	CurveSize1        = 0,
	Enabled           = true,
	FaceCamera        = false,
	LightEmission     = 0,
	LightInfluence     = 1,
	Segments          = 10,
	Texture           = "",
	TextureLength      = 1,
	TextureMode       = Enum.TextureMode.Stretch,
	TextureSpeed      = 1,
	Transparency      = NumberSequence.new(0),
	Width0            = 1,
	Width1            = 1,
	ZOffset           = 0,
}

FallbackProperties["Trail"] = {
	Attachment0        = nil,
	Attachment1        = nil,
	Brightness         = 1,
	Color              = ColorSequence.new(Color3.new(1,1,1)),
	Enabled            = true,
	FaceCamera         = false,
	Lifetime           = 2,
	LightEmission      = 0,
	LightInfluence      = 1,
	MaxLength          = 0,
	MinLength          = 0,
	Texture            = "",
	TextureLength       = 1,
	TextureMode        = Enum.TextureMode.Stretch,
	Transparency       = NumberSequence.new(0),
	WidthScale         = NumberSequence.new(1),
}

FallbackProperties["ParticleEmitter"] = {
	Acceleration      = Vector3.new(),
	Brightness        = 1,
	Color             = ColorSequence.new(Color3.new(1,1,1)),
	Drag              = 0,
	EmissionDirection = Enum.NormalId.Top,
	Enabled           = true,
	FlipbookFramerate = NumberRange.new(30),
	FlipbookIncompatible = "",
	FlipbookLayout    = Enum.ParticleFlipbookLayout.None,
	FlipbookMode      = Enum.ParticleFlipbookMode.Loop,
	LifeTime          = NumberRange.new(5, 10),
	LightEmission     = 0,
	LightInfluence    = 1,
	LockedToPart      = false,
	Orientation       = Enum.ParticleOrientation.FacingCamera,
	Rate              = 20,
	RotSpeed          = NumberRange.new(0),
	Rotation          = NumberRange.new(0),
	ShapeStyle        = Enum.ParticleEmitterShapeStyle.Volume,
	Size              = NumberSequence.new(1),
	Speed             = NumberRange.new(5),
	SpreadAngle       = Vector2.new(),
	Squash            = NumberSequence.new(0),
	Texture           = "rbxasset://textures/particles/smoke_main.dds",
	Transparency      = NumberSequence.new(0),
	VelocityInheritance = 0,
	ZOffset           = 0,
}

local ConstraintBase = { Enabled = true, Visible = false, Color = BrickColor.new("Bright blue") }

FallbackProperties["RopeConstraint"]    = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, Length = 5, Restitution = 0, Thickness = 0.1, Visible = false,
}
FallbackProperties["SpringConstraint"]  = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Coils = 5, Damping = 0, Enabled = true, FreeLength = 5, LimitsEnabled = false,
	MaxLength = 5, MinLength = 0, Radius = 0.15, Restitution = 0,
	Stiffness = 10, Thickness = 0.055, Visible = false,
}
FallbackProperties["HingeConstraint"]   = {
	Attachment0 = nil, Attachment1 = nil, ActuatorType = Enum.ActuatorType.None,
	AngularResponsiveness = 20, AngularSpeed = 45, AngularVelocity = 0,
	Color = BrickColor.new("Bright blue"), Enabled = true,
	LimitsEnabled = false, LowerAngle = -45, MotorMaxAcceleration = math.huge,
	MotorMaxTorque = math.huge, Radius = 0.15, Restitution = 0,
	ServoMaxTorque = math.huge, TargetAngle = 0, UpperAngle = 45, Visible = false,
}
FallbackProperties["BallSocketConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, LimitsEnabled = false, MaxFrictionTorque = 0,
	Radius = 0.15, Restitution = 0, TwistLimitsEnabled = false,
	TwistLowerAngle = -45, TwistUpperAngle = 45, UpperAngle = 45, Visible = false,
}
FallbackProperties["CylindricalConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, AngularActuatorType = Enum.ActuatorType.None,
	AngularLimitsEnabled = false, AngularResponsiveness = 20,
	AngularSpeed = 45, AngularVelocity = 0, Color = BrickColor.new("Bright blue"),
	Enabled = true, InclinationAngle = 0, LinearActuatorType = Enum.ActuatorType.None,
	LinearLimitsEnabled = false, LinearResponsiveness = 20,
	LinearSpeed = 2, LowerAngle = -45, LowerLimit = 0,
	MotorMaxAcceleration = math.huge, MotorMaxForce = math.huge,
	MotorMaxTorque = math.huge, Radius = 0.15, Restitution = 0,
	ServoMaxForce = math.huge, ServoMaxTorque = math.huge,
	TargetAngle = 0, TargetPosition = 0, Thickness = 0.055,
	UpperAngle = 45, UpperLimit = 0, Visible = false,
	WorldLimitsEnabled = false,
}
FallbackProperties["PrismaticConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, ActuatorType = Enum.ActuatorType.None,
	Color = BrickColor.new("Bright blue"), Enabled = true,
	LimitsEnabled = false, LinearResponsiveness = 20,
	LinearSpeed = 2, LowerLimit = 0, MotorMaxAcceleration = math.huge,
	MotorMaxForce = math.huge, Restitution = 0, ServoMaxForce = math.huge,
	TargetPosition = 0, Thickness = 0.055, UpperLimit = 0, Visible = false,
}
FallbackProperties["TorsionSpringConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Coils = 5, Damping = 0, Enabled = true, LimitsEnabled = false,
	LowerAngle = -45, MaxAngle = 45, Radius = 0.15, Restitution = 0,
	Stiffness = 10, UpperAngle = 45, Visible = false,
}
FallbackProperties["UniversalConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, MaxAngle = 45, Radius = 0.15, Restitution = 0, Visible = false,
}
FallbackProperties["WeldConstraint"]   = { Enabled = true }
FallbackProperties["Weld"]             = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["Motor6D"]          = { C0 = CFrame.new(), C1 = CFrame.new(), CurrentAngle = 0, DesiredAngle = 0, MaxVelocity = 0.1, Part0 = nil, Part1 = nil }
FallbackProperties["Snap"]             = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualWeld"]       = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualGlue"]       = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }

FallbackProperties["BodyVelocity"]     = { MaxForce = Vector3.new(4000,4000,4000), P = 10000, Velocity = Vector3.new() }
FallbackProperties["BodyPosition"]     = { D = 500, MaxForce = Vector3.new(4000,4000,4000), P = 10000, Position = Vector3.new() }
FallbackProperties["BodyForce"]        = { Force = Vector3.new() }
FallbackProperties["BodyAngularVelocity"] = { AngularVelocity = Vector3.new(), MaxTorque = Vector3.new(4000,4000,4000), P = 10000 }
FallbackProperties["BodyGyro"]         = { CFrame = CFrame.new(), D = 500, MaxTorque = Vector3.new(4000,4000,4000), P = 10000 }
FallbackProperties["BodyThrust"]       = { Force = Vector3.new(), Location = Vector3.new() }
FallbackProperties["RocketPropulsion"] = { CartoonFactor = 0.7, MaxSpeed = 50, MaxThrust = 4000, MaxTorque = Vector3.new(4000,4000,0), P = 10000, TargetOffset = Vector3.new(), TargetRadius = 4, ThrustD = 500, ThrustP = 100, TurnD = 500, TurnP = 100 }

FallbackProperties["LinearVelocityConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, ForceLimitMode = Enum.ForceLimitMode.Magnitude,
	LineDirection = Vector3.new(0,1,0), LineVelocity = 0,
	MaxAxesForce = Vector3.new(math.huge,math.huge,math.huge),
	MaxForce = math.huge, PlaneVelocity = Vector2.new(), PrimaryTangentAxis = Vector3.new(1,0,0),
	RelativeTo = Enum.ActuatorRelativeTo.Attachment0, SecondaryTangentAxis = Vector3.new(0,0,1),
	VectorVelocity = Vector3.new(), VelocityConstraintMode = Enum.VelocityConstraintMode.Vector, Visible = false,
}
FallbackProperties["AngularVelocityConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, AngularVelocity = Vector3.new(0,1,0),
	Color = BrickColor.new("Bright blue"), Enabled = true,
	MaxTorque = math.huge, ReactionTorqueEnabled = false,
	RelativeTo = Enum.ActuatorRelativeTo.Attachment0, Visible = false,
}
FallbackProperties["AlignPosition"] = {
	Attachment0 = nil, Attachment1 = nil, ApplyAtCenterOfMass = false,
	Color = BrickColor.new("Bright blue"), Enabled = true,
	ForceLimitMode = Enum.ForceLimitMode.Magnitude,
	MaxAxesForce = Vector3.new(math.huge,math.huge,math.huge),
	MaxForce = math.huge, MaxVelocity = math.huge,
	Mode = Enum.PositionAlignmentMode.TwoAttachment,
	Position = Vector3.new(), ReactionForceEnabled = false,
	Responsiveness = 200, RigidityEnabled = false, Visible = false,
}
FallbackProperties["AlignOrientation"] = {
	Attachment0 = nil, Attachment1 = nil, AlignType = Enum.OrientationAlignmentMode.TwoAttachment,
	Color = BrickColor.new("Bright blue"), CFrame = CFrame.new(), Enabled = true,
	MaxAngularVelocity = math.huge, MaxTorque = math.huge,
	Mode = Enum.OrientationAlignmentMode.TwoAttachment, PrimaryAxis = Vector3.new(0,1,0),
	PrimaryAxisOnly = false, ReactionTorqueEnabled = false,
	Responsiveness = 200, RigidityEnabled = false,
	SecondaryAxis = Vector3.new(1,0,0), Visible = false,
}

FallbackProperties["PointLight"]   = { Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Range = 16, Shadows = false }
FallbackProperties["SpotLight"]    = { Angle = 45, Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false }
FallbackProperties["SurfaceLight"] = { Angle = 90, Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false }

FallbackProperties["Atmosphere"] = { Color = Color3.fromRGB(199,199,199), Decay = Color3.fromRGB(255,255,255), Density = 0.395, Glare = 0, Haze = 0, Offset = 0 }
FallbackProperties["Sky"]        = { CelestialBodiesShown = true, MoonAngularSize = 11, MoonTextureId = "", SkyboxBk = "", SkyboxDn = "", SkyboxFt = "", SkyboxLf = "", SkyboxRt = "", SkyboxUp = "", StarCount = 3000, SunAngularSize = 21, SunTextureId = "" }
FallbackProperties["Bloom"]      = { Enabled = true, Intensity = 0.5, Size = 56, Threshold = 0.95 }
FallbackProperties["Blur"]       = { Enabled = true, Size = 24 }
FallbackProperties["ColorCorrection"] = { Brightness = 0, Contrast = 0, Enabled = true, Saturation = 0, TintColor = Color3.new(1,1,1) }
FallbackProperties["DepthOfField"] = { Enabled = true, FarIntensity = 0, FocusDistance = 50, InFocusRadius = 10, NearIntensity = 0 }
FallbackProperties["SunRaysEffect"] = { Enabled = true, Intensity = 0.5, Spread = 1 }

FallbackProperties["Humanoid"] = {
	AutoJumpEnabled        = true,
	AutoRotate             = true,
	BreakJointsOnDeath     = true,
	CameraOffset           = Vector3.new(),
	DisplayDistanceType    = Enum.HumanoidDisplayDistanceType.Viewer,
	HealthDisplayDistance  = 100,
	HealthDisplayType      = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged,
	HipHeight              = 0,
	JumpHeight             = 7.2,
	JumpPower              = 50,
	MaxHealth              = 100,
	MaxSlopeAngle          = 89,
	NameDisplayDistance    = 100,
	NameOcclusion          = Enum.NameOcclusion.OccludeAll,
	RequiresNeck           = true,
	RigType                = Enum.HumanoidRigType.R6,
	UseJumpPower           = false,
	WalkSpeed              = 16,
}

FallbackProperties["HumanoidDescription"] = {
	BackAccessory        = "",
	ClimbAnimation       = 0,
	DepthOffset          = 0,
	Face                 = 0,
	FaceAccessory        = "",
	FallAnimation        = 0,
	FrontAccessory       = "",
	GraphicTShirt        = 0,
	HairAccessory        = "",
	HatAccessory         = "",
	Head                 = 0,
	HeadColor            = Color3.fromRGB(163,162,165),
	HeadScale            = 1,
	IdleAnimation        = 0,
	JumpAnimation        = 0,
	LeftArm              = 0,
	LeftArmColor         = Color3.fromRGB(163,162,165),
	LeftLeg              = 0,
	LeftLegColor         = Color3.fromRGB(163,162,165),
	LowerTorso           = 0,
	NeckAccessory        = "",
	Pants                = 0,
	ProportionScale      = 1,
	RightArm             = 0,
	RightArmColor        = Color3.fromRGB(163,162,165),
	RightLeg             = 0,
	RightLegColor        = Color3.fromRGB(163,162,165),
	RunAnimation         = 0,
	Shirt                = 0,
	ShouldersAccessory   = "",
	SwimAnimation        = 0,
	Torso                = 0,
	TorsoColor           = Color3.fromRGB(163,162,165),
	UpperTorso           = 0,
	WaistAccessory       = "",
	WalkAnimation        = 0,
	WidthScale           = 1,
}

FallbackProperties["ScreenGui"]    = { ClipToDeviceSafeArea = false, DisplayOrder = 0, Enabled = true, IgnoreGuiInset = false, OnTopOfCoreBlur = false, ResetOnSpawn = true, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }
FallbackProperties["BillboardGui"] = { Active = false, AlwaysOnTop = false, Brightness = 1, ClipsDescendants = false, Enabled = true, ExtentsOffset = Vector2.new(), ExtentsOffsetWorldSpace = Vector3.new(), LightInfluence = 1, MaxDistance = 0, Size = UDim2.fromOffset(200,50), SizeOffset = Vector2.new(), StudsOffset = Vector3.new(), StudsOffsetWorldSpace = Vector3.new(), ZIndexBehavior = Enum.ZIndexBehavior.Sibling }
FallbackProperties["SurfaceGui"]   = { Active = false, AlwaysOnTop = false, Brightness = 1, CanvasSize = Vector2.new(800,600), ClipsDescendants = false, Enabled = true, Face = Enum.NormalId.Front, LightInfluence = 1, PixelsPerStud = 20, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }

local GuiObjectBase = {
	AnchorPoint            = Vector2.new(),
	AutomaticSize          = Enum.AutomaticSize.None,
	BackgroundColor3       = Color3.new(1,1,1),
	BackgroundTransparency = 0,
	BorderColor3           = Color3.new(0,0,0),
	BorderMode             = Enum.BorderMode.Outline,
	BorderSizePixel        = 1,
	ClipsDescendants       = false,
	LayoutOrder            = 0,
	NextSelectionDown      = nil,
	NextSelectionLeft      = nil,
	NextSelectionRight     = nil,
	NextSelectionUp        = nil,
	Position               = UDim2.new(),
	Rotation               = 0,
	Selectable             = false,
	SelectionImageObject   = nil,
	SelectionOrder         = 0,
	Size                   = UDim2.fromOffset(100,100),
	SizeConstraint         = Enum.SizeConstraint.RelativeXY,
	Visible                = true,
	ZIndex                 = 1,
}

local TextBase = {
	FontFace               = Font.new("rbxasset://fonts/families/LegacyArial.json"),
	LineHeight             = 1,
	MaxVisibleGraphemes    = -1,
	RichText               = false,
	Text                   = "",
	TextColor3             = Color3.new(0,0,0),
	TextScaled             = false,
	TextSize               = 14,
	TextStrokeColor3       = Color3.new(),
	TextStrokeTransparency = 1,
	TextTransparency       = 0,
	TextTruncate           = Enum.TextTruncate.None,
	TextWrapped            = false,
	TextXAlignment         = Enum.TextXAlignment.Center,
	TextYAlignment         = Enum.TextYAlignment.Center,
}

FallbackProperties["Frame"]         = { BackgroundTransparency = 0, Size = UDim2.fromOffset(100,100) }
FallbackProperties["TextLabel"]     = { BackgroundTransparency = 1, Text = "Label", Size = UDim2.fromOffset(200,50) }
FallbackProperties["TextButton"]    = { AutoButtonColor = true, Modal = false, Selected = false, Style = Enum.ButtonStyle.Custom, Text = "Button", Size = UDim2.fromOffset(200,50) }
FallbackProperties["TextBox"]       = { ClearTextOnFocus = true, MultiLine = false, PlaceholderColor3 = Color3.new(0.75,0.75,0.75), PlaceholderText = "", ShowNativeInput = true, Text = "", TextEditable = true, TextXAlignment = Enum.TextXAlignment.Left }
FallbackProperties["ImageLabel"]    = { BackgroundTransparency = 1, Image = "", ImageColor3 = Color3.new(1,1,1), ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0, ResampleMode = Enum.ResamplerMode.Default, ScaleType = Enum.ScaleType.Stretch, SliceCenter = Rect.new(0,0,0,0), SliceScale = 1, TileSize = UDim2.fromOffset(100,100) }
FallbackProperties["ImageButton"]   = { AutoButtonColor = true, HoverImage = "", Image = "", ImageColor3 = Color3.new(1,1,1), ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0, Modal = false, PressedImage = "", ResampleMode = Enum.ResamplerMode.Default, ScaleType = Enum.ScaleType.Stretch, Selected = false, SliceCenter = Rect.new(0,0,0,0), SliceScale = 1, Style = Enum.ButtonStyle.Custom, TileSize = UDim2.fromOffset(100,100) }
FallbackProperties["ScrollingFrame"] = { AutomaticCanvasSize = Enum.AutomaticSize.None, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", CanvasPosition = Vector2.new(), CanvasSize = UDim2.new(0,0,1,0), ClipsDescendants = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable, HorizontalScrollBarInset = Enum.ScrollBarInset.None, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", ScrollBarImageColor3 = Color3.new(0,0,0), ScrollBarImageTransparency = 0, ScrollBarThickness = 12, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollingEnabled = true, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", VerticalScrollBarInset = Enum.ScrollBarInset.None, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right }
FallbackProperties["VideoFrame"]    = { Looped = false, Playing = false, TimePosition = 0, Video = "", Volume = 0.5 }
FallbackProperties["ViewportFrame"] = { Ambient = Color3.new(1,1,1), CurrentCamera = nil, ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0, LightColor = Color3.new(1,1,1), LightDirection = Vector3.new(0,-1,-1) }
FallbackProperties["CanvasGroup"]   = { GroupColor3 = Color3.new(1,1,1), GroupTransparency = 0 }

FallbackProperties["UICorner"]      = { CornerRadius = UDim.new(0,0) }
FallbackProperties["UIStroke"]      = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(), Enabled = true, LineJoinMode = Enum.LineJoinMode.Round, Thickness = 1, Transparency = 0 }
FallbackProperties["UIPadding"]     = { PaddingBottom = UDim.new(), PaddingLeft = UDim.new(), PaddingRight = UDim.new(), PaddingTop = UDim.new() }
FallbackProperties["UIListLayout"]  = { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Left, HorizontalFlex = Enum.UIFlexAlignment.None, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, Padding = UDim.new(), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top, VerticalFlex = Enum.UIFlexAlignment.None, Wraps = false }
FallbackProperties["UIGridLayout"]  = { CellPaddingX = UDim.new(0,5), CellPaddingY = UDim.new(0,5), CellSize = UDim2.fromOffset(100,100), FillDirection = Enum.FillDirection.Horizontal, FillDirectionMaxCells = 0, HorizontalAlignment = Enum.HorizontalAlignment.Left, SortOrder = Enum.SortOrder.LayoutOrder, StartCorner = Enum.StartCorner.TopLeft, VerticalAlignment = Enum.VerticalAlignment.Top }
FallbackProperties["UITableLayout"] = { FillDirection = Enum.FillDirection.Vertical, FillEmptySpaceColumns = false, FillEmptySpaceRows = false, MajorAxis = Enum.TableMajorAxis.RowMajor, Padding = UDim2.new(), SortOrder = Enum.SortOrder.LayoutOrder }
FallbackProperties["UIPageLayout"]  = { Animated = true, Circular = false, EasingDirection = Enum.EasingDirection.Out, EasingStyle = Enum.EasingStyle.Quad, FillDirection = Enum.FillDirection.Horizontal, GamepadInputEnabled = true, Padding = UDim.new(), ScrollWheelInputEnabled = true, SortOrder = Enum.SortOrder.LayoutOrder, TweenTime = 0.5, TouchInputEnabled = true }
FallbackProperties["UISizeConstraint"]          = { MaxSize = Vector2.new(math.huge,math.huge), MinSize = Vector2.new() }
FallbackProperties["UITextSizeConstraint"]      = { MaxTextSize = 100, MinTextSize = 1 }
FallbackProperties["UIAspectRatioConstraint"]   = { AspectRatio = 1, AspectType = Enum.AspectType.FitWithinMaxSize, DominantAxis = Enum.DominantAxis.Width }
FallbackProperties["UIFlexItem"]                = { FlexMode = Enum.UIFlexMode.None, GrowRatio = 0, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, ShrinkRatio = 0 }
FallbackProperties["UIGradient"]                = { Color = ColorSequence.new(Color3.new(1,1,1)), Enabled = true, Offset = Vector2.new(), Rotation = 0, Transparency = NumberSequence.new(0) }
FallbackProperties["UIScale"]                   = { Scale = 1 }

FallbackProperties["SelectionBox"]      = { Color3 = Color3.new(0,0,1), LineThickness = 0.1, SurfaceColor3 = Color3.new(0,0,1), SurfaceTransparency = 0.5, Visible = true }
FallbackProperties["SelectionSphere"]   = { Color3 = Color3.new(0,0,1), SurfaceColor3 = Color3.new(0,0,1), SurfaceTransparency = 0.5, Visible = true }
FallbackProperties["BoxHandleAdornment"] = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Size = Vector3.new(1,1,1), SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["SphereHandleAdornment"] = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ConeHandleAdornment"]   = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Height = 1, Radius = 0.25, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["CylinderHandleAdornment"] = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Height = 1, InnerRadius = 0, Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["Highlight"]         = { DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = true, FillColor = Color3.new(1,1,1), FillTransparency = 0.5, OutlineColor = Color3.new(1,1,1), OutlineTransparency = 0 }

FallbackProperties["RemoteEvent"]   = {}
FallbackProperties["RemoteFunction"] = {}
FallbackProperties["BindableEvent"] = {}
FallbackProperties["BindableFunction"] = {}
FallbackProperties["Configuration"] = {}
FallbackProperties["NumberRange"]   = {}

local Inheritance = {
	Part               = { "BasePart", "Instance" },
	WedgePart          = { "BasePart", "Instance" },
	CornerWedgePart    = { "BasePart", "Instance" },
	TrussPart          = { "BasePart", "Instance" },
	SpawnLocation      = { "BasePart", "Instance" },
	Platform           = { "BasePart", "Instance" },
	Seat               = { "BasePart", "Instance" },
	VehicleSeat        = { "BasePart", "Instance" },
	MeshPart           = { "BasePart", "Instance" },
	UnionOperation     = { "BasePart", "Instance" },
	SpecialMesh        = { "Instance" },
	CylinderMesh       = { "Instance" },
	BlockMesh          = { "Instance" },
	Decal              = { "Instance" },
	Texture            = { "Instance" },
	Model              = { "Instance" },
	Folder             = { "Instance" },
	Tool               = { "Instance" },
	Backpack           = { "Instance" },
	StarterPack        = { "Instance" },
	StarterGear        = { "Instance" },
	Configuration      = { "Instance" },
	Script             = { "Instance" },
	LocalScript        = { "Instance" },
	ModuleScript       = { "Instance" },
	StringValue        = { "Instance" },
	NumberValue        = { "Instance" },
	BoolValue          = { "Instance" },
	IntValue           = { "Instance" },
	Vector3Value       = { "Instance" },
	CFrameValue        = { "Instance" },
	ObjectValue        = { "Instance" },
	Color3Value        = { "Instance" },
	BrickColorValue    = { "Instance" },
	RayValue           = { "Instance" },
	Animation          = { "Instance" },
	Animator           = { "Instance" },
	Sound              = { "Instance" },
	SoundService       = { "Instance" },
	EqualizerSoundEffect   = { "Instance" },
	ReverbSoundEffect      = { "Instance" },
	ChorusSoundEffect      = { "Instance" },
	CompressorSoundEffect  = { "Instance" },
	DistortionSoundEffect  = { "Instance" },
	EchoSoundEffect        = { "Instance" },
	FlangeSoundEffect      = { "Instance" },
	PitchShiftSoundEffect  = { "Instance" },
	TremoloSoundEffect     = { "Instance" },
	Attachment             = { "Instance" },
	Bone                   = { "Attachment", "Instance" },
	Beam                   = { "Instance" },
	Trail                  = { "Instance" },
	ParticleEmitter        = { "Instance" },
	BodyVelocity           = { "Instance" },
	BodyPosition           = { "Instance" },
	BodyForce              = { "Instance" },
	BodyAngularVelocity    = { "Instance" },
	BodyGyro               = { "Instance" },
	BodyThrust             = { "Instance" },
	RocketPropulsion       = { "Instance" },
	RopeConstraint         = { "Instance" },
	SpringConstraint       = { "Instance" },
	HingeConstraint        = { "Instance" },
	BallSocketConstraint   = { "Instance" },
	CylindricalConstraint  = { "Instance" },
	PrismaticConstraint    = { "Instance" },
	TorsionSpringConstraint = { "Instance" },
	UniversalConstraint    = { "Instance" },
	LinearVelocityConstraint = { "Instance" },
	AngularVelocityConstraint = { "Instance" },
	AlignPosition          = { "Instance" },
	AlignOrientation       = { "Instance" },
	WeldConstraint         = { "Instance" },
	Weld                   = { "Instance" },
	Motor6D                = { "Instance" },
	Snap                   = { "Instance" },
	ManualWeld             = { "Instance" },
	ManualGlue             = { "Instance" },
	PointLight             = { "Instance" },
	SpotLight              = { "Instance" },
	SurfaceLight           = { "Instance" },
	Atmosphere             = { "Instance" },
	Sky                    = { "Instance" },
	Bloom                  = { "Instance" },
	Blur                   = { "Instance" },
	ColorCorrection        = { "Instance" },
	DepthOfField           = { "Instance" },
	SunRaysEffect          = { "Instance" },
	Humanoid               = { "Instance" },
	HumanoidDescription    = { "Instance" },
	ScreenGui              = { "Instance" },
	BillboardGui           = { "Instance" },
	SurfaceGui             = { "Instance" },
	Frame                  = { "Instance" },
	TextLabel              = { "Instance" },
	TextButton             = { "Instance" },
	TextBox                = { "Instance" },
	ImageLabel             = { "Instance" },
	ImageButton            = { "Instance" },
	ScrollingFrame         = { "Instance" },
	VideoFrame             = { "Instance" },
	ViewportFrame          = { "Instance" },
	CanvasGroup            = { "Instance" },
	UICorner               = { "Instance" },
	UIStroke               = { "Instance" },
	UIPadding              = { "Instance" },
	UIListLayout           = { "Instance" },
	UIGridLayout           = { "Instance" },
	UITableLayout          = { "Instance" },
	UIPageLayout           = { "Instance" },
	UISizeConstraint       = { "Instance" },
	UITextSizeConstraint   = { "Instance" },
	UIAspectRatioConstraint = { "Instance" },
	UIFlexItem             = { "Instance" },
	UIGradient             = { "Instance" },
	UIScale                = { "Instance" },
	SelectionBox           = { "Instance" },
	SelectionSphere        = { "Instance" },
	BoxHandleAdornment     = { "Instance" },
	SphereHandleAdornment  = { "Instance" },
	ConeHandleAdornment    = { "Instance" },
	CylinderHandleAdornment = { "Instance" },
	Highlight              = { "Instance" },
	RemoteEvent            = { "Instance" },
	RemoteFunction         = { "Instance" },
	BindableEvent          = { "Instance" },
	BindableFunction       = { "Instance" },
}

local GuiObjectClasses = { "Frame","TextLabel","TextButton","TextBox","ImageLabel","ImageButton","ScrollingFrame","VideoFrame","ViewportFrame","CanvasGroup" }
local TextClasses      = { "TextLabel","TextButton","TextBox" }

for _, Class in ipairs(GuiObjectClasses) do
	local T = FallbackProperties[Class] or {}
	for K, V in pairs(GuiObjectBase) do if T[K] == nil then T[K] = V end end
	FallbackProperties[Class] = T
end
for _, Class in ipairs(TextClasses) do
	local T = FallbackProperties[Class]
	for K, V in pairs(TextBase) do if T[K] == nil then T[K] = V end end
end

local function ResolveFallbackProps(Inst)
	local Merged = {}
	local Class = Inst.ClassName
	local Own = FallbackProperties[Class]

	if Own then
		for K, V in pairs(Own) do
			Merged[K] = V
		end
	end

	for _, Parent in ipairs(Inheritance[Class] or { "Instance" }) do
		local P = FallbackProperties[Parent]
		if P then
			for K, V in pairs(P) do
				if Merged[K] == nil then
					Merged[K] = V
				end
			end
		end
	end

	if Merged.Name == nil or Merged.Name == "Instance" then
		Merged.Name = Class
	end

	return Merged
end

local function ResolveProps(Inst)
	local ClassSkip = ClassSkipProperties[Inst.ClassName]
		or ClassSkipProperties["BasePart"] and Inst:IsA("BasePart") and ClassSkipProperties["BasePart"]
		or {}

	if getproperties then
		local ok, Raw = pcall(getproperties, Inst)
		if ok and type(Raw) == "table" then
			local Props = {}
			for K in pairs(Raw) do
				if type(K) == "string"
					and not SkipProperties[K]
					and not ClassSkip[K]
				then
					Props[K] = true
				end
			end
			return Props
		end
	end

	local Fallback = ResolveFallbackProps(Inst)
	local Props    = {}
	for K in pairs(Fallback) do
		if not SkipProperties[K] and not ClassSkip[K] then
			local ok = pcall(function() return Inst[K] end)
			if ok then Props[K] = true end
		end
	end
	return Props
end

local function FmtNum(N)
	if N ~= N            then return "0/0"           end
	if N ==  math.huge   then return "math.huge"      end
	if N == -math.huge   then return "-math.huge"     end
	if math.floor(N) == N and math.abs(N) < 1e15 then
		return string.format("%d", N)
	end
	return string.format("%.8g", N)
end

local function FmtColor3(C)
	local R = math.round(C.R * 255)
	local G = math.round(C.G * 255)
	local B = math.round(C.B * 255)
	if math.abs(C.R - R/255) < 0.001
	and math.abs(C.G - G/255) < 0.001
	and math.abs(C.B - B/255) < 0.001 then
		return string.format("Color3.fromRGB(%d, %d, %d)", R, G, B)
	end
	return string.format("Color3.new(%s, %s, %s)", FmtNum(C.R), FmtNum(C.G), FmtNum(C.B))
end

local function FmtUDim(U)
	if U.Scale == 0 then return string.format("UDim.new(0, %d)", U.Offset) end
	if U.Offset == 0 then return string.format("UDim.new(%s, 0)", FmtNum(U.Scale)) end
	return string.format("UDim.new(%s, %d)", FmtNum(U.Scale), U.Offset)
end

local function FmtV3(V)
	if V.X == 0 and V.Y == 0 and V.Z == 0 then return "Vector3.new()" end
	return string.format("Vector3.new(%s, %s, %s)", FmtNum(V.X), FmtNum(V.Y), FmtNum(V.Z))
end

local function FmtV2(V)
	if V.X == 0 and V.Y == 0 then return "Vector2.new()" end
	return string.format("Vector2.new(%s, %s)", FmtNum(V.X), FmtNum(V.Y))
end

local function BuildGamePath(Inst)
	local Parts = {}
	local Cur = Inst

	while Cur and Cur ~= game do
		local Name = Cur.Name
		if Name:match("^[%a_][%w_]*$") then
			table.insert(Parts, 1, "." .. Name)
		else
			table.insert(Parts, 1, "[" .. string.format("%q", Name) .. "]")
		end
		Cur = Cur.Parent
	end

	return "game" .. table.concat(Parts)
end

local function SerializeValue(Val, InstVarMap)
	local T = typeof(Val)

	if T == "string"  then return string.format("%q", Val) end
	if T == "boolean" then return tostring(Val) end
	if T == "nil"     then return "nil" end

	if T == "number" then return FmtNum(Val) end

	if T == "Vector3" then return FmtV3(Val) end
	if T == "Vector2" then return FmtV2(Val) end

	if T == "Vector3int16" then
		return string.format("Vector3int16.new(%d, %d, %d)", Val.X, Val.Y, Val.Z)
	end
	if T == "Vector2int16" then
		return string.format("Vector2int16.new(%d, %d)", Val.X, Val.Y)
	end

	if T == "CFrame" then
		local X,Y,Z, R00,R01,R02, R10,R11,R12, R20,R21,R22 = Val:GetComponents()
		local Identity = R00==1 and R01==0 and R02==0
			and R10==0 and R11==1 and R12==0
			and R20==0 and R21==0 and R22==1
		if Identity then
			if X==0 and Y==0 and Z==0 then return "CFrame.new()" end
			return string.format("CFrame.new(%s, %s, %s)", FmtNum(X), FmtNum(Y), FmtNum(Z))
		end
		local ok, AX, AY, AZ = pcall(function()
			return Val:ToEulerAnglesXYZ()
		end)
		if ok then
			local Reconstructed = CFrame.new(X,Y,Z) * CFrame.fromEulerAnglesXYZ(AX,AY,AZ)
			local Rx,Ry,Rz, M00,M01,M02, M10,M11,M12, M20,M21,M22 = Reconstructed:GetComponents()
			local Close = math.abs(M00-R00)<0.0001 and math.abs(M01-R01)<0.0001
				and math.abs(M02-R02)<0.0001 and math.abs(M10-R10)<0.0001
				and math.abs(M11-R11)<0.0001 and math.abs(M12-R12)<0.0001
				and math.abs(M20-R20)<0.0001 and math.abs(M21-R21)<0.0001
				and math.abs(M22-R22)<0.0001
			if Close then
				return string.format(
					"CFrame.new(%s, %s, %s) * CFrame.fromEulerAnglesXYZ(%s, %s, %s)",
					FmtNum(X), FmtNum(Y), FmtNum(Z),
					FmtNum(AX), FmtNum(AY), FmtNum(AZ)
				)
			end
		end
		return string.format(
			"CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
			FmtNum(X),   FmtNum(Y),   FmtNum(Z),
			FmtNum(R00), FmtNum(R01), FmtNum(R02),
			FmtNum(R10), FmtNum(R11), FmtNum(R12),
			FmtNum(R20), FmtNum(R21), FmtNum(R22)
		)
	end

	if T == "Color3" then return FmtColor3(Val) end

	if T == "BrickColor" then
		return string.format('BrickColor.new("%s")', Val.Name)
	end

	if T == "UDim2" then
		local XS, XO = Val.X.Scale, Val.X.Offset
		local YS, YO = Val.Y.Scale, Val.Y.Offset
		if XS == 0 and YS == 0 then
			if XO == 0 and YO == 0 then return "UDim2.new()" end
			return string.format("UDim2.fromOffset(%d, %d)", XO, YO)
		end
		if XO == 0 and YO == 0 then
			return string.format("UDim2.fromScale(%s, %s)", FmtNum(XS), FmtNum(YS))
		end
		return string.format("UDim2.new(%s, %d, %s, %d)", FmtNum(XS), XO, FmtNum(YS), YO)
	end

	if T == "UDim" then return FmtUDim(Val) end

	if T == "Rect" then
		return string.format(
			"Rect.new(%s, %s, %s, %s)",
			FmtNum(Val.Min.X), FmtNum(Val.Min.Y),
			FmtNum(Val.Max.X), FmtNum(Val.Max.Y)
		)
	end

	if T == "NumberRange" then
		if Val.Min == Val.Max then
			return string.format("NumberRange.new(%s)", FmtNum(Val.Min))
		end
		return string.format("NumberRange.new(%s, %s)", FmtNum(Val.Min), FmtNum(Val.Max))
	end

	if T == "NumberSequence" then
		local KPs = Val.Keypoints
		if #KPs == 2
			and KPs[1].Time == 0 and KPs[2].Time == 1
			and KPs[1].Value == KPs[2].Value
			and KPs[1].Envelope == 0 and KPs[2].Envelope == 0
		then
			return string.format("NumberSequence.new(%s)", FmtNum(KPs[1].Value))
		end
		local Parts = {}
		for _, KP in ipairs(KPs) do
			if KP.Envelope ~= 0 then
				Parts[#Parts+1] = string.format(
					"NumberSequenceKeypoint.new(%s, %s, %s)",
					FmtNum(KP.Time), FmtNum(KP.Value), FmtNum(KP.Envelope)
				)
			else
				Parts[#Parts+1] = string.format(
					"NumberSequenceKeypoint.new(%s, %s)",
					FmtNum(KP.Time), FmtNum(KP.Value)
				)
			end
		end
		return "NumberSequence.new({\n\t\t"
			.. table.concat(Parts, ",\n\t\t")
			.. "\n\t})"
	end

	if T == "ColorSequence" then
		local KPs = Val.Keypoints
		local FirstValue = KPs[1].Value
		local LastValue = KPs[#KPs].Value
		if #KPs == 2
			and KPs[1].Time == 0 and KPs[2].Time == 1
			and FirstValue == LastValue
		then
			return string.format("ColorSequence.new(%s)", FmtColor3(FirstValue))
		end
		local Parts = {}
		for _, KP in ipairs(KPs) do
			Parts[#Parts+1] = string.format(
				"ColorSequenceKeypoint.new(%s, %s)",
				FmtNum(KP.Time), FmtColor3(KP.Value)
			)
		end
		return "ColorSequence.new({\n\t\t"
			.. table.concat(Parts, ",\n\t\t")
			.. "\n\t})"
	end

	if T == "Region3" then
		local Min = Val.CFrame.Position - (Val.Size / 2)
		local Max = Val.CFrame.Position + (Val.Size / 2)
		return string.format("Region3.new(%s, %s)", FmtV3(Min), FmtV3(Max))
	end

	if T == "Region3int16" then
		return string.format(
			"Region3int16.new(Vector3int16.new(%d, %d, %d), Vector3int16.new(%d, %d, %d))",
			Val.Min.X, Val.Min.Y, Val.Min.Z,
			Val.Max.X, Val.Max.Y, Val.Max.Z
		)
	end

	if T == "ColorSequenceKeypoint" then
		return string.format("ColorSequenceKeypoint.new(%s, %s)", FmtNum(Val.Time), FmtColor3(Val.Value))
	end

	if T == "NumberSequenceKeypoint" then
		if Val.Envelope ~= 0 then
			return string.format(
				"NumberSequenceKeypoint.new(%s, %s, %s)",
				FmtNum(Val.Time),
				FmtNum(Val.Value),
				FmtNum(Val.Envelope)
			)
		end
		return string.format("NumberSequenceKeypoint.new(%s, %s)", FmtNum(Val.Time), FmtNum(Val.Value))
	end

	if T == "EnumItem" then
		return string.format("Enum.%s.%s", tostring(Val.EnumType), Val.Name)
	end

	if T == "PhysicalProperties" then
		return string.format(
			"PhysicalProperties.new(%s, %s, %s, %s, %s)",
			FmtNum(Val.Density),
			FmtNum(Val.Friction),
			FmtNum(Val.Elasticity),
			FmtNum(Val.FrictionWeight),
			FmtNum(Val.ElasticityWeight)
		)
	end

	if T == "Font" then
		return string.format(
			'Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)',
			Val.Family, Val.Weight.Name, Val.Style.Name
		)
	end

	if T == "Ray" then
		return string.format("Ray.new(%s, %s)", FmtV3(Val.Origin), FmtV3(Val.Direction))
	end

	if T == "Axes" then
		local P = {}
		if Val.X then P[#P+1] = "Enum.Axis.X" end
		if Val.Y then P[#P+1] = "Enum.Axis.Y" end
		if Val.Z then P[#P+1] = "Enum.Axis.Z" end
		if #P == 0 then return "Axes.new()" end
		return "Axes.new(" .. table.concat(P, ", ") .. ")"
	end

	if T == "Faces" then
		local P = {}
		if Val.Top    then P[#P+1] = "Enum.NormalId.Top"    end
		if Val.Bottom then P[#P+1] = "Enum.NormalId.Bottom" end
		if Val.Left   then P[#P+1] = "Enum.NormalId.Left"   end
		if Val.Right  then P[#P+1] = "Enum.NormalId.Right"  end
		if Val.Front  then P[#P+1] = "Enum.NormalId.Front"  end
		if Val.Back   then P[#P+1] = "Enum.NormalId.Back"   end
		if #P == 0 then return "Faces.new()" end
		return "Faces.new(" .. table.concat(P, ", ") .. ")"
	end

	if T == "TweenInfo" then
		return string.format(
			"TweenInfo.new(%s, Enum.EasingStyle.%s, Enum.EasingDirection.%s, %s, %s, %s)",
			FmtNum(Val.Time),
			Val.EasingStyle.Name,
			Val.EasingDirection.Name,
			FmtNum(Val.RepeatCount),
			tostring(Val.Reverses),
			FmtNum(Val.DelayTime)
		)
	end

	if T == "OverlapParams" then
		return string.format(
			'(function() local p = OverlapParams.new() p.FilterType = Enum.RaycastFilterType.%s p.MaxParts = %d p.RespectCanCollide = %s return p end)()',
			Val.FilterType.Name,
			Val.MaxParts,
			tostring(Val.RespectCanCollide)
		)
	end

	if T == "RaycastParams" then
		return string.format(
			'(function() local p = RaycastParams.new() p.FilterType = Enum.RaycastFilterType.%s p.IgnoreWater = %s p.RespectCanCollide = %s return p end)()',
			Val.FilterType.Name,
			tostring(Val.IgnoreWater),
			tostring(Val.RespectCanCollide)
		)
	end

	if T == "Instance" then
		if InstVarMap and InstVarMap[Val] then return InstVarMap[Val] end
		local ok, Path = pcall(BuildGamePath, Val)
		if ok then return Path end
		return "nil"
	end

	return nil
end

local WritableProbeCache = {}
local WritablePropertyCache = {}
local DefaultPropertyCache = {}

local ReservedNames = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

local function GetWritableProbe(ClassName)
	if WritableProbeCache[ClassName] ~= nil then
		return WritableProbeCache[ClassName] or nil
	end

	local ok, Probe = pcall(Instance.new, ClassName)
	if ok then
		WritableProbeCache[ClassName] = Probe
		return Probe
	end

	WritableProbeCache[ClassName] = false
	return nil
end

local function GetDefaultPropertyValue(Inst, PropName)
	local ClassName = Inst.ClassName
	local ClassCache = DefaultPropertyCache[ClassName]
	if not ClassCache then
		ClassCache = {}
		DefaultPropertyCache[ClassName] = ClassCache
	end

	if ClassCache[PropName] ~= nil then
		local Entry = ClassCache[PropName]
		return Entry.Ok and Entry.Value or nil, Entry.Ok
	end

	local Probe = GetWritableProbe(ClassName)
	if not Probe then
		ClassCache[PropName] = { Ok = false }
		return nil, false
	end

	local ok, value = pcall(function()
		return Probe[PropName]
	end)

	ClassCache[PropName] = {
		Ok = ok,
		Value = ok and value or nil,
	}

	return value, ok
end

local function CanWriteProperty(Inst, PropName, Value)
	local ClassName = Inst.ClassName
	local ClassCache = WritablePropertyCache[ClassName]
	if not ClassCache then
		ClassCache = {}
		WritablePropertyCache[ClassName] = ClassCache
	end

	local CacheKey = PropName
	if typeof(Value) == "Instance" then
		CacheKey = PropName .. "::Instance"
	end

	if ClassCache[CacheKey] ~= nil then
		return ClassCache[CacheKey]
	end

	local Probe = GetWritableProbe(ClassName)
	if not Probe then
		ClassCache[CacheKey] = false
		return false
	end

	local ok = pcall(function()
		Probe[PropName] = Value
	end)

	ClassCache[CacheKey] = ok
	return ok
end

local function ValuesEqual(A, B, InstVarMap)
	if typeof(A) ~= typeof(B) then
		return false
	end

	if typeof(A) == "Instance" then
		return A == B
	end

	local SA = SerializeValue(A, InstVarMap)
	local SB = SerializeValue(B, InstVarMap)
	if SA and SB then
		return SA == SB
	end

	return A == B
end

local function SerializeParentValue(Parent, InstVarMap)
	if not Parent then
		return "nil"
	end

	if InstVarMap[Parent] then
		return InstVarMap[Parent]
	end

	local ok, Path = pcall(BuildGamePath, Parent)
	if ok then
		return Path
	end

	return "nil"
end

local function GetDepth(Inst)
	local Depth = 0
	local Current = Inst.Parent
	while Current do
		Depth += 1
		Current = Current.Parent
	end
	return Depth
end

local function ToVarName(Name, Fallback)
	local Parts = {}

	for Piece in tostring(Name):gmatch("[%a%d_]+") do
		if Piece ~= "" then
			Parts[#Parts + 1] = Piece
		end
	end

	if #Parts == 0 then
		Parts[1] = tostring(Fallback or "object")
	end

	for Index, Piece in ipairs(Parts) do
		local Lower = Piece:lower()
		if Index == 1 then
			Parts[Index] = Lower
		else
			Parts[Index] = Lower:sub(1, 1):upper() .. Lower:sub(2)
		end
	end

	local Result = table.concat(Parts)
	Result = Result:gsub("^_+", "")

	if Result == "" then
		Result = tostring(Fallback or "object")
	end

	if Result:match("^%d") then
		Result = "_" .. Result
	end

	if ReservedNames[Result] then
		Result = Result .. "Obj"
	end

	return Result
end

local function Build(Target)
	assert(typeof(Target) == "Instance", "[HikloSerializer] .Path must be a valid Instance")

	if Target:IsA("Model") and Target:FindFirstChildWhichIsA("Humanoid", true) then
		error("Characters cannot be built. Select a part or non-character model.")
	end

	local BuildYieldEvery = 200
	local BuildOps = 0

	local function TickBuild()
		BuildOps += 1
		if BuildOps % BuildYieldEvery == 0 and task and task.wait then
			task.wait()
		end
	end

	local Lines = {}
	local InstVarMap = {}
	local UsedNames = {}
	local NeedCS = false
	local TotalProperties = 0
	local TotalDeferredProperties = 0
	local TotalAttributes = 0
	local TotalTags = 0
	local AllInsts = { Target }
	local DeferredPropertyBlocks = {}

	local function Push(Line, ...)
		Lines[#Lines + 1] = select("#", ...) > 0 and string.format(Line, ...) or Line
	end

	local function PushBlank()
		Lines[#Lines + 1] = ""
	end

	local function PushComment(Text)
		Push("-- " .. Text)
	end

	local function PushArrayCall(FuncName, VarName, Values)
		if #Values == 0 then
			return
		end

		Push("%s(%s, {", FuncName, VarName)
		for _, Value in ipairs(Values) do
			Push("	%s,", Value)
		end
		Push("})")
	end

	local function PushMapCall(FuncName, VarName, Entries)
		if #Entries == 0 then
			return
		end

		Push("%s(%s, {", FuncName, VarName)
		for _, Entry in ipairs(Entries) do
			Push("	{ %q, %s },", Entry.Name, Entry.Value)
		end
		Push("})")
	end

	for _, Descendant in ipairs(Target:GetDescendants()) do
		AllInsts[#AllInsts + 1] = Descendant
	end

	table.sort(AllInsts, function(A, B)
		local AD = GetDepth(A)
		local BD = GetDepth(B)
		if AD ~= BD then
			return AD < BD
		end
		return A:GetFullName() < B:GetFullName()
	end)

	for Index, Inst in ipairs(AllInsts) do
		local Base = ToVarName(Inst.Name, Inst.ClassName)
		local Count = (UsedNames[Base] or 0) + 1
		UsedNames[Base] = Count
		InstVarMap[Inst] = string.format("objects[%d]", Index)

		local ok, Tags = pcall(CollectionService.GetTags, CollectionService, Inst)
		if ok and #Tags > 0 then
			NeedCS = true
		end

		TickBuild()
	end

	PushComment(("Serialized with Hiklo Serializer v%s"):format(VERSION))
	PushComment("Target: " .. Target:GetFullName())
	PushComment(("Instances: %d"):format(#AllInsts))
	PushBlank()

	if NeedCS then
		Push('local CollectionService = game:GetService("CollectionService")')
		PushBlank()
	end

	Push("local YIELD_EVERY = 250")
	Push("local _ops = 0")
	Push("local _writeErrors = 0")
	PushBlank()

	Push("local function step()")
	Push("	_ops += 1")
	Push("	if task and task.wait and _ops % YIELD_EVERY == 0 then")
	Push("		task.wait()")
	Push("	end")
	Push("end")
	PushBlank()

	Push("local function safeCall(fn)")
	Push("	local ok = pcall(fn)")
	Push("	if not ok then")
	Push("		_writeErrors += 1")
	Push("	end")
	Push("	step()")
	Push("end")
	PushBlank()

	Push("local function applyProperties(inst, props)")
	Push("	for _, entry in ipairs(props) do")
	Push("		local prop = entry[1]")
	Push("		local value = entry[2]")
	Push("		safeCall(function()")
	Push("			inst[prop] = value")
	Push("		end)")
	Push("	end")
	Push("end")
	PushBlank()

	Push("local function applyAttributes(inst, attrs)")
	Push("	for _, entry in ipairs(attrs) do")
	Push("		local name = entry[1]")
	Push("		local value = entry[2]")
	Push("		safeCall(function()")
	Push("			inst:SetAttribute(name, value)")
	Push("		end)")
	Push("	end")
	Push("end")
	PushBlank()

	if NeedCS then
		Push("local function applyTags(inst, tags)")
		Push("	for _, tag in ipairs(tags) do")
		Push("		safeCall(function()")
		Push("			CollectionService:AddTag(inst, tag)")
		Push("		end)")
		Push("	end")
		Push("end")
		PushBlank()
	end

	Push("local function attach(inst, parent)")
	Push("	safeCall(function()")
	Push("		inst.Parent = parent")
	Push("	end)")
	Push("end")
	PushBlank()

	Push("local function new(className)")
	Push("	return Instance.new(className)")
	Push("end")
	PushBlank()

	PushComment("instance declarations")
	Push("local objects = table.create(%d)", #AllInsts)
	for Index, Inst in ipairs(AllInsts) do
		Push('objects[%d] = new(%q)', Index, Inst.ClassName)
	end
	PushBlank()

	PushComment("names")
	for Index, Inst in ipairs(AllInsts) do
		Push("safeCall(function()")
		Push("\tobjects[%d].Name = %q", Index, Inst.Name)
		Push("end)")
	end
	PushBlank()

	PushComment("properties, attributes, and tags")
	for _, Inst in ipairs(AllInsts) do
		local VarName = InstVarMap[Inst]
		local PropSet = ResolveProps(Inst)
		local FallbackDefaults = ResolveFallbackProps(Inst)
		local PropNames = {}

		for PropName in pairs(PropSet) do
			PropNames[#PropNames + 1] = PropName
		end
		table.sort(PropNames)

		local PropertyEntries = {}
		local DeferredEntries = {}
		for _, PropName in ipairs(PropNames) do
			if PropName ~= "Name" then
				local ok, Value = pcall(function()
					return Inst[PropName]
				end)

				if ok and CanWriteProperty(Inst, PropName, Value) then
				local Serialized = SerializeValue(Value, InstVarMap)
				if Serialized then
					local DefaultValue, HasDefault = GetDefaultPropertyValue(Inst, PropName)
					if not HasDefault then
						DefaultValue = FallbackDefaults[PropName]
						HasDefault = DefaultValue ~= nil
					end

					if not HasDefault or not ValuesEqual(Value, DefaultValue, InstVarMap) then
						local Entry = {
							Name = PropName,
							Value = Serialized,
						}

						if typeof(Value) == "Instance" then
							DeferredEntries[#DeferredEntries + 1] = Entry
							TotalDeferredProperties += 1
						else
							PropertyEntries[#PropertyEntries + 1] = Entry
							TotalProperties += 1
						end
					end
				end
				end
			end

			TickBuild()
		end

		table.sort(PropertyEntries, function(A, B)
			if A.Name == "Name" then
				return B.Name ~= "Name"
			end
			if B.Name == "Name" then
				return false
			end
			return A.Name < B.Name
		end)

		table.sort(DeferredEntries, function(A, B)
			return A.Name < B.Name
		end)

		local AttrMap = Inst:GetAttributes()
		local AttrNames = {}
		for AttrName in pairs(AttrMap) do
			AttrNames[#AttrNames + 1] = AttrName
		end
		table.sort(AttrNames)

		local AttributeEntries = {}
		for _, AttrName in ipairs(AttrNames) do
			local Serialized = SerializeValue(AttrMap[AttrName], InstVarMap)
			if Serialized then
				AttributeEntries[#AttributeEntries + 1] = {
					Name = AttrName,
					Value = Serialized,
				}
				TotalAttributes += 1
			end
			TickBuild()
		end

		local Tags = {}
		local ok, ReadTags = pcall(CollectionService.GetTags, CollectionService, Inst)
		if ok and #ReadTags > 0 then
			table.sort(ReadTags)
			for _, Tag in ipairs(ReadTags) do
				Tags[#Tags + 1] = string.format("%q", Tag)
				TotalTags += 1
			end
		end

		if #DeferredEntries > 0 then
			DeferredPropertyBlocks[#DeferredPropertyBlocks + 1] = {
				VarName = VarName,
				Entries = DeferredEntries,
				ClassName = Inst.ClassName,
				Name = Inst.Name,
			}
		end

		if #PropertyEntries > 0 or #AttributeEntries > 0 or #Tags > 0 then
			PushComment(("[%s] %s"):format(Inst.ClassName, Inst.Name))
			if #PropertyEntries > 0 then
				PushMapCall("applyProperties", VarName, PropertyEntries)
			end
			if #AttributeEntries > 0 then
				PushMapCall("applyAttributes", VarName, AttributeEntries)
			end
			if #Tags > 0 and NeedCS then
				PushArrayCall("applyTags", VarName, Tags)
			end
			PushBlank()
		end
	end

	PushComment("parent assignments")
	for _, Inst in ipairs(AllInsts) do
		Push("attach(%s, %s)", InstVarMap[Inst], SerializeParentValue(Inst.Parent, InstVarMap))
		TickBuild()
	end
	PushBlank()

	if #DeferredPropertyBlocks > 0 then
		PushComment("instance reference properties")
		for _, Block in ipairs(DeferredPropertyBlocks) do
			PushComment(("[%s] %s"):format(Block.ClassName, Block.Name))
			PushMapCall("applyProperties", Block.VarName, Block.Entries)
			PushBlank()
		end
	end

	PushComment(("property writes: %d"):format(TotalProperties + TotalDeferredProperties))
	PushComment(("attribute writes: %d"):format(TotalAttributes))
	if NeedCS then
		PushComment(("tag writes: %d"):format(TotalTags))
	end
	PushBlank()

	Push("if _writeErrors > 0 then")
	Push('	warn(("[Builder] skipped %d write%s"):format(_writeErrors, _writeErrors == 1 and "" or "s"))')
	Push("end")
	PushBlank()
	Push("return objects[1]")

	return table.concat(Lines, "\n")
end

local HikloSerializer = {}
HikloSerializer.__index = HikloSerializer
HikloSerializer.Path = nil
HikloSerializer.Version = VERSION

function HikloSerializer:Build()
	assert(self.Path ~= nil, "[HikloSerializer] .Path is not set")
	return Build(self.Path)
end

function HikloSerializer:Save(FileName)
	local Output = self:Build()
	local Name = FileName or ("hiklo_" .. tostring(self.Path.Name):gsub("[^%w]", "_") .. "_" .. os.time() .. ".lua")

	if writefile then
		writefile(Name, Output)
		warn("[HikloSerializer] Saved -> " .. Name)
	end

	if setclipboard then
		setclipboard(Output)
		warn("[HikloSerializer] Copied to clipboard")
	end

	if not writefile and not setclipboard then
		print(Output)
	end

	return Output
end

return HikloSerializer
