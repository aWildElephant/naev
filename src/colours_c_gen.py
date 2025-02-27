#!/usr/bin/env python3

def gammaToLinear(x):
    if x <= 0.04045:
        return x / 12.92
    return pow((x + 0.055) / 1.055, 2.4)

class Colour:
    def __init__(self, name, r, g, b, a=1.0):
        self.name = name
        self.r = gammaToLinear( r )
        self.g = gammaToLinear( g )
        self.b = gammaToLinear( b )
        self.a = a

    def write_header(self, f):
        f.write(f"extern const glColour c{self.name};\n")

    def write_source(self, f):
        f.write(f"const glColour c{self.name} = {{ .r={self.r}, .g={self.g}, .b={self.b}, .a={self.a} }};\n")


COLOURS = [
    Colour( "White",  1.00, 1.00, 1.00 ),
    Colour( "Grey90", 0.90, 0.90, 0.90 ),
    Colour( "Grey80", 0.80, 0.80, 0.80 ),
    Colour( "Grey70", 0.70, 0.70, 0.70 ),
    Colour( "Grey60", 0.60, 0.60, 0.60 ),
    Colour( "Grey50", 0.50, 0.50, 0.50 ),
    Colour( "Grey45", 0.45, 0.45, 0.45 ),
    Colour( "Grey40", 0.40, 0.40, 0.40 ),
    Colour( "Grey35", 0.35, 0.35, 0.35 ),
    Colour( "Grey30", 0.30, 0.30, 0.30 ),
    Colour( "Grey25", 0.25, 0.25, 0.25 ),
    Colour( "Grey20", 0.20, 0.20, 0.20 ),
    Colour( "Grey15", 0.15, 0.15, 0.15 ),
    Colour( "Grey10", 0.10, 0.10, 0.10 ),
    Colour( "Grey5",  0.05, 0.05, 0.05 ),
    Colour( "Black",  0.00, 0.00, 0.00 ),

    # Greens
    Colour( "DarkGreen",    0.10, 0.50, 0.10 ),
    Colour( "Green",        0.20, 0.80, 0.20 ),
    Colour( "PrimeGreen",   0.00, 1.00, 0.00 ),
    # Reds
    Colour( "DarkRed",      0.60, 0.10, 0.10 ),
    Colour( "Red",          0.80, 0.20, 0.20 ),
    Colour( "PrimeRed",     1.00, 0.00, 0.00 ),
    Colour( "BrightRed",    1.00, 0.60, 0.60 ),
    # Oranges
    Colour( "Orange",       0.90, 0.70, 0.10 ),
    # Yellows
    Colour( "Gold",         1.00, 0.84, 0.00 ),
    Colour( "Yellow",       0.80, 0.80, 0.00 ),
    # Blues
    Colour( "MidnightBlue", 0.10, 0.10, 0.4 ),
    Colour( "DarkBlue",     0.10, 0.10, 0.60 ),
    Colour( "Blue",         0.20, 0.20, 0.80 ),
    Colour( "LightBlue",    0.40, 0.40, 1.00 ),
    Colour( "PrimeBlue",    0.00, 0.00, 1.00 ),
    Colour( "Cyan",         0.00, 1.00, 1.00 ),
    # Purples.
    Colour( "Purple",       0.90, 0.10, 0.90 ),
    Colour( "DarkPurple",   0.68, 0.18, 0.64 ),
    # Browns.
    Colour( "Brown",        0.59, 0.28, 0.00 ),
    # Misc.
    Colour( "Silver",       0.75, 0.75, 0.75 ),
    Colour( "Aqua",         0.00, 0.75, 1.00 ),

    Colour( "BlackHilight", 0.0, 0.0, 0.0, 0.4 ), # Hilight colour over black background

    # Outfit slot colours
    # Taken from https://cran.r-project.org/web/packages/khroma/vignettes/tol.html#muted
    Colour( "OutfitHeavy",  0.8, 0.4, 0.46 ),
    Colour( "OutfitMedium", 0.2, 0.73, 0.93 ),
    #Colour( "OutfitMedium", 0.55, 0.8, 0.93 ),
    Colour( "OutfitLight",  0.86, 0.8, 0.46 ),
    # Objects
    Colour( "Inert",        221./255., 221./255., 221./255. ),
    Colour( "Neutral",      221./255., 204./255., 119./255. ),
    Colour( "Friend",        68./255., 170./255., 153./255. ),
    Colour( "Hostile",      170./255.,  68./255., 153./255. ),
    Colour( "Restricted",   153./255., 153./255.,  51./255. ),
    # Mission Markers
    Colour( "MarkerNew",        154./255., 112./255., 158./255. ),
    Colour( "MarkerComputer",   208./255., 231./255., 202./255. ),
    Colour( "MarkerLow",        234./255., 240./255., 181./255. ),
    Colour( "MarkerHigh",       252./255., 247./255., 213./255. ),
    Colour( "MarkerPlot",       255./255., 255./255., 255./255. ),
    # Radar
    Colour( "Radar_player",     0.9, 0.1, 0.9 ),
    Colour( "Radar_tPilot",     1.0, 1.0, 1.0 ),
    Colour( "Radar_tPlanet",    1.0, 1.0, 1.0 ),
    Colour( "Radar_weap",       0.8, 0.2, 0.2 ),
    Colour( "Radar_hilight",    0.6, 1.0, 1.0 ),
    # Health
    Colour( "Shield",       0.2, 0.2, 0.8 ),
    Colour( "Armour",       0.5, 0.5, 0.5 ),
    Colour( "Energy",       0.2, 0.8, 0.2 ),
    Colour( "Fuel",         0.9, 0.1, 0.4 ),

    # Deiz's Super Font Palette
    Colour( "FontRed",      1.0, 0.4, 0.4 ),
    Colour( "FontGreen",    0.6, 1.0, 0.4 ),
    Colour( "FontBlue",     0.4, 0.6, 1.0 ),
    Colour( "FontYellow",   1.0, 1.0, 0.5 ),
    Colour( "FontGrey",     0.7, 0.7, 0.7 ),
    Colour( "FontPurple",   1.0, 0.3, 1.0 ),
    Colour( "FontOrange",   1.0, 0.7, 0.3 ),
    Colour( "FontWhite",    0.95, 0.95, 0.95 ),
]

def write_header(f):
    f.write(f"/* FILE GENERATED BY {__file__} */")

def generate_h_file(f):
    write_header(f)

    f.write("""
#ifndef COLOURS_GEN_C_H
#define COLOURS_GEN_C_H

""")
    for col in COLOURS:
        col.write_header( f )
    f.write("""
const glColour* col_fromName( const char* name );

#endif /* SHADERS_GEN_C_H */""")

def generate_c_file(f):
    write_header(f)

    f.write("""
#include <string.h>
#include "colour.h"
#include "log.h"

""")
    for col in COLOURS:
        col.write_source( f )
    f.write("""
const glColour* col_fromName( const char* name )
{
""")
    for col in COLOURS:
        f.write(f"   if (strcasecmp(name,\"{col.name}\")==0) return &c{col.name};\n")
    f.write("""
   WARN(_("Unknown colour '%s'!"),name);
   return NULL;
}""")

with open("colours.gen.h", "w") as colours_ggen_h:
    generate_h_file(colours_ggen_h)

with open("colours.gen.c", "w") as colours_ggen_c:
    generate_c_file(colours_ggen_c)
