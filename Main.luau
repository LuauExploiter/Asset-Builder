--[[
	Hiklo Serializer v4.2.1
	- Fixed Enum.Style error.
	- Characters (models containing Humanoid) are rejected.
	- Generated output now uses objects[...] storage instead of per-instance locals.
]]

local CollectionService = game:GetService("CollectionService")
local VERSION = "4.2.1"

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
	local Cur   = Inst
	while Cur and Cur ~= game do
		local N = Cur.Name
		if N:match("^[%a_][%w_]*$") then
			table.insert(Parts, 1, "." .. N)
		else
			table.insert(Parts, 1, string.format('["%s"]', N:gsub('"', '\\"')))
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

local function CanWriteProperty(Inst, PropName, Value)
	local ClassName = Inst.ClassName
	local ClassCache = WritablePropertyCache[ClassName]
	if not ClassCache then
		ClassCache = {}
		WritablePropertyCache[ClassName] = ClassCache
	end

	if ClassCache[PropName] ~= nil then
		return ClassCache[PropName]
	end

	local Probe = GetWritableProbe(ClassName)
	if not Probe then
		ClassCache[PropName] = false
		return false
	end

	local ok = pcall(function()
		Probe[PropName] = Value
	end)

	ClassCache[PropName] = ok
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

local function ShouldSkipRedundantProperty(Inst, PropName, PropSet)
	if PropSet.CFrame then
		if (Inst:IsA("BasePart") or Inst:IsA("Attachment") or Inst:IsA("Bone")) and (
			PropName == "Position"
			or PropName == "Orientation"
			or PropName == "Rotation"
		) then
			return true
		end
	end

	if PropSet.WorldCFrame then
		if (Inst:IsA("Attachment") or Inst:IsA("Bone")) and (
			PropName == "WorldPosition"
			or PropName == "WorldOrientation"
		) then
			return true
		end
	end

	return false
end

local function GetPropertyOrderRank(Inst, PropName)
	if PropName == "Name" then
		return 0
	end

	if Inst:IsA("BasePart") then
		if PropName == "Anchored" then
			return 1
		end
		if PropName == "Size" then
			return 2
		end
		if PropName == "CFrame" then
			return 3
		end
		if PropName == "Position" or PropName == "Orientation" or PropName == "Rotation" then
			return 4
		end
	end

	if Inst:IsA("Attachment") or Inst:IsA("Bone") then
		if PropName == "CFrame" then
			return 3
		end
		if PropName == "Position" or PropName == "Orientation" then
			return 4
		end
	end

	if Inst:IsA("Model") and PropName == "WorldPivot" then
		return 3
	end

	return 50
end

local function Build(Target)
	assert(typeof(Target) == "Instance", "[HikloSerializer] .Path must be a valid Instance")

	if Target:IsA("Model") and Target:FindFirstChildWhichIsA("Humanoid", true) then
		error("Characters cannot be built. Select a part or non-character model.")
	end

	local Lines = {}
	local DeferredRefs = {}
	local InstVarMap = {}
	local UsedNames = {}
	local NeedCS = false

	local function Push(S, ...)
		Lines[#Lines + 1] = select("#", ...) > 0 and string.format(S, ...) or S
	end

	local function PushBlank()
		Lines[#Lines + 1] = ""
	end

	local function PushSection(Title)
		Push(string.rep("-", 64))
		Push("-- " .. Title)
		Push(string.rep("-", 64))
		PushBlank()
	end

	local function MakeVar(Inst)
		local Base = Inst.Name:gsub("[^%w_]", "_")
		Base = Base:gsub("_+", "_")
		Base = Base:gsub("^_+", "")
		Base = Base:gsub("_+$", "")

		if Base == "" then
			Base = Inst.ClassName
		end

		if Base:match("^%d") then
			Base = "_" .. Base
		end

		if ReservedNames[Base] then
			Base = Base .. "_obj"
		end

		local Count = (UsedNames[Base] or 0) + 1
		UsedNames[Base] = Count

		if Count == 1 then
			return Base
		end

		return Base .. Count
	end

	local AllInsts = { Target }
	for _, Descendant in ipairs(Target:GetDescendants()) do
		AllInsts[#AllInsts + 1] = Descendant
	end

	for Index, Inst in ipairs(AllInsts) do
		InstVarMap[Inst] = string.format("objects[%d]", Index)
		if #CollectionService:GetTags(Inst) > 0 then
			NeedCS = true
		end
	end

	Push("-- Serialized with Hiklo Serializer v%s", VERSION)
	Push("-- Target: %s", Target:GetFullName())
	Push("-- Instances: %d", #AllInsts)
	Push("-- Storage: objects table (no per-instance locals)")
	PushBlank()

	if NeedCS then
		Push('local CollectionService = game:GetService("CollectionService")')
		PushBlank()
	end

	Push('local function set(inst, prop, value)')
	Push('	pcall(function()')
	Push('		inst[prop] = value')
	Push('	end)')
	Push('end')
	PushBlank()

	Push('local function setParent(inst, parent)')
	Push('	pcall(function()')
	Push('		inst.Parent = parent')
	Push('	end)')
	Push('end')
	PushBlank()

	Push('local function setAttr(inst, name, value)')
	Push('	pcall(function()')
	Push('		inst:SetAttribute(name, value)')
	Push('	end)')
	Push('end')
	PushBlank()

	if NeedCS then
		Push('local function addTag(inst, tag)')
		Push('	pcall(function()')
		Push('		CollectionService:AddTag(inst, tag)')
		Push('	end)')
		Push('end')
		PushBlank()
	end

	PushSection("Instance Declarations")
	Push('local objects = {}')
	for Index, Inst in ipairs(AllInsts) do
		Push('objects[%d] = Instance.new(%q)', Index, Inst.ClassName)
	end
	PushBlank()

	PushSection("Properties, Attributes, and Tags")
	for _, Inst in ipairs(AllInsts) do
		local Var = InstVarMap[Inst]
		local PropSet = ResolveProps(Inst)
		local PropNames = {}

		for PropName in pairs(PropSet) do
			PropNames[#PropNames + 1] = PropName
		end
		table.sort(PropNames, function(A, B)
			local ARank = GetPropertyOrderRank(Inst, A)
			local BRank = GetPropertyOrderRank(Inst, B)
			if ARank ~= BRank then
				return ARank < BRank
			end
			return A < B
		end)

		local HasLines = false
		local function EnsureHeader()
			if HasLines then
				return
			end
			Push('-- [%s] %s', Inst.ClassName, Inst.Name)
			HasLines = true
		end

		for _, PropName in ipairs(PropNames) do
			local ok, Value = pcall(function()
				return Inst[PropName]
			end)
			if not ok then
				continue
			end

			local Serialized = SerializeValue(Value, InstVarMap)
			if not Serialized then
				continue
			end

			if ShouldSkipRedundantProperty(Inst, PropName, PropSet) then
				continue
			end

			if not CanWriteProperty(Inst, PropName, Value) then
				continue
			end

			if typeof(Value) == "Instance" then
				DeferredRefs[#DeferredRefs + 1] = string.format('set(%s, %q, %s)', Var, PropName, Serialized)
			else
				EnsureHeader()
				Push('set(%s, %q, %s)', Var, PropName, Serialized)
			end
		end

		local AttrMap = Inst:GetAttributes()
		local AttrNames = {}
		for AttrName in pairs(AttrMap) do
			AttrNames[#AttrNames + 1] = AttrName
		end
		table.sort(AttrNames)

		for _, AttrName in ipairs(AttrNames) do
			local Serialized = SerializeValue(AttrMap[AttrName], InstVarMap)
			if Serialized then
				EnsureHeader()
				Push('setAttr(%s, %q, %s)', Var, AttrName, Serialized)
			end
		end

		local Tags = CollectionService:GetTags(Inst)
		if #Tags > 0 then
			table.sort(Tags)
			for _, Tag in ipairs(Tags) do
				EnsureHeader()
				Push('addTag(%s, %q)', Var, Tag)
			end
		end

		if HasLines then
			PushBlank()
		end
	end

	PushSection("Parent Assignments")
	for _, Inst in ipairs(AllInsts) do
		Push('setParent(%s, %s)', InstVarMap[Inst], SerializeParentValue(Inst.Parent, InstVarMap))
	end
	PushBlank()

	if #DeferredRefs > 0 then
		PushSection("Instance Reference Properties")
		for _, Line in ipairs(DeferredRefs) do
			Push(Line)
		end
		PushBlank()
	end

	return table.concat(Lines, "\n")
end

local HikloSerializer    = {}
HikloSerializer.__index  = HikloSerializer
HikloSerializer.Path     = nil
HikloSerializer.Version  = VERSION

function HikloSerializer:Build()
	assert(self.Path ~= nil, "[HikloSerializer] .Path is not set")
	return Build(self.Path)
end

function HikloSerializer:Save(FileName)
	local Output = self:Build()
	local Name   = FileName
		or ("hiklo_" .. tostring(self.Path.Name):gsub("[^%w]", "_") .. "_" .. os.time() .. ".lua")
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
