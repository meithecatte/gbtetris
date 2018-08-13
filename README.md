# gbtetris

A [pret]-style disassembly of the Gameboy Tetris. Since I'm not finished yet, you'll need to place the following ROMs into the project directory to build it:

| Filename       | Known ROM names                                         | CRC      | MD5 |
|----------------|---------------------------------------------------------|----------|-----|
| `baserom.gb`   | Tetris (Japan) / Tetris (World) / Tetris (W) (v1.0) [!] | `63F9407D` | `084f1e457749cdec86183189bd88ce69` |
| `baserom11.gb` | Tetris (World) (Rev A) / Tetris(W) (v1.1) [!]           | `46DF91AD` | `982ed5d2b12a0377eb14bcdc4123744e` |

After installing RGBDS, run `make` to generate `tetris.gb` (should be identical to `baserom.gb`) and `tetris11.gb` (should be identical to `baserom11.gb`, but it still needs some work to make it so).

[pret]: https://github.com/pret
