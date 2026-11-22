# SCP-RP Random Events

A standalone Garry's Mod event director designed for SCP-RP servers. It includes:

- Weighted random selection with repeat protection
- Configurable player requirements and event intervals
- Advance warning before automatically selected events
- A built-in announcement HUD and active-event timer
- Research and Security containment-grid calibration
- An SCP-999 facility morale tour
- A spreading SCP-008 outbreak with exposure, infection, treatment, leaks, and infected NPCs
- An SCP-610 biomass bloom that produces hostile infected organisms
- Cleanup, spawn handling, and integration hooks

## Install

Copy the `scprp_random_events` folder into:

`garrysmod/addons/scprp_random_events`

Replace the old copy completely, then restart the server or change map. Editing a
separate local copy does not update the live server addon.

After restarting, run:

`scprp_event_debug`

The expected build is `2.2.1-008-2`. If another build or `unknown` appears, the
server is loading an outdated or duplicate addon copy.

Configuration is in:

`lua/scprp_events/sh_config.lua`

Testing mode is currently enabled with `IgnoreJobRequirements = true`. This allows
any player to start and interact with event objectives. Set it to `false` before
returning the addon to normal live use.

## Admin commands

Run these in the server console, or in a client console while logged in as an admin:

- `scprp_event_list`
- `scprp_event_debug`
- `scprp_event_roles`
- `scprp_event_start containment_calibration`
- `scprp_event_start scp999_morale_tour`
- `scprp_event_start scp008_outbreak`
- `scprp_event_start scp610_biomass_bloom`
- `scprp_event_stop`
- `scprp_event_next`

`scprp_event_list` should currently display only:

- `containment_calibration`
- `scp008_outbreak`
- `scp610_biomass_bloom`
- `scp999_morale_tour`

## Gamemode integration

Use `Config.CanStartEvent` to prevent random events during setup, restarts, or critical rounds.

The addon also emits:

- `SCPRPEventStarted(id, eventData, endTime)`
- `SCPRPEventEnded(id, eventData, reason)`

## Deep Gaming integration

The specialized events use the exact DarkRP categories configured on this server:

- `D-Class`
- `Security` and `Security Specialization`
- `Foundation Enforcement`
- `Other MTF Units`
- `Research`
- `Site Administration`
- `Chaos Insurgency`
- `SCPs`

Category matching and DarkRP money rewards can be changed in
`lua/scprp_events/sh_config.lua`.

Automatic events pause while a `lastlifes_auto_breach` breach timer is active. Admins
can still force an event with `scprp_event_start`.

## Incident behavior

### SCP-008 outbreak

Ruptured canisters appear around active areas and infected NPCs spawn near them.
Personnel standing close to a leak build exposure. At 60% exposure they become
infected, take periodic damage, move more slowly, and can expose nearby personnel.
Reaching 100% exposure transforms the player into an SCP-008-2 instance. Internally,
it reuses the server's existing zombie model, health configuration, and
`weapon_ynot049_2` SWEP. The transformation lasts until death or respawn.

Research or trained biohazard responders hold `E` on canisters to neutralize them.
They can also look at an infected player and press `E` to administer a suppressant.
SCP jobs are immune to the event's infection system.

### SCP-610 biomass bloom

Destructible biomass growths appear around the facility and periodically create
hostile infected NPCs. Armed personnel must destroy every growth before time expires.

### Containment calibration

Research holds `E` to calibrate each station. Security then presses `E` to authorize
it. Completing every station grants Foundation personnel armor.

### SCP-999 morale tour

Non-SCP personnel near SCP-999 periodically receive health, armor, and a small
movement-speed increase. The event requires a living SCP-999.
