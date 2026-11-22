# SCP-RP Random Events

A standalone Garry's Mod event director designed for SCP-RP servers. It includes:

- Weighted random selection with repeat protection
- Configurable player requirements and event intervals
- Advance warning before automatically selected events
- A built-in announcement HUD and active-event timer
- Research and Security containment-grid calibration
- An SCP-999 facility morale tour
- A cognitohazard interview event for Research
- A controlled anomalous object testing request
- A temporal rift stabilization incident
- A D-Class medical screening event
- A redacted anomalous object manifest
- A reality sinkhole stabilization event
- A Site 70 power grid surge that controls map lights
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

The expected build is `2.5.2-610-biomass-model`. If another build or `unknown` appears, the
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
- `scprp_event_start cognitohazard_interview`
- `scprp_event_start object_testing_request`
- `scprp_event_start temporal_research_incident`
- `scprp_event_start dclass_medical_screening`
- `scprp_event_start redacted_object_manifest`
- `scprp_event_start reality_sinkhole`
- `scprp_event_start power_grid_surge`
- `scprp_event_start scp008_outbreak`
- `scprp_event_start scp610_biomass_bloom`
- `scprp_event_stop`
- `scprp_event_next`

`scprp_event_list` should currently display only:

- `containment_calibration`
- `cognitohazard_interview`
- `dclass_medical_screening`
- `object_testing_request`
- `power_grid_surge`
- `reality_sinkhole`
- `redacted_object_manifest`
- `scp008_outbreak`
- `scp610_biomass_bloom`
- `scp999_morale_tour`
- `temporal_research_incident`

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

The same command-and-description reference is also available in
`EVENT_LIST.txt`.

### Cognitohazard interview

Command: `scprp_event_start cognitohazard_interview`

One player is selected as the initial cognitohazard subject. Exposed subjects receive
strange messages and can spread mental static to nearby personnel. Research looks at
an exposed subject and presses `E` to complete an interview/stabilization protocol.
Stabilizing enough subjects completes the event.

### SCP object testing request

Command: `scprp_event_start object_testing_request`

An anomalous object appears near active personnel. Research must bring a test subject
nearby and hold `E` on the object to run controlled trials. Each trial records data
and triggers a random anomalous effect such as healing, damage, slow movement,
armor/speed boosts, auditory hallucinations, or minor physics disturbances.

### Temporal research incident

Command: `scprp_event_start temporal_research_incident`

A temporal rift appears with nearby anchor devices. Research holds `E` on each
anchor to stabilize it. Personnel close to the rift may experience short speed
boosts, slowdowns, jolts, anomalous sounds, or temporal warning messages. Stabilizing
all anchors collapses the rift safely.

### D-Class medical screening

Command: `scprp_event_start dclass_medical_screening`

Selected D-Class subjects are flagged for emergency screening. Medical or Research
personnel look at a marked subject and press `E` to screen them. One subject may be
an anomalous carrier and can cause coughing, movement slowdown, and mental static
nearby until screened. Cooperative D-Class receive a small payout.

### Redacted object manifest

Command: `scprp_event_start redacted_object_manifest`

Several mislabeled anomalous objects spawn around the site. Research holds `E` on
each object to classify and secure it. Objects can be harmless, unstable,
cognitohazardous, energetic, biological, or spatially distorted, each with a
different effect when identified.

### Reality sinkhole

Command: `scprp_event_start reality_sinkhole`

A localized reality distortion appears with anchor devices around it. Research
stabilizes each anchor by holding `E`. Personnel near the sinkhole may be pushed,
slowed, or receive strange warning messages until the anchors collapse the anomaly.

### Power grid surge

Command: `scprp_event_start power_grid_surge`

Emergency power terminals appear around the site. The event uses Site 70's real
`light_all` map target to turn off site lighting, with periodic flickers while the
grid is unstable. Stabilizing every terminal restores the lights. If the event ends
or times out, the addon turns `light_all` back on automatically.

### SCP-008 outbreak

Command: `scprp_event_start scp008_outbreak`

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

Command: `scprp_event_start scp610_biomass_bloom`

Destructible biomass growths appear around the facility and periodically create
hostile infected NPCs. Each growth also projects an infection zone. Personnel within
roughly 300 units build SCP-610 exposure, while exposure slowly recedes after leaving
the area. At 100% exposure, the player becomes an SCP-610 instance using the server's
`models/player/zombie_soldier.mdl` model and `weapon_ynot610` SWEP. The transformation
lasts until death or respawn. Armed personnel must destroy every growth before time
expires.

### Containment calibration

Command: `scprp_event_start containment_calibration`

Research holds `E` to calibrate each station. Security then presses `E` to authorize
it. Completing every station grants Foundation personnel armor.

### SCP-999 morale tour

Command: `scprp_event_start scp999_morale_tour`

Non-SCP personnel near SCP-999 periodically receive health, armor, and a small
movement-speed increase. The event requires a living SCP-999.
