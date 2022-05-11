#!/bin/bash
cd ~/Library/Developer/CoreSimulator/Devices/
cd `ls -t | head -n 1`/data/Containers/Data/Application/
cd `ls -t | head -n 1`
open .