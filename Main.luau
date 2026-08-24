local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- SafeEnum wrapper to prevent executor crashes on missing Enums
local SafeEnum = setmetatable({}, {
    __index = function(t, k)
        local Ok, Res = pcall(function() return Enum[k] end)
        if not Ok or not Res then return nil end
        return setmetatable({}, {
            __index = function(t2, k2)
                local Ok2, Res2 = pcall(function() return Res[k2] end)
                if not Ok2 or not Res2 then return nil end
                return Res2
            end
        })
    end
})

local SkipProperties = {
    Parent = true, 
    ClassName = true, 
    DataCost = true, 
    RobloxLocked = true,
    Archivable = true, 
    Changed = true, 
    AncestryChanged = true,
    ChildAdded = true, 
    ChildRemoved = true, 
    DescendantAdded = true,
    DescendantRemoving = true, 
    AttributeChanged = true,
    AbsolutePosition = true, 
    AbsoluteSize = true, 
    AbsoluteRotation = true,
    AbsoluteContentSize = true, 
    TotalGroupStride = true, 
    CanvasAbsoluteSize = true,
    ContentText = true, 
    TextBounds = true, 
    TextFits = true,
    LocalTransparencyModifier = true, 
    ReceiveAge = true,
    AssemblyAngularVelocity = true, 
    AssemblyLinearVelocity = true,
    AssemblyCenterOfMass = true, 
    AssemblyMass = true, 
    AssemblyRootPart = true,
    RootPriority = true, 
    Mass = true, 
    IsLoaded = true,
    PlaybackLoudness = true, 
    IsPaused = true, 
    IsPlaying = true, 
    TimeLength = true,
    UniqueId = true, 
    HistoryId = true, 
    InterpolationThrottling = true,
    FluidForces = true, 
    SimulationRadius = true, 
    StreamingRadius = true,
    IsReady = true, 
    PeakLevel = true, 
    RmsLevel = true, 
    ActivePose = true,
    Health = true, 
    Jump = true, 
    Sit = true, 
    TargetPoint = true,
    WalkToPoint = true, 
    WalkToPart = true, 
    MoveDirection = true,
    LookVector = true, 
    RootPart = true, 
    Torso = true,
    Velocity = true, 
    RotVelocity = true, 
    CoordinateFrame = true,
    WorldPivot = true, 
    CameraOrigin = true, 
    CameraOrientation = true,
    IsScriptable = true,
    RobloxOnly = true,
    DoubleClickEnabled = true,
    Expression = true,
    HideOffhandInventory = true,
    Internal = true,
    PreviousGuid = true,
    CurrentOffset = true,
    TargetOffset = true,
    Selected = true,
    RelativeSize = true,
    MappingPreset = true,
    DataSource = true,
    IsDragged = true,
    Dimensions = true,
    BackSurfaceInput = true,
    BottomSurfaceInput = true,
    FrontSurfaceInput = true,
    LeftSurfaceInput = true,
    RightSurfaceInput = true,
    TopSurfaceInput = true,
    Shiny = true,
    Specular = true,
    WorldCFrame = true, 
    WorldPosition = true, 
    WorldOrientation = true,
    WorldAxis = true, 
    WorldSecondaryAxis = true,
}

local FallbackProperties = {}

FallbackProperties["Instance"] = {
    Name = "Instance",
    Archivable = true,
}

FallbackProperties["BasePart"] = {
    Anchored = false,
    BackSurface = SafeEnum.SurfaceType.Smooth,
    BottomSurface = SafeEnum.SurfaceType.Smooth,
    CFrame = CFrame.new(),
    CanCollide = true,
    CanQuery = true,
    CanTouch = true,
    CastShadow = true,
    CollisionGroup = "Default",
    Color = Color3.new(0.639216, 0.635294, 0.647059),
    CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.1, 0.1),
    EnableFluidForces = true,
    FrontSurface = SafeEnum.SurfaceType.Smooth,
    LeftSurface = SafeEnum.SurfaceType.Smooth,
    Locked = false,
    Massless = false,
    Material = SafeEnum.Material.SmoothPlastic,
    MaterialVariant = "",
    Orientation = Vector3.new(),
    PivotOffset = CFrame.new(),
    Position = Vector3.new(),
    Reflectance = 0,
    RightSurface = SafeEnum.SurfaceType.Smooth,
    RootPriority = 0,
    Rotation = Vector3.new(),
    Size = Vector3.new(4, 1, 2),
    TopSurface = SafeEnum.SurfaceType.Smooth,
    Transparency = 0,
}

FallbackProperties["FormFactorPart"] = {}
FallbackProperties["Part"] = { Shape = SafeEnum.PartType.Block }
FallbackProperties["WedgePart"] = {}
FallbackProperties["CornerWedgePart"] = {}
FallbackProperties["TrussPart"] = {}

FallbackProperties["SpawnLocation"] = {
    AllowTeamChangeOnTouch = false,
    Duration = 10,
    Enabled = true,
    Neutral = true,
    TeamColor = BrickColor.new("White"),
    Shape = SafeEnum.PartType.Block,
}

FallbackProperties["Platform"] = {}
FallbackProperties["Seat"] = { Disabled = false, Occupant = nil }

FallbackProperties["VehicleSeat"] = {
    Disabled = false,
    HeadsUpDisplay = true,
    MaxSpeed = 100,
    Steer = 0,
    SteerFloat = 0,
    Throttle = 0,
    ThrottleFloat = 0,
    TurnSpeed = 1,
}

FallbackProperties["MeshPart"] = {
    CollisionFidelity = SafeEnum.CollisionFidelity.Default,
    DoubleSided = false,
    MeshId = "",
    MeshSize = Vector3.new(1, 1, 1),
    RenderFidelity = SafeEnum.RenderFidelity.Automatic,
    TextureID = "",
}

FallbackProperties["PartOperation"] = {
    CollisionFidelity = SafeEnum.CollisionFidelity.Default,
    RenderFidelity = SafeEnum.RenderFidelity.Automatic,
    SmoothingAngle = 30,
    UsePartColor = false,
}

FallbackProperties["UnionOperation"] = FallbackProperties["PartOperation"]
FallbackProperties["NegateOperation"] = FallbackProperties["PartOperation"]
FallbackProperties["IntersectOperation"] = FallbackProperties["PartOperation"]

FallbackProperties["SpecialMesh"] = {
    MeshId = "",
    MeshType = SafeEnum.MeshType.Head,
    Offset = Vector3.new(),
    RotationOffset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
    TextureId = "",
    VertexColor = Vector3.new(1, 1, 1),
}

FallbackProperties["CylinderMesh"] = { Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1) }
FallbackProperties["BlockMesh"] = { Offset = Vector3.new(), RotationOffset = Vector3.new(), Scale = Vector3.new(1, 1, 1) }

FallbackProperties["FileMesh"] = {
    MeshId = "",
    Offset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
    TextureId = "",
    VertexColor = Vector3.new(1, 1, 1),
}

FallbackProperties["Decal"] = {
    Color3 = Color3.new(1, 1, 1),
    Face = SafeEnum.NormalId.Front,
    Texture = "",
    Transparency = 0,
    ZIndex = 0,
}

FallbackProperties["Texture"] = {
    Color3 = Color3.new(1, 1, 1),
    Face = SafeEnum.NormalId.Front,
    OffsetStudsU = 0,
    OffsetStudsV = 0,
    StudsPerTileU = 2,
    StudsPerTileV = 2,
    Texture = "",
    Transparency = 0,
    ZIndex = 0,
}

FallbackProperties["SurfaceAppearance"] = {
    AlphaMode = SafeEnum.AlphaMode.Overlay,
    Color = Color3.new(1, 1, 1),
    ColorMap = "",
    Metalness = 0,
    MetalnessMap = "",
    NormalMap = "",
    Roughness = 0.5,
    RoughnessMap = "",
    TexturePack = "",
}

FallbackProperties["Model"] = {
    LevelOfDetail = SafeEnum.ModelLevelOfDetail.Disabled,
    ModelStreamingMode = SafeEnum.ModelStreamingMode.Default,
    PrimaryPart = nil,
    WorldPivot = CFrame.new(),
}

FallbackProperties["Folder"] = {}
FallbackProperties["Tool"] = {
    CanBeDropped = true,
    Enabled = true,
    Grip = CFrame.new(),
    GripForward = Vector3.new(0, 0, -1),
    GripPos = Vector3.new(),
    GripRight = Vector3.new(1, 0, 0),
    GripUp = Vector3.new(0, 1, 0),
    ManualActivationOnly = false,
    RequiresHandle = true,
    ToolTip = "",
}

FallbackProperties["Backpack"] = {}
FallbackProperties["StarterPack"] = {}
FallbackProperties["StarterGear"] = {}

FallbackProperties["Hat"] = {
    AttachmentForward = Vector3.new(0, 0, -1),
    AttachmentPos = Vector3.new(),
    AttachmentRight = Vector3.new(1, 0, 0),
    AttachmentUp = Vector3.new(0, 1, 0),
}

FallbackProperties["Accessory"] = {
    AccessoryType = SafeEnum.AccessoryType.Hat,
    AttachmentPoint = CFrame.new(),
}

FallbackProperties["Script"] = { Disabled = false, RunContext = SafeEnum.RunContext.Legacy, Source = "" }
FallbackProperties["LocalScript"] = { Disabled = false, Source = "" }
FallbackProperties["ModuleScript"] = { Source = "" }

FallbackProperties["StringValue"] = { Value = "" }
FallbackProperties["NumberValue"] = { Value = 0 }
FallbackProperties["BoolValue"] = { Value = false }
FallbackProperties["IntValue"] = { Value = 0 }
FallbackProperties["Vector3Value"] = { Value = Vector3.new() }
FallbackProperties["CFrameValue"] = { Value = CFrame.new() }
FallbackProperties["ObjectValue"] = { Value = nil }
FallbackProperties["Color3Value"] = { Value = Color3.new() }
FallbackProperties["BrickColorValue"] = { Value = BrickColor.new("Medium stone grey") }
FallbackProperties["RayValue"] = { Value = Ray.new(Vector3.new(), Vector3.new()) }

FallbackProperties["Animation"] = { AnimationId = "" }
FallbackProperties["Animator"] = {}
FallbackProperties["AnimationController"] = {}
FallbackProperties["AnimationTrack"] = {}

FallbackProperties["BodyColors"] = {
    HeadColor3 = Color3.fromRGB(163, 162, 165),
    LeftArmColor3 = Color3.fromRGB(163, 162, 165),
    LeftLegColor3 = Color3.fromRGB(163, 162, 165),
    RightArmColor3 = Color3.fromRGB(163, 162, 165),
    RightLegColor3 = Color3.fromRGB(163, 162, 165),
    TorsoColor3 = Color3.fromRGB(163, 162, 165),
}

FallbackProperties["CharacterMesh"] = { BaseTextureId = 0, MeshId = 0, OverlayTextureId = 0 }
FallbackProperties["Pants"] = { PantsTemplate = "" }
FallbackProperties["Shirt"] = { ShirtTemplate = "" }
FallbackProperties["ShirtGraphic"] = { Color3 = Color3.new(1, 1, 1), Graphic = "" }

FallbackProperties["WrapLayer"] = {
    AutoSkin = SafeEnum.WrapLayerAutoSkin.Disabled,
    BindOffset = CFrame.new(),
    Color = BrickColor.new("Bright blue"),
    DebugHeatmap = false,
    Enabled = true,
    InflateDelta = 0,
    Order = 0,
    Puffiness = 0,
    ReferenceMeshId = "",
    ReferenceOrigin = CFrame.new(),
    ShrinkDelta = 0,
}

FallbackProperties["WrapTarget"] = {
    CageMeshId = "",
    CageOrigin = CFrame.new(),
    Color = BrickColor.new("Bright blue"),
    DebugHeatmap = false,
    Enabled = true,
    Stiffness = 0,
}

FallbackProperties["IKControl"] = {
    ChainRoot = nil,
    Enabled = true,
    EndEffector = nil,
    Offset = CFrame.new(),
    Pole = nil,
    Priority = 0,
    SmoothTime = 0,
    Target = nil,
    Type = SafeEnum.IKControlType.Transform,
    Weight = 1,
}

FallbackProperties["Sound"] = {
    EmitterSize = 10,
    Looped = false,
    MaxDistance = 10000,
    Playing = false,
    PlayOnRemove = false,
    PlaybackRegionsEnabled = false,
    PlaybackSpeed = 1,
    RollOffMaxDistance = 10000,
    RollOffMinDistance = 10,
    RollOffMode = SafeEnum.RollOffMode.InverseTapered,
    SoundGroup = nil,
    SoundId = "",
    TimePosition = 0,
    Volume = 0.5,
}

FallbackProperties["SoundService"] = {
    AmbientReverb = SafeEnum.ReverbType.NoReverb,
    DistanceFactor = 3.33,
    DopplerScale = 1,
    RespectFilteringEnabled = true,
    VolumetricAudio = SafeEnum.VolumetricAudio.Disabled,
}

FallbackProperties["EqualizerSoundEffect"] = { HighGain = 0, LowGain = 0, MidGain = 0, Priority = 0 }
FallbackProperties["ReverbSoundEffect"] = { DecayTime = 1.5, Density = 1, Diffusion = 1, DryLevel = -6, Priority = 0, WetLevel = 0 }
FallbackProperties["ChorusSoundEffect"] = { Depth = 1, Mix = 50, Priority = 0, Rate = 0.45 }
FallbackProperties["CompressorSoundEffect"] = { Attack = 0.003, GainMakeup = 0, Priority = 0, Release = 0.5, SideChain = nil, Threshold = -24 }
FallbackProperties["DistortionSoundEffect"] = { Level = 0, Priority = 0 }
FallbackProperties["EchoSoundEffect"] = { Delay = 1, DryLevel = 0, FeedBack = 0.5, Priority = 0, WetLevel = -6 }
FallbackProperties["FlangeSoundEffect"] = { Depth = 45, Mix = 50, Priority = 0, Rate = 0.45 }
FallbackProperties["PitchShiftSoundEffect"] = { Octave = 1, Priority = 0 }
FallbackProperties["TremoloSoundEffect"] = { Depth = 1, Duty = 50, Frequency = 5, Priority = 0 }

FallbackProperties["AudioPlayer"] = {
    AssetId = "",
    Looping = false,
    PlaybackRegionsEnabled = false,
    PlaybackSpeed = 1,
    TimePosition = 0,
    Volume = 1,
}

FallbackProperties["AudioEmitter"] = {}
FallbackProperties["AudioListener"] = {}
FallbackProperties["AudioAnalyzer"] = {}
FallbackProperties["AudioChorus"] = { Bypass = false, Depth = 0.15, Mix = 0.5, Rate = 0.5 }
FallbackProperties["AudioCompressor"] = { Attack = 0.05, Bypass = false, GainMakeup = 0, Ratio = 4, Release = 0.1, Threshold = -24 }
FallbackProperties["AudioDistortion"] = { Bypass = false, Level = 0 }
FallbackProperties["AudioEqualizer"] = { Bypass = false, HighGain = 0, LowGain = 0, MidGain = 0 }
FallbackProperties["AudioFader"] = { Bypass = false, Volume = 1 }
FallbackProperties["AudioFlanger"] = { Bypass = false, Depth = 45, Mix = 0.5, Rate = 0.5 }
FallbackProperties["AudioPitchShifter"] = { Bypass = false, Octave = 1 }
FallbackProperties["AudioReverb"] = { Bypass = false, DecayTime = 1.5, Density = 1, Diffusion = 1, DryLevel = 0, WetLevel = -6 }
FallbackProperties["AudioTremolo"] = { Bypass = false, Depth = 1, Duty = 50, Frequency = 5 }
FallbackProperties["AudioDeviceInput"] = { Active = false, Muted = false, Player = nil }
FallbackProperties["AudioDeviceOutput"] = { Muted = false, Player = nil }
FallbackProperties["Wire"] = {}

FallbackProperties["Attachment"] = {
    Axis = Vector3.new(1, 0, 0),
    CFrame = CFrame.new(),
    Orientation = Vector3.new(),
    Position = Vector3.new(),
    SecondaryAxis = Vector3.new(0, 1, 0),
    Visible = false,
    WorldAxis = Vector3.new(1, 0, 0),
    WorldCFrame = CFrame.new(),
    WorldOrientation = Vector3.new(),
    WorldPosition = Vector3.new(),
    WorldSecondaryAxis = Vector3.new(0, 1, 0),
}

FallbackProperties["Bone"] = {
    CFrame = CFrame.new(),
    Orientation = Vector3.new(),
    Position = Vector3.new(),
    Transform = CFrame.new(),
    WorldCFrame = CFrame.new(),
    WorldPosition = Vector3.new(),
}

FallbackProperties["Beam"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Brightness = 1,
    Color = ColorSequence.new(Color3.new(1, 1, 1)),
    CurveSize0 = 0,
    CurveSize1 = 0,
    Enabled = true,
    FaceCamera = false,
    LightEmission = 0,
    LightInfluence = 1,
    Segments = 10,
    Texture = "",
    TextureLength = 1,
    TextureMode = SafeEnum.TextureMode.Stretch,
    TextureSpeed = 1,
    Transparency = NumberSequence.new(0),
    Width0 = 1,
    Width1 = 1,
    ZOffset = 0,
}

FallbackProperties["Trail"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Brightness = 1,
    Color = ColorSequence.new(Color3.new(1, 1, 1)),
    Enabled = true,
    FaceCamera = false,
    Lifetime = 2,
    LightEmission = 0,
    LightInfluence = 1,
    MaxLength = 0,
    MinLength = 0,
    Texture = "",
    TextureLength = 1,
    TextureMode = SafeEnum.TextureMode.Stretch,
    Transparency = NumberSequence.new(0),
    WidthScale = NumberSequence.new(1),
}

FallbackProperties["ParticleEmitter"] = {
    Acceleration = Vector3.new(),
    Brightness = 1,
    Color = ColorSequence.new(Color3.new(1, 1, 1)),
    Drag = 0,
    EmissionDirection = SafeEnum.NormalId.Top,
    Enabled = true,
    FlipbookFramerate = NumberRange.new(30),
    FlipbookIncompatible = "",
    FlipbookLayout = SafeEnum.ParticleFlipbookLayout.None,
    FlipbookMode = SafeEnum.ParticleFlipbookMode.Loop,
    LifeTime = NumberRange.new(5, 10),
    LightEmission = 0,
    LightInfluence = 1,
    LockedToPart = false,
    Orientation = SafeEnum.ParticleOrientation.FacingCamera,
    Rate = 20,
    RotSpeed = NumberRange.new(0),
    Rotation = NumberRange.new(0),
    ShapeInOut = SafeEnum.ParticleEmitterShapeInOut.Out,
    ShapePartial = SafeEnum.ParticleEmitterShapePartial.Full,
    ShapeRotation = 0,
    ShapeStyle = SafeEnum.ParticleEmitterShapeStyle.Volume,
    Size = NumberSequence.new(1),
    Speed = NumberRange.new(5),
    SpreadAngle = Vector2.new(),
    Squash = NumberSequence.new(0),
    Texture = "rbxasset://textures/particles/smoke_main.dds",
    TimeScale = 1,
    Transparency = NumberSequence.new(0),
    VelocityInheritance = 0,
    ZOffset = 0,
}

FallbackProperties["Fire"] = {
    Color = Color3.fromRGB(255, 100, 0),
    Enabled = true,
    Heat = 9,
    SecondaryColor = Color3.fromRGB(255, 255, 0),
    Size = 5,
    TimeScale = 1,
}

FallbackProperties["Smoke"] = {
    Color = Color3.fromRGB(150, 150, 150),
    Enabled = true,
    Opacity = 0.5,
    RiseVelocity = 1,
    Size = 1,
    TimeScale = 1,
}

FallbackProperties["Sparkles"] = {
    Color = Color3.new(1, 1, 1),
    Enabled = true,
    SparkleColor = Color3.new(1, 1, 1),
    TimeScale = 1,
}

FallbackProperties["RopeConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    Length = 5,
    Restitution = 0,
    Thickness = 0.1,
    Visible = false,
}

FallbackProperties["SpringConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Coils = 5,
    Color = BrickColor.new("Bright blue"),
    Damping = 0,
    Enabled = true,
    FreeLength = 5,
    LimitsEnabled = false,
    MaxLength = 5,
    MinLength = 0,
    Radius = 0.15,
    Restitution = 0,
    Stiffness = 10,
    Thickness = 0.055,
    Visible = false,
}

FallbackProperties["HingeConstraint"] = {
    ActuatorType = SafeEnum.ActuatorType.None,
    Attachment0 = nil,
    Attachment1 = nil,
    AngularResponsiveness = 20,
    AngularSpeed = 45,
    AngularVelocity = 0,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    LimitsEnabled = false,
    LowerAngle = -45,
    MotorMaxAcceleration = math.huge,
    MotorMaxTorque = math.huge,
    Radius = 0.15,
    Restitution = 0,
    ServoMaxTorque = math.huge,
    TargetAngle = 0,
    UpperAngle = 45,
    Visible = false,
}

FallbackProperties["BallSocketConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    LimitsEnabled = false,
    MaxFrictionTorque = 0,
    Radius = 0.15,
    Restitution = 0,
    TwistLimitsEnabled = false,
    TwistLowerAngle = -45,
    TwistUpperAngle = 45,
    UpperAngle = 45,
    Visible = false,
}

FallbackProperties["CylindricalConstraint"] = {
    AngularActuatorType = SafeEnum.ActuatorType.None,
    AngularLimitsEnabled = false,
    AngularResponsiveness = 20,
    AngularSpeed = 45,
    AngularVelocity = 0,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    InclinationAngle = 0,
    LinearActuatorType = SafeEnum.ActuatorType.None,
    LinearLimitsEnabled = false,
    LinearResponsiveness = 20,
    LinearSpeed = 2,
    LowerAngle = -45,
    LowerLimit = 0,
    MotorMaxAcceleration = math.huge,
    MotorMaxForce = math.huge,
    MotorMaxTorque = math.huge,
    Radius = 0.15,
    Restitution = 0,
    ServoMaxForce = math.huge,
    ServoMaxTorque = math.huge,
    TargetAngle = 0,
    TargetPosition = 0,
    Thickness = 0.055,
    UpperAngle = 45,
    UpperLimit = 0,
    Visible = false,
    WorldLimitsEnabled = false,
}

FallbackProperties["PrismaticConstraint"] = {
    ActuatorType = SafeEnum.ActuatorType.None,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    LimitsEnabled = false,
    LinearResponsiveness = 20,
    LinearSpeed = 2,
    LowerLimit = 0,
    MotorMaxAcceleration = math.huge,
    MotorMaxForce = math.huge,
    Restitution = 0,
    ServoMaxForce = math.huge,
    TargetPosition = 0,
    Thickness = 0.055,
    UpperLimit = 0,
    Visible = false,
}

FallbackProperties["TorsionSpringConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Coils = 5,
    Color = BrickColor.new("Bright blue"),
    Damping = 0,
    Enabled = true,
    LimitsEnabled = false,
    LowerAngle = -45,
    MaxAngle = 45,
    Radius = 0.15,
    Restitution = 0,
    Stiffness = 10,
    UpperAngle = 45,
    Visible = false,
}

FallbackProperties["UniversalConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    MaxAngle = 45,
    Radius = 0.15,
    Restitution = 0,
    Visible = false,
}

FallbackProperties["LinearVelocityConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    ForceLimitMode = SafeEnum.ForceLimitMode.Magnitude,
    LineDirection = Vector3.new(0, 1, 0),
    LineVelocity = 0,
    MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
    MaxForce = math.huge,
    PlaneVelocity = Vector2.new(),
    PrimaryTangentAxis = Vector3.new(1, 0, 0),
    RelativeTo = SafeEnum.ActuatorRelativeTo.Attachment0,
    SecondaryTangentAxis = Vector3.new(0, 0, 1),
    VectorVelocity = Vector3.new(),
    VelocityConstraintMode = SafeEnum.VelocityConstraintMode.Vector,
    Visible = false,
}

FallbackProperties["AngularVelocityConstraint"] = {
    AngularVelocity = Vector3.new(0, 1, 0),
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    MaxTorque = math.huge,
    ReactionTorqueEnabled = false,
    RelativeTo = SafeEnum.ActuatorRelativeTo.Attachment0,
    Visible = false,
}

FallbackProperties["AlignPosition"] = {
    ApplyAtCenterOfMass = false,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    ForceLimitMode = SafeEnum.ForceLimitMode.Magnitude,
    MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
    MaxForce = math.huge,
    MaxVelocity = math.huge,
    Mode = SafeEnum.PositionAlignmentMode.TwoAttachment,
    Position = Vector3.new(),
    ReactionForceEnabled = false,
    Responsiveness = 200,
    RigidityEnabled = false,
    Visible = false,
}

FallbackProperties["AlignOrientation"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    CFrame = CFrame.new(),
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    MaxAngularVelocity = math.huge,
    MaxTorque = math.huge,
    Mode = SafeEnum.OrientationAlignmentMode.TwoAttachment,
    PrimaryAxis = Vector3.new(0, 1, 0),
    PrimaryAxisOnly = false,
    ReactionTorqueEnabled = false,
    Responsiveness = 200,
    RigidityEnabled = false,
    SecondaryAxis = Vector3.new(1, 0, 0),
    Visible = false,
}

FallbackProperties["WeldConstraint"] = { Enabled = true, Part0 = nil, Part1 = nil }
FallbackProperties["Weld"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }

FallbackProperties["Motor6D"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    CurrentAngle = 0,
    DesiredAngle = 0,
    MaxVelocity = 0.1,
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Snap"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualWeld"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["ManualGlue"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }
FallbackProperties["Motor"] = { C0 = CFrame.new(), C1 = CFrame.new(), CurrentAngle = 0, DesiredAngle = 0, MaxVelocity = 0.1, Part0 = nil, Part1 = nil }
FallbackProperties["Glue"] = { C0 = CFrame.new(), C1 = CFrame.new(), Part0 = nil, Part1 = nil }

FallbackProperties["RigidConstraint"] = { Attachment0 = nil, Attachment1 = nil, Enabled = true, Visible = false }

FallbackProperties["SliderConstraint"] = {
    ActuatorType = SafeEnum.ActuatorType.None,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    LimitsEnabled = false,
    LowerLimit = 0,
    MotorMaxAcceleration = math.huge,
    MotorMaxForce = math.huge,
    Restitution = 0,
    ServoMaxForce = math.huge,
    TargetPosition = 0,
    UpperLimit = 0,
    Visible = false,
}

FallbackProperties["BodyVelocity"] = { MaxForce = Vector3.new(4000, 4000, 4000), P = 10000, Velocity = Vector3.new() }
FallbackProperties["BodyPosition"] = { D = 500, MaxForce = Vector3.new(4000, 4000, 4000), P = 10000, Position = Vector3.new() }
FallbackProperties["BodyForce"] = { Force = Vector3.new() }
FallbackProperties["BodyAngularVelocity"] = { AngularVelocity = Vector3.new(), MaxTorque = Vector3.new(4000, 4000, 4000), P = 10000 }
FallbackProperties["BodyGyro"] = { CFrame = CFrame.new(), D = 500, MaxTorque = Vector3.new(4000, 4000, 4000), P = 10000 }
FallbackProperties["BodyThrust"] = { Force = Vector3.new(), Location = Vector3.new() }

FallbackProperties["RocketPropulsion"] = {
    CartoonFactor = 0.7,
    MaxSpeed = 50,
    MaxThrust = 4000,
    MaxTorque = Vector3.new(4000, 4000, 0),
    P = 10000,
    TargetOffset = Vector3.new(),
    TargetRadius = 4,
    ThrustD = 500,
    ThrustP = 100,
    TurnD = 500,
    TurnP = 100,
}

FallbackProperties["PointLight"] = { Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Range = 16, Shadows = false }
FallbackProperties["SpotLight"] = { Angle = 45, Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Face = SafeEnum.NormalId.Front, Range = 16, Shadows = false }
FallbackProperties["SurfaceLight"] = { Angle = 90, Brightness = 1, Color = Color3.new(1, 1, 1), Enabled = true, Face = SafeEnum.NormalId.Front, Range = 16, Shadows = false }

FallbackProperties["Atmosphere"] = {
    Color = Color3.fromRGB(199, 199, 199),
    Decay = Color3.fromRGB(255, 255, 255),
    Density = 0.395,
    Glare = 0,
    Haze = 0,
    Offset = 0,
}

FallbackProperties["Sky"] = {
    CelestialBodiesShown = true,
    MoonAngularSize = 11,
    MoonTextureId = "",
    SkyboxBk = "",
    SkyboxDn = "",
    SkyboxFt = "",
    SkyboxLf = "",
    SkyboxRt = "",
    SkyboxUp = "",
    StarCount = 3000,
    SunAngularSize = 21,
    SunTextureId = "",
}

FallbackProperties["Clouds"] = { Cover = 0.5, Density = 0.9, Enabled = true }
FallbackProperties["Bloom"] = { Enabled = true, Intensity = 0.5, Size = 56, Threshold = 0.95 }
FallbackProperties["Blur"] = { Enabled = true, Size = 24 }
FallbackProperties["ColorCorrection"] = { Brightness = 0, Contrast = 0, Enabled = true, Saturation = 0, TintColor = Color3.new(1, 1, 1) }
FallbackProperties["DepthOfField"] = { Enabled = true, FarIntensity = 0, FocusDistance = 50, InFocusRadius = 10, NearIntensity = 0 }
FallbackProperties["SunRaysEffect"] = { Enabled = true, Intensity = 0.5, Spread = 1 }

FallbackProperties["ProximityPrompt"] = {
    ActionText = "Interact",
    AutoLocalize = true,
    ClickablePrompt = true,
    Enabled = true,
    GamepadKeyCode = SafeEnum.KeyCode.ButtonX,
    HoldDuration = 0,
    KeyboardKeyCode = SafeEnum.KeyCode.E,
    MaxActivationDistance = 10,
    ObjectText = "",
    RequiresLineOfSight = true,
    Style = SafeEnum.ProximityPromptStyle.Default,
    UIOffset = Vector2.new(),
}

FallbackProperties["ClickDetector"] = { CursorIcon = "", MaxActivationDistance = 32 }
FallbackProperties["ForceField"] = { Visible = true }
FallbackProperties["PathfindingModifier"] = { IsBlocked = false, Label = "", PassThrough = false }
FallbackProperties["PathfindingLink"] = { Attachment0 = nil, Attachment1 = nil, Bidirectional = true, Label = "" }

FallbackProperties["Dialog"] = {
    BehaviorType = SafeEnum.DialogBehaviorType.SinglePlayer,
    ConversationDistance = 25,
    Enabled = true,
    GoodbyeChoiceActive = false,
    GoodbyeDialog = "",
    InitialPrompt = "",
    Purpose = SafeEnum.DialogPurpose.Help,
    Tone = SafeEnum.DialogTone.Neutral,
}

FallbackProperties["DialogChoice"] = {
    GoodbyeChoiceActive = false,
    GoodbyeDialog = "",
    ResponseDialog = "",
    UserDialog = "",
}

FallbackProperties["Humanoid"] = {
    AutoJumpEnabled = true,
    AutoRotate = true,
    BreakJointsOnDeath = true,
    CameraOffset = Vector3.new(),
    DisplayDistanceType = SafeEnum.HumanoidDisplayDistanceType.Viewer,
    HealthDisplayDistance = 100,
    HealthDisplayType = SafeEnum.HumanoidHealthDisplayType.DisplayWhenDamaged,
    HipHeight = 0,
    JumpHeight = 7.2,
    JumpPower = 50,
    MaxHealth = 100,
    MaxSlopeAngle = 89,
    NameDisplayDistance = 100,
    NameOcclusion = SafeEnum.NameOcclusion.OccludeAll,
    RequiresNeck = true,
    RigType = SafeEnum.HumanoidRigType.R6,
    UseJumpPower = false,
    WalkSpeed = 16,
}

FallbackProperties["HumanoidDescription"] = {
    BackAccessory = "",
    ClimbAnimation = 0,
    DepthOffset = 0,
    Face = 0,
    FaceAccessory = "",
    FallAnimation = 0,
    FrontAccessory = "",
    GraphicTShirt = 0,
    HairAccessory = "",
    HatAccessory = "",
    Head = 0,
    HeadColor = Color3.fromRGB(163, 162, 165),
    HeadScale = 1,
    IdleAnimation = 0,
    JumpAnimation = 0,
    LeftArm = 0,
    LeftArmColor = Color3.fromRGB(163, 162, 165),
    LeftLeg = 0,
    LeftLegColor = Color3.fromRGB(163, 162, 165),
    LowerTorso = 0,
    NeckAccessory = "",
    Pants = 0,
    ProportionScale = 1,
    RightArm = 0,
    RightArmColor = Color3.fromRGB(163, 162, 165),
    RightLeg = 0,
    RightLegColor = Color3.fromRGB(163, 162, 165),
    RunAnimation = 0,
    Shirt = 0,
    ShouldersAccessory = "",
    SwimAnimation = 0,
    Torso = 0,
    TorsoColor = Color3.fromRGB(163, 162, 165),
    UpperTorso = 0,
    WaistAccessory = "",
    WalkAnimation = 0,
    WidthScale = 1,
}

FallbackProperties["Camera"] = {
    CameraType = SafeEnum.CameraType.Custom,
    FieldOfView = 70,
    FieldOfViewMode = SafeEnum.FieldOfViewMode.Vertical,
    HeadLocked = true,
    MaxZoom = 400,
    MinZoom = 0,
}

FallbackProperties["TextChatService"] = {
    ChatTranslationEnabled = false,
    CreateDefaultCommands = true,
    CreateDefaultTextChannels = true,
}

FallbackProperties["TextChannel"] = { WelcomeMessage = "" }
FallbackProperties["TextChatCommand"] = { Enabled = true, PrimaryAlias = "", SecondaryAlias = "" }

FallbackProperties["ChatWindowConfiguration"] = {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.6,
    Enabled = true,
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
    HorizontalAlignment = SafeEnum.HorizontalAlignment.Left,
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    TextStrokeColor3 = Color3.new(),
    TextStrokeTransparency = 0.75,
    VerticalAlignment = SafeEnum.VerticalAlignment.Bottom,
}

FallbackProperties["BubbleChatConfiguration"] = {
    BackgroundColor3 = Color3.fromRGB(250, 250, 250),
    BackgroundTransparency = 0.1,
    BubbleDuration = 30,
    BubblesToShow = 2,
    CornerRadius = UDim.new(0, 12),
    Enabled = true,
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
    LocalPlayerStudsOffset = Vector3.new(0, 6, 0),
    MaxDistance = 100,
    MinimizeDistance = 40,
    NormLength = 200,
    Padding = 8,
    TailVisible = true,
    TextColor3 = Color3.new(),
    TextSize = 16,
    TextStrokeColor3 = Color3.new(1, 1, 1),
    TextStrokeTransparency = 1,
    VerticalStudsOffset = 0,
}

local GuiObjectBase = {
    Active = false,
    AnchorPoint = Vector2.new(),
    AutomaticSize = SafeEnum.AutomaticSize.None,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0,
    BorderColor3 = Color3.new(0, 0, 0),
    BorderMode = SafeEnum.BorderMode.Outline,
    BorderSizePixel = 1,
    ClipsDescendants = false,
    LayoutOrder = 0,
    NextSelectionDown = nil,
    NextSelectionLeft = nil,
    NextSelectionRight = nil,
    NextSelectionUp = nil,
    Position = UDim2.new(),
    Rotation = 0,
    Selectable = false,
    SelectionImageObject = nil,
    SelectionOrder = 0,
    Size = UDim2.fromOffset(100, 100),
    SizeConstraint = SafeEnum.SizeConstraint.RelativeXY,
    Visible = true,
    ZIndex = 1,
}

local TextBase = {
    FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json"),
    LineHeight = 1,
    MaxVisibleGraphemes = -1,
    RichText = false,
    Text = "",
    TextColor3 = Color3.new(0, 0, 0),
    TextScaled = false,
    TextSize = 14,
    TextStrokeColor3 = Color3.new(),
    TextStrokeTransparency = 1,
    TextTransparency = 0,
    TextTruncate = SafeEnum.TextTruncate.None,
    TextWrapped = false,
    TextXAlignment = SafeEnum.TextXAlignment.Center,
    TextYAlignment = SafeEnum.TextYAlignment.Center,
}

FallbackProperties["ScreenGui"] = {
    ClipToDeviceSafeArea = false,
    DisplayOrder = 0,
    Enabled = true,
    IgnoreGuiInset = false,
    OnTopOfCoreBlur = false,
    ResetOnSpawn = true,
    ScreenInsets = SafeEnum.ScreenInsets.DeviceSafeInsets,
    ZIndexBehavior = SafeEnum.ZIndexBehavior.Sibling,
}

FallbackProperties["BillboardGui"] = {
    Active = false,
    AlwaysOnTop = false,
    Brightness = 1,
    ClipsDescendants = false,
    Enabled = true,
    ExtentsOffset = Vector2.new(),
    ExtentsOffsetWorldSpace = Vector3.new(),
    LightInfluence = 1,
    MaxDistance = 0,
    Size = UDim2.fromOffset(200, 50),
    SizeOffset = Vector2.new(),
    StudsOffset = Vector3.new(),
    StudsOffsetWorldSpace = Vector3.new(),
    ZIndexBehavior = SafeEnum.ZIndexBehavior.Sibling,
}

FallbackProperties["SurfaceGui"] = {
    Active = false,
    AlwaysOnTop = false,
    Brightness = 1,
    CanvasSize = Vector2.new(800, 600),
    ClipsDescendants = false,
    Enabled = true,
    Face = SafeEnum.NormalId.Front,
    LightInfluence = 1,
    PixelsPerStud = 20,
    SizingMode = SafeEnum.SurfaceGuiSizingMode.FixedSize,
    ZIndexBehavior = SafeEnum.ZIndexBehavior.Sibling,
}

FallbackProperties["Frame"] = { BackgroundTransparency = 0, Size = UDim2.fromOffset(100, 100) }
FallbackProperties["TextLabel"] = { BackgroundTransparency = 1, Size = UDim2.fromOffset(200, 50), Text = "Label" }
FallbackProperties["TextButton"] = { AutoButtonColor = true, Modal = false, Selected = false, Size = UDim2.fromOffset(200, 50), Style = SafeEnum.ButtonStyle.Custom, Text = "Button" }
FallbackProperties["TextBox"] = { ClearTextOnFocus = true, MultiLine = false, PlaceholderColor3 = Color3.new(0.75, 0.75, 0.75), PlaceholderText = "", ShowNativeInput = true, Text = "", TextEditable = true, TextXAlignment = SafeEnum.TextXAlignment.Left }

FallbackProperties["ImageLabel"] = {
    BackgroundTransparency = 1,
    Image = "",
    ImageColor3 = Color3.new(1, 1, 1),
    ImageRectOffset = Vector2.new(),
    ImageRectSize = Vector2.new(),
    ImageTransparency = 0,
    ResampleMode = SafeEnum.ResamplerMode.Default,
    ScaleType = SafeEnum.ScaleType.Stretch,
    SliceCenter = Rect.new(0, 0, 0, 0),
    SliceScale = 1,
    TileSize = UDim2.fromOffset(100, 100),
}

FallbackProperties["ImageButton"] = {
    AutoButtonColor = true,
    HoverImage = "",
    Image = "",
    ImageColor3 = Color3.new(1, 1, 1),
    ImageRectOffset = Vector2.new(),
    ImageRectSize = Vector2.new(),
    ImageTransparency = 0,
    Modal = false,
    PressedImage = "",
    ResampleMode = SafeEnum.ResamplerMode.Default,
    ScaleType = SafeEnum.ScaleType.Stretch,
    Selected = false,
    SliceCenter = Rect.new(0, 0, 0, 0),
    SliceScale = 1,
    Style = SafeEnum.ButtonStyle.Custom,
    TileSize = UDim2.fromOffset(100, 100),
}

FallbackProperties["ScrollingFrame"] = {
    AutomaticCanvasSize = SafeEnum.AutomaticSize.None,
    BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
    CanvasPosition = Vector2.new(),
    CanvasSize = UDim2.new(0, 0, 1, 0),
    ClipsDescendants = true,
    ElasticBehavior = SafeEnum.ElasticBehavior.WhenScrollable,
    HorizontalScrollBarInset = SafeEnum.ScrollBarInset.None,
    MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    ScrollBarImageColor3 = Color3.new(0, 0, 0),
    ScrollBarImageTransparency = 0,
    ScrollBarThickness = 12,
    ScrollingDirection = SafeEnum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
    VerticalScrollBarInset = SafeEnum.ScrollBarInset.None,
    VerticalScrollBarPosition = SafeEnum.VerticalScrollBarPosition.Right,
}

FallbackProperties["VideoFrame"] = { Looped = false, Playing = false, TimePosition = 0, Video = "", Volume = 0.5 }
FallbackProperties["ViewportFrame"] = { Ambient = Color3.new(1, 1, 1), CurrentCamera = nil, ImageColor3 = Color3.new(1, 1, 1), ImageTransparency = 0, LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(0, -1, -1) }
FallbackProperties["CanvasGroup"] = { GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 0 }
FallbackProperties["UICorner"] = { CornerRadius = UDim.new(0, 0) }
FallbackProperties["UIStroke"] = { ApplyStrokeMode = SafeEnum.ApplyStrokeMode.Border, Color = Color3.new(), Enabled = true, LineJoinMode = SafeEnum.LineJoinMode.Round, Thickness = 1, Transparency = 0 }
FallbackProperties["UIPadding"] = { PaddingBottom = UDim.new(), PaddingLeft = UDim.new(), PaddingRight = UDim.new(), PaddingTop = UDim.new() }

FallbackProperties["UIListLayout"] = {
    FillDirection = SafeEnum.FillDirection.Vertical,
    HorizontalAlignment = SafeEnum.HorizontalAlignment.Left,
    HorizontalFlex = SafeEnum.UIFlexAlignment.None,
    ItemLineAlignment = SafeEnum.ItemLineAlignment.Automatic,
    Padding = UDim.new(),
    SortOrder = SafeEnum.SortOrder.LayoutOrder,
    VerticalAlignment = SafeEnum.VerticalAlignment.Top,
    VerticalFlex = SafeEnum.UIFlexAlignment.None,
    Wraps = false,
}

FallbackProperties["UIGridLayout"] = {
    CellPaddingX = UDim.new(0, 5),
    CellPaddingY = UDim.new(0, 5),
    CellSize = UDim2.fromOffset(100, 100),
    FillDirection = SafeEnum.FillDirection.Horizontal,
    FillDirectionMaxCells = 0,
    HorizontalAlignment = SafeEnum.HorizontalAlignment.Left,
    SortOrder = SafeEnum.SortOrder.LayoutOrder,
    StartCorner = SafeEnum.StartCorner.TopLeft,
    VerticalAlignment = SafeEnum.VerticalAlignment.Top,
}

FallbackProperties["UITableLayout"] = {
    FillDirection = SafeEnum.FillDirection.Vertical,
    FillEmptySpaceColumns = false,
    FillEmptySpaceRows = false,
    MajorAxis = SafeEnum.TableMajorAxis.RowMajor,
    Padding = UDim2.new(),
    SortOrder = SafeEnum.SortOrder.LayoutOrder,
}

FallbackProperties["UIPageLayout"] = {
    Animated = true,
    Circular = false,
    EasingDirection = SafeEnum.EasingDirection.Out,
    EasingStyle = SafeEnum.EasingStyle.Quad,
    FillDirection = SafeEnum.FillDirection.Horizontal,
    GamepadInputEnabled = true,
    Padding = UDim.new(),
    ScrollWheelInputEnabled = true,
    SortOrder = SafeEnum.SortOrder.LayoutOrder,
    TweenTime = 0.5,
    TouchInputEnabled = true,
}

FallbackProperties["UISizeConstraint"] = { MaxSize = Vector2.new(math.huge, math.huge), MinSize = Vector2.new() }
FallbackProperties["UITextSizeConstraint"] = { MaxTextSize = 100, MinTextSize = 1 }
FallbackProperties["UIAspectRatioConstraint"] = { AspectRatio = 1, AspectType = SafeEnum.AspectType.FitWithinMaxSize, DominantAxis = SafeEnum.DominantAxis.Width }
FallbackProperties["UIFlexItem"] = { FlexMode = SafeEnum.UIFlexMode.None, GrowRatio = 0, ItemLineAlignment = SafeEnum.ItemLineAlignment.Automatic, ShrinkRatio = 0 }
FallbackProperties["UIGradient"] = { Color = ColorSequence.new(Color3.new(1, 1, 1)), Enabled = true, Offset = Vector2.new(), Rotation = 0, Transparency = NumberSequence.new(0) }
FallbackProperties["UIScale"] = { Scale = 1 }

FallbackProperties["SelectionBox"] = { Adornee = nil, Color3 = Color3.new(0, 0, 1), LineThickness = 0.1, SurfaceColor3 = Color3.new(0, 0, 1), SurfaceTransparency = 0.5, Visible = true }
FallbackProperties["SelectionSphere"] = { Adornee = nil, Color3 = Color3.new(0, 0, 1), SurfaceColor3 = Color3.new(0, 0, 1), SurfaceTransparency = 0.5, Visible = true }

FallbackProperties["BoxHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Size = Vector3.new(1, 1, 1), SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["SphereHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ConeHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Height = 1, Radius = 0.25, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["CylinderHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Height = 1, InnerRadius = 0, Radius = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["LineHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Length = 1, Thickness = 1, Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ImageHandleAdornment"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(1, 1, 1), Image = "", RelativeSize = 0, SizeRelativeOffset = Vector3.new(), Transparency = 0, Visible = true, ZIndex = 0 }
FallbackProperties["ArcHandles"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(0, 0, 1), Visible = true, ZIndex = 0 }
FallbackProperties["Handles"] = { Adornee = nil, AlwaysOnTop = false, Color3 = Color3.new(0, 0, 1), Faces = Faces.new(), Style = SafeEnum.HandlesStyle.Resize, Visible = true, ZIndex = 0 }

FallbackProperties["SelectionPartLasso"] = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Part = nil }
FallbackProperties["SelectionPointLasso"] = { Color = BrickColor.new("Bright blue"), Humanoid = nil, Point = Vector3.new() }

FallbackProperties["Highlight"] = {
    Adornee = nil,
    DepthMode = SafeEnum.HighlightDepthMode.AlwaysOnTop,
    Enabled = true,
    FillColor = Color3.new(1, 1, 1),
    FillTransparency = 0.5,
    OutlineColor = Color3.new(1, 1, 1),
    OutlineTransparency = 0,
}

FallbackProperties["RemoteEvent"] = {}
FallbackProperties["RemoteFunction"] = {}
FallbackProperties["BindableEvent"] = {}
FallbackProperties["BindableFunction"] = {}
FallbackProperties["Configuration"] = {}

FallbackProperties["MaterialService"] = { Use2022Materials = true }

FallbackProperties["MaterialVariant"] = {
    BaseMaterial = SafeEnum.Material.SmoothPlastic,
    ColorMap = "",
    MetalnessMap = "",
    NormalMap = "",
    RoughnessMap = "",
}

FallbackProperties["Terrain"] = {
    Decoration = true,
    DrawParentAndChildren = false,
    MaterialColors = "MaterialColorPalette",
    WaterColor = Color3.fromRGB(12, 84, 90),
    WaterReflectance = 0,
    WaterTransparency = 0.3,
    WaterWaveSize = 5,
    WaterWaveSpeed = 10,
}

FallbackProperties["TerrainRegion"] = {}
FallbackProperties["StarterGui"] = { AutoResetLocalPlayerCamera = true, ShowTalkativeMessages = true }

FallbackProperties["StarterPlayer"] = {
    AutoJumpEnabled = false,
    CameraMaxZoomDistance = 400,
    CameraMinZoomDistance = 0.5,
    CharacterJumpHeight = 7.2,
    CharacterJumpPower = 50,
    CharacterUseJumpPower = false,
    CharacterWalkSpeed = 16,
    DevCameraOcclusionMode = SafeEnum.DevCameraOcclusionMode.Zoom,
    DevTouchCameraMovementMode = SafeEnum.DevTouchCameraMovementMode.Watch,
    EnableMouseLockOption = false,
    MouseIconEnabled = true,
}

FallbackProperties["StarterPlayerScripts"] = {}
FallbackProperties["LocalizationService"] = { CoreScriptLocalizationsEnabled = true }
FallbackProperties["Chat"] = { BubbleChatEnabled = false, TypingIndicator = false }

local GuiObjectClasses = { "Frame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "ScrollingFrame", "VideoFrame", "ViewportFrame", "CanvasGroup" }
local TextClasses = { "TextLabel", "TextButton", "TextBox" }

for _, Class in ipairs(GuiObjectClasses) do
    local T = FallbackProperties[Class] or {}
    for K, V in pairs(GuiObjectBase) do
        if T[K] == nil then T[K] = V end
    end
    FallbackProperties[Class] = T
end

for _, Class in ipairs(TextClasses) do
    local T = FallbackProperties[Class]
    for K, V in pairs(TextBase) do
        if T[K] == nil then T[K] = V end
    end
end

local Inheritance = {
    Part = {"BasePart", "Instance"}, WedgePart = {"BasePart", "Instance"},
    CornerWedgePart = {"BasePart", "Instance"}, TrussPart = {"BasePart", "Instance"},
    SpawnLocation = {"BasePart", "Instance"}, Platform = {"BasePart", "Instance"},
    Seat = {"BasePart", "Instance"}, VehicleSeat = {"BasePart", "Instance"},
    MeshPart = {"BasePart", "Instance"}, UnionOperation = {"BasePart", "Instance"},
    PartOperation = {"BasePart", "Instance"}, NegateOperation = {"BasePart", "Instance"},
    IntersectOperation = {"BasePart", "Instance"}, FormFactorPart = {"BasePart", "Instance"},
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
    Attachment = {"Instance"}, Bone = {"Attachment", "Instance"},
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
    ManualWeld = {"Instance"}, ManualGlue = {"Instance"}, Motor = {"Instance"}, Glue = {"Instance"},
    RigidConstraint = {"Instance"}, SliderConstraint = {"Instance"},
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
    CylinderHandleAdornment = {"Instance"}, LineHandleAdornment = {"Instance"},
    ImageHandleAdornment = {"Instance"}, ArcHandles = {"Instance"},
    Handles = {"Instance"}, SelectionPartLasso = {"Instance"},
    SelectionPointLasso = {"Instance"}, Highlight = {"Instance"},
    RemoteEvent = {"Instance"}, RemoteFunction = {"Instance"},
    BindableEvent = {"Instance"}, BindableFunction = {"Instance"},
    Dialog = {"Instance"}, DialogChoice = {"Instance"},
    TextChatService = {"Instance"}, TextChannel = {"Instance"},
    TextChatCommand = {"Instance"},
    ChatWindowConfiguration = {"Instance"}, BubbleChatConfiguration = {"Instance"},
    StarterGui = {"Instance"}, StarterPlayer = {"Instance"},
    StarterPlayerScripts = {"Instance"}, LocalizationService = {"Instance"},
    Chat = {"Instance"},
}

local ExactPropertyHints = {
    Instance = { "Name" },
    BasePart = {
        "Anchored", "BackSurface", "BottomSurface", "CFrame", "CanCollide", "CanQuery", "CanTouch",
        "CastShadow", "CollisionGroup", "Color", "CustomPhysicalProperties",
        "EnableFluidForces", "FrontSurface", "LeftSurface", "Locked", "Massless", "Material", "MaterialVariant",
        "Orientation", "PivotOffset", "Position", "Reflectance", "RightSurface",
        "RootPriority", "Rotation", "Size", "TopSurface", "Transparency",
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

local function Num(N)
    if N ~= N then return "0/0" end
    if N == math.huge then return "math.huge" end
    if N == -math.huge then return "-math.huge" end
    if math.floor(N) == N and math.abs(N) < 1e15 then return tostring(N) end
    return string.format("%.8g", N)
end

local function GetPath(I, Refs)
    if not I then return "nil" end
    if Refs[I] then return string.format("o[%d]", Refs[I]) end
    local P = {}
    local C = I
    while C and C ~= game do
        local N = C.Name
        if N:match("^[%a_][%w_]*$") then
            table.insert(P, 1, "."..N)
        else
            table.insert(P, 1, string.format("[%q]", N))
        end
        C = C.Parent
    end
    if #P == 0 then return "nil" end
    return "game" .. table.concat(P)
end

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
        local Ok, Res = pcall(function() return tostring(V) end)
        if Ok then
            return string.format("(select(2, pcall(function() return %s end)) or nil)", Res)
        end
        return "nil"
    end
    if T == "NumberRange" then return (V.Min == V.Max) and string.format("NumberRange.new(%s)", Num(V.Min)) or string.format("NumberRange.new(%s,%s)", Num(V.Min), Num(V.Max)) end
    if T == "PhysicalProperties" then return string.format("PhysicalProperties.new(%s,%s,%s,%s,%s)", Num(V.Density), Num(V.Friction), Num(V.Elasticity), Num(V.FrictionWeight), Num(V.ElasticityWeight)) end
    if T == "NumberSequence" then
        local K = V.Keypoints
        if #K==2 and K[1].Time==0 and K[2].Time==1 and K[1].Value==K[2].Value and K[1].Envelope==0 and K[2].Envelope==0 then return string.format("NumberSequence.new(%s)", Num(K[1].Value)) end
        local P = {}
        for _, Kp in ipairs(K) do P[#P+1] = string.format("NumberSequenceKeypoint.new(%s,%s%s)", Num(Kp.Time), Num(Kp.Value), Kp.Envelope ~= 0 and (","..Num(Kp.Envelope)) or "") end
        return "NumberSequence.new({"..table.concat(P, ",").."})"
    end
    if T == "ColorSequence" then
        local K = V.Keypoints
        if #K==2 and K[1].Time==0 and K[2].Time==1 and K[1].Value==K[2].Value then return string.format("ColorSequence.new(%s)", Ser(K[1].Value)) end
        local P = {}
        for _, Kp in ipairs(K) do P[#P+1] = string.format("ColorSequenceKeypoint.new(%s,%s)", Num(Kp.Time), Ser(Kp.Value)) end
        return "ColorSequence.new({"..table.concat(P, ",").."})"
    end
    if T == "Rect" then return string.format("Rect.new(%s,%s,%s,%s)", Num(V.Min.X), Num(V.Min.Y), Num(V.Max.X), Num(V.Max.Y)) end
    if T == "Font" then return string.format('Font.new("%s",Enum.FontWeight.%s,Enum.FontStyle.%s)', V.Family, V.Weight.Name, V.Style.Name) end
    if T == "Ray" then return string.format("Ray.new(%s,%s)", Ser(V.Origin), Ser(V.Direction)) end
    if T == "TweenInfo" then return string.format("TweenInfo.new(%s,%s,%s,%s,%s,%s)", Num(V.Time), tostring(V.EasingStyle), tostring(V.EasingDirection), Num(V.RepeatCount), tostring(V.Reverses), Num(V.DelayTime)) end
    if T == "DateTime" then return string.format("DateTime.fromUnixTimestamp(%d)", V.UnixTimestamp) end
    if T == "Axes" then
        local P = {}
        if V.X then P[#P+1] = "Enum.Axis.X" end if V.Y then P[#P+1] = "Enum.Axis.Y" end if V.Z then P[#P+1] = "Enum.Axis.Z" end
        return "Axes.new("..table.concat(P, ",")..")"
    end
    if T == "Faces" then
        local P = {}
        if V.Top then P[#P+1] = "Enum.NormalId.Top" end if V.Bottom then P[#P+1] = "Enum.NormalId.Bottom" end
        if V.Left then P[#P+1] = "Enum.NormalId.Left" end if V.Right then P[#P+1] = "Enum.NormalId.Right" end
        if V.Front then P[#P+1] = "Enum.NormalId.Front" end if V.Back then P[#P+1] = "Enum.NormalId.Back" end
        return "Faces.new("..table.concat(P, ",")..")"
    end
    if T == "OverlapParams" then return string.format("(function()local p=OverlapParams.new()p.FilterType=%s p.MaxParts=%d p.RespectCanCollide=%s return p end)()", tostring(V.FilterType), V.MaxParts, tostring(V.RespectCanCollide)) end
    if T == "RaycastParams" then return string.format("(function()local p=RaycastParams.new()p.FilterType=%s p.IgnoreWater=%s p.RespectCanCollide=%s return p end)()", tostring(V.FilterType), tostring(V.IgnoreWater), tostring(V.RespectCanCollide)) end
    return nil
end

local function _Get(I, P) return I[P] end
local function _New(C) return Instance.new(C) end
local function _IsA(I, C) return I:IsA(C) end
local function _Attrs(I) return I:GetAttributes() end
local function _Tags(I) return CollectionService:GetTags(I) end
local function _IsService(I)
    local Ok, Res = pcall(function() return I:IsA("Service") end)
    return Ok and Res
end

local function UploadScript(Src)
    local Ok, Res = pcall(function()
        return request({
            Url = "https://api-c15.pages.dev/api/v2/",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ content = Src, expiry_days = 30 })
        })
    end)
    if Ok and Res and Res.Body then
        local OkD, Data = pcall(function() return HttpService:JSONDecode(Res.Body) end)
        if OkD and Data and Data.url then
            task.wait(0.1)
            return Data.url
        end
    end
    return nil
end

local function GetSrc(Inst)
    if not pcall(_IsA, Inst, "LuaSourceContainer") then return nil, false end
    local Src = ""
    if decompile then
        local Ok, Res = pcall(decompile, Inst)
        if Ok and type(Res) == "string" then Src = Res end
    end
    if #Src == 0 then
        local Ok, Res = pcall(_Get, Inst, "Source")
        if Ok and type(Res) == "string" then Src = Res end
    end
    if #Src > 0 then
        local Url = UploadScript(Src)
        if Url then
            return Url, true
        end
    end
    return Src, false
end

local function ResolveFallbackProps(Inst)
    local Merged = {}
    local Class = Inst.ClassName
    local Own = FallbackProperties[Class]
    if Own then
        for K, V in pairs(Own) do Merged[K] = V end
    end
    for _, Parent in ipairs(Inheritance[Class] or {"Instance"}) do
        local P = FallbackProperties[Parent]
        if P then
            for K, V in pairs(P) do
                if Merged[K] == nil then Merged[K] = V end
            end
        end
    end
    if Merged.Name == nil or Merged.Name == "Instance" then Merged.Name = Class end
    return Merged
end

local function AddHintProps(Dest, Inst)
    for ClassName, PropList in pairs(ExactPropertyHints) do
        local Include = false
        if ClassName == "Instance" then
            Include = true
        else
            local Ok, Result = pcall(_IsA, Inst, ClassName)
            Include = Ok and Result or false
        end
        if Include then
            for _, PropName in ipairs(PropList) do Dest[PropName] = true end
        end
    end
end

local function MergePropertyDump(Dest, Raw)
    if type(Raw) ~= "table" then return end
    for K, V in pairs(Raw) do
        if type(K) == "string" then
            Dest[K] = true
        elseif type(V) == "string" then
            Dest[V] = true
        elseif type(V) == "table" then
            local Name = rawget(V, "Name") or rawget(V, "name") or rawget(V, "Property") or rawget(V, "property")
            if type(Name) == "string" then Dest[Name] = true end
        end
    end
end

local PropCache = {}
local function GetProps(Inst)
    local C = Inst.ClassName
    if PropCache[C] then return PropCache[C] end
    local P = {}
    if listproperties then
        local Ok, Res = pcall(listproperties, Inst)
        if Ok and type(Res) == "table" then MergePropertyDump(P, Res) end
    end
    if gethiddenproperties then
        local Ok, Res = pcall(gethiddenproperties, Inst)
        if Ok and type(Res) == "table" then MergePropertyDump(P, Res) end
    end
    if pcall(_IsA, Inst, "LuaSourceContainer") then P["Source"] = true end
    for K in pairs(ResolveFallbackProps(Inst)) do P[K] = true end
    AddHintProps(P, Inst)
    for K in pairs(P) do
        if SkipProperties[K] then
            P[K] = nil
        elseif not pcall(_Get, Inst, K) then
            P[K] = nil
        end
    end
    PropCache[C] = P
    return P
end

local function Build(Target)
    local Instances = {Target}
    for _, D in ipairs(Target:GetDescendants()) do
        Instances[#Instances+1] = D
    end
    local Refs = {}
    for Idx, Inst in ipairs(Instances) do
        Refs[Inst] = Idx
    end

    local Out = {}
    local function P(...)
        Out[#Out+1] = string.format(...)
    end

    P("local o={}")
    P("local _s=function(i,p,v) i[p]=v end")
    P("local S=function(i,p,v) local Ok,Err=pcall(function() i[p]=v end) if not Ok and sethiddenproperty then pcall(function() sethiddenproperty(i,p,v) end) end end")
    P("local A=function(i,a,v) pcall(function() i:SetAttribute(a,v) end) end")
    P("local CS=game:GetService('CollectionService')")
    P("local T=function(i,t) pcall(function() CS:AddTag(i,t) end) end")
    P("local _p=function(i,v) pcall(function() i.Parent=v end) end")

    local InstOK = {}
    local IsDummy = {}

    for Idx, Inst in ipairs(Instances) do
        local Ok = pcall(_New, Inst.ClassName)
        if _IsService(Inst) then Ok = false end
        
        if Ok then
            InstOK[Idx] = true
            P("o[%d]=Instance.new(%q)", Idx, Inst.ClassName)
        else
            InstOK[Idx] = true
            IsDummy[Idx] = true
            P("o[%d]=Instance.new('Folder')", Idx)
        end
    end

    local Deferred = {}

    for Idx, Inst in ipairs(Instances) do
        if InstOK[Idx] and not IsDummy[Idx] then
            local Props = GetProps(Inst)
            
            -- CRITICAL 1:1 VFX FIX: If CFrame is present, do not serialize Position/Orientation/Rotation
            -- because setting Position after CFrame wipes the rotation!
            if Props.CFrame then
                Props.Position = nil
                Props.Orientation = nil
                Props.Rotation = nil
            end

            local Pnames = {}
            for N in pairs(Props) do Pnames[#Pnames+1] = N end
            table.sort(Pnames)
            for _, PropName in ipairs(Pnames) do
                local Ok, Val = pcall(_Get, Inst, PropName)
                if Ok then
                    local T = typeof(Val)
                    if T == "Instance" then
                        Deferred[#Deferred+1] = string.format("S(o[%d],%q,%s)", Idx, PropName, GetPath(Val, Refs))
                    elseif T == "function" then
                    elseif PropName == "Source" then
                        local Src, IsUrl = GetSrc(Inst)
                        if Src and #Src > 0 then
                            if IsUrl then
                                Deferred[#Deferred+1] = string.format(
                                    "pcall(function() local C=game:HttpGet(%q) S(o[%d],'Source',C) if o[%d]:IsA('Script') and not o[%d].Disabled then task.spawn(function() loadstring(C, \"\")() end) end end)",
                                    Src, Idx, Idx, Idx
                                )
                            else
                                Deferred[#Deferred+1] = string.format("S(o[%d],'Source',%q)", Idx, Src)
                            end
                        end
                    else
                        local S = Ser(Val, Refs)
                        if S then
                            P("S(o[%d],%q,%s)", Idx, PropName, S)
                        end
                    end
                end
            end

            local Ok, Attrs = pcall(_Attrs, Inst)
            if Ok then
                local S = {}
                for K, V in pairs(Attrs) do S[#S+1] = {K, V} end
                table.sort(S, function(A, B) return A[1] < B[1] end)
                for _, A in ipairs(S) do
                    local Str = Ser(A[2], Refs)
                    if Str then
                        P("A(o[%d],%q,%s)", Idx, A[1], Str)
                    end
                end
            end

            local Ok, Tags = pcall(_Tags, Inst)
            if Ok then
                table.sort(Tags)
                for _, T in ipairs(Tags) do
                    P("T(o[%d],%q)", Idx, T)
                end
            end
        elseif IsDummy[Idx] then
            P("S(o[%d],'Name',%q)", Idx, Inst.Name)
        end
    end

    for _, D in ipairs(Deferred) do P(D) end

    for Idx, Inst in ipairs(Instances) do
        local P = Inst.Parent
        if P then
            local Path = GetPath(P, Refs)
            if Path ~= "nil" then
                P("pcall(_p,o[%d],%s)", Idx, Path)
            end
        end
    end

    P("return o[1]")
    return table.concat(Out, "\n")
end

local API = {}
API.Path = nil
function API:Build()
    local T = self.Path
    if type(T) == "string" then
        local LoadFunc = loadstring or load
        if not LoadFunc then error("loadstring not available") end
        local Ok, Inst = pcall(function()
            local fn = LoadFunc("return " .. T, "")
            if fn then return fn() end
            return nil
        end)
        if Ok and typeof(Inst) == "Instance" then
            return Build(Inst)
        end
        error("Invalid Path string: " .. T)
    end
    return Build(T)
end
function API:Save(Name)
    local Out = self:Build()
    local N = Name or ("hiklo_" .. tostring(self.Path.Name):gsub("[^%w]", "_") .. ".lua")
    if writefile then writefile(N, Out) end
    if setclipboard then setclipboard(Out) end
    if not writefile and not setclipboard then print(Out) end
    return Out
end

return API
