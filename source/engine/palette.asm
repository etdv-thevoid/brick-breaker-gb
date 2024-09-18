INCLUDE "includes/includes.inc"


SECTION "Color Palette Functions", ROM0

/*
Sets background palette 0
*/
_LoadPalette::
    call _IsGBColor
    jr z, .monochrome

.color:
    ld hl, _DefaultPalette
    call _SetBackgroundPaletteAll
    
    ld hl, _DefaultPalette
    call _SetSpritePaletteAll

.monochrome:
    jp _SetDMGPalettesDefault


/*
Simple default palette colors

- Greyscale
- Red
- Blue
- Green
- Yellow
- Orange
- Cyan
- Magenta
*/
_DefaultPalette:
    INCLUDE "assets/palettes/default.pal"
.end:

ENDSECTION
