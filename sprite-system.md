## Terminology

Object -- a 8x8 or 8x16 tile placed on the screen independently of the background layers by the Gameboy hardware.
Sprite -- a collection of objects arranged in a specific pattern, treated atomically by the game - for example,
the currently falling tetromino, or a cursor in a menu.

The game uses quite a few different structures for managing sprites. The only one in RAM is `wSpriteList`. It contains
information about all sprites currently present on the screen, but one of the wrappers around it ignores the first
on the list.

Rendering a sprite starts with `SpriteDescriptorPointers`, which is indexed into with the sprite ID from the `wSpriteList`
entry. `SpriteDescript
