from dataclasses import dataclass

@dataclass
class Cell:
    position: tuple
    status: bool = False
