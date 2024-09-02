globals [
  red-food-count       ;; Used to count how successful the red ants are
  yellow-food-count    ;; Used to count how successful the yellow ants are
]


patches-own [
  chemical             ;; amount of chemical on this patch
  chemical-2           ;; amount of chemical-2 on this patch
  food                 ;; amount of food on this patch (0, 1, or 2)
  nest?                ;; true on nest patches, false elsewhere
  nest2?               ;; true on second nest patches, false elsewhere
  nest-scent           ;; number that is higher closer to the nest
  nest-scent-2         ;; number that is higher closer to the second nest
  food-source-number   ;; number (1, 2, or 3) to identify the food sources
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape turtles "bug"
  setup-patches
  reset-ticks

end


to setup-patches
  setup-nest

  create-circle
  ask patches [
    recolor-patch

  ]

end

to setup-nest  ;; patch procedure

  ;; Sets up random coordinates for the nest locations
  let centerX random-xcor
  let centerY random-ycor
  let centerX2 random-xcor
  let centerY2 random-ycor


  ;; Creates first nest and population
  ask patches[
    set nest? (distancexy centerX centerY) < 4
  ;; spread a nest-scent over the whole world -- stronger near the nest
    set nest-scent 200 - distancexy centerX centerY

  ]

  create-turtles population
  [ set size 2         ;; easier to see
    set color red
    setxy centerX centerY ]   ;; red = not carrying food

  ;; Creates second nest and population
  ask patches[
    set nest2? (distancexy centerX2 centerY2) < 4
  ;; spread a second different nest-scent over the whole world -- stronger near the second nest
    set nest-scent-2 200 - distancexy centerX2 centerY2
  ]

  create-turtles population-2
  [ set size 2         ;; easier to see
    set color yellow
    setxy centerX2 centerY2]   ;; yellow = not carrying food


end

to create-circle
  ;; Decide how big food spots should be, and sets up random coordinates to decide where to place them.
  let radius 6
  let centerX random-xcor  ; Random X-coordinate for the center of the circle
  let centerY random-ycor  ; Random Y-coordinate for the center of the circle
  let centerX2 random-xcor  ; Random X-coordinate for the center of the circle
  let centerY2 random-ycor  ; Random Y-coordinate for the center of the circle
  let centerX3 random-xcor  ; Random X-coordinate for the center of the circle
  let centerY3 random-ycor  ; Random Y-coordinate for the center of the circle
  let centerX4 random-xcor  ; Random X-coordinate for the center of the circle (optional unused)
  let centerY4 random-ycor  ; Random Y-coordinate for the center of the circle (optional unused)
  let num 1


;; First food patch
  ask patches [
      if distanceXY centerX centerY <= radius [
        set food-source-number num
        if food-source-number > 0
        [ set food one-of [1 2 3] ]
        recolor-patch

    ]

  ]



;; Second food patch
  ask patches [
      if distanceXY centerX2 centerY2 <= radius [
        set food-source-number (num + 1)
        if food-source-number > 0
        [ set food one-of [1 2 3] ]
        recolor-patch

    ]

  ]



;; Third food patch
  ask patches [
      if distanceXY centerX3 centerY3 <= radius [
        set food-source-number (num + 2)
        if food-source-number > 0
      [ set food one-of [1 2 3] ]
        recolor-patch

    ]

  ]


end



;; patch procedure
to recolor-patch

  ;; give color to nest and food sources
  ifelse nest?
  [ set pcolor violet ]
  [ ifelse nest2? ;; For second nest
    [ set pcolor magenta ]
    [ ifelse food > 0
      [ if food-source-number = 1 [ set pcolor cyan ]
        if food-source-number = 2 [ set pcolor sky  ]
        if food-source-number = 3 [ set pcolor blue ]
        if food-source-number = 4 [ set pcolor green ]  ;; Unused fourth nest (optional)
      ]
      ;; scale color to show chemical concentration
      [ ifelse chemical > 1
        [ set pcolor scale-color green chemical 0.5 5 ] ;; Shows first chemcial
        [ set pcolor scale-color blue chemical-2 0.5 5 ] ;; Shows chemical-2
      ]
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures for ALL ants ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go  ;; forever button



  ask turtles with [color = red or color = orange + 1] ;; Decides how the red and orange ants move
  [
    ifelse color = red
    [ look-for-food  ]       ;; not carrying food? look for it
    [return-to-nest ]       ;; carrying food? take it back to nest
    wiggle
    fd 1 ]

    ;; Decides whether to check to see if a red ant should die based on death-timer slider and if death-timer-red-affected? has been set to True
    if ticks mod death-timer-red-ants = 0 and death-timer-red-affected? = True [
    let last-red-food-count red-food-count

    ;; If this comes out to true, we should then find a red ant and check to see if there are any ants of this type left
    if red-food-count = last-red-food-count [

      ;; This will execute if red-food-count hasn't increased in death-timer ticks
      let red-ant one-of turtles with [color = red]

      ;; If ants of this type are left, then we let one die. Otherwise, we do nothing.
      ifelse red-ant != nobody [
        ask red-ant [die]
      ] [

      ]
    ]
  ]

  diffuse chemical (diffusion-rate / 100) ;; Then diffuse chemical
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch
    ]





  ask turtles with [color = yellow or color = lime + 1] ;; Decides how the yellow and lime ants move
  [
    ;; Adjust behavior based on aggression level
    ;; If aggression level is higher than a random number between 0 and 100, behave aggressively
    ifelse aggression >= random 100 [
      ;; Do not act aggressively if lime colored, just find nest
      ifelse color = lime + 1 [
        look-for-food-nest-2
        return-to-nest-2
        wiggle-2
      ]
      [

        ;; Otherwise, if the number of ticks is right, act agressive (made to make ants act less aggressive at lower aggression levels, to "scale" things more properly)
        ifelse ticks mod 10 = 0 [
          aggressive-behavior
        ] [
          ;; Otherwise, just look for food
          look-for-food-nest-2
          wiggle-2
        ]
      ]
    ]
    [
    ;; Otherwise, behave normally
    ifelse color = yellow [
      look-for-food-nest-2
    ] [
      return-to-nest-2
    ]
    wiggle-2

   ]
]

  ;; Decides whether to check to see if a yellow ant should die based on death-timer slider
  if ticks mod death-timer = 0 [

    let last-yellow-food-count yellow-food-count

    ;; If this comes out to true, we should then find a yellow ant and check to see if there are any ants of this type left
    if yellow-food-count = last-yellow-food-count [

      ;; This will execute if yellow-food-count hasn't increased in death-timer ticks
      let yellow-ants one-of turtles with [color = yellow]
      ;; If ants of this type are left, then we let one die. Otherwise, we do nothing.
      ifelse yellow-ants != nobody [
        ask yellow-ants [die]
      ] [

      ]
    ]
  ]


diffuse chemical-2 (diffusion-rate / 100) ;; Then diffuse second chemical
ask patches
[ set chemical-2 chemical-2 * (100 - evaporation-rate) / 100  ;; slowly evaporate second chemical
  recolor-patch
]

tick ;; Make time pass

;; Then decide if we need to reset the setup and go process again
if ticks >= ticks-till-reset
  [setup
   go]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Red/orange ant Go procedures ONLY;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; red/orange turtle procedure
to return-to-nest
  ifelse nest?
  [ ;; drop food and head out again
    set red-food-count red-food-count + 1
    set color red
    rt 180 ]
  [ set chemical chemical + 60  ;; drop some chemical
    uphill-nest-scent ]         ;; head toward the greatest value of nest-scent
end




;; red/orange turtle procedure
to look-for-food
  if food > 0
  [ set color orange + 1     ;; pick up food
    set food food - 1        ;; and reduce the food source
    rt 180                   ;; and turn around
    stop ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 0.05) and (chemical < 2)
  [ uphill-chemical ]
end




;; red/orange turtle procedure
;; sniff left and right, and go where the strongest smell is
to uphill-chemical  ;; turtle procedure
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end




;; red/orange turtle procedure
;; sniff left and right, and go where the strongest smell is
to uphill-nest-scent
  let scent-ahead nest-scent-at-angle   0
  let scent-right nest-scent-at-angle  45
  let scent-left  nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end



;; red/orange turtle procedure
to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent] of p
end




;; red/orange turtle procedure
to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end



;; red/orange turtle procedure
to wiggle
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Yellow/Lime ant Go procedures ONLY;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to-report get-red-orange-ants-locations
  let red-orange-ants-locations []

  ;; Gets a list with the x and y-coordinates of all red/orange ants, then returns it after
  ask turtles with [color = red or color = orange + 1]
  [
    set red-orange-ants-locations lput list xcor ycor red-orange-ants-locations
  ]
  report red-orange-ants-locations
end


;; turtle procedure for yellow/lime ants
to-report find-ant [red-orange-locations]
  if empty? red-orange-locations [ ;; Are there no red ants? If yes, give an empty list so no runtime error occurs
    report []
  ]

  ;; If no, go through each x and y-coordinate, find an ant which is closest to you.
  let closest-x item 0 item 0 red-orange-locations
  let closest-y item 1 item 0 red-orange-locations
  let my-xcor xcor
  let my-ycor ycor

  let i 0

  ;; Goes through each red/orange ant to see which one is closest to current yellow ant following instructions.
  foreach red-orange-locations [

    let current-x item 0 item i red-orange-locations
    let current-y item 1 item i red-orange-locations

    if (my-xcor - current-x)  < (my-xcor - closest-x) [
      if (my-ycor - current-y) <= (my-ycor - closest-y)
      [
      set closest-x current-x
      set closest-y current-y
      ]
    ]
   ]
   let min-distance list closest-x closest-y
   report min-distance
end


;; turtle procedure for yellow/lime ants
to aggressive-behavior
  ;; Get the locations of red and orange ants and find the closest one to current yellow ant following instructions
  let red-orange-locations get-red-orange-ants-locations
  let min-distance find-ant red-orange-locations

  ;; Check if there are no red or orange ants
  if empty? min-distance [
      ifelse color = yellow or color = lime + 1 [
        look-for-food-nest-2
      ] [
        return-to-nest-2
      ]
      wiggle-2
    stop ;; Do nothing if there are no red or orange ants
  ]

  ;; Calculate the difference in coordinates
  let target-x item 0 min-distance
  let target-y item 1 min-distance
  let diff-x target-x - xcor
  let diff-y target-y - ycor

  ;; Calculate the angle towards the target
  let target-heading atan diff-x diff-y

  ;; Turn and move towards the target
  set heading target-heading
  fd 1

  ;; Check if any yellow ant is directly on top of a red orange ant. If so, and the aggression-death-chance is greater than a random number, kill the red or orange ant.
  let red-target one-of turtles with [color = red or color = orange + 1] in-radius 1
  ask turtles with [color = yellow] [
    if red-target != nobody and aggression-death-chance > random 100 [
      ask red-target [ die ]
      ;; Additionally, check if aggressor-death-chance is greater than a random number. If so, kill the yellow ant too.
      if aggressor-death-chance >= random 100 [
        die
      ]
      ;; Additionally, check if make-red-orange-ant-food is greater than a random number. If so, make the red/orange ant food for the yellow ants.
      if make-red-orange-ant-food >= random 100 and aggression-death-chance > random 100 [
        set food 1
        set color lime + 1
        return-to-nest-2
        fd 1
      ]
    ]
  ]
end



;; turtle procedure for yellow/lime ants
to return-to-nest-2
  ifelse nest2?
  [ ;; drop food and head out again
    set yellow-food-count yellow-food-count + 1
    set color yellow
    rt 180 ]
  [ set chemical-2 chemical-2 + 60  ;; drop some chemical
    uphill-nest-scent-2 ]         ;; head toward the greatest value of nest-scent
end


;; turtle procedure for yellow/lime ants
to look-for-food-nest-2
  if food > 0
  [ set color lime + 1     ;; pick up food
    set food food - 1        ;; and reduce the food source
    rt 180                   ;; and turn around
    stop ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical-2 >= 0.05) and (chemical-2 < 2)
  [ uphill-chemical-2 ]
end



;; turtle procedure for yellow/lime ants
to uphill-chemical-2
  let scent-ahead chemical-scent-at-angle-2   0
  let scent-right chemical-scent-at-angle-2  45
  let scent-left  chemical-scent-at-angle-2 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end


;; turtle procedure for yellow/lime ants
;; sniff left and right, and go where the strongest smell is
to uphill-nest-scent-2
  let scent-ahead nest-scent-at-angle-2   0
  let scent-right nest-scent-at-angle-2  45
  let scent-left  nest-scent-at-angle-2 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end




;; turtle procedure for yellow/lime ants
to-report nest-scent-at-angle-2 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent-2] of p
end


;; turtle procedure for yellow/lime ants
to-report chemical-scent-at-angle-2 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical-2] of p
end



;; turtle procedure for yellow/lime ants
to wiggle-2
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
  fd 1
end




; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
319
10
966
658
-1
-1
9.0
1
10
1
1
1
0
0
0
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
43
84
123
117
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
119
218
152
diffusion-rate
diffusion-rate
0.0
99.0
97.0
1.0
1
NIL
HORIZONTAL

SLIDER
28
154
218
187
evaporation-rate
evaporation-rate
0.0
99.0
7.0
1.0
1
NIL
HORIZONTAL

BUTTON
133
84
208
117
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
28
10
218
43
population
population
0.0
200.0
200.0
1.0
1
NIL
HORIZONTAL

PLOT
13
347
281
553
Food in each pile
Time
Food
0.0
50.0
0.0
120.0
true
false
"" ""
PENS
"food-in-pile1" 1.0 0 -11221820 true "" "plotxy ticks sum [food] of patches with [pcolor = cyan]"
"food-in-pile2" 1.0 0 -13791810 true "" "plotxy ticks sum [food] of patches with [pcolor = sky]"
"food-in-pile3" 1.0 0 -13345367 true "" "plotxy ticks sum [food] of patches with [pcolor = blue]"
"pen-3" 1.0 0 -10899396 true "" "plotxy ticks sum [food] of patches with [pcolor = green]"

SLIDER
28
47
218
80
population-2
population-2
0
200
200.0
1
1
NIL
HORIZONTAL

SLIDER
28
190
219
223
aggression
aggression
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
28
226
220
259
aggression-death-chance
aggression-death-chance
0
100
100.0
1
1
NIL
HORIZONTAL

PLOT
13
561
281
767
Red Food Count Vs. Yellow Food Count
Time
Food
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -2674135 true "" "plot red-food-count"
"pen-2" 1.0 0 -4079321 true "" "plot yellow-food-count"

PLOT
982
190
1240
378
Red Ants vs Yellow Ants
Time
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count turtles with [color = red or color = orange + 1]"
"pen-1" 1.0 0 -4079321 true "" "plot count turtles with [color = yellow or color = lime + 1]"

SLIDER
28
261
221
294
aggressor-death-chance
aggressor-death-chance
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
28
297
221
330
ticks-till-reset
ticks-till-reset
0
2000
1108.0
2
1
ticks
HORIZONTAL

SLIDER
983
10
1171
43
death-timer
death-timer
1
200
2.0
1
1
ticks
HORIZONTAL

CHOOSER
983
133
1172
178
death-timer-red-affected?
death-timer-red-affected?
true false
1

SLIDER
982
92
1172
125
make-red-orange-ant-food
make-red-orange-ant-food
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
982
50
1172
83
death-timer-red-ants
death-timer-red-ants
1
200
2.0
1
1
ticks
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

In this project, there are two colonies of ants that forage for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

The red ant colony is always scavenging for food, and have evolved to be scavangers that sometimes even make extremely efficient use of the little to no food they might have. For this reason, their chemcial has precedence over yellow ant chemicals, and can overtake it, sometimes leading to yellow ant confusion depending on the chemical's abilities. Additionally, you can decide if the red ants have gained a useful mutation that allows them to use the energy they've gotten from food in the past to live for extended periods without food, no longer dying from hunger nearly as easily as yellow ants.

However, the yellow ants have evolved their own advantage, and can gain the ability to eliminate ants from the red colony. Depending on user choice, they can even use the red ants for food, simulating the omnivorous nature of many ants, who will even eat other insects. However, this may have even more negative effects on their scavenging abilities, as other yellow ants may be attracted longer to an area that has hardly any food or red/orange ants because of the chemicals that are put down afterwards.

The amount of food that red ants get vs. the yellow ants, or comparing that alongside how many of each type of ant is alive near the end of each simulation, is the main way of deciding which ant species "won" that simulation. However, because of the advantages both red ants and yellow andts can have, the population graph can be yet another useful indicator of who has "won" between the species.

## HOW IT WORKS

When any ant finds a piece of food, it carries the food back to the nest, dropping a chemical as it moves. When other ants of the same type "sniff" their chemical, they follow their chemical toward the food. As more ants carry food to the nest, they reinforce the chemical trail. When red ants pick up food, they turn orange. When yellow ants pick up food, they turn lime colored.

Red ants can only pick up on and follow the chemicals of red ants, and yellow ants can only pick up on and follow the chemicals of yellow ants. The outline of the red ant's chemicals is always green, meanwhile the outline of the yellow ant's chemicals is always blue. 

Yellow ants have a variable aggression rating which is used to decide whether they should attack the nearest red ant or not. The higher the aggression, the more likely it is that they use their senses to attack red/orange ants. However, they can only ever attack red/orange ants when they are not carrying food. If they are lime colored they can never attack other ants, and must bring food back to the nest first.

Additionally, the ability to kill a red/orange ant, or to kill such an ant and walk away alive, is not always guranteed. Depending on user settings, they yellow ant may fail to kill a red/orange ant, or should they succeed in killing one, the red/orange ant fighting back may cause them to die as well, often negating the benefits of aggression.

Finally, after a certain period of time that the user can choose, the program will reset, starting again and placing all items in random spots once again.

## HOW TO USE IT

Click the SETUP button to set up the ant nests (red ants have a violet nest, while yellow ants have an magenta nest) and three piles of food in random locations.

Click the GO button to start the simulation.

The EVAPORATION-RATE slider controls the evaporation rate of the chemicals for both ants.

The DIFFUSION-RATE slider controls the diffusion rate of the chemicals for both ants.

If you want to change the likelyhood that yellow ants attack the nearest red ant, move the AGGRESSION slider. 

If you want to change the likelyhood that yellow ants succeed in eliminating the nearest red ant, move the AGGRESSION-DEATH-CHANCE slider. 

If you want to change the likelyhood that red/orange ants succeed in eliminating the yellow ant along with them, move the AGGRESSOR-DEATH-CHANCE slider. 

If you want to change the number of ticks before the program resets and runs again, move the TICKS-TILL-RESET slider.

If you want to change the number of ticks before the a yellow ant may die of hunger, move the DEATH-TIMER slider.

If you want to change the number of ticks before the a red ant may die of hunger, move the DEATH-TIMER-RED-ANTS slider.

If you want to change the likelyhood that red/orange ants become food for the yellow ants, move the MAKE-RED-ORANGE-ANT-FOOD slider. 

If you want to change it so that red ants gain the ability to live for extended periods without food (the whole simulation(s), as long as this global variable is kept false of course), change the DEATH-TIMER-RED-AFFECTED? chooser to false.


If you want to change the number of red colony ants, move the POPULATION slider before pressing SETUP.

If you want to change the number of yellow colony ants, move the POPULATION-2 slider before pressing SETUP.


## NETLOGO FEATURES

The built-in `diffuse` primitive lets us diffuse the chemical easily without complicated code.

The primitive `patch-right-and-ahead` is used to make the ants smell in different directions without actually turning.

## HOW TO CITE

This model is based off of another very similar model made by Uri Wilensky! Make sure to credit both them and Netlogo!

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the original model itself:

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds."  Cambridge, MA: MIT Press.  Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 1998.

<!-- 1997 1998 MIT -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
