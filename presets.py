class Presets:
    def __init__(self, board):
        self.board = board

    def toad(self):
        true_list = [(2, 2), (3, 2), (4, 2), (1, 3), (2, 3), (3, 3)]

        for x, y in true_list:
            self.board[x][y].status = True

        return self.board
