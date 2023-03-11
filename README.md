# Missionaries-and-Cannibals
A lisp program that uses an iteratively deepening Tree-A* search algorithm to solve the 'Missionaries and Cannibals' problem.

Description: The program uses an iteratively deepening Tree-A* search algorithm to solve the problem. The algorithm takes a problem struct which is defined by its initial state and type. There are additional functions and structs such as node, expand, successors etc. Successors function returns an action-state pair given a state. This is used in expand function which generates the nodes that can be reached from a specific node. Nodes hold state, parent, action, g-cost (cost so far), h-cost (estimated cost to goal), f-cost (h + g) information. The algorithm decides what nodes to expand based on f-cost. Lastly, Solve function is used in order to print the state and actions that lead to the solution node neatly.

Problem1 and Problam2 are defined inside the program where Problem1is 15 missionaries 15 cannibals case, and Problem2 is 20 missionaries 20 cannibals case.

To run: (solve problem1 #'tree-ida*-search)
(solve problem1 #'tree-ida*-search)

To view solution node: (tree-ida*-search problem1)
(tree-ida*-search problem2)

Terminal session output:
[1]> (load "cannibals_missionaries.lisp")
;; Loading file cannibals_missionaries.lisp ...
;; Loaded file cannibals_missionaries.lisp
#P"/Users/yusufcavus/Desktop/cannibals_missionaries.lisp"
[2]> (solve problem1 #'tree-ida*-search)
Action State
====== =====
(15 15 1 0 0 0)
(0 5 1) (15 10 0 0 5 1)
(0 -1 -1) (15 11 1 0 4 0)
(5 1 1) (10 10 0 5 5 1)
(-1 -1 -1) (11 11 1 4 4 0)
(3 3 1) (8 8 0 7 7 1)
(-1 -1 -1) (9 9 1 6 6 0)
(3 3 1) (6 6 0 9 9 1)
(-1 -1 -1) (7 7 1 8 8 0)
(3 3 1) (4 4 0 11 11 1)
(-1 -1 -1) (5 5 1 10 10 0)
(5 0 1) (0 5 0 15 10 1)
(0 -1 -1) (0 6 1 15 9 0)
(0 5 1) (0 1 0 15 14 1)
(-1 0 -1) (1 1 1 14 14 0)
(1 1 1) (0 0 0 15 15 1)
====== =====
Total of 91 nodes expanded.
NIL
[3]> (solve problem2 #'tree-ida*-search)
Action State
====== =====
(20 20 1 0 0 0)
(0 5 1) (20 15 0 0 5 1)
(0 -1 -1) (20 16 1 0 4 0)
(5 1 1) (15 15 0 5 5 1)
(-1 -1 -1) (16 16 1 4 4 0)
(3 3 1) (13 13 0 7 7 1)
(-1 -1 -1) (14 14 1 6 6 0)
(3 3 1) (11 11 0 9 9 1)
(-1 -1 -1) (12 12 1 8 8 0)
(3 3 1) (9 9 0 11 11 1)
(-1 -1 -1) (10 10 1 10 10 0)
(3 3 1) (7 7 0 13 13 1)
(-1 -1 -1) (8 8 1 12 12 0)
(3 3 1) (5 5 0 15 15 1)
(-1 -1 -1) (6 6 1 14 14 0)
(6 0 1) (0 6 0 20 14 1)
(0 -1 -1) (0 7 1 20 13 0)
(0 4 1) (0 3 0 20 17 1)
(0 -1 -1) (0 4 1 20 16 0)
(0 4 1) (0 0 0 20 20 1)
====== =====
Total of 355 nodes expanded.
NIL
