INCLUDE "includes/includes.inc"


SECTION "Tileset Functions", ROM0

/*
Load tileset data into VRAM.
*/
_LoadTileset::
    ld hl, _Tileset0
    ld bc, (_Tileset0.end - _Tileset0)
    ld de, vBLK01.0
    call _VideoMemCopy
    
    ld hl, _Tileset1
    ld bc, (_Tileset1.end - _Tileset1)
    ld de, vBLK01.128
    call _VideoMemCopy

    ld hl, _Tileset2
    ld bc, (_Tileset2.end - _Tileset2)
    ld de, vBLK21.0
    jp _VideoMemCopy


_Tileset0:
    INCBIN "assets/tilesets/tileset_0.2bpp"
.end:

_Tileset1:
    INCBIN "assets/tilesets/tileset_1.2bpp"
.end:

_Tileset2:
    INCBIN "assets/tilesets/tileset_2.2bpp"
.end:


ENDSECTION
