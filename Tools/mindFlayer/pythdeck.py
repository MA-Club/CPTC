import collections      # start with collections

Card = collections.namedtuple('Card', ['rank', 'suit'])         # names card, subset rank & suit

class FrenchDeck:
    ranks = [str(n) for n in range(1, 11)] + list('JQKA')       # string of 1-10, joker queen king ace 
    suits = 'spades diamonds clubs hearts'.split()              # splits into 4 suits

    def __init__(self):                                         # assigns each card a suit
        self._cards = [Card(rank, suit) for suit in self.suits
        for rank in self.ranks]
    def __len__(self):                                          # assigns each card a number(length)
        return len(self._cards)
    def __getitem__(self, position):                            # assigns them as number, suit
        return self._cards[position]
deck = FrenchDeck()                         # defines as frenchdeck

while True:    
    choose = input("Random or All Cards? ")
    if choose == 'Random':
            from random import choice       # imports random to roll the dice without input
            print(choice(deck))             # prints random
    elif choose == 'All Cards':
        for card in deck:                   # calls all values
            print(card)                     # prints all values
    else:
        print("pls no steppy :(")           # set to only two valid strings. all other dump a
                                            # no steppy.