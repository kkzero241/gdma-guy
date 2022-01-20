rgbgfx ./guy-anim/000.png -o ./guy-anim/000.2bpp
rgbgfx ./guy-anim/001.png -o ./guy-anim/001.2bpp
rgbgfx ./guy-anim/002.png -o ./guy-anim/002.2bpp
rgbgfx ./guy-anim/003.png -o ./guy-anim/003.2bpp
rgbgfx ./guy-anim/004.png -o ./guy-anim/004.2bpp
rgbgfx ./guy-anim/005.png -o ./guy-anim/005.2bpp
rgbgfx ./guy-anim/006.png -o ./guy-anim/006.2bpp
rgbgfx ./guy-anim/007.png -o ./guy-anim/007.2bpp
rgbasm -L -o gdma-guy.o gdma-guy.asm
rgblink -o gdma-guy.gb gdma-guy.o
rgbfix -C -t "GDMA GUY       " -v -p 0xFF gdma-guy.gb