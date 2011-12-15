#!/bin/bash
echo beep.sh

beep() { $*; echo -e \\a; }
