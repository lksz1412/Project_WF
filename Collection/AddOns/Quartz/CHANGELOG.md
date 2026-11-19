# Quartz

## [3.8.0](https://github.com/Nevcairiel/Quartz/tree/3.8.0) (2026-09-23)
[Full Changelog](https://github.com/Nevcairiel/Quartz/compare/3.7.17...3.8.0) [Previous Releases](https://github.com/Nevcairiel/Quartz/releases)

- Fix swing timer for queued melee attacks in Classic and TBC  
- Update locale script to handle TOC directives  
- Fix some retail checks that should also include forever  
- Remove redundant upvalues  
- Add forever channeling ticks, cloned from classic era  
- Replace AceEvent and AceBucket with our own event handling  
    Events are now registered through a small dispatcher of our own, which  
    gives every module a frame for its events. That allows registering  
    events for specific units, which the client then filters, instead of  
    receiving them for every unit.  
    - All modules register their events through the new functions, with  
      unit events where the event was only needed for some units  
    - Modules unregister their events when they are disabled, which  
      AceEvent did for them before  
    - The cast bars register their events for the unit of the bar  
    - The bucket for UNIT\_AURA in the Buff module is replaced by a timer  
    - AceEvent is only used for the message to update the Mirror timers  
      anymore, which other addons may send  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a recorder for swings to the tests, and load them on Forever  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a Swing module for WoW Forever  
    Forever announces every swing of the player through PLAYER\_SWING, with  
    the time until the next one. The attack speed of the player is secret  
    in combat, and the combat log is not available, so the swings can't be  
    put together like on other clients.  
    This adds a second implementation of the module for Forever, which  
    uses the same settings and runs the bar on the announced duration.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a probe for AuraContainers to the tests  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a Buff module based on AuraContainers for retail and Forever  
    Aura information is secret on these clients, the bars of the Buff  
    module can no longer be built from it. This adds a second  
    implementation of the module, which uses the same settings, and is  
    loaded instead of the original one on mainline clients.  
    The bars are provided by Blizzards AuraContainer. It creates a button  
    for every aura, which is filled with the pieces of a bar: a status bar,  
    icon, name, time and the number of applications. The container drives  
    those from the aura, and colors debuffs by their dispel type.  
    - Bars can no longer be fixed to a duration  
    - The number of applications is shown separate from the name  
    - The look of the bars can only be changed while auras are not secret,  
      changes during combat are applied afterwards  
    - The containers are told to update when the unit changes, and  
      regularly, as they miss the removal of some auras  
    - Free bars are moved through a stand-in frame  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a recorder for UNIT\_SPELLCAST\_SENT to the tests  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Fix the Range module and disable it on clients with secrets  
    The global IsSpellInRange no longer exists, and the range check never  
    matched the result of C\_Spell.IsSpellInRange, which is used on all  
    clients now, with the id of the spell.  
    The unit a spell is cast at is only known by its name, which is secret  
    for most units on retail and Forever. The module can't match the name  
    to a unit there, and is no longer loaded on those clients.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add WoW Forever to the TOC  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add a recorder for the global cooldown to the tests  
    /qtest gcd records the cooldown information of casts, and how well the  
    global cooldown can be followed from the spell that was cast.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Make the GCD bar work with secret cooldowns  
    The cooldown of a spell is secret, so the global cooldown can no longer  
    be recognized by its length, or its progress be calculated.  
    A spell reports if it is on the global cooldown, which is never secret.  
    Its cooldown duration then runs a status bar without a visible fill,  
    which the spark is anchored to. A secret duration can't tell when it  
    expired, so the bar is hidden once the spell is no longer on the global  
    cooldown.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add tests for the look of uninterruptible casts  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Make the look of uninterruptible casts work with secret values  
    Whether a cast can be interrupted is a secret boolean for most units,  
    which can not be tested. Instead of switching the look in Lua, both  
    looks are set up and the client picks from the boolean:  
    - The bar color is evaluated with EvaluateColorValueFromBoolean  
    - The no interrupt border is a separate frame shown through  
      SetAlphaFromBoolean, while the regular border is faded out  
    - The shield is shown through SetAlphaFromBoolean  
    A cast that becomes interruptible now also gets its regular bar color  
    back.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Silence unused variable warnings for variable starting with an underscore  
- Fix opening the options from the slash command  
    Settings.OpenToCategory expects the category ID returned from  
    AddToBlizOptions, not the name of the category.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add tests and probes for duration driven cast bars  
    - Regression cases for the cast bar running on a duration: formatter,  
      replaced and shifted durations, stop and interrupt handlers, module  
      callbacks, zero-length casts and the flight timer  
    - /qtest baseline samples the player bar on every frame of a cast  
    - /qtest probe and /qtest record document how the client behaves with  
      durations, timers and secret casts  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Run the cast bars on DurationObjects  
    The cast bars are now driven by StatusBar:SetTimerDuration with the  
    duration of the units cast, instead of calculating the progress from  
    raw time values on every frame. This also works for units whose cast  
    times are secret, like target and focus.  
    - The spark is anchored to the bar texture  
    - The time text is formatted through a NumericRuleFormatter, which  
      replicates Util.TimeFormat and can format secret values  
    - Casts with secret times end through their events only, are treated  
      as interruptible, and don't show pushback  
    - Latency shifts the duration of the bar, Flight starts its timer  
      through the new StartTimer, and Tradeskill no longer resets the  
      range of the bar, which would stop the duration  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Add in-game tests for the status bar  
    Quartz\_Tests is a development-only addon, excluded from packaging. It  
    compares the native status bar against the previous implementation and  
    drives the player cast bar with synthetic casts. Run with /qtest.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Replace the custom status bar with a native StatusBar  
    The hand-rolled status bar is replaced by a StatusBar widget, created  
    through the same Quartz3:CreateStatusBar factory. The native widget  
    errors on NaN values, so guard the cast bar against zero-length casts.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Update TOC for 12.1.5 and exclude unsupported modules on retail  
    Swing, Interrupt and EnemyCasts do not work on Midnight yet and are  
    not loaded on mainline for now.  
    Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>  
- Avoid taint from Blizzard Hiding  
