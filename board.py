from cell import Cell
from presets import Presets

# an idea to shift check status from the board to the cell is make the board a global var
# N should defo be separated into 2 distinct variables 

class Board:
    def __init__(self, gens=400, N=6):
        self.N = N
        self.gameboard = [[Cell((x, y)) for y in range(N)] for x in range(N)]
        
        # run preloaded specs here
        # this should be changed so that preset methods can work in tandem
        self.gameboard = Presets(self.gameboard).toad()

        for num_gens in range(gens):
            self.check_status()

    def get_neighbors(self, pos):
        if pos == (0, 0):
            e = self.gameboard[pos[0]][pos[1] + 1]
            g = self.gameboard[pos[0] + 1][pos[1]]
            h = self.gameboard[pos[0] + 1][pos[1] + 1]

            return [e, g, h]

        elif pos == (self.N-1, self.N-1):
            a = self.gameboard[pos[0] - 1][pos[1] - 1]
            b = self.gameboard[pos[0] - 1][pos[1]]
            d = self.gameboard[pos[0]][pos[1] - 1]

            return [a, b, d]

        elif pos == (0, self.N-1):
            d = self.gameboard[pos[0]][pos[1] - 1]
            f = self.gameboard[pos[0] + 1][pos[1] - 1]
            g = self.gameboard[pos[0] + 1][pos[1]]

            return [d, f, g]

        elif pos == (self.N-1, 0):
            b = self.gameboard[pos[0] - 1][pos[1]]
            c = self.gameboard[pos[0] - 1][pos[1] + 1]
            e = self.gameboard[pos[0]][pos[1] + 1]

            return [b, c, e]

        elif pos[0] == 0:
            d = self.gameboard[pos[0]][pos[1] - 1]
            e = self.gameboard[pos[0]][pos[1] + 1]
            f = self.gameboard[pos[0] + 1][pos[1] - 1]
            g = self.gameboard[pos[0] + 1][pos[1]]
            h = self.gameboard[pos[0] + 1][pos[1] + 1]

            return [d, e, f, g, h]

        elif pos[1] == 0:
            b = self.gameboard[pos[0] - 1][pos[1]]
            c = self.gameboard[pos[0] - 1][pos[1] + 1]
            e = self.gameboard[pos[0]][pos[1] + 1]
            g = self.gameboard[pos[0] + 1][pos[1]]
            h = self.gameboard[pos[0] + 1][pos[1] + 1]
            return [b, c, e, g, h]

        elif pos[0] == self.N-1:
            a = self.gameboard[pos[0] - 1][pos[1] - 1]
            b = self.gameboard[pos[0] - 1][pos[1]]
            c = self.gameboard[pos[0] - 1][pos[1] + 1]
            d = self.gameboard[pos[0]][pos[1] - 1]
            e = self.gameboard[pos[0]][pos[1] + 1]

            return [a, b, c, d, e]

        elif pos[1] == self.N-1:
            a = self.gameboard[pos[0] - 1][pos[1] - 1]
            b = self.gameboard[pos[0] - 1][pos[1]]
            d = self.gameboard[pos[0]][pos[1] - 1]
            f = self.gameboard[pos[0] + 1][pos[1] - 1]
            g = self.gameboard[pos[0] + 1][pos[1]]

            return [a, b, d, f, g]

        else:
            a = self.gameboard[pos[0] - 1][pos[1] - 1]
            b = self.gameboard[pos[0] - 1][pos[1]]
            c = self.gameboard[pos[0] - 1][pos[1] + 1]
            d = self.gameboard[pos[0]][pos[1] - 1]
            e = self.gameboard[pos[0]][pos[1] + 1]
            f = self.gameboard[pos[0] + 1][pos[1] - 1]
            g = self.gameboard[pos[0] + 1][pos[1]]
            h = self.gameboard[pos[0] + 1][pos[1] + 1]

            return [a, b, c, d, e, f, g, h]

    def check_status(self):
        for line in self.gameboard:
            for cell in line:
                neighbor_list = self.get_neighbors(cell.position)
                live_neighbor_count = 0

                for cell in neighbor_list:
                    if cell.status == True:
                        live_neighbor_count += 1

                if cell.status == True and live_neighbor_count < 2:
                    cell.status = False
                elif cell.status == True and (
                    live_neighbor_count == 2 or live_neighbor_count == 3
                ):
                    cell.status = True
                elif cell.status == True and live_neighbor_count > 3:
                    cell.status = False
                elif cell.status == False and live_neighbor_count == 3:
                    cell.status = True
