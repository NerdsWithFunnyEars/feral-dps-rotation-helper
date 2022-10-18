Change log v.3.321
-Fixed a missed debug info

Change log v.3.32
-Slightly changed FB algorithm decision during berserk

Change log v.3.31
- Added a "cycle" option (in main option menu) for "conservative play" if you check it the algorithm doesn't take into account ooc chance to proc in order to compute expected energy replenish / second. This should led to a smoother cycle and better Savage Roar and RIP uptime. It's possible that you lose (on average) a little dps but it should be more stable. This option is enabled by default, you'll found it in the main option menu
- Slight change in the algorithm that choce between RIP and Ferocious Bite.
-Partially code revamp for better performance.
- Fixed a problem with lag-correction check box.

Change log v.3.304
- Fixed a bug in the berserk option menu

Change log v.3.303
- Added reputation ring proc
- Fixed issues in proc monitors with procs not shown or shown in multiple positions.
-Changed the icon for bleeds tracker in CD monitor, now it's a blood drop like the First Aid Icon.

Change log v.3.302
- Fixed a bug due to interaction with trauma that prevented mangle debuff to show properly (leading to a mangle spam cycle)

Change log v.3.301
- added 2 missing trinkets.
- started code revamp for cataclysm.

Change log. v.3.3
- FBN now automatically take care of enchants, metagems, glyphs and tier bonuses (you no longer need to check/uncheck them into the options menu)
- changed the options interface to avoid visualization problems
-added t9 and t10 bonuses and their weight in the algorithm
- added latest tier trinkets and procs
-m angle set to 60 seconds in the algorithm

Change log. v.3.244
- Added Vindication debuff tracking
- Updated Curse of Weakness tracking


Change log. v.3.243
-Added (checked by default) a lag correction check under the main fbn option window. In olders version is already present but you can't uncheck it. If you are having problem with rake/mangle/TF being suggested too early try to uncheck it.

-Added 2T9 set bonuses, Idol of Mutilation and new trinkets.

Change log. v.3.242
- Boss Mod now working again.

Change log. v.3.241
-FBN now works with patch 3.2
- Boss Mod temporary disabled for debugging
- Ability damage updated.

To Do:
- Put back the boss mod and update it
- Add new set bonuses and trinket procs.

Change log. v.3.240
- Fixed "expected time to die" for bosses who can increase their health (fixed the cycle with them).
- Added bleeds monitor into the cycle, now the abilities are chocen also taking into account if there is any bleed active on the target (before it assumed that they are always up)
- Added a "bleed debuff" icon (the same icon as "maim") into CD monitor frame, it is where previously was OOC-proc. When OOC proc it shows on top of it (you can turn it off from the "show" options menu).
- Many addition in the cycle menu:
 - You can now put a weight on RIP uptime (default is 1), with a weight of 4-5 you should be able to keep it always up.
- You can put a weight on rake/shred (default is 0.9) based on the relative DPE needed to avoid rake (for istance with 0.9 you avoid rake only if rake does less than 90% of shred DPE.
- you can put a weight on SR vs. other finishers (default is 1) to avoid clipping (0) or clip it more (high values).
- you can choce mangle-priority (default is 2). With 2 it try to keep it always up, with 1 it keep it up only if is efficient FOR YOU. With 0 it suggest mangle only if it's down (no energy pooling for mangling).
- You can choce energy pooling magnitude (default = 3). Basically it's the number of CP needed to avoid pooling (higher the number, higher the number of times you will pool energy).

Change log v.3.239
- Minor bug fix.
- Added size and font option for boss mod monitor.

Change log v.3.238
- Added a check for Drain Life on Yogg-Saron
- Added a check to toggle shred on tentacles for Yogg-Saron fight.

Change log v.3.237
- Fixed low level target dummies suggestion monitor.
- Fixed "Blood of the Old God" proc into proc monitor.

Change log v.3.236
- Target dummies are now fixed, the addon no longer thinks that they are going to die soon.
- An error with interrupt saved variable when updating from version older than 3.22 is fixed. As a side effect you interrupt options will be reseted.

Change log v.3.235
- Fixed a bug that wiped interrupt options under Boss Mod after a reload.
- Fixed a bug with the estimated time before kill and boss health %. Now the suggestion monitor should work accordingly with it (don't rake/rip if the mob is going to die) and the XT boss mod also (save berserk for heart).

Change log v.3.234
- Fixed hysteria, ToT, MD into proc monitor, added idol procs.

Change log v.3.233

- Fixed an error for Yogg-Brain, now it correctly suggest to shred
- Probably fixed an error on Razorscale (it should suggest to berserk only on him) -need more testing-
- Fixed an error with specific fight buff into font panel
- Fixed an error that overwrote SR timer with other CDs.
- Probably fixed an error that show aggro warning when in bearform.

Added a proc monitor (I still need to finish it up and let you set up fonts) that keep track of weapon proc, trinket proc and temporary buff like hysteria. The trinkets icons change automatical when they first proc.


Change log (from 3.22):

-Fixed an error with boss mod frames that showed a long negative time if the buff/debuff doesn't expire.

- NPC ID is now checkable under the show options in the interface configuration menu.


Version 3.237


You can access interface options with "/fbn" from the console.

Remember to lock the frame!

The addon has different component:
- suggester panel where you can see the best move to do.
For the cat version embended with the prediction frame where you can see the next move 1 second in the future depending on 1 cp or 2 cps generation, while on the left side you can see avaible dps cd like Tiger's Fury and Berserk.
For the bear version, you'll see on the right side, insteead of future move, the barkskin icon when avaiable and the "maul suggester".
- a "real stats" panel (your real crit vs. bosses, your real armor pen value considering sunders, etc.. and so on, the panel change on the fly and it's used to compute the best ability for the suggestion panel). It works only if you target something.
- an hud: mana, energy, rage, threat, life, boss casting bar. Al with color changing due to status.
- 3 cooldown monitor: 1 for survival and long CDs and the other 2 that switch between bear and cat and take care of timers.
- An Omen of Clarity graphic frame (the large frame at the center of the screen)
- A Savage Roar / Cooldown frame (numbers) center high.
- A Combo point / Lacerate stack to the left high.
- An Energy/Rage Frame to the right high.
- a notice frame with different icons near the hud, combined with the boss mod:
  hourglass: wait for energy to regen.
  lifebelt: use survival cd
  round arrows: turn to the back
  alarm clock: is time for someone else to taunt your mob
  up arrow: out of range
  down arrow: go away from here!
  right arrow: kitte the mobe or strafe
  green check: go all out with dps!
  forbid: can't use that now
  bell: pay attention at this situation!
  yellow allert: 90% tank threat
  red allert: 100% tank threat
- A boss mod that let you select some energy saving for particular situation, boss to interrupt, boss with mangle only and some cycle change due to particular fights.

- 2 boss mod frame that let you show boss fight specific buff/debuff (left), and yours fight specific buff/debuff.

From the interface option you can:
show/hide each frame
change font type and size of each frame
change size of each frame
lock/unlock the frame and move them
Change the cycle selecting the expected number of SR combo point, if you want to use shred and so on.

Everything else is autoselected based on your gear, spec and buffs.


For infos look at:
http://elitistjerks.com/f73/t49702-feralbynight_cat_bear_simulation_tool/