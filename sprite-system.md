## Terminology

Object -- a 8x8 or 8x16 tile placed on the screen independently of the background layers by the Gameboy hardware.
Sprite -- a collection of objects arranged in a specific pattern, treated atomically by the game - for example,
the currently falling tetromino, or a cursor in a menu.

The game uses quite a few different structures for managing sprites. The only one in RAM is `wSpriteList`. It contains
information about all sprites currently present on the screen, but one of the wrappers around it ignores the first
entry on the list.

The `wSpriteList` contains 16-byte long entries. Only the first 7 bytes are used:

| Offset | Name                       | Meaning                                                                                                                     |
|--------|----------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| 0      | `SPRITE_OFFSET_VISIBILITY` | If set to `SPRITE_HIDDEN` (`$80`), the Y coordinate of all objects rendered is set to `$ff`, effectively hiding the sprite. |
| 1      | `SPRITE_OFFSET_Y`          | The Y screen coordinate of the anchor                                                                                       |
| 2      | `SPRITE_OFFSET_X`          | The X screen coordinate of the anchor                                                                                       |
| 3      | `SPRITE_OFFSET_ID`         | The ID of the sprite, explained later                                                                                       |
| 4      | `SPRITE_OFFSET_BELOW_BG`   | If set

`wSpriteList` is often filled with sprite lists copied from ROM. This is handled by the `LoadSprites`
and `LoadSingleSprite` routines.

Every time `wSpriteList` is updated, `UpdateSprites` is called, which generates the appropriate entries in the OAM.

Rendering a sprite starts with `SpriteDescriptorPointers`, which is indexed into with the value of `SPRITE_OFFSET_ID`.
A four-byte sprite descriptor is fetched, which contains the pointer to the object list for the sprite, as well as
the coordinates of the anchor in the sprite, negated.

Each object list is prefixed by a pointer to a dimension descriptor, which maps the linear list of object IDs
that follows to the two dimensions of the screen. The list of object IDs can, apart from tileset indices,
contain three special values:

 - `$ff` indicates the end of the list, and makes the routine move on to the next sprite in `wSpriteList`, if any.
 - `$fe` indicates an empty spot, and makes the routine skip an entry in the dimension descriptor.
 - `$fd` indicates that the next actual object ID to follow is to be flipped horizontally.
