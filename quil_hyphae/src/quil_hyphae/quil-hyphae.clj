(ns quil-hyphae.core
  (:require [quil.core :as q]
            [quil.middleware :as m]))

; PARAMETERS
(def bg-color [255 255 255])
(def max-level 500)
(def min-width 1)
(def threshold-p 9)
(def p-branch-l 0.3)
(def p-branch-s 0.15)
(def dist 0.5)
(def threshold-wid 10)
(def b-wred-l 0.6)
(def b-wred-s 0.9)
(def branch-split-angle (/ q/PI 3))
(def wiggle 0.3)
(def start-width 13)

; (def bg-color (q/color 255 0 0)) this doesn't works

(def empty-hyphae '())
(defn stack-push [stack x]
  (conj stack x))
(defn stack-head [stack]
  (first stack))
; equivelent with the core (pop hyphae)
(defn stack-pop [stack]
  (drop 1 stack))

;(stack-push hyphae 7)
;(stack-head hyphae)
;(stack-pop hyphae)
    


(defn generate-on-node [p]

  (if (or (> (p :level) max-level)
          (> (p :x) (q/width)) (< (p :x) 0)
          (> (p :y) (q/height)) (< (p :y) 0)
          (<= (p :width) min-width))
    ; return parent keep child and branch as nil 
    ; if exceed max level or out of bond or stroke is too thin
    p
    
    (if (<= (rand 1)
            (if (< (p :width) threshold-p) p-branch-s p-branch-l))
      ; create a new branch
      (merge p (let [b-delta (* branch-split-angle (rand-nth [1 -1]))
                     ; this is clearly not a optimized way 
                     ; the java version is just "brD = d + brDelta + random (-wi, wi)"
                     d-branch (+ (p :direction) b-delta (q/random (p :wiggle) (- (p :wiggle))))
                     d-child (+ (- (p :direction) b-delta) (q/random (p :wiggle) (- (p :wiggle))))]
                 {:branch {:direction d-branch
                           :width (* (p :width) (if (> (p :width) threshold-wid) b-wred-l b-wred-s)) 
                           :x (+ (p :x) (* (q/cos d-branch) (p :width) dist))
                           :y (+ (p :y) (* (q/sin d-branch) (p :width) dist))
                           :wiggle (p :wiggle)
                           :level (inc (p :level))
                           :child nil
                           :branch nil
                           :parent p}
                  :child {:direction d-child
                          :width (* (p :width) (if (> (p :width) threshold-wid) b-wred-l b-wred-s))
                          :x (+ (p :x) (* (q/cos d-child) (p :width) dist))
                          :y (+ (p :y) (* (q/sin d-child) (p :width) dist))
                          :wiggle (p :wiggle)
                          :level (inc (p :level))
                          :child nil
                          :branch nil
                          :parent p}}))
      ; no new branch
      (merge p (let [d-child (+ (p :direction) (q/random (p :wiggle) (- (p :wiggle))))]
              {:child {:direction d-child
                        :width (p :width)
                        :x (+ (p :x) (* (q/cos d-child) (p :width) dist))
                        :y (+ (p :y) (* (q/sin d-child) (p :width) dist))
                        :wiggle (p :wiggle)
                        :level (inc (p :level))
                        :child nil
                        :branch nil
                        :parent p}})))))


(defn show-node [node]
  (q/stroke 0)
  (q/stroke-weight (node :width))
  (if (nil? (node :parent))
    (q/point (node :x) (node :y))
    (let [p (node :parent)]
      (q/line (p :x) (p :y) (node :x) (node :y)))))


(defn setup []
  (q/frame-rate 1)

  (def root-1 {:direction 0
               :width start-width
               :x (* (q/width) 0.5)
               :y (* (q/height) 0.5)
               :wiggle wiggle
               :level 0
               :child nil
               :branch nil
               :parent nil})
  {:stack (stack-push empty-hyphae root-1)
   :length 1})


(defn update-state [state]
  (let [cur-node (generate-on-node (stack-head (state :stack)))]
    (println cur-node) 
    ; maybe use -> ?
    ; what should be plugin at (state :stack)
    {:stack (stack-pop (when (not (nil? (cur-node :child)))
                         (stack-push (when (not (nil? (cur-node :branch)))
                                       (stack-push (state :stack) (cur-node :branch))) (cur-node :child))))
     :length (inc (state :length))}))


(defn draw-state [state]
  (println state)
  (when (> (state :length ) 5) q/no-loop)
  ;(q/background bg-color) this doesn't works
  (apply q/background bg-color)
  (let [cur-node (stack-head (state :stack))]
    (show-node cur-node)
  )
)
  

(q/defsketch quil-hyphae
  :title "Quil Hyphae"
  :size [500 500] 
  :setup setup
  :update update-state
  :draw draw-state
  :features [:keep-on-top]
  :middleware [m/fun-mode])
