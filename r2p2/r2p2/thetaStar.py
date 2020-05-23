""" This module implements Theta*'s path planning algorithm.

Two variants are included: grid-based, and mesh-based.

"""

__author__ = "Sergio de la Mata Moratilla; Javier Pastor Moreno"
__authors__ = ["Sergio de la Mata Moratilla; Javier Pastor Moreno"]
__contact__ = "sergio.matam@edu.uah.es; javier.pastor@edu.uah.es"
__copyright__ = "Copyright 2020, UAH"
__credits__ = ["Mario Cobos Maestre"]
__date__ = "2020/05/22"
__deprecated__ = False
__email__ =  "sergio.matam@edu.uah.es; javier.pastor@edu.uah.es"
__license__ = "GPLv3"
__maintainer__ = "Sergio de la Mata Moratilla; Javier Pastor Moreno"
__status__ = "Development"
__version__ = "0.0.1"

"""
    Code modified from https://https://github.com/ISG-UAH/R2P2
"""

import path_planning as pp

def children(point,grid):
    """
        Calculates the children of a given node over a grid.
        Inputs:
            - point: node for which to calculate children.
            - grid: grid over which to calculate children.
        Outputs:
            - list of children for the given node.
    """
    x,y = point.grid_point
    if x > 0 and x < len(grid) - 1:
        if y > 0 and y < len(grid[0]) - 1:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y),(x,y - 1),(x,y + 1),(x+1,y),\
                      (x-1, y-1), (x-1, y+1), (x+1, y-1),\
                      (x+1, y+1)]]
        elif y > 0:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y),(x,y - 1),(x+1,y),\
                      (x-1, y-1), (x+1, y-1)]]
        else:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y),(x,y + 1),(x+1,y),\
                      (x-1, y+1), (x+1, y+1)]]
    elif x > 0:
        if y > 0 and y < len(grid[0]) - 1:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y),(x,y - 1),(x,y + 1),\
                      (x-1, y-1), (x-1, y+1)]]
        elif y > 0:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y),(x,y - 1),(x-1, y-1)]]
        else:
            links = [grid[d[0]][d[1]] for d in\
                     [(x-1, y), (x,y + 1), (x-1, y+1)]]
    else:
        if y > 0 and y < len(grid[0]) - 1:
            links = [grid[d[0]][d[1]] for d in\
                     [(x+1, y),(x,y - 1),(x,y + 1),\
                      (x+1, y-1), (x+1, y+1)]]
        elif y > 0:
            links = [grid[d[0]][d[1]] for d in\
                     [(x+1, y),(x,y - 1),(x+1, y-1)]]
        else:
            links = [grid[d[0]][d[1]] for d in\
                     [(x+1, y), (x,y + 1), (x+1, y+1)]]
    return [link for link in links if link.value != 9]

def checkObst(x, y, grid):
     return (grid[int(x)][int(y)].value >= 5)

def lineOfSight(current, node, grid):
     x0, y0 = current.grid_point
     x1, y1 = node.grid_point
     difference_posx = x1 - x0
     difference_posy = y1 - y0
     f = 0
     if difference_posy < 0:
          difference_posy = - difference_posy
          s_posy = -1
     else:
          s_posy = 1
     if difference_posx < 0:
          difference_posx = - difference_posx
          s_posx = -1
     else:
          s_posx = 1
     if difference_posx >= difference_posy:
          while x0 != x1:
               f += difference_posy
               if f >= difference_posx:
                    if checkObst(x0 + ((s_posx - 1)/2), y0 + ((s_posy - 1)/2), grid):
                         return False
                    y0 = y0 + s_posy
                    f -= difference_posx
               if (f != 0) and (checkObst(x0 + ((s_posx - 1)/2), y0 + ((s_posy - 1)/2), grid)):
                    return False
               if (difference_posy == 0) and (checkObst(x0 + ((s_posx - 1)/2), y0,grid)) and (checkObst(x0 + ((s_posx - 1)/2), y0 - 1, grid)):
                    return False
               x0 += s_posx
     else:
          while y0 != y1:
               f += difference_posx
               if f >= difference_posy:
                    if checkObst(x0 + ((s_posx - 1)/2), y0 + ((s_posy - 1)/2), grid):
                         return False
                    x0 = x0 + s_posx
                    f -= difference_posx
               if (f != 0) and (checkObst(x0 + ((s_posx - 1)/2), y0 + ((s_posy - 1)/2), grid)):
                    return False
               if (difference_posy == 0) and (checkObst(x0 + ((s_posx - 1)/2), y0, grid)) and (checkObst(x0 + ((s_posx - 1)/2), y0 - 1, grid)):
                    return False
               y0 += s_posy
     return True

def thetaStar(start, goal, grid, heur='naive'):
     """
        Executes the Theta* path planning algorithm over a given grid.
        Inputs:
            - origin: node at which to start.
            - goal: node that needs to be reached.
            - grid: grid over which to execute the algorithm
            - heur: reference to a string representing an heuristic.
            Unused, kept to standarize input.
        Outputs:
            - ordered list of nodes representing the path found from
            origin to goal.
    """
     #Opened and closed sets
     opened_set = set()
     closed_set = set()
     #Current position at the starting point
     current = start
     #Introduced the starting point to the opened set
     opened_set.add(current)
     #While the opened set has nodes to be studied
     while opened_set: 
          #Search for its item with the lowest G + H value
          current = min(opened_set, key = lambda o:o.G + o.H)
          pp.expanded_nodes += 1
          # Current position is the same as the goal
          if current == goal: 
               path = []
               #Include the positions to the path until the current position has not a parent
               while current.parent: 
                    path.append(current)
                    current = current.parent
               path.append(current)
               return path[::-1]
          #Delete the item from the opened set used and introduce it to the closed set
          opened_set.remove(current)
          closed_set.add(current)
          
          #Go through the node's children/siblings
          for node in children(current, grid):
               #Skip the node if it is at the closed set 
               if node in closed_set:
                    continue
               #Verify if the node is at the opened set
               if node in opened_set:
                    #Check if the obtained G value is lower to the one from the node
                    g_aux = current.G + current.move_cost(node)
                    # New g value is lower to the one which has the node
                    if node.G > g_aux: 
                         #Update the node's parent
                         node.G = g_aux
                         node.parent = current
               else:
                    if (current.parent != None) and (lineOfSight(current.parent, node,grid)):
                         node.G = current.parent.G + current.parent.move_cost(node)
                         node.H = pp.heuristic[heur](node, goal)
                         node.parent = current.parent
                         opened_set.add(node)
                    else:
                         #Needed to be calculated the G and H values for the node studied
                         node.G = current.G + current.move_cost(node)
                         node.H = pp.heuristic[heur](node,goal)
                         #Set the parent to current studied position & include the node to the openeed set
                         node.parent = current
                         opened_set.add(node)
     #Throw an exception if there is no path
     raise ValueError('No Path Found')

pp.register_search_method('Theta*', thetaStar)
