Tests:
======

To run tests, just type 'rake'


Example Usage:
===============

```shell
$ ./game.rb examples/80_by_40.txt
```

to run the simulation without display (only show the generation count at game end), use the -s switch:

```shell
$ ./game.rb examples/80_by_40.txt -s
```

to run the simulation without cycle detection (don't stop if the pattern repeats), use the -C switch:

```shell
$ ./game.rb examples/80_by_40.txt -C
```

Instructions:
=============

Your task is to write a program to calculate the next
generation of Conway's game of life, given any starting
position. You start with a two dimensional grid of cells,
where each cell is either alive or dead. The grid is finite,
and no life can exist off the edges. When calculating the
next generation of the grid, follow these four rules:

1. Any live cell with fewer than two live neighbours dies,
   as if caused by underpopulation.
2. Any live cell with more than three live neighbours dies,
   as if by overcrowding.
3. Any live cell with two or three live neighbours lives
   on to the next generation.
4. Any dead cell with exactly three live neighbours becomes
   a live cell.

Examples: * indicates live cell, . indicates dead cell

Example input: (4 x 8 grid)
```pre
--------
----@---
---@@---
--------
```

Example output:
```pre
--------
---@@---
---@@---
--------
```
