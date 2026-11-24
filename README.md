# ลอยกระทงออนไลน์

A single-page online Loy Krathong. A full-screen night river in front of a golden-lit Wat Arun, with sky lanterns, fireworks and original Thai-style music.

- 13 krathong designs: banana leaf, lotus, marigold, orchid, ice and coconut shell, plus Terminal/ASCII, Prompt, Padlock, Shield and Audit styles
- A name and a wish on each krathong, with a random wish button
- Everyone's krathongs float left to right. Tap one to read its wish and press "ขอให้คำอธิษฐานเป็นจริง"
- A running total of krathongs floated
- Saves a 9:16 video or image for an IG or Facebook Story

Everything is drawn on a `<canvas>` and the music is synthesized with the Web Audio API, so there are no image or audio assets. The melody is original, not the copyrighted "รำวงลอยกระทง".

## Running it

`index.html` is written for claude.ai Artifacts. The shared river, the total count and the save-to-device button use that platform's `db`, `user` and `downloads` capabilities. Opened anywhere else, the page still works, but each person's krathongs float only in their own browser.
