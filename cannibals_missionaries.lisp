
(defstruct problem
  "A problem is defined by the initial state, and the type of problem it is."
  (initial-state (required)) ; A state in the domain
  (goal nil)                 ; Optionally store the desired state here.
  (num-expanded 0)           ; Number of nodes expanded in search for solution.
  (iterative? nil)           ; Are we using an iterative algorithm?
)

(defstruct (cannibal-problem 
	       (:include problem (initial-state (make-cannibal-state))))
) 

(defmethod goal-test ((problem cannibal-problem) state)
  "The goal is to move all missionaries and cannibals to the other(second) side.
  It means no missionaries and cannibals on the first side"
  (= 0 (m1 state) (c1 state))
)

(defmethod successors ((problem cannibal-problem) state)
  "Return a list of (action . state) pairs. An action is a triple of the
  form (delta-m delta-c delta-b), where a positive delta means to move from
  side 1 to side 2; negative is the opposite.  For example, the action (+3 +3 +1)
  means move 3 missionaries, 3 cannibals, and 1 boat from side 1 to side 2."
  (let ((pairs nil))
   (dolist (action '(
        ;possible actions from side1 to side2
        (+1 0 +1) (0 +1 +1) (+2 0 +1) (0 +2 +1) (+1 +1 +1) ;1 or 2 people crossing
        (+3 0 +1) (0 +3 +1) (+2 +1 +1) (+1 +2 +1) ;3 people crossing  
        (+4 0 +1) (0 +4 +1) (+3 +1 +1) (+1 +3 +1) (+2 +2 +1) ;4 people crossing
        (+5 0 +1) (0 +5 +1) (+4 +1 +1) (+1 +4 +1) (+3 +2 +1) (+2 +3 +1) ;5 people crossing
        (+6 0 +1) (0 +6 +1) (+5 +1 +1) (+1 +5 +1) (+4 +2 +1) (+2 +4 +1) (+3 +3 +1) ;6 people crossing
        ;possible actions from side2 to side1
        (-1 0 -1) (0 -1 -1) (-2 0 -1) (0 -2 -1) (-1 -1 -1) ;1 or 2 people crossing
        (-3 0 -1) (0 -3 -1) (-2 -1 -1) (-1 -2 -1) ;3 people crossing  
        (-4 0 -1) (0 -4 -1) (-3 -1 -1) (-1 -3 -1) (-2 -2 -1) ;4 people crossing
        (-5 0 -1) (0 -5 -1) (-4 -1 -1) (-1 -4 -1) (-3 -2 -1) (-2 -3 -1) ;5 people crossing
        (-6 0 -1) (0 -6 -1) (-5 -1 -1) (-1 -5 -1) (-4 -2 -1) (-2 -4 -1) (-3 -3 -1) ;6 people crossing
        )) 
            (let ((new-state (take-the-boat state action)))
            (when (and new-state (not (cannibals-can-eat? new-state)))
                (push (cons action new-state) pairs))))
            pairs)
)

(defstruct (cannibal-state (:conc-name nil) (:type list))
  "The state says how many missionaries, cannibals, and boats on each
  side.  The components m1,c1,b1 stand for the number of missionaries,
  cannibals and boats, respectively, on the first side of the river.
  The components m2,c2,b2 are for the other side of the river."
  ;initializing to 15 missionaries and 15 cannibals
  (m1 15) (c1 15) (b1 1) (m2 0) (c2 0) (b2 0)
)

(defun take-the-boat (state action)
  "Move a certain number of missionaries, cannibals, and boats (if possible)."
  (destructuring-bind (delta-m delta-c delta-b) action
    (if (or (and (= delta-b +1) (> (b1 state) 0))
	    (and (= delta-b -1) (> (b2 state) 0)))
	(let ((new (copy-cannibal-state state)))
	  (decf (m1 new) delta-m) (incf (m2 new) delta-m)
	  (decf (c1 new) delta-c) (incf (c2 new) delta-c)
	  (decf (b1 new) delta-b) (incf (b2 new) delta-b)
	  (if (and (>= (m1 new) 0) (>= (m2 new) 0)
		   (>= (c1 new) 0) (>= (c2 new) 0))
	      new
	    nil))
      nil))
)

(defun cannibals-can-eat? (state)
  "The cannibals feast if they outnumber the missionaries on either side."
  (or (> (c1 state) (m1 state) 0)
      (> (c2 state) (m2 state) 0))
)

(defmethod h-cost ((problem cannibal-problem) state) 
  ( / (+ (m1 state) (c1 state)) 2 ) ;h cost defined as number of people on side1 / 2
)

(defmethod edge-cost ((problem cannibal-problem) node action state)
  "edge cost is 1"
  1
)

(defstruct node
  "Node for generic search.  A node contains a state, a domain-specific
  representation of a point in the search space.  A node also contains 
  bookkeeping information such as the cost so far (g-cost) and estimated cost 
  to go (h-cost)"
  (state (required))        ; a state in the domain
  (parent nil)              ; the parent node of this node
  (action nil)              ; the domain action leading to state
  (successors nil)          ; list of sucessor nodes
  (unexpanded nil)          ; successors not yet examined (SMA* only)
  (depth 0)                 ; depth of node in tree (root = 0)
  (g-cost 0)                ; path cost from root to node
  (h-cost 0)                ; estimated distance from state to goal
  (f-cost 0)                ; g-cost + h-cost
  (expanded? nil)           ; any successors examined?
)

(defun expand (node problem)
  "Generate a list of all the nodes that can be reached from a node."
  ;; Note the problem's successor-fn returns a list of (action . state) pairs.
  ;; This function turns each of these into a node.
  ;; If a node has already been expanded for some reason, then return no nodes,
  ;; unless we are using an iterative algorithm.
  (unless (and (node-expanded? node) (not (problem-iterative? problem)))
    (setf (node-expanded? node) t)
    (incf (problem-num-expanded problem))
    (let ((nodes nil))
      (dolist (x (successors problem (node-state node)))
	   (let* ((g (+ (node-g-cost node) 
			(edge-cost problem node (car x) (cdr x))))
		  (h (h-cost problem (cdr x))))
	     (push
	      (make-node 
	       :parent node :action (car x) :state (cdr x)
	       :depth (1+ (node-depth node)) :g-cost g :h-cost h
	       ;; use the pathmax equation [p 98] for f:
	       :f-cost (max (node-f-cost node) (+ g h)))
	      nodes)))
      nodes))
)

(defun create-start-node (problem)
  "Make the starting node, corresponding to the problem's initial state."
  (let ((h (h-cost problem (problem-initial-state problem))))
    (make-node :state (problem-initial-state problem)
	       :h-cost h :f-cost h))
)

(defun solution-actions (node &optional (actions-so-far nil))
  "Return a list of actions that will lead to the node's state."
  (cond ((null node) actions-so-far)
	((null (node-parent node)) actions-so-far)
	(t (solution-actions (node-parent node)
			     (cons (node-action node) actions-so-far))))
)

(defun solution-nodes (node &optional (nodes-so-far nil))
  "Return a list of the nodes along the path to the solution."
  (cond ((null node) nodes-so-far)
	(t (solution-nodes (node-parent node)
			   (cons node nodes-so-far))))
)

(defun solve (problem &optional (algorithm))
  "Print a list of actions that will solve the problem (if possible).
  Return the node that solves the problem, or nil."
  (setf (problem-num-expanded problem) 0)
  (let ((node (funcall algorithm problem)))
    (print-solution problem node)
  )
)

(defun print-solution (problem node)
  "Print a table of the actions and states leading up to a solution."
  (if node
      (format t "~&Action ~20T State~%====== ~20T =====~%")
    (format t "~&No solution found.~&"))
  (dolist (n (solution-nodes node))
       (format t "~&~A ~20T ~A~%"
	       (or (node-action n) "") (node-state n)))
  (format t "====== ~20T =====~%Total of ~D node~:P expanded."
	  (problem-num-expanded problem))
)

(defun tree-ida*-search (problem)
  "Iterative Deepening Tree-A* Search"
  ;; The main loop does a series of f-cost-bounded depth-first
  ;; searches until a solution is found. After each search, the f-cost
  ;; bound is increased to the smallest f-cost value found that
  ;; exceeds the previous bound.
  (setf (problem-iterative? problem) t)
  (let* ((root (create-start-node problem))
	 (f-limit (node-f-cost root))
	 (solution nil))
    (loop (multiple-value-setq (solution f-limit)
	    (DFS-contour root problem f-limit))
        ;(format t "DFS-contour returned ~S at ~F" solution f-limit)
	(if (not (null solution)) (RETURN solution))
	(if (= f-limit 10000000) (RETURN nil))))
)

(defun DFS-contour (node problem f-limit)
  "Return a solution and a new f-cost limit."
  (let ((next-f 10000000))
    (cond ((> (node-f-cost node) f-limit)
	   (values nil (node-f-cost node)))
	  ((goal-test problem (node-state node))
	   (values node f-limit))
	  (t (dolist (s (expand node problem))
		  (multiple-value-bind (solution new-f)
		      (DFS-contour s problem f-limit)
		    (if (not (null solution))
			(RETURN-FROM DFS-contour (values solution f-limit)))
		    (setq next-f (min next-f new-f))))
	     (values nil next-f))))
)

(setf problem1 (make-cannibal-problem :goal '(0 0 0 15 15 1)))
(setf problem2 (make-cannibal-problem :initial-state '(20 20 1 0 0 0) :goal '(0 0 0 20 20 1)))
