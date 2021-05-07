# Conway's Game of Life

Conway's Game is a zero-player one, we can only influence the starting state
The rules of the game are quite simple (from wikipedia):
  1. Any live cell with 2 or 3 live neighbors survives
  2. Any dead cell with 3 live neighbors becomes a live cell
  3. All other live cells die in the next generation. Similarly, all other dead cells stay dead
  
Here are some additional links to help get you up to speed on the concept:
  1. [Try Conway's Game online](https://conwaylife.appspot.com)
  2. [Conway's Game of Life on Wikipedia](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
  3. [An Introduction to Conway's Game of Life](https://www.youtube.com/watch?v=ouipbDkwHWA)

### To-do:
  1. Create a vizualizer (either in pygame or tkinter)
  2. Move the `check_status()` function from the board class to the cell class (should improve efficiency at massive scale)
  3. Create as many presets as possible and maybe even move the board generation into presets
  
