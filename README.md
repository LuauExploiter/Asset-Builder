# Dex++ Builder Fork

This is a fork of Dex Explorer ++ by Chillz.

It keeps the original Dex++ behavior and layout, but adds one extra option to the explorer context menu:

**Generate Builder**

When you right click an eligible object (or long-press it on mobile), Dex++ can generate builder code for that selection and open it in the built-in notepad.

## Supported selections

The Generate Builder option appears for:

- Model
- Tool
- Part / BasePart
- Folder

## What Generate Builder does

Generate Builder takes the selected object and tries to turn it into reusable Lua code that rebuilds it as closely as possible.

That includes things like:

- the object name
- parent / hierarchy
- descendants
- parts and models
- meshes
- decals and textures
- particles / VFX
- GUI objects
- BillboardGuis
- text objects
- fonts
- colors
- gradients
- many common visual and instance properties

The result is shown in Dex++ Notepad so you can copy it, save it, edit it, or run it yourself.

## Why this fork exists

The point of this fork is simple:

keep the original Dex++ feel, but add a quick way to generate builder code straight from the explorer.

Instead of manually rebuilding something or writing a serializer by hand, you can select it in Dex++ and generate the code from there.

## Credits

- Chillz — original Dex++ / main explorer script
- Hiklo — Generate Builder feature

## Notes

The main addition is the Generate Builder option.

Builder accuracy depends on what the executor can actually read from the game at runtime, so some results can vary depending on environment.
