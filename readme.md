# This project is deprecated. Please do not use

This repo contains the zone and surface files for making a Presonus FaderPort work nicely with REAPER. There are some script in here for making working on the files a bit easier.

## Start

* Fork and clone this repo. 
* Run `npm instal`, all dependencies will be added
* Copy `.env.dist` to `.env` and make the next changes:
  * Set the REAPER resource path for `REAPER_PATH`. This is used to copy the files into the correct folder after changes.
  * Set actionId of `always-on.lua` in ALWAYS_ON_ACTION. Not a must, but gives a better representation.

## Developing

* Run `npm run watch`. This will the script watch the files for changes. If a file has changed, it will be copied to the CSI folder.
* Do your thing.


