[![Discord](https://img.shields.io/discord/1146846558508302366.svg?colorB=7289DA&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHYAAABWAgMAAABnZYq0AAAACVBMVEUAAB38%2FPz%2F%2F%2F%2Bm8P%2F9AAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfhBxwQJhxy2iqrAAABoElEQVRIx7WWzdGEIAyGgcMeKMESrMJ6rILZCiiBg4eYKr%2Fd1ZAfgXFm98sJfAyGNwno3G9sLucgYGpQ4OGVRxQTREMDZjF7ILSWjoiHo1n%2BE03Aw8p7CNY5IhkYd%2F%2F6MtO3f8BNhR1QWnarCH4tr6myl0cWgUVNcfMcXACP1hKrGMt8wcAyxide7Ymcgqale7hN6846uJCkQxw6GG7h2MH4Czz3cLqD1zHu0VOXMfZjHLoYvsdd0Q7ZvsOkafJ1P4QXxrWFd14wMc60h8JKCbyQvImzlFjyGoZTKzohwWR2UzSONHhYXBQOaKKsySsahwGGDnb%2FiYPJw22sCqzirSULYy1qtHhXGbtgrM0oagBV4XiTJok3GoLoDNH8ooTmBm7ZMsbpFzi2bgPGoXWXME6XT%2BRJ4GLddxJ4PpQy7tmfoU2HPN6cKg%2BledKHBKlF8oNSt5w5g5o8eXhu1IOlpl5kGerDxIVT%2BztzKepulD8utXqpChamkzzuo7xYGk%2FkpSYuviLXun5bzdRf0Krejzqyz7Z3p0I1v2d6HmA07dofmS48njAiuMgAAAAASUVORK5CYII%3D)](https://discord.gg/ZuUWPaSrHa)
# oniki (this is a meme name that'll probably change later idk)
This is a side project I've been working on for a while. The idea is that it'll be an open-world-ish bullet-hell RPG with \[REDACTED\] and \[REDACTED\]. It's still at its toddler stages though. Since I'm planning on making this a pretty big game, it'll take quite a while for even a demo to be out.

## Progress
Do these numbers even mean anything? Probably no, I just pull them out of my ass. This does look kinda cool tho so whatever.
|  |  |
| --- | --- |
| [GodotSTG](#godotstg) | ![](https://geps.dev/progress/70) |
| [Overworld](#overworld) | ![](https://geps.dev/progress/3) |
| [Pause Menu](#pause-menu) | ![](https://geps.dev/progress/70) |
| [Lore/Story](#lorestory) | ![](https://geps.dev/progress/1) |

**Overall: ![](https://geps.dev/progress/4)**

## Checklist
I first want to refine the system behind the danmaku battles. To summarize, the battles will play similarly to something like Touhou, so it'll have spellcards, extra-forgiving hitboxes and all that fun stuff.

### GodotSTG
GodotSTG is the plugin I'm working on right now. The plan is to have a plugin that manages all the battle logic, bullet optimisation and all that. This'll probably the most tedious part since I won't get much of a return for a good while, and the fact that I want to make it as extensive and sturdy as possible only makes it worse. So here it goes:
  - [X] A simple circular pattern
  - [X] A simple interface to configure patterns
  - [X] A way to combine patterns into spellcards (so a spell can consist of multiple patterns running at the same time)
  - [X] Pattern sequencing (seperating patterns into sets that can run one after another, and these sequences can also be tied to health/time thresholds)
  - [X] Zones (Areas where patterns entering/exiting is checked and this can be used to change the behaviour of bullets)
  - [ ] Enemy movement (either within a `Path2D` or random slight movements)
  - [X] Optimisation via reducing the amount of nodes in every bullet (there are currently 2: one for the sprite and one for the collision. THere used to be 4, the other 2 were a `VisibleOnScreenNotifier2D`(switched to slightly off-screen colliders) and a second `Sprite2D`(2 sprites were there so I could change the outer and inner color seperately using `CanvasItem.modulate`, but there was a less expensive approach, which was to use a `GradientTexture2D` for bullet sprites.))
  - [X] ~Optimisation via the use of object pooling~ ~(further testing revealed that pooling (or at least for my implementations) is SLOWER. This is mainly because godot doesn't have a garbage collector, and it's pretty fast at instantiating nodes too.)~ (further FURTHER testing revealed that while the last statement is true, when you use too many RIDs, not having it causes some problems since Godot caches RIDs or something, I cba to fact-check)
  - [X] Optimisation via low-level tomfuckery (Appaerently I can just manage all my logic through the `PhysicsServer2D` API. This lets me create colliders with way less overhead. It's a bit more tedious to set up since it requires you to do most of the dirty work, but I got about 4.5x the FPS with this approach (right now, I'm getting around 350 FPS with 2.5k bullets))
  - [ ] Optimisation via literal black magic (In case if the last few options aren't enough (they probably are, even touhou games have a 2k bullet cap), I still have a few more options; mainly multithreading, GDExtension and actually recompiling the engine. I know I said I'd have a boss with 20 phases but this is too much, even for me. It'd be funny to rewrite the Godot's entire physics server in HolyC or Brainfuck or something though.)
  - [ ] More pattern options
  - [X] An ID system to switch between battle objects (This is so I can start a battle from the dialogue system. Clyde offers a trigger system that allows it to emit a signal with the trigger name as a parameter. Then I can just trim its prefix (battle triggers are called "battle_x" where x is the file name for the battle, this is so I can use triggers for other purposes in the future) and just pass the ID to a `load_battle()` function)
  - [ ] Releasing GodotSTG as a standalone plugin (I'm waiting on this until it feels like an actually complete plugin. I also want to write an extensive guide on how to use it.)

### Overworld
I haven't thought on how I want the overworld to function. I'm pretty sure it'll be (or at least feel like) one absolute unit, rather than being seperated to lots of sections.
  - [X] Player movement (focus, hit, run and all that)
  - [ ] Inventory system (unsure about that, i might just skip this altogether)
  - [X] Dialogue system (with choices and all that. This was way easier than I thought, mostly thanks to the Clyde Dialogue plugin. It's insane how powerful it is. It's definitely a must-have for any RPG.)
  - [ ] Sprite work (I'm ass at art, I have no clue how I'll get this one done.)
  - [ ] Cutscenes
  - [ ] Signs that you can read

### Pause Menu
IDK how, but I already have mostly finished this one. It was somehow easier than I thought, all I needed was a system that'd iterate over every menu button on startup and connect all the correct signals from them to a seperate callable.
  - [X] Pause/unpause the game (literally 2 lines of code)
  - [X] Blur the screen when paused (gdshader was kinda difficult for me, so I asked my old friend ChatGippity for help. It came up with an 11x11 gaussian blur. It looks nice, but is pretty expensive on resources. What I do to get around that is flashing the blur on screen for a single frame, getting a screenshot and replacing the shader object with that. It isn't perfect but it's the best that I could come up with.)
  - [X] Save system (EZ!!! I even got to use serialization. Also added a quicksave button.)
  - [X] Options (A few features are missing, but that's something that future me has to deal with)
  - [X] Option pickers (I'm constructing this using hardcoded arrays, and defining actions for buttons suing match statements. I implemented them in the way they are in case if I \[REDACTED\].)
  - [ ] Adding the \[REDACTED\]. IDK if I can, but if I manage to pull it off, it'll be so cool.
  - [ ] Dealing with mouse inputs (Mouse inputs work for the UI, but they create some nasty problems in the long run, because of my implementation of some menu features. There is a good chance I might block all mouse input inthe game, nothing other than menus use them anyway.)

### Lore/Story
Oh yeah, this'll be a fun one. I have a broad idea on how the story will go and the major points. I should probably start writing the lore on some document or something. When writing this readme, I figured it basically catalyzes my drive to work on the game, since it gives me a way to work on the game that doesn't involve coding or anything. There is also the fact that the flesh is weak, and the machine is eternal. I can easily forget about some cool plot point, which would be a shame.
  - [ ] idk what to put here











Tom is a genius.
