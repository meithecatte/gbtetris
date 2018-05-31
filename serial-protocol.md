## Titlescreen

On the titlescreen, selecting the 2-player mode will send SERIAL\_MASTER (`$29`). The other game should respond with
SERIAL\_SLAVE (`$55`). The games keep track of which one is the master in their `hMasterSlave` variables.

The master game initiates transfers by writing to `hSendBuffer` and `hSendBufferValid`. These variables are read and handled
in the `VBlankInterrupt` routine. A serial interrupt fires in the slave game, which will save the byte it just received in
`hRecvBuffer`. Unless the serial state is set to 1, the slave game will respond with its `hSendBuffer`.

After negotiating which game is the master, both games will go to the music select screen, but only one of them will be controllable. The master game will constantly send the current selection with one of the `MUSIC_TYPE_` constants, while the slave game will respond with `SERIAL_MUSIC_ACK`. When the player controlling the master game decides on the music, this will be signaled with `SERIAL_MUSIC_DONE`.
