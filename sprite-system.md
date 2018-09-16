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

To illustrate this, let's look at the sprite definition of a T tetromino, or, to be more specific -- one of them.
Tetrominoes have four sprite descriptors each, one for each possible rotation state. This also applies
to O, I, Z and S, even though their rotational symmetry creates duplicate descriptors. Apart from
the ingenuity of the person who entered the data, nothing prevents duplicating the pointers in the
`SpriteDescriptorPointers` list instead of repeating all the data.

At least, all tetrominoes make use of the same dimension descriptor:

```asm
SpriteDim4x4::
	db 0,  0
	db 0,  8
	db 0,  16
	db 0,  24
	db 8,  0
	db 8,  8
	db 8,  16
	db 8,  24
	db 16, 0
	db 16, 8
	db 16, 16
	db 16, 24
	db 24, 0
	db 24, 8
	db 24, 16
	db 24, 24
```

This set of coordinate pairs is then mapped to the individual objects making up the tetromino:

```asm
; make it readable
_ EQU $fe

SpriteT1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $85, _,   _
	db $85, $85, _,   _
	db _,   $85, $ff
```
