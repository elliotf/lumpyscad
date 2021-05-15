# lumpyscad

Reusable library methods/functions/things for OpenSCAD

Inspired by https://github.com/nophead/NopSCADlib but not as well documented and not as tidy

## Installation

Clone into your OpenSCAD library path

```
$ mkdir -p ~/.local/share/OpenSCAD/libraries
$ cd ~/.local/share/OpenSCAD/libraries
$ git clone https://github.com/elliotf/lumpyscad.git
```

## Usage

You probably don't want to use this.

If you want to try it out, include it in your openscad file:

```
include <lumpyscad/lib.scad>;
```

Yes, `include` rather than `use`, because it has a number of variables that I use in my projects (left, right, front, rear, etc) that I don't like restating.
