local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
}

local FallbackProperties = {}

FallbackProperties["Instance"] = {
    Name = "Instance",
    Archivable = true,
}

FallbackProperties["BasePart"] = {
    Anchored = false,
    BackSurface = Enum.SurfaceType.Smooth,
    BackSurfaceInput = Enum.InputType.NoInput,
    BottomSurface = Enum.SurfaceType.Smooth,
    BottomSurfaceInput = Enum.InputType.NoInput,
    CFrame = CFrame.new(),
    CanCollide = true,
    CanQuery = true,
    CanTouch = true,
    CastShadow = true,
    CollisionGroup = "Default",
    Color = Color3.new(0.639216, 0.635294, 0.647059),
    CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.1, 0.1),
    EnableFluidForces = true,
    FrontSurface = Enum.SurfaceType.Smooth,
    FrontSurfaceInput = Enum.InputType.NoInput,
    LeftSurface = Enum.SurfaceType.Smooth,
    LeftSurfaceInput = Enum.InputType.NoInput,
    Locked = false,
    Massless = false,
    Material = Enum.Material.SmoothPlastic,
    MaterialVariant = "",
    Orientation = Vector3.new(),
    PivotOffset = CFrame.new(),
    Position = Vector3.new(),
    Reflectance = 0,
    RightSurface = Enum.SurfaceType.Smooth,
    RightSurfaceInput = Enum.InputType.NoInput,
    RootPriority = 0,
    Rotation = Vector3.new(),
    Size = Vector3.new(4, 1, 2),
    TopSurface = Enum.SurfaceType.Smooth,
    TopSurfaceInput = Enum.InputType.NoInput,
    Transparency = 0,
}

FallbackProperties["FormFactorPart"] = {
    FormFactor = Enum.FormFactor.Custom,
}

FallbackProperties["Part"] = {
    Shape = Enum.PartType.Block,
}

FallbackProperties["WedgePart"] = {
}

FallbackProperties["CornerWedgePart"] = {
}

FallbackProperties["TrussPart"] = {
    Style = Enum.TrussStyle.Alternating,
}

FallbackProperties["SpawnLocation"] = {
    AllowTeamChangeOnTouch = false,
    Duration = 10,
    Enabled = true,
    Neutral = true,
    TeamColor = BrickColor.new("White"),
    Shape = Enum.PartType.Block,
}

FallbackProperties["Platform"] = {
}

FallbackProperties["Seat"] = {
    Disabled = false,
    Occupant = nil,
}

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
    CollisionFidelity = Enum.CollisionFidelity.Default,
    DoubleSided = false,
    MeshId = "",
    MeshSize = Vector3.new(1, 1, 1),
    RenderFidelity = Enum.RenderFidelity.Automatic,
    TextureID = "",
}

FallbackProperties["PartOperation"] = {
    CollisionFidelity = Enum.CollisionFidelity.Default,
    RenderFidelity = Enum.RenderFidelity.Automatic,
    SmoothingAngle = 30,
    UsePartColor = false,
}

FallbackProperties["UnionOperation"] = FallbackProperties["PartOperation"]
FallbackProperties["NegateOperation"] = FallbackProperties["PartOperation"]
FallbackProperties["IntersectOperation"] = FallbackProperties["PartOperation"]

FallbackProperties["SpecialMesh"] = {
    MeshId = "",
    MeshType = Enum.MeshType.Head,
    Offset = Vector3.new(),
    RotationOffset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
    TextureId = "",
    VertexColor = Vector3.new(1, 1, 1),
}

FallbackProperties["CylinderMesh"] = {
    Offset = Vector3.new(),
    RotationOffset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
}

FallbackProperties["BlockMesh"] = {
    Offset = Vector3.new(),
    RotationOffset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
}

FallbackProperties["FileMesh"] = {
    MeshId = "",
    Offset = Vector3.new(),
    Scale = Vector3.new(1, 1, 1),
    TextureId = "",
    VertexColor = Vector3.new(1, 1, 1),
}

FallbackProperties["Decal"] = {
    Color3 = Color3.new(1, 1, 1),
    Face = Enum.NormalId.Front,
    Shiny = 0,
    Specular = 0,
    Texture = "",
    Transparency = 0,
    ZIndex = 0,
}

FallbackProperties["Texture"] = {
    Color3 = Color3.new(1, 1, 1),
    Face = Enum.NormalId.Front,
    OffsetStudsU = 0,
    OffsetStudsV = 0,
    Shiny = 0,
    Specular = 0,
    StudsPerTileU = 2,
    StudsPerTileV = 2,
    Texture = "",
    Transparency = 0,
    ZIndex = 0,
}

FallbackProperties["SurfaceAppearance"] = {
    AlphaMode = Enum.AlphaMode.Overlay,
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
    LevelOfDetail = Enum.ModelLevelOfDetail.Disabled,
    ModelStreamingMode = Enum.ModelStreamingMode.Default,
    PrimaryPart = nil,
    WorldPivot = CFrame.new(),
}

FallbackProperties["Folder"] = {
}

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

FallbackProperties["Backpack"] = {
}

FallbackProperties["StarterPack"] = {
}

FallbackProperties["StarterGear"] = {
}

FallbackProperties["Hat"] = {
    AttachmentForward = Vector3.new(0, 0, -1),
    AttachmentPos = Vector3.new(),
    AttachmentRight = Vector3.new(1, 0, 0),
    AttachmentUp = Vector3.new(0, 1, 0),
}

FallbackProperties["Accessory"] = {
    AccessoryType = Enum.AccessoryType.Hat,
    AttachmentPoint = CFrame.new(),
}

FallbackProperties["Script"] = {
    Disabled = false,
    RunContext = Enum.RunContext.Legacy,
    Source = "",
}

FallbackProperties["LocalScript"] = {
    Disabled = false,
    Source = "",
}

FallbackProperties["ModuleScript"] = {
    Source = "",
}

FallbackProperties["StringValue"] = {
    Value = "",
}

FallbackProperties["NumberValue"] = {
    Value = 0,
}

FallbackProperties["BoolValue"] = {
    Value = false,
}

FallbackProperties["IntValue"] = {
    Value = 0,
}

FallbackProperties["Vector3Value"] = {
    Value = Vector3.new(),
}

FallbackProperties["CFrameValue"] = {
    Value = CFrame.new(),
}

FallbackProperties["ObjectValue"] = {
    Value = nil,
}

FallbackProperties["Color3Value"] = {
    Value = Color3.new(),
}

FallbackProperties["BrickColorValue"] = {
    Value = BrickColor.new("Medium stone grey"),
}

FallbackProperties["RayValue"] = {
    Value = Ray.new(Vector3.new(), Vector3.new()),
}

FallbackProperties["Animation"] = {
    AnimationId = "",
}

FallbackProperties["Animator"] = {
}

FallbackProperties["AnimationController"] = {
}

FallbackProperties["AnimationTrack"] = {
}

FallbackProperties["BodyColors"] = {
    HeadColor3 = Color3.fromRGB(163, 162, 165),
    LeftArmColor3 = Color3.fromRGB(163, 162, 165),
    LeftLegColor3 = Color3.fromRGB(163, 162, 165),
    RightArmColor3 = Color3.fromRGB(163, 162, 165),
    RightLegColor3 = Color3.fromRGB(163, 162, 165),
    TorsoColor3 = Color3.fromRGB(163, 162, 165),
}

FallbackProperties["CharacterMesh"] = {
    BaseTextureId = 0,
    BodyPart = Enum.BodyPart.Head,
    MeshId = 0,
    OverlayTextureId = 0,
}

FallbackProperties["Pants"] = {
    PantsTemplate = "",
}

FallbackProperties["Shirt"] = {
    ShirtTemplate = "",
}

FallbackProperties["ShirtGraphic"] = {
    Color3 = Color3.new(1, 1, 1),
    Graphic = "",
}

FallbackProperties["WrapLayer"] = {
    AutoSkin = Enum.WrapLayerAutoSkin.Disabled,
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
    Type = Enum.IKControlType.Transform,
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
    RollOffMode = Enum.RollOffMode.InverseTapered,
    SoundGroup = nil,
    SoundId = "",
    TimePosition = 0,
    Volume = 0.5,
}

FallbackProperties["SoundService"] = {
    AmbientReverb = Enum.ReverbType.NoReverb,
    DistanceFactor = 3.33,
    DopplerScale = 1,
    RespectFilteringEnabled = true,
    VolumetricAudio = Enum.VolumetricAudio.Disabled,
}

FallbackProperties["EqualizerSoundEffect"] = {
    HighGain = 0,
    LowGain = 0,
    MidGain = 0,
    Priority = 0,
}

FallbackProperties["ReverbSoundEffect"] = {
    DecayTime = 1.5,
    Density = 1,
    Diffusion = 1,
    DryLevel = -6,
    Priority = 0,
    WetLevel = 0,
}

FallbackProperties["ChorusSoundEffect"] = {
    Depth = 1,
    Mix = 50,
    Priority = 0,
    Rate = 0.45,
}

FallbackProperties["CompressorSoundEffect"] = {
    Attack = 0.003,
    GainMakeup = 0,
    Priority = 0,
    Release = 0.5,
    SideChain = nil,
    Threshold = -24,
}

FallbackProperties["DistortionSoundEffect"] = {
    Level = 0,
    Priority = 0,
}

FallbackProperties["EchoSoundEffect"] = {
    Delay = 1,
    DryLevel = 0,
    FeedBack = 0.5,
    Priority = 0,
    WetLevel = -6,
}

FallbackProperties["FlangeSoundEffect"] = {
    Depth = 45,
    Mix = 50,
    Priority = 0,
    Rate = 0.45,
}

FallbackProperties["PitchShiftSoundEffect"] = {
    Octave = 1,
    Priority = 0,
}

FallbackProperties["TremoloSoundEffect"] = {
    Depth = 1,
    Duty = 50,
    Frequency = 5,
    Priority = 0,
}

FallbackProperties["AudioPlayer"] = {
    AssetId = "",
    Looping = false,
    PlaybackRegionsEnabled = false,
    PlaybackSpeed = 1,
    TimePosition = 0,
    Volume = 1,
}

FallbackProperties["AudioEmitter"] = {
}

FallbackProperties["AudioListener"] = {
}

FallbackProperties["AudioAnalyzer"] = {
}

FallbackProperties["AudioChorus"] = {
    Bypass = false,
    Depth = 0.15,
    Mix = 0.5,
    Rate = 0.5,
}

FallbackProperties["AudioCompressor"] = {
    Attack = 0.05,
    Bypass = false,
    GainMakeup = 0,
    Ratio = 4,
    Release = 0.1,
    Threshold = -24,
}

FallbackProperties["AudioDistortion"] = {
    Bypass = false,
    Level = 0,
}

FallbackProperties["AudioEqualizer"] = {
    Bypass = false,
    HighGain = 0,
    LowGain = 0,
    MidGain = 0,
}

FallbackProperties["AudioFader"] = {
    Bypass = false,
    Volume = 1,
}

FallbackProperties["AudioFlanger"] = {
    Bypass = false,
    Depth = 45,
    Mix = 0.5,
    Rate = 0.5,
}

FallbackProperties["AudioPitchShifter"] = {
    Bypass = false,
    Octave = 1,
}

FallbackProperties["AudioReverb"] = {
    Bypass = false,
    DecayTime = 1.5,
    Density = 1,
    Diffusion = 1,
    DryLevel = 0,
    WetLevel = -6,
}

FallbackProperties["AudioTremolo"] = {
    Bypass = false,
    Depth = 1,
    Duty = 50,
    Frequency = 5,
}

FallbackProperties["AudioDeviceInput"] = {
    Active = false,
    Muted = false,
    Player = nil,
}

FallbackProperties["AudioDeviceOutput"] = {
    Muted = false,
    Player = nil,
}

FallbackProperties["Wire"] = {
}

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
    TextureMode = Enum.TextureMode.Stretch,
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
    TextureMode = Enum.TextureMode.Stretch,
    Transparency = NumberSequence.new(0),
    WidthScale = NumberSequence.new(1),
}

FallbackProperties["ParticleEmitter"] = {
    Acceleration = Vector3.new(),
    Brightness = 1,
    Color = ColorSequence.new(Color3.new(1, 1, 1)),
    Drag = 0,
    EmissionDirection = Enum.NormalId.Top,
    Enabled = true,
    FlipbookFramerate = NumberRange.new(30),
    FlipbookIncompatible = "",
    FlipbookLayout = Enum.ParticleFlipbookLayout.None,
    FlipbookMode = Enum.ParticleFlipbookMode.Loop,
    LifeTime = NumberRange.new(5, 10),
    LightEmission = 0,
    LightInfluence = 1,
    LockedToPart = false,
    Orientation = Enum.ParticleOrientation.FacingCamera,
    Rate = 20,
    RotSpeed = NumberRange.new(0),
    Rotation = NumberRange.new(0),
    ShapeInOut = Enum.ParticleEmitterShapeInOut.Out,
    ShapePartial = Enum.ParticleEmitterShapePartial.Full,
    ShapeRotation = 0,
    ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
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
    ActuatorType = Enum.ActuatorType.None,
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
    AngularActuatorType = Enum.ActuatorType.None,
    AngularLimitsEnabled = false,
    AngularResponsiveness = 20,
    AngularSpeed = 45,
    AngularVelocity = 0,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    InclinationAngle = 0,
    LinearActuatorType = Enum.ActuatorType.None,
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
    ActuatorType = Enum.ActuatorType.None,
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
    ForceLimitMode = Enum.ForceLimitMode.Magnitude,
    LineDirection = Vector3.new(0, 1, 0),
    LineVelocity = 0,
    MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
    MaxForce = math.huge,
    PlaneVelocity = Vector2.new(),
    PrimaryTangentAxis = Vector3.new(1, 0, 0),
    RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
    SecondaryTangentAxis = Vector3.new(0, 0, 1),
    VectorVelocity = Vector3.new(),
    VelocityConstraintMode = Enum.VelocityConstraintMode.Vector,
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
    RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
    Visible = false,
}

FallbackProperties["AlignPosition"] = {
    ApplyAtCenterOfMass = false,
    Attachment0 = nil,
    Attachment1 = nil,
    Color = BrickColor.new("Bright blue"),
    Enabled = true,
    ForceLimitMode = Enum.ForceLimitMode.Magnitude,
    MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
    MaxForce = math.huge,
    MaxVelocity = math.huge,
    Mode = Enum.PositionAlignmentMode.TwoAttachment,
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
    Mode = Enum.OrientationAlignmentMode.TwoAttachment,
    PrimaryAxis = Vector3.new(0, 1, 0),
    PrimaryAxisOnly = false,
    ReactionTorqueEnabled = false,
    Responsiveness = 200,
    RigidityEnabled = false,
    SecondaryAxis = Vector3.new(1, 0, 0),
    Visible = false,
}

FallbackProperties["WeldConstraint"] = {
    Enabled = true,
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Weld"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Motor6D"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    CurrentAngle = 0,
    DesiredAngle = 0,
    MaxVelocity = 0.1,
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Snap"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["ManualWeld"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["ManualGlue"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Motor"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    CurrentAngle = 0,
    DesiredAngle = 0,
    MaxVelocity = 0.1,
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["Glue"] = {
    C0 = CFrame.new(),
    C1 = CFrame.new(),
    Part0 = nil,
    Part1 = nil,
}

FallbackProperties["RigidConstraint"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Enabled = true,
    Visible = false,
}

FallbackProperties["SliderConstraint"] = {
    ActuatorType = Enum.ActuatorType.None,
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

FallbackProperties["BodyVelocity"] = {
    MaxForce = Vector3.new(4000, 4000, 4000),
    P = 10000,
    Velocity = Vector3.new(),
}

FallbackProperties["BodyPosition"] = {
    D = 500,
    MaxForce = Vector3.new(4000, 4000, 4000),
    P = 10000,
    Position = Vector3.new(),
}

FallbackProperties["BodyForce"] = {
    Force = Vector3.new(),
}

FallbackProperties["BodyAngularVelocity"] = {
    AngularVelocity = Vector3.new(),
    MaxTorque = Vector3.new(4000, 4000, 4000),
    P = 10000,
}

FallbackProperties["BodyGyro"] = {
    CFrame = CFrame.new(),
    D = 500,
    MaxTorque = Vector3.new(4000, 4000, 4000),
    P = 10000,
}

FallbackProperties["BodyThrust"] = {
    Force = Vector3.new(),
    Location = Vector3.new(),
}

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

FallbackProperties["PointLight"] = {
    Brightness = 1,
    Color = Color3.new(1, 1, 1),
    Enabled = true,
    Range = 16,
    Shadows = false,
}

FallbackProperties["SpotLight"] = {
    Angle = 45,
    Brightness = 1,
    Color = Color3.new(1, 1, 1),
    Enabled = true,
    Face = Enum.NormalId.Front,
    Range = 16,
    Shadows = false,
}

FallbackProperties["SurfaceLight"] = {
    Angle = 90,
    Brightness = 1,
    Color = Color3.new(1, 1, 1),
    Enabled = true,
    Face = Enum.NormalId.Front,
    Range = 16,
    Shadows = false,
}

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

FallbackProperties["Clouds"] = {
    Cover = 0.5,
    Density = 0.9,
    Enabled = true,
}

FallbackProperties["Bloom"] = {
    Enabled = true,
    Intensity = 0.5,
    Size = 56,
    Threshold = 0.95,
}

FallbackProperties["Blur"] = {
    Enabled = true,
    Size = 24,
}

FallbackProperties["ColorCorrection"] = {
    Brightness = 0,
    Contrast = 0,
    Enabled = true,
    Saturation = 0,
    TintColor = Color3.new(1, 1, 1),
}

FallbackProperties["DepthOfField"] = {
    Enabled = true,
    FarIntensity = 0,
    FocusDistance = 50,
    InFocusRadius = 10,
    NearIntensity = 0,
}

FallbackProperties["SunRaysEffect"] = {
    Enabled = true,
    Intensity = 0.5,
    Spread = 1,
}

FallbackProperties["ProximityPrompt"] = {
    ActionText = "Interact",
    AutoLocalize = true,
    ClickablePrompt = true,
    Enabled = true,
    GamepadKeyCode = Enum.KeyCode.ButtonX,
    HoldDuration = 0,
    KeyboardKeyCode = Enum.KeyCode.E,
    MaxActivationDistance = 10,
    ObjectText = "",
    RequiresLineOfSight = true,
    Style = Enum.ProximityPromptStyle.Default,
    UIOffset = Vector2.new(),
}

FallbackProperties["ClickDetector"] = {
    CursorIcon = "",
    MaxActivationDistance = 32,
}

FallbackProperties["ForceField"] = {
    Visible = true,
}

FallbackProperties["PathfindingModifier"] = {
    IsBlocked = false,
    Label = "",
    PassThrough = false,
}

FallbackProperties["PathfindingLink"] = {
    Attachment0 = nil,
    Attachment1 = nil,
    Bidirectional = true,
    Label = "",
}

FallbackProperties["Dialog"] = {
    BehaviorType = Enum.DialogBehaviorType.SinglePlayer,
    ConversationDistance = 25,
    Enabled = true,
    GoodbyeChoiceActive = false,
    GoodbyeDialog = "",
    InitialPrompt = "",
    Purpose = Enum.DialogPurpose.Help,
    Tone = Enum.DialogTone.Neutral,
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
    DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer,
    HealthDisplayDistance = 100,
    HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged,
    HipHeight = 0,
    JumpHeight = 7.2,
    JumpPower = 50,
    MaxHealth = 100,
    MaxSlopeAngle = 89,
    NameDisplayDistance = 100,
    NameOcclusion = Enum.NameOcclusion.OccludeAll,
    RequiresNeck = true,
    RigType = Enum.HumanoidRigType.R6,
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
    CameraType = Enum.CameraType.Custom,
    FieldOfView = 70,
    FieldOfViewMode = Enum.FieldOfViewMode.Vertical,
    HeadLocked = true,
    MaxZoom = 400,
    MinZoom = 0,
}

FallbackProperties["TextChatService"] = {
    ChatTranslationEnabled = false,
    CreateDefaultCommands = true,
    CreateDefaultTextChannels = true,
}

FallbackProperties["TextChannel"] = {
    WelcomeMessage = "",
}

FallbackProperties["TextChatCommand"] = {
    Enabled = true,
    PrimaryAlias = "",
    SecondaryAlias = "",
}

FallbackProperties["ChatWindowConfiguration"] = {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.6,
    Enabled = true,
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    TextStrokeColor3 = Color3.new(),
    TextStrokeTransparency = 0.75,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
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
    AutomaticSize = Enum.AutomaticSize.None,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0,
    BorderColor3 = Color3.new(0, 0, 0),
    BorderMode = Enum.BorderMode.Outline,
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
    SizeConstraint = Enum.SizeConstraint.RelativeXY,
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
    TextTruncate = Enum.TextTruncate.None,
    TextWrapped = false,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}

FallbackProperties["ScreenGui"] = {
    ClipToDeviceSafeArea = false,
    DisplayOrder = 0,
    Enabled = true,
    IgnoreGuiInset = false,
    OnTopOfCoreBlur = false,
    ResetOnSpawn = true,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}

FallbackProperties["SurfaceGui"] = {
    Active = false,
    AlwaysOnTop = false,
    Brightness = 1,
    CanvasSize = Vector2.new(800, 600),
    ClipsDescendants = false,
    Enabled = true,
    Face = Enum.NormalId.Front,
    LightInfluence = 1,
    PixelsPerStud = 20,
    SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}

FallbackProperties["Frame"] = {
    BackgroundTransparency = 0,
    Size = UDim2.fromOffset(100, 100),
}

FallbackProperties["TextLabel"] = {
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(200, 50),
    Text = "Label",
}

FallbackProperties["TextButton"] = {
    AutoButtonColor = true,
    Modal = false,
    Selected = false,
    Size = UDim2.fromOffset(200, 50),
    Style = Enum.ButtonStyle.Custom,
    Text = "Button",
}

FallbackProperties["TextBox"] = {
    ClearTextOnFocus = true,
    MultiLine = false,
    PlaceholderColor3 = Color3.new(0.75, 0.75, 0.75),
    PlaceholderText = "",
    ShowNativeInput = true,
    Text = "",
    TextEditable = true,
    TextXAlignment = Enum.TextXAlignment.Left,
}

FallbackProperties["ImageLabel"] = {
    BackgroundTransparency = 1,
    Image = "",
    ImageColor3 = Color3.new(1, 1, 1),
    ImageRectOffset = Vector2.new(),
    ImageRectSize = Vector2.new(),
    ImageTransparency = 0,
    ResampleMode = Enum.ResamplerMode.Default,
    ScaleType = Enum.ScaleType.Stretch,
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
    ResampleMode = Enum.ResamplerMode.Default,
    ScaleType = Enum.ScaleType.Stretch,
    Selected = false,
    SliceCenter = Rect.new(0, 0, 0, 0),
    SliceScale = 1,
    Style = Enum.ButtonStyle.Custom,
    TileSize = UDim2.fromOffset(100, 100),
}

FallbackProperties["ScrollingFrame"] = {
    AutomaticCanvasSize = Enum.AutomaticSize.None,
    BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
    CanvasPosition = Vector2.new(),
    CanvasSize = UDim2.new(0, 0, 1, 0),
    ClipsDescendants = true,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    HorizontalScrollBarInset = Enum.ScrollBarInset.None,
    MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    ScrollBarImageColor3 = Color3.new(0, 0, 0),
    ScrollBarImageTransparency = 0,
    ScrollBarThickness = 12,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
    VerticalScrollBarInset = Enum.ScrollBarInset.None,
    VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
}

FallbackProperties["VideoFrame"] = {
    Looped = false,
    Playing = false,
    TimePosition = 0,
    Video = "",
    Volume = 0.5,
}

FallbackProperties["ViewportFrame"] = {
    Ambient = Color3.new(1, 1, 1),
    CurrentCamera = nil,
    ImageColor3 = Color3.new(1, 1, 1),
    ImageTransparency = 0,
    LightColor = Color3.new(1, 1, 1),
    LightDirection = Vector3.new(0, -1, -1),
}

FallbackProperties["CanvasGroup"] = {
    GroupColor3 = Color3.new(1, 1, 1),
    GroupTransparency = 0,
}

FallbackProperties["UICorner"] = {
    CornerRadius = UDim.new(0, 0),
}

FallbackProperties["UIStroke"] = {
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(),
    Enabled = true,
    LineJoinMode = Enum.LineJoinMode.Round,
    Thickness = 1,
    Transparency = 0,
}

FallbackProperties["UIPadding"] = {
    PaddingBottom = UDim.new(),
    PaddingLeft = UDim.new(),
    PaddingRight = UDim.new(),
    PaddingTop = UDim.new(),
}

FallbackProperties["UIListLayout"] = {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    HorizontalFlex = Enum.UIFlexAlignment.None,
    ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
    Padding = UDim.new(),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    VerticalFlex = Enum.UIFlexAlignment.None,
    Wraps = false,
}

FallbackProperties["UIGridLayout"] = {
    CellPaddingX = UDim.new(0, 5),
    CellPaddingY = UDim.new(0, 5),
    CellSize = UDim2.fromOffset(100, 100),
    FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = 0,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    StartCorner = Enum.StartCorner.TopLeft,
    VerticalAlignment = Enum.VerticalAlignment.Top,
}

FallbackProperties["UITableLayout"] = {
    FillDirection = Enum.FillDirection.Vertical,
    FillEmptySpaceColumns = false,
    FillEmptySpaceRows = false,
    MajorAxis = Enum.TableMajorAxis.RowMajor,
    Padding = UDim2.new(),
    SortOrder = Enum.SortOrder.LayoutOrder,
}

FallbackProperties["UIPageLayout"] = {
    Animated = true,
    Circular = false,
    EasingDirection = Enum.EasingDirection.Out,
    EasingStyle = Enum.EasingStyle.Quad,
    FillDirection = Enum.FillDirection.Horizontal,
    GamepadInputEnabled = true,
    Padding = UDim.new(),
    ScrollWheelInputEnabled = true,
    SortOrder = Enum.SortOrder.LayoutOrder,
    TweenTime = 0.5,
    TouchInputEnabled = true,
}

FallbackProperties["UISizeConstraint"] = {
    MaxSize = Vector2.new(math.huge, math.huge),
    MinSize = Vector2.new(),
}

FallbackProperties["UITextSizeConstraint"] = {
    MaxTextSize = 100,
    MinTextSize = 1,
}

FallbackProperties["UIAspectRatioConstraint"] = {
    AspectRatio = 1,
    AspectType = Enum.AspectType.FitWithinMaxSize,
    DominantAxis = Enum.DominantAxis.Width,
}

FallbackProperties["UIFlexItem"] = {
    FlexMode = Enum.UIFlexMode.None,
    GrowRatio = 0,
    ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
    ShrinkRatio = 0,
}

FallbackProperties["UIGradient"] = {
    Color = ColorSequence.new(Color3.new(1, 1, 1)),
    Enabled = true,
    Offset = Vector2.new(),
    Rotation = 0,
    Transparency = NumberSequence.new(0),
}

FallbackProperties["UIScale"] = {
    Scale = 1,
}

FallbackProperties["SelectionBox"] = {
    Adornee = nil,
    Color3 = Color3.new(0, 0, 1),
    LineThickness = 0.1,
    SurfaceColor3 = Color3.new(0, 0, 1),
    SurfaceTransparency = 0.5,
    Visible = true,
}

FallbackProperties["SelectionSphere"] = {
    Adornee = nil,
    Color3 = Color3.new(0, 0, 1),
    SurfaceColor3 = Color3.new(0, 0, 1),
    SurfaceTransparency = 0.5,
    Visible = true,
}

FallbackProperties["BoxHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Size = Vector3.new(1, 1, 1),
    SizeRelativeOffset = Vector3.new(),
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["SphereHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Radius = 1,
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["ConeHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Height = 1,
    Radius = 0.25,
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["CylinderHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Height = 1,
    InnerRadius = 0,
    Radius = 1,
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["LineHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Length = 1,
    Thickness = 1,
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["ImageHandleAdornment"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(1, 1, 1),
    Image = "",
    RelativeSize = 0,
    SizeRelativeOffset = Vector3.new(),
    Transparency = 0,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["ArcHandles"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(0, 0, 1),
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["Handles"] = {
    Adornee = nil,
    AlwaysOnTop = false,
    Color3 = Color3.new(0, 0, 1),
    Faces = Faces.new(),
    Style = Enum.HandlesStyle.Resize,
    Visible = true,
    ZIndex = 0,
}

FallbackProperties["SelectionPartLasso"] = {
    Color = BrickColor.new("Bright blue"),
    Humanoid = nil,
    Part = nil,
}

FallbackProperties["SelectionPointLasso"] = {
    Color = BrickColor.new("Bright blue"),
    Humanoid = nil,
    Point = Vector3.new(),
}

FallbackProperties["Highlight"] = {
    Adornee = nil,
    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    Enabled = true,
    FillColor = Color3.new(1, 1, 1),
    FillTransparency = 0.5,
    OutlineColor = Color3.new(1, 1, 1),
    OutlineTransparency = 0,
}

FallbackProperties["RemoteEvent"] = {
}

FallbackProperties["RemoteFunction"] = {
}

FallbackProperties["BindableEvent"] = {
}

FallbackProperties["BindableFunction"] = {
}

FallbackProperties["Configuration"] = {
}

FallbackProperties["MaterialService"] = {
    Use2022Materials = true,
}

FallbackProperties["MaterialVariant"] = {
    BaseMaterial = Enum.Material.SmoothPlastic,
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

FallbackProperties["TerrainRegion"] = {
}

FallbackProperties["StarterGui"] = {
    AutoResetLocalPlayerCamera = true,
    ShowTalkativeMessages = true,
}

FallbackProperties["StarterPlayer"] = {
    AutoJumpEnabled = false,
    CameraMaxZoomDistance = 400,
    CameraMinZoomDistance = 0.5,
    CameraMode = Enum.CameraMode.Normal,
    CharacterJumpHeight = 7.2,
    CharacterJumpPower = 50,
    CharacterUseJumpPower = false,
    CharacterWalkSpeed = 16,
    DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom,
    DevTouchCameraMovementMode = Enum.DevTouchCameraMovementMode.Watch,
    EnableMouseLockOption = false,
    MouseIconEnabled = true,
    UserInputTouchData = nil,
}

FallbackProperties["StarterPlayerScripts"] = {
}

FallbackProperties["LocalizationService"] = {
    CoreScriptLocalizationsEnabled = true,
}

FallbackProperties["Chat"] = {
    BubbleChatEnabled = false,
    Callbacks = {},
    TypingIndicator = false,
}

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
    Part = {"BasePart", "Instance"},
    WedgePart = {"BasePart", "Instance"},
    CornerWedgePart = {"BasePart", "Instance"},
    TrussPart = {"BasePart", "Instance"},
    SpawnLocation = {"BasePart", "Instance"},
    Platform = {"BasePart", "Instance"},
    Seat = {"BasePart", "Instance"},
    VehicleSeat = {"BasePart", "Instance"},
    MeshPart = {"BasePart", "Instance"},
    UnionOperation = {"BasePart", "Instance"},
    PartOperation = {"BasePart", "Instance"},
    NegateOperation = {"BasePart", "Instance"},
    IntersectOperation = {"BasePart", "Instance"},
    FormFactorPart = {"BasePart", "Instance"},
    SpecialMesh = {"Instance"},
    CylinderMesh = {"Instance"},
    BlockMesh = {"Instance"},
    FileMesh = {"Instance"},
    Decal = {"Instance"},
    Texture = {"Instance"},
    SurfaceAppearance = {"Instance"},
    Model = {"Instance"},
    Folder = {"Instance"},
    Tool = {"Instance"},
    Hat = {"Instance"},
    Accessory = {"Instance"},
    Backpack = {"Instance"},
    StarterPack = {"Instance"},
    StarterGear = {"Instance"},
    Configuration = {"Instance"},
    MaterialService = {"Instance"},
    MaterialVariant = {"Instance"},
    Script = {"Instance"},
    LocalScript = {"Instance"},
    ModuleScript = {"Instance"},
    StringValue = {"Instance"},
    NumberValue = {"Instance"},
    BoolValue = {"Instance"},
    IntValue = {"Instance"},
    Vector3Value = {"Instance"},
    CFrameValue = {"Instance"},
    ObjectValue = {"Instance"},
    Color3Value = {"Instance"},
    BrickColorValue = {"Instance"},
    RayValue = {"Instance"},
    Animation = {"Instance"},
    Animator = {"Instance"},
    AnimationController = {"Instance"},
    AnimationTrack = {"Instance"},
    Sound = {"Instance"},
    SoundService = {"Instance"},
    EqualizerSoundEffect = {"Instance"},
    ReverbSoundEffect = {"Instance"},
    ChorusSoundEffect = {"Instance"},
    CompressorSoundEffect = {"Instance"},
    DistortionSoundEffect = {"Instance"},
    EchoSoundEffect = {"Instance"},
    FlangeSoundEffect = {"Instance"},
    PitchShiftSoundEffect = {"Instance"},
    TremoloSoundEffect = {"Instance"},
    AudioPlayer = {"Instance"},
    AudioEmitter = {"Instance"},
    AudioListener = {"Instance"},
    AudioAnalyzer = {"Instance"},
    AudioChorus = {"Instance"},
    AudioCompressor = {"Instance"},
    AudioDistortion = {"Instance"},
    AudioEqualizer = {"Instance"},
    AudioFader = {"Instance"},
    AudioFlanger = {"Instance"},
    AudioPitchShifter = {"Instance"},
    AudioReverb = {"Instance"},
    AudioTremolo = {"Instance"},
    AudioDeviceInput = {"Instance"},
    AudioDeviceOutput = {"Instance"},
    Wire = {"Instance"},
    Attachment = {"Instance"},
    Bone = {"Attachment", "Instance"},
    Beam = {"Instance"},
    Trail = {"Instance"},
    ParticleEmitter = {"Instance"},
    Fire = {"Instance"},
    Smoke = {"Instance"},
    Sparkles = {"Instance"},
    BodyVelocity = {"Instance"},
    BodyPosition = {"Instance"},
    BodyForce = {"Instance"},
    BodyAngularVelocity = {"Instance"},
    BodyGyro = {"Instance"},
    BodyThrust = {"Instance"},
    RocketPropulsion = {"Instance"},
    RopeConstraint = {"Instance"},
    SpringConstraint = {"Instance"},
    HingeConstraint = {"Instance"},
    BallSocketConstraint = {"Instance"},
    CylindricalConstraint = {"Instance"},
    PrismaticConstraint = {"Instance"},
    TorsionSpringConstraint = {"Instance"},
    UniversalConstraint = {"Instance"},
    WeldConstraint = {"Instance"},
    LinearVelocityConstraint = {"Instance"},
    AngularVelocityConstraint = {"Instance"},
    AlignPosition = {"Instance"},
    AlignOrientation = {"Instance"},
    Weld = {"Instance"},
    Motor6D = {"Instance"},
    Snap = {"Instance"},
    ManualWeld = {"Instance"},
    ManualGlue = {"Instance"},
    Motor = {"Instance"},
    Glue = {"Instance"},
    RigidConstraint = {"Instance"},
    SliderConstraint = {"Instance"},
    PointLight = {"Instance"},
    SpotLight = {"Instance"},
    SurfaceLight = {"Instance"},
    Atmosphere = {"Instance"},
    Sky = {"Instance"},
    Clouds = {"Instance"},
    Bloom = {"Instance"},
    Blur = {"Instance"},
    ColorCorrection = {"Instance"},
    DepthOfField = {"Instance"},
    SunRaysEffect = {"Instance"},
    IKControl = {"Instance"},
    Humanoid = {"Instance"},
    HumanoidDescription = {"Instance"},
    BodyColors = {"Instance"},
    CharacterMesh = {"Instance"},
    Pants = {"Instance"},
    Shirt = {"Instance"},
    ShirtGraphic = {"Instance"},
    WrapLayer = {"Instance"},
    WrapTarget = {"Instance"},
    Camera = {"Instance"},
    ScreenGui = {"Instance"},
    BillboardGui = {"Instance"},
    SurfaceGui = {"Instance"},
    Frame = {"Instance"},
    TextLabel = {"Instance"},
    TextButton = {"Instance"},
    TextBox = {"Instance"},
    ImageLabel = {"Instance"},
    ImageButton = {"Instance"},
    ScrollingFrame = {"Instance"},
    VideoFrame = {"Instance"},
    ViewportFrame = {"Instance"},
    CanvasGroup = {"Instance"},
    UICorner = {"Instance"},
    UIStroke = {"Instance"},
    UIPadding = {"Instance"},
    UIListLayout = {"Instance"},
    UIGridLayout = {"Instance"},
    UITableLayout = {"Instance"},
    UIPageLayout = {"Instance"},
    UISizeConstraint = {"Instance"},
    UITextSizeConstraint = {"Instance"},
    UIAspectRatioConstraint = {"Instance"},
    UIFlexItem = {"Instance"},
    UIGradient = {"Instance"},
    UIScale = {"Instance"},
    ProximityPrompt = {"Instance"},
    ClickDetector = {"Instance"},
    ForceField = {"Instance"},
    PathfindingModifier = {"Instance"},
    PathfindingLink = {"Instance"},
    SelectionBox = {"Instance"},
    SelectionSphere = {"Instance"},
    BoxHandleAdornment = {"Instance"},
    SphereHandleAdornment = {"Instance"},
    ConeHandleAdornment = {"Instance"},
    CylinderHandleAdornment = {"Instance"},
    LineHandleAdornment = {"Instance"},
    ImageHandleAdornment = {"Instance"},
    ArcHandles = {"Instance"},
    Handles = {"Instance"},
    SelectionPartLasso = {"Instance"},
    SelectionPointLasso = {"Instance"},
    Highlight = {"Instance"},
    RemoteEvent = {"Instance"},
    RemoteFunction = {"Instance"},
    BindableEvent = {"Instance"},
    BindableFunction = {"Instance"},
    Dialog = {"Instance"},
    DialogChoice = {"Instance"},
    TextChatService = {"Instance"},
    TextChannel = {"Instance"},
    TextChatCommand = {"Instance"},
    ChatWindowConfiguration = {"Instance"},
    BubbleChatConfiguration = {"Instance"},
    StarterGui = {"Instance"},
    StarterPlayer = {"Instance"},
    StarterPlayerScripts = {"Instance"},
    LocalizationService = {"Instance"},
    Chat = {"Instance"},
}

local ExactPropertyHints = {
    Instance = { "Name" },
    BasePart = {
        "Anchored", "BackSurface", "BackSurfaceInput", "BottomSurface",
        "BottomSurfaceInput", "CFrame", "CanCollide", "CanQuery", "CanTouch",
        "CastShadow", "CollisionGroup", "Color", "CustomPhysicalProperties",
        "EnableFluidForces", "FrontSurface", "FrontSurfaceInput", "LeftSurface",
        "LeftSurfaceInput", "Locked", "Massless", "Material", "MaterialVariant",
        "Orientation", "PivotOffset", "Position", "Reflectance", "RightSurface",
        "RightSurfaceInput", "RootPriority", "Rotation", "Size", "TopSurface",
        "TopSurfaceInput", "Transparency",
    },
    Part = { "Shape" },
    MeshPart = { "CollisionFidelity", "DoubleSided", "MeshId", "MeshSize", "RenderFidelity", "TextureID" },
    PartOperation = { "CollisionFidelity", "RenderFidelity", "SmoothingAngle", "UsePartColor" },
    SpecialMesh = { "MeshId", "MeshType", "Offset", "RotationOffset", "Scale", "TextureId", "VertexColor" },
    FileMesh = { "MeshId", "Offset", "Scale", "TextureId", "VertexColor" },
    Decal = { "Color3", "Face", "Shiny", "Specular", "Texture", "Transparency", "ZIndex" },
    Texture = { "Color3", "Face", "OffsetStudsU", "OffsetStudsV", "Shiny", "Specular", "StudsPerTileU", "StudsPerTileV", "Texture", "Transparency", "ZIndex" },
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
    ParticleEmitter = { "Acceleration", "Brightness", "Color", "Drag", "EmissionDirection", "Enabled", "FlipbookFramerate", "FlipbookLayout", "FlipbookMode", "LifeTime", "LightEmission", "LightInfluence", "LockedToPart", "Orientation", "Rate", "RotSpeed", "Rotation", "ShapeInOut", "ShapePartial", "ShapeRotation", "ShapeStyle", "Size", "Speed", "SpreadAngle", "Squash", "Texture", "TimeScale", "Transparency", "VelocityInheritance", "ZOffset" },
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

local function num(n)
    if n ~= n then return "0/0" end
    if n == math.huge then return "math.huge" end
    if n == -math.huge then return "-math.huge" end
    if math.floor(n) == n and math.abs(n) < 1e15 then return tostring(n) end
    return string.format("%.8g", n)
end

local function getPath(i, refs)
    if not i then return "nil" end
    if refs[i] then return string.format("o[%d]", refs[i]) end
    local p = {}
    local c = i
    while c and c ~= game do
        local n = c.Name
        if n:match("^[%a_][%w_]*$") then
            table.insert(p, 1, "."..n)
        else
            table.insert(p, 1, string.format("[%q]", n))
        end
        c = c.Parent
    end
    if #p == 0 then return "nil" end
    return "game" .. table.concat(p)
end

local function ser(v, refs)
    local t = typeof(v)
    if t == "nil" then return "nil" end
    if t == "boolean" then return tostring(v) end
    if t == "number" then return num(v) end
    if t == "string" then return string.format("%q", v) end
    if t == "Instance" then return getPath(v, refs) end
    if t == "CFrame" then
        local x,y,z,r00,r01,r02,r10,r11,r12,r20,r21,r22 = v:GetComponents()
        if r00==1 and r01==0 and r02==0 and r10==0 and r11==1 and r12==0 and r20==0 and r21==0 and r22==1 then
            if x==0 and y==0 and z==0 then return "CFrame.new()" end
            return string.format("CFrame.new(%s,%s,%s)", num(x),num(y),num(z))
        end
        return string.format("CFrame.new(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", num(x),num(y),num(z),num(r00),num(r01),num(r02),num(r10),num(r11),num(r12),num(r20),num(r21),num(r22))
    end
    if t == "Vector3" then return (v.X==0 and v.Y==0 and v.Z==0) and "Vector3.new()" or string.format("Vector3.new(%s,%s,%s)", num(v.X),num(v.Y),num(v.Z)) end
    if t == "Vector2" then return (v.X==0 and v.Y==0) and "Vector2.new()" or string.format("Vector2.new(%s,%s)", num(v.X),num(v.Y)) end
    if t == "Vector3int16" then return string.format("Vector3int16.new(%d,%d,%d)", v.X, v.Y, v.Z) end
    if t == "Vector2int16" then return string.format("Vector2int16.new(%d,%d)", v.X, v.Y) end
    if t == "Color3" then
        local r,g,b = math.round(v.R*255), math.round(v.G*255), math.round(v.B*255)
        if math.abs(v.R-r/255)<0.001 and math.abs(v.G-g/255)<0.001 and math.abs(v.B-b/255)<0.001 then
            return string.format("Color3.fromRGB(%d,%d,%d)", r,g,b)
        end
        return string.format("Color3.new(%s,%s,%s)", num(v.R),num(v.G),num(v.B))
    end
    if t == "UDim2" then
        local XS, XO, YS, YO = v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset
        if XS==0 and YS==0 then return (XO==0 and YO==0) and "UDim2.new()" or string.format("UDim2.fromOffset(%d,%d)", XO, YO) end
        if XO==0 and YO==0 then return string.format("UDim2.fromScale(%s,%s)", num(XS), num(YS)) end
        return string.format("UDim2.new(%s,%d,%s,%d)", num(XS), XO, num(YS), YO)
    end
    if t == "UDim" then
        if v.Scale==0 and v.Offset==0 then return "UDim.new()" end
        if v.Offset==0 then return string.format("UDim.new(%s,0)", num(v.Scale)) end
        if v.Scale==0 then return string.format("UDim.new(0,%d)", v.Offset) end
        return string.format("UDim.new(%s,%d)", num(v.Scale), v.Offset)
    end
    if t == "BrickColor" then return string.format('BrickColor.new("%s")', v.Name) end
    if t == "EnumItem" then return tostring(v) end
    if t == "NumberRange" then return (v.Min == v.Max) and string.format("NumberRange.new(%s)", num(v.Min)) or string.format("NumberRange.new(%s,%s)", num(v.Min),num(v.Max)) end
    if t == "PhysicalProperties" then return string.format("PhysicalProperties.new(%s,%s,%s,%s,%s)", num(v.Density),num(v.Friction),num(v.Elasticity),num(v.FrictionWeight),num(v.ElasticityWeight)) end
    if t == "NumberSequence" then
        local k = v.Keypoints
        if #k==2 and k[1].Time==0 and k[2].Time==1 and k[1].Value==k[2].Value and k[1].Envelope==0 and k[2].Envelope==0 then return string.format("NumberSequence.new(%s)", num(k[1].Value)) end
        local p = {}
        for _, kp in ipairs(k) do p[#p+1] = string.format("NumberSequenceKeypoint.new(%s,%s%s)", num(kp.Time), num(kp.Value), kp.Envelope ~= 0 and (","..num(kp.Envelope)) or "") end
        return "NumberSequence.new({"..table.concat(p, ",").."})"
    end
    if t == "ColorSequence" then
        local k = v.Keypoints
        if #k==2 and k[1].Time==0 and k[2].Time==1 and k[1].Value==k[2].Value then return string.format("ColorSequence.new(%s)", ser(k[1].Value)) end
        local p = {}
        for _, kp in ipairs(k) do p[#p+1] = string.format("ColorSequenceKeypoint.new(%s,%s)", num(kp.Time), ser(kp.Value)) end
        return "ColorSequence.new({"..table.concat(p, ",").."})"
    end
    if t == "Rect" then return string.format("Rect.new(%s,%s,%s,%s)", num(v.Min.X),num(v.Min.Y),num(v.Max.X),num(v.Max.Y)) end
    if t == "Font" then return string.format('Font.new("%s",Enum.FontWeight.%s,Enum.FontStyle.%s)', v.Family, v.Weight.Name, v.Style.Name) end
    if t == "Ray" then return string.format("Ray.new(%s,%s)", ser(v.Origin), ser(v.Direction)) end
    if t == "TweenInfo" then return string.format("TweenInfo.new(%s,%s,%s,%s,%s,%s)", num(v.Time), tostring(v.EasingStyle), tostring(v.EasingDirection), num(v.RepeatCount), tostring(v.Reverses), num(v.DelayTime)) end
    if t == "DateTime" then return string.format("DateTime.fromUnixTimestamp(%d)", v.UnixTimestamp) end
    if t == "Axes" then
        local p = {}
        if v.X then p[#p+1] = "Enum.Axis.X" end if v.Y then p[#p+1] = "Enum.Axis.Y" end if v.Z then p[#p+1] = "Enum.Axis.Z" end
        return "Axes.new("..table.concat(p, ",")..")"
    end
    if t == "Faces" then
        local p = {}
        if v.Top then p[#p+1] = "Enum.NormalId.Top" end if v.Bottom then p[#p+1] = "Enum.NormalId.Bottom" end
        if v.Left then p[#p+1] = "Enum.NormalId.Left" end if v.Right then p[#p+1] = "Enum.NormalId.Right" end
        if v.Front then p[#p+1] = "Enum.NormalId.Front" end if v.Back then p[#p+1] = "Enum.NormalId.Back" end
        return "Faces.new("..table.concat(p, ",")..")"
    end
    if t == "OverlapParams" then return string.format("(function()local p=OverlapParams.new()p.FilterType=%s p.MaxParts=%d p.RespectCanCollide=%s return p end)()", tostring(v.FilterType), v.MaxParts, tostring(v.RespectCanCollide)) end
    if t == "RaycastParams" then return string.format("(function()local p=RaycastParams.new()p.FilterType=%s p.IgnoreWater=%s p.RespectCanCollide=%s return p end)()", tostring(v.FilterType), tostring(v.IgnoreWater), tostring(v.RespectCanCollide)) end
    return nil
end

local function _get(i, p) return i[p] end
local function _new(c) return Instance.new(c) end
local function _isa(i, c) return i:IsA(c) end
local function _attrs(i) return i:GetAttributes() end
local function _tags(i) return CollectionService:GetTags(i) end

local function getSrc(inst)
    if not pcall(_isa, inst, "LuaSourceContainer") then return nil end
    local s = ""
    if decompile then
        local ok, res = pcall(decompile, inst)
        if ok and type(res) == "string" then s = res end
    end
    if #s == 0 then
        local ok, res = pcall(_get, inst, "Source")
        if ok and type(res) == "string" then s = res end
    end
    return s
end

local function ResolveFallbackProps(inst)
    local Merged = {}
    local Class = inst.ClassName
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

local function AddHintProps(Dest, inst)
    for ClassName, PropList in pairs(ExactPropertyHints) do
        local Include = false
        if ClassName == "Instance" then
            Include = true
        else
            local ok, result = pcall(_isa, inst, ClassName)
            Include = ok and result or false
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

local propCache = {}
local function getProps(inst)
    local c = inst.ClassName
    if propCache[c] then return propCache[c] end
    local p = {}
    if listproperties then
        local ok, res = pcall(listproperties, inst)
        if ok and type(res) == "table" then MergePropertyDump(p, res) end
    end
    if gethiddenproperties then
        local ok, res = pcall(gethiddenproperties, inst)
        if ok and type(res) == "table" then MergePropertyDump(p, res) end
    end
    if pcall(_isa, inst, "LuaSourceContainer") then p["Source"] = true end
    for k in pairs(ResolveFallbackProps(inst)) do p[k] = true end
    AddHintProps(p, inst)
    for k in pairs(p) do
        if SkipProperties[k] then
            p[k] = nil
        elseif not pcall(_get, inst, k) then
            p[k] = nil
        end
    end
    propCache[c] = p
    return p
end

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
    local function P(...)
        out[#out+1] = string.format(...)
    end

    P("local o={}")
    P("local _s=function(i,p,v) i[p]=v end")
    P("local S=function(i,p,v) if not pcall(_s,i,p,v) and sethiddenproperty then pcall(sethiddenproperty,i,p,v) end end")
    P("local A=function(i,a,v) pcall(i.SetAttribute, i, a, v) end")
    P("local CS=game:GetService('CollectionService')")
    P("local T=function(i,t) pcall(CS.AddTag, CS, i, t) end")
    P("local _p=function(i,v) i.Parent=v end")

    local instOK = {}
    for idx, inst in ipairs(instances) do
        instOK[idx] = pcall(_new, inst.ClassName)
        if instOK[idx] then
            P("o[%d]=Instance.new(%q)", idx, inst.ClassName)
        else
            P("o[%d]=nil", idx)
        end
    end

    local deferred = {}

    for idx, inst in ipairs(instances) do
        if instOK[idx] then
            local props = getProps(inst)
            local pnames = {}
            for n in pairs(props) do pnames[#pnames+1] = n end
            table.sort(pnames)
            for _, p in ipairs(pnames) do
                local ok, v = pcall(_get, inst, p)
                if ok then
                    local t = typeof(v)
                    if t == "Instance" then
                        deferred[#deferred+1] = string.format("S(o[%d],%q,%s)", idx, p, getPath(v, refs))
                    elseif t == "function" then
                        -- skip
                    elseif p == "Source" then
                        local src = getSrc(inst)
                        if src and #src > 0 then
                            deferred[#deferred+1] = string.format("S(o[%d],'Source',%q)", idx, src)
                        end
                    else
                        local s = ser(v, refs)
                        if s then
                            P("S(o[%d],%q,%s)", idx, p, s)
                        end
                    end
                end
            end

            local ok, attrs = pcall(_attrs, inst)
            if ok then
                local s = {}
                for k, v in pairs(attrs) do s[#s+1] = {k, v} end
                table.sort(s, function(a,b) return a[1] < b[1] end)
                for _, a in ipairs(s) do
                    local str = ser(a[2], refs)
                    if str then
                        P("A(o[%d],%q,%s)", idx, a[1], str)
                    end
                end
            end

            local ok, tags = pcall(_tags, inst)
            if ok then
                table.sort(tags)
                for _, t in ipairs(tags) do
                    P("T(o[%d],%q)", idx, t)
                end
            end
        end
    end

    for _, d in ipairs(deferred) do P(d) end

    for idx, inst in ipairs(instances) do
        local p = inst.Parent
        if p then
            local path = getPath(p, refs)
            if path ~= "nil" then
                P("pcall(_p,o[%d],%s)", idx, path)
            end
        end
    end

    P("return o[1]")
    return table.concat(out, ";")
end

local API = {}
API.Path = nil
function API:Build()
    return Build(self.Path)
end
function API:Save(name)
    local out = self:Build()
    local n = name or ("hiklo_" .. tostring(self.Path.Name):gsub("[^%w]", "_") .. ".lua")
    if writefile then writefile(n, out) end
    if setclipboard then setclipboard(out) end
    if not writefile and not setclipboard then print(out) end
    return out
end

return API
