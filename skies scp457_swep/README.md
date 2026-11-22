# SCP-457 SWEP

A standalone Garry's Mod SCP-RP weapon. While the thermal aura is active, nearby
players are ignited and receive configurable burn damage. SCP-457 also grows in
physical size as more living players gather nearby.

## Installation

Copy `skies scp457_swep` into:

`garrysmod/addons/skies scp457_swep`

Restart the server or change map after installing it.

## Weapon

Class name:

`weapon_scprp_457`

Controls:

- Left click: toggle the thermal aura
- Reload: toggle the thermal aura

The aura starts enabled whenever the weapon is deployed.

## Configuration

Edit:

`lua/autorun/sh_scprp_457_config.lua`

The radius, damage, ignition duration, line-of-sight checks, sounds, and immune
jobs/categories can all be changed there.

Growth is controlled by:

- `GrowthRadius`: how close players must be to contribute
- `ScalePerPlayer`: added model scale for each nearby player
- `MaximumModelScale`: hard size limit
- `GrowthTransitionTime`: how smoothly SCP-457 changes size

The player's previous model scale is restored when the weapon is holstered,
dropped, or removed.

## Fire extinguisher containment

This addon supports `weapon_extinguisher` from Workshop item `104607228`.

Two different players must stand within the configured range and actively spray
SCP-457 at the same time. When both streams are aimed at him:

- His thermal aura is disabled
- His model smoothly shrinks to its normal size
- Any active fire on SCP-457 is extinguished

He can reactivate the aura afterward with left click or reload. Extinguisher
requirements and range can be changed in the configuration file.
