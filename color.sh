#!/bin/bash
echo color.sh

CLR="\e[2J\e[H"

COL_ATTR=0
COL_FG=30
COL_BG=47

color() { printf "\e[${COL_BG:+$COL_BG}${COL_FG:+;$COL_FG}${COL_ATTR:+;$COL_ATTR}m"; }

attr_reset()	{ $*; COL_ATTR=0; color; COL_ATTR=; }

attr_brt()	{ COL_ATTR=1; color; $*; }
attr_dim()	{ COL_ATTR=2; color; $*; }
attr_ul()	{ COL_ATTR=4; color; $*; }
attr_blink()	{ COL_ATTR=5; color; $*; }
attr_rev()	{ COL_ATTR=7; color; $*; }
attr_hidden()	{ COL_ATTR=8; color; $*; }

fg_black()	{ COL_FG=30; color; $*; }
fg_red()	{ COL_FG=31; color; $*; }
fg_green()	{ COL_FG=32; color; $*; }
fg_yellow()	{ COL_FG=33; color; $*; }
fg_blue()	{ COL_FG=34; color; $*; }
fg_mag()	{ COL_FG=35; color; $*; }
fg_cyan()	{ COL_FG=36; color; $*; }
fg_white()	{ COL_FG=37; color; $*; }

bg_black()	{ COL_BG=40; color; $*; }
bg_red()	{ COL_BG=41; color; $*; }
bg_green()	{ COL_BG=42; color; $*; }
bg_yellow()	{ COL_BG=43; color; $*; }
bg_blue()	{ COL_BG=44; color; $*; }
bg_mag()	{ COL_BG=45; color; $*; }
bg_cyan()	{ COL_BG=46; color; $*; }
bg_white()	{ COL_BG=47; color; $*; }

all_reset()     { $*; COL_FG=30; COL_BG=47; attr_reset; }

black()		{ all_reset fg_black $*; }
red()		{ all_reset fg_red $*; }
green()		{ all_reset fg_green $*; }
yellow()	{ all_reset fg_yellow $*; }
blue()		{ all_reset fg_blue $*; }
mag()		{ all_reset fg_mag $*; }
cyan()		{ all_reset fg_cyan $*; }
white()		{ all_reset fg_white $*; }

RESET="\e[m"

loc() { printf "\e[$1;$2H"; }
erase() { printf "\e[2J"; }
eraseall() { printf "\e[3J"; }
repeat() { while echo; do $*; done; }
repeatc() { printf "\033[2J"; while printf "\033[0;0f"; do $*; done; }

