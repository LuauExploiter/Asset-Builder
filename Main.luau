-- HikloSerializer v6.0.0
-- Full Roblox instance hierarchy serializer.
-- NEW in 6.0: decompile cleaner, module [[]] inlining, getconnections
--             capture, IKControl, full Audio API, TextChat, Dialog,
--             expanded property tables, better script handling.

local CollectionService = game:GetService("CollectionService")
local VERSION = "6.0.0"

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
	YieldEveryInstances     = 75,
	OutputYieldEvery        = 150,
	OutputYieldEveryObjects = 100,
	ConvertScriptsToInline  = true,
	CleanDecompiledSource   = true,  -- run multi-pass cleaner on decompiled code
	InlineModules           = true,  -- wrap ModuleScript source in [[]] + loadstring
	CaptureConnections      = true,  -- use getconnections to dump signal handlers
	AnnotateDecompiled      = true,  -- prepend [DECOMPILED] comment on decompiled blocks
}

-- ============================================================
-- SKIP TABLES
-- ============================================================
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
	-- Audio runtime
	IsReady = true, PeakLevel = true, RmsLevel = true,
	-- IK runtime
	ActivePose = true,
}

local ClassSkipProperties = {
	Humanoid = {
		Health = true, Jump = true, Sit = true, TargetPoint = true,
		WalkToPoint = true, WalkToPart = true, MoveDirection = true,
		LookVector = true, RootPart = true, Torso = true,
	},
	BasePart = {
		Velocity = true, RotVelocity = true,
		AssemblyAngularVelocity = true, AssemblyLinearVelocity = true,
	},
	Camera = { CoordinateFrame = true },
	AudioPlayer = { TimeLength = true, IsReady = true, IsPlaying = true },
}

-- ============================================================
-- FALLBACK PROPERTIES
-- ============================================================
local FallbackProperties = {}

FallbackProperties["Instance"] = { Name = "Instance", Archivable = true }

FallbackProperties["BasePart"] = {
	Anchored = false, CanCollide = true, CanTouch = true, CanQuery = true,
	CastShadow = true, CFrame = CFrame.new(),
	Color = Color3.new(0.639216, 0.635294, 0.647059),
	CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.1, 0.1),
	EnableFluidForces = true, Locked = false, Massless = false,
	Material = Enum.Material.SmoothPlastic, MaterialVariant = "",
	Position = Vector3.new(), Reflectance = 0,
	RenderFidelity = Enum.RenderFidelity.Automatic, Rotation = Vector3.new(),
	Size = Vector3.new(4, 1, 2), Transparency = 0,
	CollisionGroup = "Default",
}
FallbackProperties["Part"]             = { Shape = Enum.PartType.Block }
FallbackProperties["WedgePart"]        = {}
FallbackProperties["CornerWedgePart"]  = {}
FallbackProperties["TrussPart"]        = {}
FallbackProperties["SpawnLocation"] = {
	AllowTeamChangeOnTouch = false, Duration = 10, Enabled = true,
	Neutral = true, TeamColor = BrickColor.new("White"),
}
FallbackProperties["Platform"]     = {}
FallbackProperties["Seat"]         = { Disabled = false }
FallbackProperties["VehicleSeat"] = {
	Disabled = false, HeadsUpDisplay = true, MaxSpeed = 100,
	Steer = 0, SteerFloat = 0, Throttle = 0, ThrottleFloat = 0, TurnSpeed = 1,
}
FallbackProperties["MeshPart"] = {
	DoubleSided = false, MeshId = "", MeshSize = Vector3.new(1, 1, 1),
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionFidelity = Enum.CollisionFidelity.Default,
	TextureID = "",
}
FallbackProperties["PartOperation"] = {
	SmoothingAngle = 30, UsePartColor = false,
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionFidelity = Enum.CollisionFidelity.Default,
}
FallbackProperties["UnionOperation"]  = FallbackProperties["PartOperation"]
FallbackProperties["NegateOperation"] = FallbackProperties["PartOperation"]
FallbackProperties["IntersectOperation"] = FallbackProperties["PartOperation"]

FallbackProperties["SpecialMesh"] = {
	MeshId = "", TextureId = "", MeshType = Enum.MeshType.Head,
	Offset = Vector3.new(), RotationOffset = Vector3.new(),
	Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1),
}
FallbackProperties["CylinderMesh"] = {
	Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1),
}
FallbackProperties["BlockMesh"] = {
	Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1),
}
FallbackProperties["FileMesh"] = {
	MeshId = "", TextureId = "", Offset = Vector3.new(),
	Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1),
}
FallbackProperties["Decal"] = {
	Color3 = Color3.new(1, 1, 1), Face = Enum.NormalId.Front,
	Texture = "", Transparency = 0, ZIndex = 0,
}
FallbackProperties["Texture"] = {
	Color3 = Color3.new(1, 1, 1), Face = Enum.NormalId.Front,
	OffsetStudsU = 0, OffsetStudsV = 0, StudsPerTileU = 2, StudsPerTileV = 2,
	Texture = "", Transparency = 0,
}
FallbackProperties["SurfaceAppearance"] = {
	AlphaMode = Enum.AlphaMode.Overlay, ColorMap = "", MetalnessMap = "",
	NormalMap = "", RoughnessMap = "", TexturePack = "",
	Color = Color3.new(1, 1, 1), Roughness = 0.5, Metalness = 0,
}
FallbackProperties["Model"]  = { LevelOfDetail = Enum.ModelLevelOfDetail.Disabled, WorldPivot = CFrame.new() }
FallbackProperties["Folder"] = {}
FallbackProperties["Tool"] = {
	CanBeDropped = true, Enabled = true, Grip = CFrame.new(),
	GripForward = Vector3.new(0, 0, -1), GripPos = Vector3.new(),
	GripRight = Vector3.new(1, 0, 0), GripUp = Vector3.new(0, 1, 0),
	ManualActivationOnly = false, RequiresHandle = true, ToolTip = "",
}
FallbackProperties["Backpack"]    = {}
FallbackProperties["StarterPack"] = {}
FallbackProperties["StarterGear"] = {}
FallbackProperties["Hat"] = {
	AttachmentForward = Vector3.new(0, 0, -1), AttachmentPos = Vector3.new(),
	AttachmentRight = Vector3.new(1, 0, 0), AttachmentUp = Vector3.new(0, 1, 0),
}
FallbackProperties["Accessory"] = {
	AccessoryType = Enum.AccessoryType.Hat, AttachmentPoint = CFrame.new(),
}
FallbackProperties["Script"]       = { Disabled = false, RunContext = Enum.RunContext.Legacy, Source = "" }
FallbackProperties["LocalScript"]  = { Disabled = false, Source = "" }
FallbackProperties["ModuleScript"] = { Source = "" }

FallbackProperties["StringValue"]    = { Value = "" }
FallbackProperties["NumberValue"]    = { Value = 0 }
FallbackProperties["BoolValue"]      = { Value = false }
FallbackProperties["IntValue"]       = { Value = 0 }
FallbackProperties["Vector3Value"]   = { Value = Vector3.new() }
FallbackProperties["CFrameValue"]    = { Value = CFrame.new() }
FallbackProperties["ObjectValue"]    = { Value = nil }
FallbackProperties["Color3Value"]    = { Value = Color3.new() }
FallbackProperties["BrickColorValue"] = { Value = BrickColor.new("Medium stone grey") }
FallbackProperties["RayValue"]       = { Value = Ray.new(Vector3.new(), Vector3.new()) }

FallbackProperties["Animation"] = { AnimationId = "" }
FallbackProperties["Animator"]  = {}
FallbackProperties["AnimationController"] = {}
FallbackProperties["AnimationTrack"]      = {}

FallbackProperties["BodyColors"] = {
	HeadColor3    = Color3.fromRGB(163, 162, 165),
	LeftArmColor3 = Color3.fromRGB(163, 162, 165),
	LeftLegColor3 = Color3.fromRGB(163, 162, 165),
	RightArmColor3 = Color3.fromRGB(163, 162, 165),
	RightLegColor3 = Color3.fromRGB(163, 162, 165),
	TorsoColor3    = Color3.fromRGB(163, 162, 165),
}
FallbackProperties["CharacterMesh"] = {
	BaseTextureId = 0, BodyPart = Enum.BodyPart.Head,
	MeshId = 0, OverlayTextureId = 0,
}
FallbackProperties["Pants"]       = { PantsTemplate = "" }
FallbackProperties["Shirt"]       = { ShirtTemplate = "" }
FallbackProperties["ShirtGraphic"] = { Color3 = Color3.new(1, 1, 1), Graphic = "" }
FallbackProperties["WrapLayer"] = {
	AutoSkin = Enum.WrapLayerAutoSkin.Disabled, BindOffset = CFrame.new(),
	Color = BrickColor.new("Bright blue"), DebugHeatmap = false, Enabled = true,
	InflateDelta = 0, Order = 0, Puffiness = 0, ReferenceMeshId = "",
	ReferenceOrigin = CFrame.new(), ShrinkDelta = 0,
}
FallbackProperties["WrapTarget"] = {
	CageMeshId = "", CageOrigin = CFrame.new(),
	Color = BrickColor.new("Bright blue"), DebugHeatmap = false,
	Enabled = true, Stiffness = 0,
}

-- IK
FallbackProperties["IKControl"] = {
	ChainRoot = nil, Enabled = true, EndEffector = nil,
	Offset = CFrame.new(), Pole = nil, Priority = 0,
	SmoothTime = 0, Target = nil,
	Type = Enum.IKControlType.Transform, Weight = 1,
}

-- Sounds (legacy)
FallbackProperties["Sound"] = {
	EmitterSize = 10, Looped = false, MaxDistance = 10000,
	Playing = false, PlayOnRemove = false, PlaybackRegionsEnabled = false,
	PlaybackSpeed = 1, RollOffMaxDistance = 10000, RollOffMinDistance = 10,
	RollOffMode = Enum.RollOffMode.InverseTapered,
	SoundGroup = nil, SoundId = "", TimePosition = 0, Volume = 0.5,
}
FallbackProperties["SoundService"] = {
	AmbientReverb = Enum.ReverbType.NoReverb, DistanceFactor = 3.33,
	DopplerScale = 1, RespectFilteringEnabled = true,
	VolumetricAudio = Enum.VolumetricAudio.Disabled,
}
FallbackProperties["EqualizerSoundEffect"]  = { HighGain = 0, LowGain = 0, MidGain = 0, Priority = 0 }
FallbackProperties["ReverbSoundEffect"]     = { DecayTime = 1.5, Density = 1, Diffusion = 1, DryLevel = -6, Priority = 0, WetLevel = 0 }
FallbackProperties["ChorusSoundEffect"]     = { Depth = 1, Priority = 0, Rate = 0.45, Mix = 50 }
FallbackProperties["CompressorSoundEffect"] = { Attack = 0.003, GainMakeup = 0, Priority = 0, Release = 0.5, SideChain = nil, Threshold = -24 }
FallbackProperties["DistortionSoundEffect"] = { Level = 0, Priority = 0 }
FallbackProperties["EchoSoundEffect"]       = { Delay = 1, DryLevel = 0, FeedBack = 0.5, Priority = 0, WetLevel = -6 }
FallbackProperties["FlangeSoundEffect"]     = { Depth = 45, Mix = 50, Priority = 0, Rate = 0.45 }
FallbackProperties["PitchShiftSoundEffect"] = { Octave = 1, Priority = 0 }
FallbackProperties["TremoloSoundEffect"]    = { Depth = 1, Duty = 50, Frequency = 5, Priority = 0 }

-- New Audio API
FallbackProperties["AudioPlayer"] = {
	AssetId = "", Looping = false, PlaybackRegionsEnabled = false,
	PlaybackSpeed = 1, TimePosition = 0, Volume = 1,
}
FallbackProperties["AudioEmitter"]          = {}
FallbackProperties["AudioListener"]         = {}
FallbackProperties["AudioAnalyzer"]         = {}
FallbackProperties["AudioChorus"] = {
	Bypass = false, Depth = 0.15, Mix = 0.5, Rate = 0.5,
}
FallbackProperties["AudioCompressor"] = {
	Attack = 0.05, Bypass = false, GainMakeup = 0,
	Ratio = 4, Release = 0.1, Threshold = -24,
}
FallbackProperties["AudioDistortion"]  = { Bypass = false, Level = 0 }
FallbackProperties["AudioEqualizer"]   = { Bypass = false, HighGain = 0, LowGain = 0, MidGain = 0 }
FallbackProperties["AudioFader"]       = { Bypass = false, Volume = 1 }
FallbackProperties["AudioFlanger"]     = { Bypass = false, Depth = 45, Mix = 0.5, Rate = 0.5 }
FallbackProperties["AudioPitchShifter"] = { Bypass = false, Octave = 1 }
FallbackProperties["AudioReverb"] = {
	Bypass = false, DecayTime = 1.5, Density = 1, Diffusion = 1,
	DryLevel = 0, WetLevel = -6,
}
FallbackProperties["AudioTremolo"] = { Bypass = false, Depth = 1, Duty = 50, Frequency = 5 }
FallbackProperties["AudioDeviceInput"]  = { Active = false, Muted = false, Player = nil }
FallbackProperties["AudioDeviceOutput"] = { Muted = false, Player = nil }
FallbackProperties["Wire"]              = {}

-- Attachments / Bones
FallbackProperties["Attachment"] = {
	Axis = Vector3.new(1, 0, 0), CFrame = CFrame.new(),
	Orientation = Vector3.new(), Position = Vector3.new(),
	SecondaryAxis = Vector3.new(0, 1, 0), Visible = false,
	WorldAxis = Vector3.new(1, 0, 0), WorldCFrame = CFrame.new(),
	WorldOrientation = Vector3.new(), WorldPosition = Vector3.new(),
	WorldSecondaryAxis = Vector3.new(0, 1, 0),
}
FallbackProperties["Bone"] = {
	CFrame = CFrame.new(), Orientation = Vector3.new(), Position = Vector3.new(),
	Transform = CFrame.new(), WorldCFrame = CFrame.new(), WorldPosition = Vector3.new(),
}

-- Effects
FallbackProperties["Beam"] = {
	Attachment0 = nil, Attachment1 = nil, Brightness = 1,
	Color = ColorSequence.new(Color3.new(1, 1, 1)), CurveSize0 = 0, CurveSize1 = 0,
	Enabled = true, FaceCamera = false, LightEmission = 0, LightInfluence = 1,
	Segments = 10, Texture = "", TextureLength = 1,
	TextureMode = Enum.TextureMode.Stretch, TextureSpeed = 1,
	Transparency = NumberSequence.new(0), Width0 = 1, Width1 = 1, ZOffset = 0,
}
FallbackProperties["Trail"] = {
	Attachment0 = nil, Attachment1 = nil, Brightness = 1,
	Color = ColorSequence.new(Color3.new(1, 1, 1)), Enabled = true,
	FaceCamera = false, Lifetime = 2, LightEmission = 0, LightInfluence = 1,
	MaxLength = 0, MinLength = 0, Texture = "", TextureLength = 1,
	TextureMode = Enum.TextureMode.Stretch,
	Transparency = NumberSequence.new(0), WidthScale = NumberSequence.new(1),
}
FallbackProperties["ParticleEmitter"] = {
	Acceleration = Vector3.new(), Brightness = 1,
	Color = ColorSequence.new(Color3.new(1, 1, 1)), Drag = 0,
	EmissionDirection = Enum.NormalId.Top, Enabled = true,
	FlipbookFramerate = NumberRange.new(30), FlipbookIncompatible = "",
	FlipbookLayout = Enum.ParticleFlipbookLayout.None,
	FlipbookMode = Enum.ParticleFlipbookMode.Loop,
	LifeTime = NumberRange.new(5, 10), LightEmission = 0, LightInfluence = 1,
	LockedToPart = false, Orientation = Enum.ParticleOrientation.FacingCamera,
	Rate = 20, RotSpeed = NumberRange.new(0), Rotation = NumberRange.new(0),
	ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
	Size = NumberSequence.new(1), Speed = NumberRange.new(5),
	SpreadAngle = Vector2.new(), Squash = NumberSequence.new(0),
	Texture = "rbxasset://textures/particles/smoke_main.dds",
	Transparency = NumberSequence.new(0), VelocityInheritance = 0, ZOffset = 0,
}
FallbackProperties["Fire"] = {
	Color = Color3.fromRGB(255, 100, 0), Enabled = true, Heat = 9,
	SecondaryColor = Color3.fromRGB(255, 255, 0), Size = 5, TimeScale = 1,
}
FallbackProperties["Smoke"] = {
	Color = Color3.fromRGB(150, 150, 150), Enabled = true,
	Opacity = 0.5, RiseVelocity = 1, Size = 1, TimeScale = 1,
}
FallbackProperties["Sparkles"] = {
	Color = Color3.new(1, 1, 1), Enabled = true,
	SparkleColor = Color3.new(1, 1, 1), TimeScale = 1,
}

-- Constraints (modern)
FallbackProperties["RopeConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, Length = 5, Restitution = 0, Thickness = 0.1, Visible = false,
}
FallbackProperties["SpringConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Coils = 5, Damping = 0, Enabled = true, FreeLength = 5, LimitsEnabled = false,
	MaxLength = 5, MinLength = 0, Radius = 0.15, Restitution = 0,
	Stiffness = 10, Thickness = 0.055, Visible = false,
}
FallbackProperties["HingeConstraint"] = {
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
	UpperAngle = 45, UpperLimit = 0, Visible = false, WorldLimitsEnabled = false,
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
FallbackProperties["LinearVelocityConstraint"] = {
	Attachment0 = nil, Attachment1 = nil, Color = BrickColor.new("Bright blue"),
	Enabled = true, ForceLimitMode = Enum.ForceLimitMode.Magnitude,
	LineDirection = Vector3.new(0, 1, 0), LineVelocity = 0,
	MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
	MaxForce = math.huge, PlaneVelocity = Vector2.new(),
	PrimaryTangentAxis = Vector3.new(1, 0, 0),
	RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
	SecondaryTangentAxis = Vector3.new(0, 0, 1),
	VectorVelocity = Vector3.new(),
	VelocityConstraintMode = Enum.VelocityConstraintMode.Vector, Visible = false,
}
FallbackProperties["AngularVelocityConstraint"] = {
	Attachment0 = nil, Attachment1 = nil,
	AngularVelocity = Vector3.new(0, 1, 0),
	Color = BrickColor.new("Bright blue"), Enabled = true,
	MaxTorque = math.huge, ReactionTorqueEnabled = false,
	RelativeTo = Enum.ActuatorRelativeTo.Attachment0, Visible = false,
}
FallbackProperties["AlignPosition"] = {
	Attachment0 = nil, Attachment1 = nil, ApplyAtCenterOfMass = false,
	Color = BrickColor.new("Bright blue"), Enabled = true,
	ForceLimitMode = Enum.ForceLimitMode.Magnitude,
	MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
	MaxForce = math.huge, MaxVelocity = math.huge,
	Mode = Enum.PositionAlignmentMode.TwoAttachment,
	Position = Vector3.new(), ReactionForceEnabled = false,
	Responsiveness = 200, RigidityEnabled = false, Visible = false,
}
FallbackProperties["AlignOrientation"] = {
	Attachment0 = nil, Attachment1 = nil,
	CFrame = CFrame.new(), Color = BrickColor.new("Bright blue"), Enabled = true,
	MaxAngularVelocity = math.huge, MaxTorque = math.huge,
	Mode = Enum.OrientationAlignmentMode.TwoAttachment,
	PrimaryAxis = Vector3.new(0, 1, 0), PrimaryAxisOnly = false,
	ReactionTorqueEnabled = false, Responsiveness = 200, RigidityEnabled = false,
	SecondaryAxis = Vector3.new(1, 0, 0), Visible = false,
}
FallbackProperties["WeldConstraint"] = { Enabled = true }
FallbackProperties["Weld"]     = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["Motor6D"]  = {
	C0 = CFrame.new(), C1 = CFrame.new(), CurrentAngle = 0,
	DesiredAngle = 0, MaxVelocity = 0.1, Part0 = nil, Part1 = nil,
}
FallbackProperties["Snap"]       = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualWeld"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualGlue"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }

-- Legacy body movers
FallbackProperties["BodyVelocity"]        = { MaxForce = Vector3.new(4000,4000,4000), P = 10000, Velocity = Vector3.new() }
FallbackProperties["BodyPosition"]        = { D = 500, MaxForce = Vector3.new(4000,4000,4000), P = 10000, Position = Vector3.new() }
FallbackProperties["BodyForce"]           = { Force = Vector3.new() }
FallbackProperties["BodyAngularVelocity"] = { AngularVelocity = Vector3.new(), MaxTorque = Vector3.new(4000,4000,4000), P = 10000 }
FallbackProperties["BodyGyro"]            = { CFrame = CFrame.new(), D = 500, MaxTorque = Vector3.new(4000,4000,4000), P = 10000 }
FallbackProperties["BodyThrust"]          = { Force = Vector3.new(), Location = Vector3.new() }
FallbackProperties["RocketPropulsion"] = {
	CartoonFactor = 0.7, MaxSpeed = 50, MaxThrust = 4000,
	MaxTorque = Vector3.new(4000,4000,0), P = 10000,
	TargetOffset = Vector3.new(), TargetRadius = 4,
	ThrustD = 500, ThrustP = 100, TurnD = 500, TurnP = 100,
}

-- Lights
FallbackProperties["PointLight"]   = { Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Range = 16, Shadows = false }
FallbackProperties["SpotLight"]    = { Angle = 45, Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false }
FallbackProperties["SurfaceLight"] = { Angle = 90, Brightness = 1, Color = Color3.new(1,1,1), Enabled = true, Face = Enum.NormalId.Front, Range = 16, Shadows = false }

-- Environment
FallbackProperties["Atmosphere"] = {
	Color = Color3.fromRGB(199,199,199), Decay = Color3.fromRGB(255,255,255),
	Density = 0.395, Glare = 0, Haze = 0, Offset = 0,
}
FallbackProperties["Sky"] = {
	CelestialBodiesShown = true, MoonAngularSize = 11, MoonTextureId = "",
	SkyboxBk = "", SkyboxDn = "", SkyboxFt = "", SkyboxLf = "", SkyboxRt = "", SkyboxUp = "",
	StarCount = 3000, SunAngularSize = 21, SunTextureId = "",
}
FallbackProperties["Clouds"]         = { Cover = 0.5, Density = 0.9, Enabled = true }
FallbackProperties["Bloom"]          = { Enabled = true, Intensity = 0.5, Size = 56, Threshold = 0.95 }
FallbackProperties["Blur"]           = { Enabled = true, Size = 24 }
FallbackProperties["ColorCorrection"] = { Brightness = 0, Contrast = 0, Enabled = true, Saturation = 0, TintColor = Color3.new(1,1,1) }
FallbackProperties["DepthOfField"]   = { Enabled = true, FarIntensity = 0, FocusDistance = 50, InFocusRadius = 10, NearIntensity = 0 }
FallbackProperties["SunRaysEffect"]  = { Enabled = true, Intensity = 0.5, Spread = 1 }

-- Interaction
FallbackProperties["ProximityPrompt"] = {
	ActionText = "Interact", AutoLocalize = true, ClickablePrompt = true,
	Enabled = true, GamepadKeyCode = Enum.KeyCode.ButtonX, HoldDuration = 0,
	KeyboardKeyCode = Enum.KeyCode.E, MaxActivationDistance = 10, ObjectText = "",
	RequiresLineOfSight = true, Style = Enum.ProximityPromptStyle.Default,
	UIOffset = Vector2.new(),
}
FallbackProperties["ClickDetector"]    = { CursorIcon = "", MaxActivationDistance = 32 }
FallbackProperties["ForceField"]       = { Visible = true }
FallbackProperties["PathfindingModifier"] = { IsBlocked = false, Label = "", PassThrough = false }
FallbackProperties["PathfindingLink"]  = { Attachment0 = nil, Attachment1 = nil, Bidirectional = true, Label = "" }

-- Dialog
FallbackProperties["Dialog"] = {
	BehaviorType = Enum.DialogBehaviorType.SinglePlayer,
	ConversationDistance = 25, Enabled = true,
	GoodbyeChoiceActive = false, GoodbyeDialog = "",
	InitialPrompt = "", Purpose = Enum.DialogPurpose.Help,
	Tone = Enum.DialogTone.Neutral,
}
FallbackProperties["DialogChoice"] = {
	GoodbyeChoiceActive = false, GoodbyeDialog = "",
	ResponseDialog = "", UserDialog = "",
}

-- Humanoid
FallbackProperties["Humanoid"] = {
	AutoJumpEnabled = true, AutoRotate = true, BreakJointsOnDeath = true,
	CameraOffset = Vector3.new(),
	DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer,
	HealthDisplayDistance = 100,
	HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged,
	HipHeight = 0, JumpHeight = 7.2, JumpPower = 50, MaxHealth = 100,
	MaxSlopeAngle = 89, NameDisplayDistance = 100,
	NameOcclusion = Enum.NameOcclusion.OccludeAll, RequiresNeck = true,
	RigType = Enum.HumanoidRigType.R6, UseJumpPower = false, WalkSpeed = 16,
}
FallbackProperties["HumanoidDescription"] = {
	BackAccessory = "", ClimbAnimation = 0, DepthOffset = 0,
	Face = 0, FaceAccessory = "", FallAnimation = 0,
	FrontAccessory = "", GraphicTShirt = 0, HairAccessory = "",
	HatAccessory = "", Head = 0, HeadColor = Color3.fromRGB(163,162,165),
	HeadScale = 1, IdleAnimation = 0, JumpAnimation = 0,
	LeftArm = 0, LeftArmColor = Color3.fromRGB(163,162,165),
	LeftLeg = 0, LeftLegColor = Color3.fromRGB(163,162,165),
	LowerTorso = 0, NeckAccessory = "", Pants = 0,
	ProportionScale = 1, RightArm = 0, RightArmColor = Color3.fromRGB(163,162,165),
	RightLeg = 0, RightLegColor = Color3.fromRGB(163,162,165),
	RunAnimation = 0, Shirt = 0, ShouldersAccessory = "",
	SwimAnimation = 0, Torso = 0, TorsoColor = Color3.fromRGB(163,162,165),
	UpperTorso = 0, WaistAccessory = "", WalkAnimation = 0, WidthScale = 1,
}
FallbackProperties["Camera"] = {
	CameraType = Enum.CameraType.Custom, FieldOfView = 70,
	FieldOfViewMode = Enum.FieldOfViewMode.Vertical, HeadLocked = true,
	MaxZoom = 400, MinZoom = 0,
}

-- TextChat
FallbackProperties["TextChatService"] = {
	ChatTranslationEnabled = false,
	CreateDefaultCommands = true, CreateDefaultTextChannels = true,
}
FallbackProperties["TextChannel"]    = { WelcomeMessage = "" }
FallbackProperties["TextChatCommand"] = { Enabled = true, PrimaryAlias = "", SecondaryAlias = "" }
FallbackProperties["ChatWindowConfiguration"] = {
	Enabled = true, BackgroundColor3 = Color3.fromRGB(0,0,0),
	BackgroundTransparency = 0.6,
	FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextColor3 = Color3.new(1,1,1), TextSize = 14,
	TextStrokeColor3 = Color3.new(), TextStrokeTransparency = 0.75,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
}
FallbackProperties["BubbleChatConfiguration"] = {
	Enabled = true, BackgroundColor3 = Color3.fromRGB(250,250,250),
	BackgroundTransparency = 0.1, BubbleDuration = 30, BubblesToShow = 2,
	CornerRadius = UDim.new(0,12),
	FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
	LocalPlayerStudsOffset = Vector3.new(0,6,0), MaxDistance = 100,
	MinimizeDistance = 40, NormLength = 200, Padding = 8,
	TailVisible = true, TextColor3 = Color3.new(), TextSize = 16,
	TextStrokeColor3 = Color3.new(1,1,1), TextStrokeTransparency = 1,
	VerticalStudsOffset = 0,
}

-- GUI base tables
local GuiObjectBase = {
	AnchorPoint = Vector2.new(), AutomaticSize = Enum.AutomaticSize.None,
	BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0,
	BorderColor3 = Color3.new(0,0,0), BorderMode = Enum.BorderMode.Outline,
	BorderSizePixel = 1, ClipsDescendants = false, LayoutOrder = 0,
	NextSelectionDown = nil, NextSelectionLeft = nil,
	NextSelectionRight = nil, NextSelectionUp = nil,
	Position = UDim2.new(), Rotation = 0, Selectable = false,
	SelectionImageObject = nil, SelectionOrder = 0,
	Size = UDim2.fromOffset(100,100), SizeConstraint = Enum.SizeConstraint.RelativeXY,
	Visible = true, ZIndex = 1,
}
local TextBase = {
	FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json"),
	LineHeight = 1, MaxVisibleGraphemes = -1, RichText = false,
	Text = "", TextColor3 = Color3.new(0,0,0), TextScaled = false,
	TextSize = 14, TextStrokeColor3 = Color3.new(),
	TextStrokeTransparency = 1, TextTransparency = 0,
	TextTruncate = Enum.TextTruncate.None, TextWrapped = false,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
}

FallbackProperties["ScreenGui"] = {
	ClipToDeviceSafeArea = false, DisplayOrder = 0, Enabled = true,
	IgnoreGuiInset = false, OnTopOfCoreBlur = false, ResetOnSpawn = true,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}
FallbackProperties["BillboardGui"] = {
	Active = false, AlwaysOnTop = false, Brightness = 1, ClipsDescendants = false,
	Enabled = true, ExtentsOffset = Vector2.new(), ExtentsOffsetWorldSpace = Vector3.new(),
	LightInfluence = 1, MaxDistance = 0, Size = UDim2.fromOffset(200,50),
	SizeOffset = Vector2.new(), StudsOffset = Vector3.new(),
	StudsOffsetWorldSpace = Vector3.new(), ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}
FallbackProperties["SurfaceGui"] = {
	Active = false, AlwaysOnTop = false, Brightness = 1,
	CanvasSize = Vector2.new(800,600), ClipsDescendants = false,
	Enabled = true, Face = Enum.NormalId.Front, LightInfluence = 1,
	PixelsPerStud = 20, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}
FallbackProperties["Frame"]        = { BackgroundTransparency = 0, Size = UDim2.fromOffset(100,100) }
FallbackProperties["TextLabel"]    = { BackgroundTransparency = 1, Text = "Label", Size = UDim2.fromOffset(200,50) }
FallbackProperties["TextButton"]   = { AutoButtonColor = true, Modal = false, Selected = false, Style = Enum.ButtonStyle.Custom, Text = "Button", Size = UDim2.fromOffset(200,50) }
FallbackProperties["TextBox"]      = { ClearTextOnFocus = true, MultiLine = false, PlaceholderColor3 = Color3.new(0.75,0.75,0.75), PlaceholderText = "", ShowNativeInput = true, Text = "", TextEditable = true, TextXAlignment = Enum.TextXAlignment.Left }
FallbackProperties["ImageLabel"]   = { BackgroundTransparency = 1, Image = "", ImageColor3 = Color3.new(1,1,1), ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0, ResampleMode = Enum.ResamplerMode.Default, ScaleType = Enum.ScaleType.Stretch, SliceCenter = Rect.new(0,0,0,0), SliceScale = 1, TileSize = UDim2.fromOffset(100,100) }
FallbackProperties["ImageButton"]  = { AutoButtonColor = true, HoverImage = "", Image = "", ImageColor3 = Color3.new(1,1,1), ImageRectOffset = Vector2.new(), ImageRectSize = Vector2.new(), ImageTransparency = 0, Modal = false, PressedImage = "", ResampleMode = Enum.ResamplerMode.Default, ScaleType = Enum.ScaleType.Stretch, Selected = false, SliceCenter = Rect.new(0,0,0,0), SliceScale = 1, Style = Enum.ButtonStyle.Custom, TileSize = UDim2.fromOffset(100,100) }
FallbackProperties["ScrollingFrame"] = {
	AutomaticCanvasSize = Enum.AutomaticSize.None,
	BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
	CanvasPosition = Vector2.new(), CanvasSize = UDim2.new(0,0,1,0),
	ClipsDescendants = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	HorizontalScrollBarInset = Enum.ScrollBarInset.None,
	MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
	ScrollBarImageColor3 = Color3.new(0,0,0), ScrollBarImageTransparency = 0,
	ScrollBarThickness = 12, ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollingEnabled = true,
	TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
	VerticalScrollBarInset = Enum.ScrollBarInset.None,
	VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
}
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
FallbackProperties["UISizeConstraint"]       = { MaxSize = Vector2.new(math.huge,math.huge), MinSize = Vector2.new() }
FallbackProperties["UITextSizeConstraint"]   = { MaxTextSize = 100, MinTextSize = 1 }
FallbackProperties["UIAspectRatioConstraint"] = { AspectRatio = 1, AspectType = Enum.AspectType.FitWithinMaxSize, DominantAxis = Enum.DominantAxis.Width }
FallbackProperties["UIFlexItem"]    = { FlexMode = Enum.UIFlexMode.None, GrowRatio = 0, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, ShrinkRatio = 0 }
FallbackProperties["UIGradient"]    = { Color = ColorSequence.new(Color3.new(1,1,1)), Enabled = true, Offset = Vector2.new(), Rotation = 0, Transparency = NumberSequence.new(0) }
FallbackProperties["UIScale"]       = { Scale = 1 }

-- Adornments / highlights
FallbackProperties["SelectionBox"]            = { Color3 = Color3.new(0,0,1), LineThickness = 0.1, SurfaceColor3 = Color3.new(0,0,1), SurfaceTransparency = 0.5, Visible = true }
FallbackProperties["SelectionSphere"]         = { Color3 = Color3.new(0,0,1), SurfaceColor3 = Color3.new(0,0,1), SurfaceTransparency = 0.5, Visible = true }
FallbackProperties["BoxHandleAdornment"]      = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Size = Vector3.new(1,1,1), SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["SphereHandleAdornment"]   = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ConeHandleAdornment"]     = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Height = 1, Radius = 0.25, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["CylinderHandleAdornment"] = { AlwaysOnTop = false, Color3 = Color3.new(1,1,1), Height = 1, InnerRadius = 0, Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ArcHandles"]              = {}
FallbackProperties["Handles"]                 = {}
FallbackProperties["SelectionPartLasso"]      = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Part = nil }
FallbackProperties["SelectionPointLasso"]     = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Point = Vector3.new() }
FallbackProperties["Highlight"] = {
	DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = true,
	FillColor = Color3.new(1,1,1), FillTransparency = 0.5,
	OutlineColor = Color3.new(1,1,1), OutlineTransparency = 0,
}

FallbackProperties["RemoteEvent"]     = {}
FallbackProperties["RemoteFunction"]  = {}
FallbackProperties["BindableEvent"]   = {}
FallbackProperties["BindableFunction"] = {}
FallbackProperties["Configuration"]   = {}
FallbackProperties["MaterialService"] = {}
FallbackProperties["MaterialVariant"] = {
	BaseMaterial = Enum.Material.SmoothPlastic,
	ColorMap = "", MetalnessMap = "", NormalMap = "", RoughnessMap = "",
}

-- Merge GuiObjectBase + TextBase into the right classes
local GuiObjectClasses = {
	"Frame", "TextLabel", "TextButton", "TextBox",
	"ImageLabel", "ImageButton", "ScrollingFrame",
	"VideoFrame", "ViewportFrame", "CanvasGroup",
}
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

-- ============================================================
-- INHERITANCE MAP
-- ============================================================
local Inheritance = {
	Part = {"BasePart","Instance"}, WedgePart = {"BasePart","Instance"},
	CornerWedgePart = {"BasePart","Instance"}, TrussPart = {"BasePart","Instance"},
	SpawnLocation = {"BasePart","Instance"}, Platform = {"BasePart","Instance"},
	Seat = {"BasePart","Instance"}, VehicleSeat = {"BasePart","Instance"},
	MeshPart = {"BasePart","Instance"}, UnionOperation = {"BasePart","Instance"},
	PartOperation = {"BasePart","Instance"}, NegateOperation = {"BasePart","Instance"},
	IntersectOperation = {"BasePart","Instance"},
	SpecialMesh = {"Instance"}, CylinderMesh = {"Instance"},
	BlockMesh = {"Instance"}, FileMesh = {"Instance"},
	Decal = {"Instance"}, Texture = {"Instance"}, SurfaceAppearance = {"Instance"},
	Model = {"Instance"}, Folder = {"Instance"}, Tool = {"Instance"},
	Hat = {"Instance"}, Accessory = {"Instance"},
	Backpack = {"Instance"}, StarterPack = {"Instance"}, StarterGear = {"Instance"},
	Configuration = {"Instance"}, MaterialService = {"Instance"},
	MaterialVariant = {"Instance"},
	Script = {"Instance"}, LocalScript = {"Instance"}, ModuleScript = {"Instance"},
	StringValue = {"Instance"}, NumberValue = {"Instance"}, BoolValue = {"Instance"},
	IntValue = {"Instance"}, Vector3Value = {"Instance"}, CFrameValue = {"Instance"},
	ObjectValue = {"Instance"}, Color3Value = {"Instance"},
	BrickColorValue = {"Instance"}, RayValue = {"Instance"},
	Animation = {"Instance"}, Animator = {"Instance"},
	AnimationController = {"Instance"}, AnimationTrack = {"Instance"},
	Sound = {"Instance"}, SoundService = {"Instance"},
	EqualizerSoundEffect = {"Instance"}, ReverbSoundEffect = {"Instance"},
	ChorusSoundEffect = {"Instance"}, CompressorSoundEffect = {"Instance"},
	DistortionSoundEffect = {"Instance"}, EchoSoundEffect = {"Instance"},
	FlangeSoundEffect = {"Instance"}, PitchShiftSoundEffect = {"Instance"},
	TremoloSoundEffect = {"Instance"},
	AudioPlayer = {"Instance"}, AudioEmitter = {"Instance"},
	AudioListener = {"Instance"}, AudioAnalyzer = {"Instance"},
	AudioChorus = {"Instance"}, AudioCompressor = {"Instance"},
	AudioDistortion = {"Instance"}, AudioEqualizer = {"Instance"},
	AudioFader = {"Instance"}, AudioFlanger = {"Instance"},
	AudioPitchShifter = {"Instance"}, AudioReverb = {"Instance"},
	AudioTremolo = {"Instance"}, AudioDeviceInput = {"Instance"},
	AudioDeviceOutput = {"Instance"}, Wire = {"Instance"},
	Attachment = {"Instance"}, Bone = {"Attachment","Instance"},
	Beam = {"Instance"}, Trail = {"Instance"},
	ParticleEmitter = {"Instance"}, Fire = {"Instance"},
	Smoke = {"Instance"}, Sparkles = {"Instance"},
	BodyVelocity = {"Instance"}, BodyPosition = {"Instance"},
	BodyForce = {"Instance"}, BodyAngularVelocity = {"Instance"},
	BodyGyro = {"Instance"}, BodyThrust = {"Instance"},
	RocketPropulsion = {"Instance"}, RopeConstraint = {"Instance"},
	SpringConstraint = {"Instance"}, HingeConstraint = {"Instance"},
	BallSocketConstraint = {"Instance"}, CylindricalConstraint = {"Instance"},
	PrismaticConstraint = {"Instance"}, TorsionSpringConstraint = {"Instance"},
	UniversalConstraint = {"Instance"}, WeldConstraint = {"Instance"},
	LinearVelocityConstraint = {"Instance"}, AngularVelocityConstraint = {"Instance"},
	AlignPosition = {"Instance"}, AlignOrientation = {"Instance"},
	Weld = {"Instance"}, Motor6D = {"Instance"}, Snap = {"Instance"},
	ManualWeld = {"Instance"}, ManualGlue = {"Instance"},
	PointLight = {"Instance"}, SpotLight = {"Instance"}, SurfaceLight = {"Instance"},
	Atmosphere = {"Instance"}, Sky = {"Instance"}, Clouds = {"Instance"},
	Bloom = {"Instance"}, Blur = {"Instance"}, ColorCorrection = {"Instance"},
	DepthOfField = {"Instance"}, SunRaysEffect = {"Instance"},
	IKControl = {"Instance"},
	Humanoid = {"Instance"}, HumanoidDescription = {"Instance"},
	BodyColors = {"Instance"}, CharacterMesh = {"Instance"},
	Pants = {"Instance"}, Shirt = {"Instance"}, ShirtGraphic = {"Instance"},
	WrapLayer = {"Instance"}, WrapTarget = {"Instance"},
	Camera = {"Instance"}, ScreenGui = {"Instance"},
	BillboardGui = {"Instance"}, SurfaceGui = {"Instance"},
	Frame = {"Instance"}, TextLabel = {"Instance"}, TextButton = {"Instance"},
	TextBox = {"Instance"}, ImageLabel = {"Instance"}, ImageButton = {"Instance"},
	ScrollingFrame = {"Instance"}, VideoFrame = {"Instance"},
	ViewportFrame = {"Instance"}, CanvasGroup = {"Instance"},
	UICorner = {"Instance"}, UIStroke = {"Instance"}, UIPadding = {"Instance"},
	UIListLayout = {"Instance"}, UIGridLayout = {"Instance"},
	UITableLayout = {"Instance"}, UIPageLayout = {"Instance"},
	UISizeConstraint = {"Instance"}, UITextSizeConstraint = {"Instance"},
	UIAspectRatioConstraint = {"Instance"}, UIFlexItem = {"Instance"},
	UIGradient = {"Instance"}, UIScale = {"Instance"},
	ProximityPrompt = {"Instance"}, ClickDetector = {"Instance"},
	ForceField = {"Instance"}, PathfindingModifier = {"Instance"},
	PathfindingLink = {"Instance"}, SelectionBox = {"Instance"},
	SelectionSphere = {"Instance"}, BoxHandleAdornment = {"Instance"},
	SphereHandleAdornment = {"Instance"}, ConeHandleAdornment = {"Instance"},
	CylinderHandleAdornment = {"Instance"}, ArcHandles = {"Instance"},
	Handles = {"Instance"}, SelectionPartLasso = {"Instance"},
	SelectionPointLasso = {"Instance"}, Highlight = {"Instance"},
	RemoteEvent = {"Instance"}, RemoteFunction = {"Instance"},
	BindableEvent = {"Instance"}, BindableFunction = {"Instance"},
	Dialog = {"Instance"}, DialogChoice = {"Instance"},
	TextChatService = {"Instance"}, TextChannel = {"Instance"},
	TextChatCommand = {"Instance"},
	ChatWindowConfiguration = {"Instance"}, BubbleChatConfiguration = {"Instance"},
}

-- ============================================================
-- EXACT PROPERTY HINTS
-- ============================================================
local ExactPropertyHints = {
	Instance = { "Name" },
	BasePart = {
		"Anchored","Size","CFrame","PivotOffset","Position","Orientation","Rotation",
		"BrickColor","Color","Material","MaterialVariant","Transparency","Reflectance",
		"CanCollide","CanTouch","CanQuery","CastShadow","Locked","Massless",
		"CustomPhysicalProperties","TopSurface","BottomSurface","LeftSurface",
		"RightSurface","FrontSurface","BackSurface",
		"TopParamA","TopParamB","BottomParamA","BottomParamB",
		"LeftParamA","LeftParamB","RightParamA","RightParamB",
		"FrontParamA","FrontParamB","BackParamA","BackParamB",
		"CollisionGroup","RootPriority","EnableFluidForces",
	},
	Part                = { "Shape" },
	MeshPart            = { "MeshId","MeshSize","TextureID","RenderFidelity","DoubleSided","CollisionFidelity" },
	PartOperation       = { "SmoothingAngle","UsePartColor","RenderFidelity","CollisionFidelity" },
	UnionOperation      = { "SmoothingAngle","UsePartColor","RenderFidelity","CollisionFidelity" },
	NegateOperation     = { "SmoothingAngle","UsePartColor","RenderFidelity","CollisionFidelity" },
	IntersectOperation  = { "SmoothingAngle","UsePartColor","RenderFidelity","CollisionFidelity" },
	SpecialMesh         = { "MeshType","MeshId","TextureId","Scale","Offset","VertexColor","RotationOffset" },
	FileMesh            = { "MeshId","TextureId","Scale","Offset","VertexColor" },
	Decal               = { "Texture","Transparency","Face","Color3","Shiny","Specular","ZIndex" },
	Texture             = { "Texture","Transparency","Face","Color3","Shiny","Specular","StudsPerTileU","StudsPerTileV","OffsetStudsU","OffsetStudsV","ZIndex" },
	SurfaceAppearance   = { "AlphaMode","ColorMap","MetalnessMap","NormalMap","RoughnessMap","TexturePack","Color","Roughness","Metalness" },
	MaterialVariant     = { "BaseMaterial","ColorMap","MetalnessMap","NormalMap","RoughnessMap" },
	Model               = { "WorldPivot","LevelOfDetail","ModelStreamingMode","PrimaryPart" },
	Tool                = { "CanBeDropped","Enabled","Grip","GripForward","GripPos","GripRight","GripUp","ManualActivationOnly","RequiresHandle","ToolTip" },
	Accessory           = { "AccessoryType","AttachmentPoint" },
	BodyColors          = { "HeadColor3","LeftArmColor3","LeftLegColor3","RightArmColor3","RightLegColor3","TorsoColor3" },
	Pants               = { "PantsTemplate" },
	Shirt               = { "ShirtTemplate" },
	ShirtGraphic        = { "Color3","Graphic" },
	WrapLayer           = { "AutoSkin","BindOffset","Enabled","InflateDelta","Order","Puffiness","ReferenceMeshId","ReferenceOrigin","ShrinkDelta" },
	WrapTarget          = { "CageMeshId","CageOrigin","Enabled","Stiffness" },
	Script              = { "Disabled","RunContext","Source" },
	LocalScript         = { "Disabled","Source" },
	ModuleScript        = { "Source" },
	Attachment          = { "Axis","SecondaryAxis","CFrame","Position","Orientation","Visible" },
	Bone                = { "Transform","CFrame","Position","Orientation" },
	IKControl           = { "ChainRoot","Enabled","EndEffector","Offset","Pole","Priority","SmoothTime","Target","Type","Weight" },
	Beam                = { "Color","Transparency","Texture","TextureLength","TextureMode","TextureSpeed","Width0","Width1","CurveSize0","CurveSize1","FaceCamera","LightEmission","LightInfluence","Brightness","Enabled","Segments","ZOffset" },
	Trail               = { "Color","Transparency","Texture","TextureLength","TextureMode","WidthScale","FaceCamera","LightEmission","LightInfluence","Brightness","Enabled","Lifetime","MaxLength","MinLength" },
	ParticleEmitter     = { "Acceleration","Brightness","Color","Drag","EmissionDirection","Enabled","FlipbookFramerate","FlipbookLayout","FlipbookMode","LifeTime","LightEmission","LightInfluence","LockedToPart","Orientation","Rate","RotSpeed","Rotation","ShapeStyle","ShapeInOut","ShapePartial","ShapeRotation","Size","Speed","SpreadAngle","Squash","Texture","TimeScale","Transparency","VelocityInheritance","ZOffset" },
	Fire                = { "Color","SecondaryColor","Enabled","Heat","Size","TimeScale" },
	Smoke               = { "Color","Enabled","Opacity","RiseVelocity","Size","TimeScale" },
	Sparkles            = { "Color","Enabled","SparkleColor","TimeScale" },
	Sound               = { "SoundId","Volume","PlaybackSpeed","TimePosition","Looped","PlayOnRemove","RollOffMaxDistance","RollOffMinDistance","RollOffMode","EmitterSize","MaxDistance","PlaybackRegionsEnabled","SoundGroup" },
	AudioPlayer         = { "AssetId","Looping","PlaybackRegionsEnabled","PlaybackSpeed","TimePosition","Volume" },
	AudioEmitter        = {},
	AudioListener       = {},
	AudioFader          = { "Bypass","Volume" },
	AudioEqualizer      = { "Bypass","HighGain","LowGain","MidGain" },
	AudioCompressor     = { "Bypass","Attack","GainMakeup","Ratio","Release","Threshold" },
	AudioDistortion     = { "Bypass","Level" },
	AudioPitchShifter   = { "Bypass","Octave" },
	AudioReverb         = { "Bypass","DecayTime","Density","Diffusion","DryLevel","WetLevel" },
	AudioChorus         = { "Bypass","Depth","Mix","Rate" },
	AudioFlanger        = { "Bypass","Depth","Mix","Rate" },
	AudioTremolo        = { "Bypass","Depth","Duty","Frequency" },
	AlignPosition       = { "Attachment0","Attachment1","ApplyAtCenterOfMass","Enabled","ForceLimitMode","MaxAxesForce","MaxForce","MaxVelocity","Mode","Position","ReactionForceEnabled","Responsiveness","RigidityEnabled" },
	AlignOrientation    = { "Attachment0","Attachment1","CFrame","Enabled","MaxAngularVelocity","MaxTorque","Mode","PrimaryAxis","PrimaryAxisOnly","ReactionTorqueEnabled","Responsiveness","RigidityEnabled","SecondaryAxis" },
	LinearVelocityConstraint  = { "Attachment0","Enabled","ForceLimitMode","LineDirection","LineVelocity","MaxAxesForce","MaxForce","PlaneVelocity","RelativeTo","VelocityConstraintMode","VectorVelocity","Visible" },
	AngularVelocityConstraint = { "Attachment0","AngularVelocity","Enabled","MaxTorque","ReactionTorqueEnabled","RelativeTo","Visible" },
	GuiObject           = { "AnchorPoint","AutomaticSize","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","ClipsDescendants","LayoutOrder","Position","Rotation","Selectable","SelectionOrder","Size","SizeConstraint","Visible","ZIndex","Active" },
	TextLabel           = { "Text","FontFace","TextColor3","TextSize","TextScaled","TextWrapped","TextTransparency","TextStrokeColor3","TextStrokeTransparency","TextXAlignment","TextYAlignment","RichText","LineHeight","MaxVisibleGraphemes","TextTruncate","TextDirection" },
	TextButton          = { "Text","FontFace","TextColor3","TextSize","TextScaled","TextWrapped","TextTransparency","TextStrokeColor3","TextStrokeTransparency","TextXAlignment","TextYAlignment","RichText","LineHeight","MaxVisibleGraphemes","AutoButtonColor","Modal","Selected","Style","TextTruncate" },
	TextBox             = { "Text","FontFace","TextColor3","TextSize","TextScaled","TextWrapped","TextTransparency","TextStrokeColor3","TextStrokeTransparency","TextXAlignment","TextYAlignment","RichText","LineHeight","MaxVisibleGraphemes","ClearTextOnFocus","MultiLine","PlaceholderColor3","PlaceholderText","ShowNativeInput","TextEditable","TextTruncate" },
	ImageLabel          = { "Image","ImageColor3","ImageTransparency","ImageRectOffset","ImageRectSize","ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize" },
	ImageButton         = { "Image","ImageColor3","ImageTransparency","ImageRectOffset","ImageRectSize","ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize","AutoButtonColor","HoverImage","PressedImage","Modal","Selected","Style" },
	ScrollingFrame      = { "AutomaticCanvasSize","BottomImage","CanvasPosition","CanvasSize","ElasticBehavior","HorizontalScrollBarInset","MidImage","ScrollBarImageColor3","ScrollBarImageTransparency","ScrollBarThickness","ScrollingDirection","ScrollingEnabled","TopImage","VerticalScrollBarInset","VerticalScrollBarPosition" },
	ViewportFrame       = { "Ambient","ImageColor3","ImageTransparency","LightColor","LightDirection" },
	CanvasGroup         = { "GroupColor3","GroupTransparency" },
	UIListLayout        = { "FillDirection","HorizontalAlignment","HorizontalFlex","ItemLineAlignment","Padding","SortOrder","VerticalAlignment","VerticalFlex","Wraps" },
	UIGridLayout        = { "CellPadding","CellPaddingX","CellPaddingY","CellSize","FillDirection","FillDirectionMaxCells","HorizontalAlignment","SortOrder","StartCorner","VerticalAlignment" },
	UITableLayout       = { "FillDirection","FillEmptySpaceColumns","FillEmptySpaceRows","MajorAxis","Padding","SortOrder" },
	UIPageLayout        = { "Animated","Circular","EasingDirection","EasingStyle","FillDirection","GamepadInputEnabled","Padding","ScrollWheelInputEnabled","SortOrder","TweenTime","TouchInputEnabled" },
	UIScale             = { "Scale" },
	UICorner            = { "CornerRadius" },
	UIStroke            = { "ApplyStrokeMode","Color","Enabled","LineJoinMode","Thickness","Transparency" },
	UIGradient          = { "Color","Enabled","Offset","Rotation","Transparency" },
	UIPadding           = { "PaddingBottom","PaddingLeft","PaddingRight","PaddingTop" },
	UISizeConstraint    = { "MaxSize","MinSize" },
	UITextSizeConstraint = { "MaxTextSize","MinTextSize" },
	UIAspectRatioConstraint = { "AspectRatio","AspectType","DominantAxis" },
	UIFlexItem          = { "FlexMode","GrowRatio","ItemLineAlignment","ShrinkRatio" },
	ProximityPrompt     = { "ActionText","AutoLocalize","ClickablePrompt","Enabled","GamepadKeyCode","HoldDuration","KeyboardKeyCode","MaxActivationDistance","ObjectText","RequiresLineOfSight","Style","UIOffset" },
	ClickDetector       = { "CursorIcon","MaxActivationDistance" },
	Highlight           = { "DepthMode","Enabled","FillColor","FillTransparency","OutlineColor","OutlineTransparency" },
	SelectionBox        = { "Adornee","Color3","LineThickness","SurfaceColor3","SurfaceTransparency","Visible" },
	PathfindingModifier = { "IsBlocked","Label","PassThrough" },
	PathfindingLink     = { "Bidirectional","Label" },
	ForceField          = { "Visible" },
	Camera              = { "CameraType","FieldOfView","FieldOfViewMode","Focus","HeadLocked","MaxZoom","MinZoom" },
	Dialog              = { "BehaviorType","ConversationDistance","Enabled","GoodbyeChoiceActive","GoodbyeDialog","InitialPrompt","Purpose","Tone" },
	DialogChoice        = { "GoodbyeChoiceActive","GoodbyeDialog","ResponseDialog","UserDialog" },
	TextChatService     = { "ChatTranslationEnabled","CreateDefaultCommands","CreateDefaultTextChannels" },
	TextChannel         = { "WelcomeMessage" },
	TextChatCommand     = { "Enabled","PrimaryAlias","SecondaryAlias" },
}

-- ============================================================
-- SIGNALS TO CAPTURE via getconnections
-- ============================================================
local SignalsToCapture = {
	-- Checked against every instance (Instance-level signals)
	Instance  = { "Changed","ChildAdded","ChildRemoved","DescendantAdded","DescendantRemoving","AttributeChanged" },
	BasePart  = { "Touched","TouchEnded" },
	Humanoid  = { "Died","Running","Jumping","Climbing","Swimming","FreeFalling","FallingDown","GettingUp","Ragdoll","StateChanged","Seated","MoveToFinished" },
	Tool      = { "Activated","Deactivated","Equipped","Unequipped" },
	ClickDetector     = { "MouseClick","RightMouseClick","MouseHoverEnter","MouseHoverLeave" },
	ProximityPrompt   = { "Triggered","TriggerEnded","PromptShown","PromptHidden" },
	BindableEvent     = { "Event" },
	TextButton        = { "Activated","MouseButton1Click","MouseButton1Down","MouseButton1Up","MouseButton2Click","MouseButton2Down","MouseButton2Up" },
	ImageButton       = { "Activated","MouseButton1Click","MouseButton1Down","MouseButton1Up","MouseButton2Click","MouseButton2Down","MouseButton2Up" },
	GuiObject         = { "InputBegan","InputChanged","InputEnded","MouseEnter","MouseLeave","MouseMoved","SelectionGained","SelectionLost" },
	Sound             = { "Ended","Loaded","Paused","Played","Stopped","DidLoop" },
	Dialog            = { "DialogChoiceSelected" },
	AnimationTrack    = {}, -- skip, runtime
	RemoteEvent       = {}, -- skip, cross-boundary
	RemoteFunction    = {}, -- skip, cross-boundary
}

-- ============================================================
-- RESERVED NAMES
-- ============================================================
local ReservedNames = {
	["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,
	["end"]=true,["false"]=true,["for"]=true,["function"]=true,["if"]=true,
	["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,
	["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,
	["while"]=true,
}

-- ============================================================
-- FORMAT HELPERS
-- ============================================================
local function FmtNum(N)
	if N ~= N then return "0/0" end
	if N == math.huge then return "math.huge" end
	if N == -math.huge then return "-math.huge" end
	if math.floor(N) == N and math.abs(N) < 1e15 then return string.format("%d", N) end
	return string.format("%.8g", N)
end

local function FmtColor3(C)
	local R = math.round(C.R * 255)
	local G = math.round(C.G * 255)
	local B = math.round(C.B * 255)
	if math.abs(C.R - R/255) < 0.001 and math.abs(C.G - G/255) < 0.001 and math.abs(C.B - B/255) < 0.001 then
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

local function SerializeMultilineString(S)
	for Level = 0, 20 do
		local Close = "]" .. string.rep("=", Level) .. "]"
		if not S:find(Close, 1, true) then
			local Open = "[" .. string.rep("=", Level) .. "["
			return Open .. "\n" .. S .. "\n" .. Close
		end
	end
	return string.format("%q", S)
end

local function BuildGamePath(Inst)
	local Parts = {}
	local Cur = Inst
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

-- ============================================================
-- VALUE SERIALIZER
-- ============================================================
local function SerializeValue(Val, InstVarMap)
	local T = typeof(Val)
	if T == "string" then
		if #Val > 200 and Val:find("\n") then return SerializeMultilineString(Val) end
		return string.format("%q", Val)
	end
	if T == "boolean" then return tostring(Val) end
	if T == "nil"     then return "nil" end
	if T == "number"  then return FmtNum(Val) end
	if T == "Vector3" then return FmtV3(Val) end
	if T == "Vector2" then return FmtV2(Val) end
	if T == "Vector3int16" then return string.format("Vector3int16.new(%d, %d, %d)", Val.X, Val.Y, Val.Z) end
	if T == "Vector2int16" then return string.format("Vector2int16.new(%d, %d)", Val.X, Val.Y) end

	if T == "CFrame" then
		local X,Y,Z,R00,R01,R02,R10,R11,R12,R20,R21,R22 = Val:GetComponents()
		local Identity = R00==1 and R01==0 and R02==0
			and R10==0 and R11==1 and R12==0
			and R20==0 and R21==0 and R22==1
		if Identity then
			if X==0 and Y==0 and Z==0 then return "CFrame.new()" end
			return string.format("CFrame.new(%s, %s, %s)", FmtNum(X), FmtNum(Y), FmtNum(Z))
		end
		local ok, AX, AY, AZ = pcall(function() return Val:ToEulerAnglesXYZ() end)
		if ok then
			local Rec = CFrame.new(X,Y,Z) * CFrame.fromEulerAnglesXYZ(AX, AY, AZ)
			local _,_,_,M00,M01,M02,M10,M11,M12,M20,M21,M22 = Rec:GetComponents()
			local Close = math.abs(M00-R00)<0.0001 and math.abs(M01-R01)<0.0001
				and math.abs(M02-R02)<0.0001 and math.abs(M10-R10)<0.0001
				and math.abs(M11-R11)<0.0001 and math.abs(M12-R12)<0.0001
				and math.abs(M20-R20)<0.0001 and math.abs(M21-R21)<0.0001
				and math.abs(M22-R22)<0.0001
			if Close then
				return string.format(
					"CFrame.new(%s, %s, %s) * CFrame.fromEulerAnglesXYZ(%s, %s, %s)",
					FmtNum(X),FmtNum(Y),FmtNum(Z),FmtNum(AX),FmtNum(AY),FmtNum(AZ)
				)
			end
		end
		return string.format(
			"CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
			FmtNum(X),FmtNum(Y),FmtNum(Z),
			FmtNum(R00),FmtNum(R01),FmtNum(R02),
			FmtNum(R10),FmtNum(R11),FmtNum(R12),
			FmtNum(R20),FmtNum(R21),FmtNum(R22)
		)
	end

	if T == "Color3"     then return FmtColor3(Val) end
	if T == "BrickColor" then return string.format('BrickColor.new("%s")', Val.Name) end

	if T == "UDim2" then
		local XS,XO = Val.X.Scale, Val.X.Offset
		local YS,YO = Val.Y.Scale, Val.Y.Offset
		if XS==0 and YS==0 then
			if XO==0 and YO==0 then return "UDim2.new()" end
			return string.format("UDim2.fromOffset(%d, %d)", XO, YO)
		end
		if XO==0 and YO==0 then return string.format("UDim2.fromScale(%s, %s)", FmtNum(XS), FmtNum(YS)) end
		return string.format("UDim2.new(%s, %d, %s, %d)", FmtNum(XS), XO, FmtNum(YS), YO)
	end
	if T == "UDim" then return FmtUDim(Val) end

	if T == "Rect" then
		return string.format("Rect.new(%s, %s, %s, %s)",
			FmtNum(Val.Min.X), FmtNum(Val.Min.Y), FmtNum(Val.Max.X), FmtNum(Val.Max.Y))
	end
	if T == "NumberRange" then
		if Val.Min == Val.Max then return string.format("NumberRange.new(%s)", FmtNum(Val.Min)) end
		return string.format("NumberRange.new(%s, %s)", FmtNum(Val.Min), FmtNum(Val.Max))
	end
	if T == "NumberSequence" then
		local KPs = Val.Keypoints
		if #KPs==2 and KPs[1].Time==0 and KPs[2].Time==1
			and KPs[1].Value==KPs[2].Value and KPs[1].Envelope==0 and KPs[2].Envelope==0
		then
			return string.format("NumberSequence.new(%s)", FmtNum(KPs[1].Value))
		end
		local Parts = {}
		for _, KP in ipairs(KPs) do
			if KP.Envelope ~= 0 then
				Parts[#Parts+1] = string.format("NumberSequenceKeypoint.new(%s, %s, %s)", FmtNum(KP.Time), FmtNum(KP.Value), FmtNum(KP.Envelope))
			else
				Parts[#Parts+1] = string.format("NumberSequenceKeypoint.new(%s, %s)", FmtNum(KP.Time), FmtNum(KP.Value))
			end
		end
		return "NumberSequence.new({\n\t\t" .. table.concat(Parts, ",\n\t\t") .. "\n\t})"
	end
	if T == "ColorSequence" then
		local KPs = Val.Keypoints
		if #KPs==2 and KPs[1].Time==0 and KPs[2].Time==1 and KPs[1].Value==KPs[2].Value then
			return string.format("ColorSequence.new(%s)", FmtColor3(KPs[1].Value))
		end
		local Parts = {}
		for _, KP in ipairs(KPs) do
			Parts[#Parts+1] = string.format("ColorSequenceKeypoint.new(%s, %s)", FmtNum(KP.Time), FmtColor3(KP.Value))
		end
		return "ColorSequence.new({\n\t\t" .. table.concat(Parts, ",\n\t\t") .. "\n\t})"
	end
	if T == "EnumItem" then return string.format("Enum.%s.%s", tostring(Val.EnumType), Val.Name) end
	if T == "PhysicalProperties" then
		return string.format("PhysicalProperties.new(%s, %s, %s, %s, %s)",
			FmtNum(Val.Density), FmtNum(Val.Friction), FmtNum(Val.Elasticity),
			FmtNum(Val.FrictionWeight), FmtNum(Val.ElasticityWeight))
	end
	if T == "Font" then
		return string.format('Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)',
			Val.Family, Val.Weight.Name, Val.Style.Name)
	end
	if T == "Ray" then return string.format("Ray.new(%s, %s)", FmtV3(Val.Origin), FmtV3(Val.Direction)) end
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
		return string.format("TweenInfo.new(%s, Enum.EasingStyle.%s, Enum.EasingDirection.%s, %s, %s, %s)",
			FmtNum(Val.Time), Val.EasingStyle.Name, Val.EasingDirection.Name,
			FmtNum(Val.RepeatCount), tostring(Val.Reverses), FmtNum(Val.DelayTime))
	end
	if T == "OverlapParams" then
		return string.format(
			'(function() local p = OverlapParams.new() p.FilterType = Enum.RaycastFilterType.%s p.MaxParts = %d p.RespectCanCollide = %s return p end)()',
			Val.FilterType.Name, Val.MaxParts, tostring(Val.RespectCanCollide))
	end
	if T == "RaycastParams" then
		return string.format(
			'(function() local p = RaycastParams.new() p.FilterType = Enum.RaycastFilterType.%s p.IgnoreWater = %s p.RespectCanCollide = %s return p end)()',
			Val.FilterType.Name, tostring(Val.IgnoreWater), tostring(Val.RespectCanCollide))
	end
	if T == "Instance" then
		if InstVarMap and InstVarMap[Val] then return InstVarMap[Val] end
		local ok, Path = pcall(BuildGamePath, Val)
		if ok then return Path end
		return "nil"
	end
	return nil
end

-- ============================================================
-- DECOMPILE CLEANER
-- Cleans up decompiled Luau source into something readable.
-- Multi-pass: strip headers, infer var names, rename obfuscated
-- vars, remove no-op patterns, normalize whitespace.
-- ============================================================
local function DecompileClean(src, scriptName)
	if not src or #src == 0 then return src end
	scriptName = scriptName or "unknown"

	-- Split to lines for header stripping
	local rawLines = {}
	for line in (src .. "\n"):gmatch("([^\n]*)\n") do
		rawLines[#rawLines+1] = line
	end

	-- Pass 1: strip decompiler header (first N consecutive comment lines matching known patterns)
	local headerPatterns = {
		"[Dd]ecompil", "[Gg]enerated", "IronBrew", "luadec", "unluac",
		"bytecode", "Bytecode", "obfuscati", "Obfuscati",
		"This code was", "Compiled with",
	}
	local startLine = 1
	for i = 1, math.min(8, #rawLines) do
		local stripped = rawLines[i]:match("^%s*%-%-+%s*(.*)")
		if stripped then
			local isHeader = false
			for _, pat in ipairs(headerPatterns) do
				if stripped:find(pat) then isHeader = true; break end
			end
			if isHeader or #stripped == 0 then
				startLine = i + 1
			else
				break
			end
		else
			break
		end
	end

	-- Pass 2: collect source from startLine onward
	local working = table.concat(rawLines, "\n", startLine)

	-- Pass 3: infer readable names for l_%d+_%d+ and similar obfuscated vars
	-- Scan for assignment patterns and build an inference map
	local varMap = {}

	-- Pattern: varId = game:GetService("SvcName")
	for varId, svc in working:gmatch("(l_%d+_%d+)%s*=%s*game:GetService%(%s*['\"]([^'\"]+)['\"]%s*%)") do
		if not varMap[varId] then varMap[varId] = svc end
	end
	-- Pattern: varId = game.ServiceName (top-level services)
	for varId, svc in working:gmatch("(l_%d+_%d+)%s*=%s*game%.([A-Z][%w_]*)") do
		if not varMap[varId] then varMap[varId] = svc end
	end
	-- Pattern: varId = Instance.new("ClassName")
	for varId, cls in working:gmatch("(l_%d+_%d+)%s*=%s*Instance%.new%(%s*['\"]([^'\"]+)['\"]%s*%)") do
		if not varMap[varId] then
			varMap[varId] = cls:sub(1,1):lower() .. cls:sub(2)
		end
	end
	-- Pattern: varId = require(...)
	for varId in working:gmatch("(l_%d+_%d+)%s*=%s*require%s*%(") do
		if not varMap[varId] then varMap[varId] = "mod" end
	end
	-- Pattern: varId = workspace
	for varId in working:gmatch("(l_%d+_%d+)%s*=%s*workspace[^.]") do
		if not varMap[varId] then varMap[varId] = "workspace" end
	end
	-- Pattern: local varId = {} -> tbl
	for varId in working:gmatch("local%s+(l_%d+_%d+)%s*=%s*%{") do
		if not varMap[varId] then varMap[varId] = "tbl" end
	end
	-- Pattern: local varId = function -> fn
	for varId in working:gmatch("local%s+(l_%d+_%d+)%s*=%s*function") do
		if not varMap[varId] then varMap[varId] = "fn" end
	end

	-- Deduplicate renamed vars: if same inferred name appears multiple times, suffix with counter
	local nameCount = {}
	local finalMap  = {}
	-- First, collect all l_%d+_%d+ in order of appearance so un-inferred ones get sequential names
	local seenOrder = {}
	local seenSet   = {}
	for varId in working:gmatch("l_%d+_%d+") do
		if not seenSet[varId] then
			seenSet[varId] = true
			seenOrder[#seenOrder+1] = varId
		end
	end
	for _, varId in ipairs(seenOrder) do
		local baseName = varMap[varId] or "v"
		nameCount[baseName] = (nameCount[baseName] or 0) + 1
		local final = baseName .. (nameCount[baseName] == 1 and "" or nameCount[baseName])
		-- Make sure it's a valid Lua identifier and not reserved
		final = final:gsub("[^%w_]", "_"):gsub("^(%d)", "_%1")
		if ReservedNames[final] then final = final .. "_" end
		finalMap[varId] = final
	end

	-- Pass 4: apply renames
	-- Use gsub with word-boundary-like check to avoid partial matches
	working = working:gsub("(l_%d+_%d+)", function(varId)
		return finalMap[varId] or varId
	end)

	-- Pass 5: clean up common decompiler artifacts
	-- Remove upvalue comment lines
	working = working:gsub("\n%s*%-%- upvalue %d+[^\n]*", "")
	-- Remove empty do/end blocks (do\n\tend or do end on same line)
	working = working:gsub("\ndo\n%s*end\n", "\n")
	working = working:gsub("\ndo%s+end\n",   "\n")
	-- Remove standalone semicolons on their own line
	working = working:gsub("\n(%s*);(%s*)\n", "\n")
	-- Remove "if true then ... end" -> just the body (simple single-line case)
	working = working:gsub("if%s+true%s+then%s+(.-)%s+end", "%1")
	-- Clean "local _ = nil" no-ops
	working = working:gsub("local%s+_%s*=%s*nil%s*\n", "")
	-- Collapse 3+ blank lines to 2
	working = working:gsub("\n\n\n+", "\n\n")
	-- Strip trailing whitespace per line
	working = working:gsub("([^\n]*) +\n", "%1\n")
	-- Remove leading blank lines
	working = working:gsub("^\n+", "")

	-- Pass 6: add decompiled annotation header
	if Config.AnnotateDecompiled then
		working = "-- [DECOMPILED: " .. scriptName .. " | cleaned by HikloSerializer v" .. VERSION .. "]\n" .. working
	end

	return working
end

-- ============================================================
-- SCRIPT SOURCE HANDLING
-- ============================================================
local function ReadProperty(Inst, PropName)
	local ok, Value = pcall(function() return Inst[PropName] end)
	if ok then return true, Value end
	if gethiddenproperty then
		local okH, HV = pcall(gethiddenproperty, Inst, PropName)
		if okH then return true, HV end
	end
	return false, nil
end

local function GetScriptSource(Inst)
	local okCheck, isLSC = pcall(function() return Inst:IsA("LuaSourceContainer") end)
	if not okCheck or not isLSC then return nil, false end

	-- Try decompile first
	if typeof(decompile) == "function" then
		local ok, Result = pcall(decompile, Inst)
		if ok and type(Result) == "string" and #Result > 0 then
			local cleaned = Config.CleanDecompiledSource
				and DecompileClean(Result, Inst.Name)
				or Result
			return cleaned, true
		end
	end

	-- Fallback: read Source property directly
	local ok, Result = ReadProperty(Inst, "Source")
	if ok and type(Result) == "string" then return Result, false end

	-- Last resort placeholder
	local Fallback = {
		"-- Source could not be captured.",
		"-- ClassName: " .. tostring(Inst.ClassName),
		"-- Name: " .. tostring(Inst.Name),
	}
	if Inst:IsA("Script") then
		local okRC, RC = ReadProperty(Inst, "RunContext")
		if okRC and RC ~= nil then
			Fallback[#Fallback+1] = "-- RunContext: " .. tostring(RC)
		end
	end
	return table.concat(Fallback, "\n"), false
end

-- ============================================================
-- MODULE INLINE EMITTER
-- Emits a [[]] wrapped loadstring block for ModuleScripts.
-- Returns (varName, lines[]) where varName is the exports var.
-- ============================================================
local function EmitModuleInline(Push, PushBlank, Var, InstName, Src, WasDecompiled)
	local safeVarName = (InstName:gsub("[^%w_]", "_"):gsub("^(%d)", "_%1"):gsub("_+$", "") or "mod")
	safeVarName = safeVarName .. "_exports"

	local srcStr = SerializeMultilineString(Src)
	local label = WasDecompiled and " [decompiled]" or ""

	PushBlank()
	Push("-- Module: %s (%s)%s", InstName, Var, label)
	Push("local %s", safeVarName)
	Push("do")
	Push("\tlocal _src = %s", srcStr)
	Push('\tlocal _fn, _err = loadstring(_src, "@%s")', InstName)
	Push("\tif not _fn then")
	Push('\t\twarn("[HikloSerializer] Module parse error in %s:", _err)', InstName)
	Push("\telse")
	Push("\t\tlocal _ok, _result = pcall(_fn)")
	Push("\t\tif _ok then")
	Push("\t\t\t%s = _result", safeVarName)
	Push("\t\telse")
	Push('\t\t\twarn("[HikloSerializer] Module exec error in %s:", _result)', InstName)
	Push("\t\tend")
	Push("\tend")
	Push("end")
	Push("-- Usage: %s.YourFunction(...)", safeVarName)
	PushBlank()

	return safeVarName
end

-- ============================================================
-- CONNECTION CAPTURE via getconnections
-- ============================================================
local function GetSignalsForInst(Inst)
	local signals = {}
	local seen    = {}

	local function AddList(list)
		for _, s in ipairs(list) do
			if not seen[s] then seen[s] = true; signals[#signals+1] = s end
		end
	end

	AddList(SignalsToCapture.Instance)
	for ClassName, List in pairs(SignalsToCapture) do
		if ClassName ~= "Instance" then
			local ok, isA = pcall(function() return Inst:IsA(ClassName) end)
			if ok and isA then AddList(List) end
		end
	end
	return signals
end

-- Returns a list of {signal=str, source=str} for all captured connections.
local function CaptureConnections(Inst)
	if not getconnections then return {} end

	local captured = {}
	local signals  = GetSignalsForInst(Inst)

	for _, sigName in ipairs(signals) do
		local ok, sig = pcall(function() return Inst[sigName] end)
		if not ok or sig == nil then continue end

		local okC, conns = pcall(getconnections, sig)
		if not okC or type(conns) ~= "table" then continue end

		for _, conn in ipairs(conns) do
			-- Try to get the Lua function from the connection
			local fn = nil
			pcall(function()
				fn = conn.Function
			end)
			if type(fn) ~= "function" then continue end

			-- Decompile the handler function
			local src = nil
			if typeof(decompile) == "function" then
				local okD, res = pcall(decompile, fn)
				if okD and type(res) == "string" and #res > 4 then
					src = Config.CleanDecompiledSource
						and DecompileClean(res, sigName .. "_handler")
						or res
				end
			end

			if src then
				captured[#captured+1] = { signal = sigName, source = src }
			end
		end
	end

	return captured
end

-- ============================================================
-- PROPERTY HELPERS
-- ============================================================
local function MergePropNames(Dest, Source)
	for PropName in pairs(Source) do Dest[PropName] = true end
end

local function MergePropertyDump(Dest, Raw)
	if type(Raw) ~= "table" then return end
	for K, V in pairs(Raw) do
		if type(K) == "string" then
			Dest[K] = true
		elseif type(V) == "string" then
			Dest[V] = true
		elseif type(V) == "table" then
			local Name = rawget(V, "Name") or rawget(V, "name")
				or rawget(V, "Property") or rawget(V, "property")
			if type(Name) == "string" then Dest[Name] = true end
		end
	end
end

local WritableProbeCache    = {}
local WritablePropertyCache = {}

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
	local ClassName  = Inst.ClassName
	local ClassCache = WritablePropertyCache[ClassName]
	if not ClassCache then
		ClassCache = {}
		WritablePropertyCache[ClassName] = ClassCache
	end
	if ClassCache[PropName] ~= nil then return ClassCache[PropName] end
	local Probe = GetWritableProbe(ClassName)
	if not Probe then ClassCache[PropName] = false; return false end
	local ok = pcall(function() Probe[PropName] = Value end)
	ClassCache[PropName] = ok
	return ok
end

local function ValuesEqual(A, B)
	if typeof(A) ~= typeof(B) then return false end
	if typeof(A) == "Instance" then return A == B end
	local SA = SerializeValue(A, nil)
	local SB = SerializeValue(B, nil)
	if SA and SB then return SA == SB end
	return A == B
end

local function SerializeParentValue(Parent, InstVarMap)
	if not Parent then return "nil" end
	if InstVarMap[Parent] then return InstVarMap[Parent] end
	local ok, Path = pcall(BuildGamePath, Parent)
	if ok then return Path end
	return "nil"
end

-- ============================================================
-- PROPERTY ORDERING / FILTERING
-- ============================================================
local function ShouldUseFinalVisualProperty(Inst, PropName)
	if Inst:IsA("TextLabel") or Inst:IsA("TextButton") or Inst:IsA("TextBox") then
		if PropName=="TextColor3" or PropName=="TextTransparency"
			or PropName=="TextStrokeColor3" or PropName=="TextStrokeTransparency"
			or PropName=="Font" or PropName=="FontFace"
			or PropName=="OpenTypeFeatures" or PropName=="LineHeight"
			or PropName=="RichText" or PropName=="TextScaled" or PropName=="TextWrapped"
			or PropName=="TextDirection" or PropName=="TextTruncate"
			or PropName=="MaxVisibleGraphemes"
		then return true end
	end
	if Inst:IsA("UIGradient") then
		if PropName=="Color" or PropName=="Transparency" or PropName=="Offset"
			or PropName=="Rotation" or PropName=="Enabled" then return true end
	end
	if Inst:IsA("UIStroke") then
		if PropName=="Color" or PropName=="Transparency" or PropName=="Thickness"
			or PropName=="Enabled" or PropName=="ApplyStrokeMode" or PropName=="LineJoinMode"
		then return true end
	end
	if Inst:IsA("ImageLabel") or Inst:IsA("ImageButton") then
		if PropName=="Image" or PropName=="ImageColor3" or PropName=="ImageTransparency"
			or PropName=="ScaleType" or PropName=="SliceCenter" or PropName=="SliceScale"
			or PropName=="TileSize" then return true end
	end
	if Inst:IsA("ScrollingFrame") then
		if PropName=="CanvasSize" or PropName=="CanvasPosition"
			or PropName=="ScrollBarThickness" then return true end
	end
	if Inst:IsA("GuiObject") then
		if PropName=="BackgroundColor3" or PropName=="BackgroundTransparency"
			or PropName=="BorderColor3" or PropName=="BorderMode"
			or PropName=="BorderSizePixel" then return true end
	end
	if Inst:IsA("Highlight") then
		if PropName=="FillColor" or PropName=="FillTransparency"
			or PropName=="OutlineColor" or PropName=="OutlineTransparency"
		then return true end
	end
	if Inst:IsA("ParticleEmitter") then
		if PropName=="Color" or PropName=="Size" or PropName=="Transparency"
			or PropName=="Squash" then return true end
	end
	if Inst:IsA("Beam") or Inst:IsA("Trail") then
		if PropName=="Color" or PropName=="Transparency" or PropName=="WidthScale"
		then return true end
	end
	return false
end

local function ShouldUseLateProperty(Inst, PropName, Value)
	if typeof(Value) == "Instance" then return true end
	local lateProps = {
		WorldPivot=true, PrimaryPart=true, CFrame=true, PivotOffset=true,
		Adornee=true, CurrentCamera=true, Attachment0=true, Attachment1=true,
		Part0=true, Part1=true, ChainRoot=true, EndEffector=true, Pole=true, Target=true,
		MeshId=true, TextureID=true, TextureId=true, Texture=true,
		SoundId=true, AnimationId=true, AssetId=true, Source=true,
		CageMeshId=true, ReferenceMeshId=true,
		ColorMap=true, NormalMap=true, MetalnessMap=true, RoughnessMap=true,
		Video=true, Image=true, HoverImage=true, PressedImage=true,
		SkyboxBk=true, SkyboxDn=true, SkyboxFt=true, SkyboxLf=true,
		SkyboxRt=true, SkyboxUp=true, MoonTextureId=true, SunTextureId=true,
		PantsTemplate=true, ShirtTemplate=true, Graphic=true,
	}
	return lateProps[PropName] == true
end

local function ShouldSkipRedundantProperty(Inst, PropName, PropSet)
	if PropSet.CFrame then
		if (Inst:IsA("BasePart") or Inst:IsA("Attachment") or Inst:IsA("Bone"))
			and (PropName=="Position" or PropName=="Orientation" or PropName=="Rotation")
		then return true end
	end
	if PropSet.WorldCFrame then
		if (Inst:IsA("Attachment") or Inst:IsA("Bone"))
			and (PropName=="WorldPosition" or PropName=="WorldOrientation"
				or PropName=="WorldAxis" or PropName=="WorldSecondaryAxis")
		then return true end
	end
	if PropSet.FontFace and PropName == "Font" then return true end
	return false
end

local function GetPropertyOrderRank(Inst, PropName)
	if PropName == "Name" then return 0 end
	if Inst:IsA("BasePart") then
		if PropName == "Anchored"                                          then return 1 end
		if PropName == "Size"                                              then return 2 end
		if PropName == "PivotOffset"                                       then return 3 end
		if PropName == "CFrame"                                            then return 4 end
		if PropName == "Position" or PropName == "Orientation" or PropName == "Rotation" then return 5 end
		if PropName == "Color" or PropName == "BrickColor"                 then return 6 end
		if PropName == "Material" or PropName == "MaterialVariant"         then return 7 end
		if PropName == "Transparency"                                      then return 8 end
		if PropName == "CanCollide"                                        then return 9 end
	end
	if Inst:IsA("Attachment") or Inst:IsA("Bone") then
		if PropName == "CFrame"   then return 3 end
		if PropName == "Position" or PropName == "Orientation" then return 4 end
	end
	if Inst:IsA("Model") then
		if PropName == "PrimaryPart" then return 3 end
		if PropName == "WorldPivot"  then return 90 end
	end
	if Inst:IsA("GuiObject") then
		if PropName == "Size"        then return 1 end
		if PropName == "Position"    then return 2 end
		if PropName == "AnchorPoint" then return 3 end
		if PropName == "Visible"     then return 4 end
		if PropName == "ZIndex"      then return 5 end
	end
	if Inst:IsA("Beam") or Inst:IsA("Trail") then
		if PropName == "Attachment0" or PropName == "Attachment1" then return 2 end
	end
	if Inst:IsA("Weld") or Inst:IsA("Motor6D") or Inst:IsA("Snap")
		or Inst:IsA("ManualWeld") or Inst:IsA("ManualGlue")
	then
		if PropName == "Part0" or PropName == "Part1" then return 2 end
		if PropName == "C0"    or PropName == "C1"    then return 3 end
	end
	if Inst:IsA("IKControl") then
		if PropName == "ChainRoot"   then return 1 end
		if PropName == "EndEffector" then return 2 end
		if PropName == "Target"      then return 3 end
	end
	return 50
end

-- ============================================================
-- PROP RESOLUTION
-- ============================================================
local function AddHintProps(Dest, Inst)
	for ClassName, PropList in pairs(ExactPropertyHints) do
		local Include = false
		if ClassName == "Instance" then
			Include = true
		else
			local ok, result = pcall(function() return Inst:IsA(ClassName) end)
			Include = ok and result or false
		end
		if Include then
			for _, PropName in ipairs(PropList) do Dest[PropName] = true end
		end
	end
end

local function ResolveFallbackProps(Inst)
	local Merged = {}
	local Class  = Inst.ClassName
	local Own    = FallbackProperties[Class]
	if Own then
		for K, V in pairs(Own) do Merged[K] = V end
	end
	for _, Parent in ipairs(Inheritance[Class] or {"Instance"}) do
		local P = FallbackProperties[Parent]
		if P then
			for K, V in pairs(P) do if Merged[K] == nil then Merged[K] = V end end
		end
	end
	if Merged.Name == nil or Merged.Name == "Instance" then Merged.Name = Class end
	return Merged
end

local function ResolveProps(Inst)
	local okBP, isBP = pcall(function() return Inst:IsA("BasePart") end)
	local ClassSkip   = ClassSkipProperties[Inst.ClassName]
		or (okBP and isBP and ClassSkipProperties["BasePart"])
		or {}

	local Props = {}

	if listproperties then
		local ok, Raw = pcall(listproperties, Inst)
		if ok then MergePropertyDump(Props, Raw) end
	end
	if getproperties then
		local ok, Raw = pcall(getproperties, Inst)
		if ok then MergePropertyDump(Props, Raw) end
	end
	if gethiddenproperties then
		local ok, Raw = pcall(gethiddenproperties, Inst)
		if ok then MergePropertyDump(Props, Raw) end
	end

	MergePropNames(Props, ResolveFallbackProps(Inst))
	AddHintProps(Props, Inst)

	for K in pairs(Props) do
		if SkipProperties[K] or ClassSkip[K] then
			Props[K] = nil
		else
			local ok = ReadProperty(Inst, K)
			if not ok then Props[K] = nil end
		end
	end
	return Props
end

-- ============================================================
-- BUILD
-- ============================================================
local function Build(Target)
	assert(typeof(Target) == "Instance", "[HikloSerializer] .Path must be a valid Instance")

	local Lines             = {}
	local DeferredRefs      = {}
	local DeferredLateProps = {}
	local DeferredVisualProps = {}
	local ScriptBlocks      = {}
	local ConnectionBlocks  = {}
	local InstVarMap        = {}
	local UsedNames         = {}
	local NeedCS            = false

	local function Push(S, ...)
		Lines[#Lines+1] = select("#", ...) > 0 and string.format(S, ...) or S
	end
	local function PushBlank()
		Lines[#Lines+1] = ""
	end
	local function PushComment(S, ...)
		Lines[#Lines+1] = "-- " .. (select("#", ...) > 0 and string.format(S, ...) or S)
	end

	local function MakeVar(Inst)
		local Base = Inst.Name:gsub("[^%w_]", "_")
		Base = Base:gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
		if Base == "" then Base = Inst.ClassName end
		if Base:match("^%d") then Base = "_" .. Base end
		if ReservedNames[Base] then Base = Base .. "_obj" end
		local Count = (UsedNames[Base] or 0) + 1
		UsedNames[Base] = Count
		return Count == 1 and Base or (Base .. Count)
	end

	local AllInsts = { Target }
	for _, Desc in ipairs(Target:GetDescendants()) do
		AllInsts[#AllInsts+1] = Desc
	end

	for Index, Inst in ipairs(AllInsts) do
		InstVarMap[Inst] = string.format("objects[%d]", Index)
		if #CollectionService:GetTags(Inst) > 0 then NeedCS = true end
	end

	-- Header comment
	Push("-- Generated by HikloSerializer v" .. VERSION)
	Push("-- Target: " .. Target.Name .. " (" .. Target.ClassName .. ")")
	Push("-- Descendants: " .. tostring(#AllInsts - 1))
	Push("-- " .. os.date("%Y-%m-%d %H:%M:%S"))
	PushBlank()

	if NeedCS then
		Push('local CollectionService = game:GetService("CollectionService")')
		PushBlank()
	end

	Push("local _yc = 0")
	PushBlank()

	-- Core helpers
	Push("local function set(inst, prop, value)")
	Push("\tlocal ok = pcall(function() inst[prop] = value end)")
	Push("\tif not ok and sethiddenproperty then")
	Push("\t\tpcall(sethiddenproperty, inst, prop, value)")
	Push("\tend")
	Push("\t_yc = _yc + 1")
	Push(string.format("\tif _yc %% %d == 0 then task.wait() end", Config.OutputYieldEvery))
	Push("end")
	PushBlank()

	Push("local function setParent(inst, parent)")
	Push("\tpcall(function() inst.Parent = parent end)")
	Push("end")
	PushBlank()

	Push("local function setAttr(inst, name, value)")
	Push("\tpcall(function() inst:SetAttribute(name, value) end)")
	Push("end")
	PushBlank()

	if NeedCS then
		Push("local function addTag(inst, tag)")
		Push("\tpcall(function() CollectionService:AddTag(inst, tag) end)")
		Push("end")
		PushBlank()
	end

	-- Instance creation
	Push("local objects = {}")
	for Index, Inst in ipairs(AllInsts) do
		local ok, _ = pcall(Instance.new, Inst.ClassName)
		if ok then
			Push("objects[%d] = Instance.new(%q)", Index, Inst.ClassName)
		else
			Push("objects[%d] = nil -- %s could not be instantiated", Index, Inst.ClassName)
		end
		if Index % Config.OutputYieldEveryObjects == 0 then Push("task.wait()") end
	end
	PushBlank()

	-- Per-instance property application
	for ListIndex, Inst in ipairs(AllInsts) do
		if ListIndex % Config.YieldEveryInstances == 0 then task.wait() end

		local Var      = InstVarMap[Inst]
		local PropSet  = ResolveProps(Inst)
		local PropNames = {}

		for PropName in pairs(PropSet) do PropNames[#PropNames+1] = PropName end
		table.sort(PropNames, function(A, B)
			local AR = GetPropertyOrderRank(Inst, A)
			local BR = GetPropertyOrderRank(Inst, B)
			if AR ~= BR then return AR < BR end
			return A < B
		end)

		local InstIsScript, InstIsModule
		do
			local okS, vS = pcall(function() return Inst:IsA("Script") end)
			InstIsScript = okS and vS
			local okM, vM = pcall(function() return Inst:IsA("ModuleScript") end)
			InstIsModule = okM and vM
		end

		for _, PropName in ipairs(PropNames) do
			local ok, Value = ReadProperty(Inst, PropName)
			if not ok then continue end

			if PropName == "Source" then
				local Src, WasDecompiled = GetScriptSource(Inst)
				if not Src then continue end

				if InstIsModule and Config.InlineModules then
					-- ModuleScript: emit [[]] inline executor + set Source
					EmitModuleInline(Push, PushBlank, Var, Inst.Name, Src, WasDecompiled)
					-- Also set the actual Source property so require() works
					DeferredLateProps[#DeferredLateProps+1] = string.format(
						"set(%s, %q, %s)", Var, "Source", SerializeMultilineString(Src)
					)
				elseif InstIsScript and not InstIsModule and Config.ConvertScriptsToInline then
					if WasDecompiled then
						-- Decompiled Script: loadstring block
						ScriptBlocks[#ScriptBlocks+1] = {
							Source    = Src,
							ClassName = Inst.ClassName,
							Name      = Inst.Name,
							Var       = Var,
						}
						DeferredLateProps[#DeferredLateProps+1] = string.format(
							"set(%s, %q, true)", Var, "Disabled"
						)
					else
						DeferredLateProps[#DeferredLateProps+1] = string.format(
							"set(%s, %q, %s)", Var, "Source", SerializeMultilineString(Src)
						)
					end
				else
					DeferredLateProps[#DeferredLateProps+1] = string.format(
						"set(%s, %q, %s)", Var, "Source", SerializeMultilineString(Src)
					)
				end
				continue
			end

			local Serialized = SerializeValue(Value, InstVarMap)
			if not Serialized then continue end
			if ShouldSkipRedundantProperty(Inst, PropName, PropSet) then continue end

			local line = string.format("set(%s, %q, %s)", Var, PropName, Serialized)

			if typeof(Value) == "Instance" then
				DeferredRefs[#DeferredRefs+1] = line
			elseif ShouldUseFinalVisualProperty(Inst, PropName) then
				DeferredVisualProps[#DeferredVisualProps+1] = line
			elseif ShouldUseLateProperty(Inst, PropName, Value) then
				DeferredLateProps[#DeferredLateProps+1] = line
			else
				Push(line)
			end
		end

		-- Attributes
		local AttrMap   = Inst:GetAttributes()
		local AttrNames = {}
		for AttrName in pairs(AttrMap) do AttrNames[#AttrNames+1] = AttrName end
		table.sort(AttrNames)
		for _, AttrName in ipairs(AttrNames) do
			local AS = SerializeValue(AttrMap[AttrName], InstVarMap)
			if AS then Push("setAttr(%s, %q, %s)", Var, AttrName, AS) end
		end

		-- Tags
		local Tags = CollectionService:GetTags(Inst)
		if #Tags > 0 then
			table.sort(Tags)
			for _, Tag in ipairs(Tags) do Push("addTag(%s, %q)", Var, Tag) end
		end

		-- Capture connections if enabled
		if Config.CaptureConnections then
			local Conns = CaptureConnections(Inst)
			if #Conns > 0 then
				ConnectionBlocks[#ConnectionBlocks+1] = {
					Var   = Var,
					Name  = Inst.Name,
					Class = Inst.ClassName,
					Conns = Conns,
				}
			end
		end

		PushBlank()
	end

	-- Parent assignments
	PushComment("Parent assignments")
	for Index, Inst in ipairs(AllInsts) do
		Push("setParent(%s, %s)", InstVarMap[Inst], SerializeParentValue(Inst.Parent, InstVarMap))
		if Index % Config.OutputYieldEveryObjects == 0 then Push("task.wait()") end
	end
	PushBlank()

	-- Deferred: instance references
	if #DeferredRefs > 0 then
		PushComment("Instance reference properties")
		for _, Line in ipairs(DeferredRefs) do Push(Line) end
		PushBlank()
	end

	-- Deferred: late properties
	if #DeferredLateProps > 0 then
		PushComment("Late properties (assets, sources, cross-refs)")
		for _, Line in ipairs(DeferredLateProps) do Push(Line) end
		PushBlank()
	end

	-- Deferred: final visual properties
	if #DeferredVisualProps > 0 then
		PushComment("Final visual properties")
		for _, Line in ipairs(DeferredVisualProps) do Push(Line) end
		PushBlank()
	end

	-- Decompiled script execution blocks
	if #ScriptBlocks > 0 then
		PushComment("================================================================")
		PushComment("DECOMPILED SCRIPT EXECUTION BLOCKS")
		PushComment("Scripts run via loadstring. Source has been cleaned.")
		PushComment("================================================================")
		PushBlank()
		for _, Block in ipairs(ScriptBlocks) do
			Push("-- %s (%s)", Block.Name, Block.ClassName)
			Push("task.spawn(function()")
			Push("\tlocal _fn, _err = loadstring(%s, %q)", SerializeMultilineString(Block.Source), "@" .. Block.Name)
			Push("\tif not _fn then")
			Push('\t\twarn("[HikloSerializer] Script load error in %s:", %q, _err)', Block.Name, Block.Name)
			Push("\t\treturn")
			Push("\tend")
			Push("\tlocal _ok, _err2 = pcall(_fn)")
			Push('\t\tif not _ok then warn("[HikloSerializer] Script runtime error in %s:", %q, _err2) end', Block.Name, Block.Name)
			Push("end)")
			PushBlank()
		end
	end

	-- Connection re-bindings
	if #ConnectionBlocks > 0 then
		PushComment("================================================================")
		PushComment("CAPTURED CONNECTIONS (via getconnections)")
		PushComment("Decompiled handler source embedded below.")
		PushComment("Note: upvalue closures cannot be reconstructed.")
		PushComment("================================================================")
		PushBlank()
		for _, Block in ipairs(ConnectionBlocks) do
			Push("-- Connections for: %s (%s) = %s", Block.Name, Block.Class, Block.Var)
			for _, Conn in ipairs(Block.Conns) do
				Push("pcall(function()")
				Push("\t-- Signal: %s", Conn.signal)
				Push("\tlocal _hSrc = %s", SerializeMultilineString(Conn.source))
				Push('\tlocal _hFn, _hErr = loadstring("return " .. _hSrc:match("^%%s*(.-)%%s*$"), "@conn_%s_%s")', Block.Name, Conn.signal)
				Push("\tif _hFn then")
				Push("\t\tlocal _ok, _handler = pcall(_hFn)")
				Push("\t\tif _ok and type(_handler) == \"function\" then")
				Push("\t\t\t%s.%s:Connect(_handler)", Block.Var, Conn.signal)
				Push("\t\tend")
				Push("\telse")
				-- handler source might not be a bare function expr; fall back to wrapping
				Push('\t\tlocal _wSrc = "return function(...) " .. _hSrc .. " end"')
				Push('\t\tlocal _wFn = loadstring(_wSrc, "@conn_%s_%s_wrapped")', Block.Name, Conn.signal)
				Push("\t\tif _wFn then")
				Push("\t\t\tlocal _ok2, _h2 = pcall(_wFn)")
				Push("\t\t\tif _ok2 and type(_h2) == \"function\" then")
				Push("\t\t\t\t%s.%s:Connect(_h2)", Block.Var, Conn.signal)
				Push("\t\t\tend")
				Push("\t\tend")
				Push("\tend")
				Push("end)")
				PushBlank()
			end
		end
	end

	Push("return objects[1]")
	return table.concat(Lines, "\n")
end

-- ============================================================
-- PUBLIC API
-- ============================================================
local HikloSerializer = {}
HikloSerializer.__index = HikloSerializer
HikloSerializer.Path    = nil
HikloSerializer.Version = VERSION

function HikloSerializer:Build()
	assert(self.Path ~= nil, "[HikloSerializer] .Path is not set")
	return Build(self.Path)
end

function HikloSerializer:Save(FileName)
	local Output = self:Build()
	local Name = FileName
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

-- Convenience: clean a decompiled source string directly
-- HikloSerializer:CleanSource(src, name) -> cleaned string
function HikloSerializer:CleanSource(Src, Name)
	return DecompileClean(Src, Name or "unknown")
end

-- Convenience: capture connections from an instance directly
-- HikloSerializer:GetConnections(inst) -> [{signal, source}]
function HikloSerializer:GetConnections(Inst)
	return CaptureConnections(Inst)
end

return HikloSerializer
