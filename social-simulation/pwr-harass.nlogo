globals [
;; ローバル変数定義
  group-sites    ;; agentset of patches where groups are located
  hpow-member-groupA  ;; how many hpow members are in a group
  lpow-member-groupA  ;; how many lpow members are in a group
  idea-A              ;; idea数用変数

  hpow-member-groupB
  lpow-member-groupB
  idea-B

  hpow-member-groupC
  lpow-member-groupC
  idea-C

  hpow-member-groupD
  lpow-member-groupD
  idea-D

  mylist　　　　　　　　;; カラーチャート変更用リスト

]
;種の設定
breed [hpows hpow ]
breed [lpows lpow ]

;エージェントのプロパティ
turtles-own [

  my-group-site
  group-no
  energy


]

;lpowのプロパティ
lpows-own [
  mental
  idea
]

; 初期セットアップ
to setup
  clear-all

  ; カラーチャート並べ替え
  set mylist []
  let ix1 10
  let ix2 1
  let col-ix1 139
  let col-ix2 139

  while [ix1 > 0]
  [
    set ix2 1
    while [ ix2 < 15 ]
    [
      set mylist lput col-ix2 mylist
      set col-ix2 col-ix2 - 10
      set ix2 ix2 + 1
    ]
    set col-ix1 col-ix1 - 1
    set col-ix2 col-ix1
    set ix1 ix1 - 1

  ]
  show(mylist)

  ; パッチ初期設定
  ask patches [
    ;; world-height = 33
    if pxcor <= 10 and pycor >= (world-height / 4) [ set pcolor 84 ] ;A
    if pxcor <= 10 and pycor >= 0 and pycor < (world-height / 4) [ set pcolor 85 ] ;B
    if pxcor <= 10 and pycor < 0 and pycor > (world-height / -4) [ set pcolor 94 ] ;C
    if pxcor <= 10 and pycor <= (world-height / -4) [ set pcolor 95 ] ;D
    if pxcor >= 11 [ set pcolor white ]
    if pxcor = 13 and pycor = 16  [ set pcolor red ]
    if pxcor = 12 and pycor = 15  [ set pcolor red ]
    if pxcor = 13 and pycor = 15  [ set pcolor red ]
    if pxcor = 14 and pycor = 15  [ set pcolor red ]
    if pxcor = 13 and pycor = 14  [ set pcolor red ]


  ]
  ask patches with [pxcor = -16 and pycor = 16] [ set plabel "A" ]
  ask patches with [pxcor = -16 and pycor = 8] [ set plabel "B" ]
  ask patches with [pxcor = -16 and pycor = -1] [ set plabel "C" ]
  ask patches with [pxcor = -16 and pycor = -9] [ set plabel "D" ]
  ask patches with [pxcor = -3 and pycor = 12] [ set pcolor brown ]
  ask patches with [pxcor = -3 and pycor = 4] [ set pcolor brown ]
  ask patches with [pxcor = -3 and pycor = -4] [ set pcolor brown ]
  ask patches with [pxcor = -3 and pycor = -12] [ set pcolor brown ]
  set group-sites patches with [group-site?]

  ; hpow作成
  create-hpows initial-number-hpows  ; create the man who has power, then initialize their variables
  [
    set shape  "face neutral"
    set color red
    set size 2  ; easier to see
    ;;set energy 100.0
    set my-group-site one-of group-sites
    my-group-no
    move-to my-group-site

  ]

  ; lpow作成
  create-lpows initial-number-lpows  ; create the man who has not power, then initialize their variables
  [
    set shape "person"
    ;;set color white
    set size 2  ; easier to see
    ;;set energy random 100
    set energy random (139)
    ;;show energy
    if energy < 50 [ set energy  energy + 50 ]
    show energy
    set mental 0
    set idea 100
    set color item energy mylist
    ;;set color random (139)
    ;;if color = 84 or color = 85 or color = 94 or color = 95 [ set color color + 4  ]
    ;;show color
    ;;show shapes
    set my-group-site one-of group-sites
    my-group-no
    move-to my-group-site

  ]

  ; 各エリアのエージェント数カウント
  count-group-turtles
  ; エージェント ばらける
  move-turtles

  reset-ticks
end

to go
  set idea-A 0
  set idea-B 0
  set idea-C 0
  set idea-D 0

  ; 100ticks 以上で終了
  if (ticks >= 100) or lpows = nobody [stop]

  ; lpow メンタルアップデート
  ask lpows [ update-mental]

  ; lpow idea数アップデート
  ask lpows [ update-number-idea ]
  show (idea-A)
  show (idea-B)
  show (idea-C)
  show (idea-D)

  ; energy(メンタル)チェック
  ask lpows [ energy-check ]

  ask lpows [
    ; energyが50を下回ったら会議室移動
    if ( energy < 50 and mental = 0 ) [
      if get-hpow-member > 1 [

        set my-group-site one-of group-sites
        my-group-no
        move-to my-group-site
        face min-one-of patches with [pcolor = brown] [distance myself]
        move-to-patch
        ;;show (who)
        ]
      ]
  ]

  ; エージェント数カウント
  count-group-turtles



  tick
end

to update-mental  ;; lpow procedure hpow人数分energy マイナス
  if mental = 0 [
    let hp-count 0
    set hp-count get-hpow-member

    set energy (energy - (hp-count * 1) )
    ;;if hp-count = 0 [ show (energy) ]
    ;;show (energy)
    ;;show (hp-count)
    set color item energy mylist
    ;set color ( color - 0.5 )
    ;if color = 84 or color = 85 or color = 94 or color = 95 [ set color color - 0.5  ]
  ]
end

to update-number-idea   ;;  各グループidea数カウント
  if mental = 0 [

    let hp-count 0

    set hp-count get-hpow-member
    set hp-count (hp-count * 1)
    if idea > 0 [ set idea (idea - hp-count) ]
    if group-no = 1
      [ set idea-A (idea-A + idea) ]
    if group-no = 2
      [ set idea-B (idea-B + idea) ]
    if group-no = 3
      [ set idea-C (idea-C + idea) ]
    if group-no = 4
      [ set idea-D (idea-D + idea) ]

  ]

  ;;wait 0.01
end

to energy-check  ;; energyが閾値を下回ったら病院へ行く

  if ( energy < tolerance and mental = 0 ) [
      set color  [ black ] of self
      setxy ((random-float 4) + 11) (random-float 15) - 5
      set mental [ 1 ] of self

  ]

end


to-report group-site?  ;; patch procedure

  report pcolor = brown

end

to count-group-turtles

  set hpow-member-groupA count hpows with [ pxcor <= 10 and pycor >= (world-height / 4) ]
  set lpow-member-groupA count lpows with [ pxcor <= 10 and pycor >= (world-height / 4)]
  set hpow-member-groupB count hpows with [ pxcor <= 10 and pycor >= 0 and pycor < (world-height / 4) ]
  set lpow-member-groupB count lpows with [ pxcor <= 10 and pycor >= 0 and pycor < (world-height / 4) ]
  set hpow-member-groupC count hpows with [ pxcor <= 10 and pycor < 0 and pycor > (world-height / -4)]
  set lpow-member-groupC count lpows with [ pxcor <= 10 and pycor < 0 and pycor > (world-height / -4) ]
  set hpow-member-groupD count hpows with [ pxcor <= 10 and pycor <= (world-height / -4) ]
  set lpow-member-groupD count lpows with [ pxcor <= 10 and pycor <= (world-height / -4) ]
  ;;show (hpow-member-groupA)
  ;;show (lpow-member-groupA)
  ;;show (hpow-member-groupB)
  ;;show (lpow-member-groupB)
  ;;show (hpow-member-groupC)
  ;;show (lpow-member-groupC)
  ;;show (hpow-member-groupD)
  ;;show (lpow-member-groupD)

end

to my-group-no

  if my-group-site = (patch -3 12)  [ set group-no 1 ]
  if my-group-site = (patch -3 4)   [ set group-no 2 ]
  if my-group-site = (patch -3 -4)  [ set group-no 3 ]
  if my-group-site = (patch -3 -12) [ set group-no 4 ]
  ;;show (group-no)

end

to-report get-hpow-member
  if group-no = 1
    [ report hpow-member-groupA ]
  if group-no = 2
    [ report hpow-member-groupB ]
  if group-no = 3
    [ report hpow-member-groupC ]
  if group-no = 4
    [ report hpow-member-groupD ]

end

to-report get-lpow-member
  if group-no = 1
    [ report lpow-member-groupA ]
  if group-no = 2
    [ report lpow-member-groupB ]
  if group-no = 3
    [ report lpow-member-groupC ]
  if group-no = 4
    [ report lpow-member-groupD ]

end



to move-turtles
  ask turtles [
    face min-one-of patches with [pcolor = brown] [distance myself]
    move-to-patch
  ]
end

to move-to-patch
  ifelse [pcolor] of patch-here = brown
  [ right random 360
    forward 2 ]
  [ forward 2
    move-to-patch ]
    display
end
@#$#@#$#@
GRAPHICS-WINDOW
270
15
707
453
-1
-1
13.0
1
15
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
20
10
88
43
setup
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

BUTTON
170
10
240
43
go
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

BUTTON
95
10
165
43
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
20
120
195
153
tolerance
tolerance
0.0
40.0
20.0
1.0
1
%
HORIZONTAL

PLOT
720
50
995
285
Number of idea
clock
NIL
0.0
10.0
0.0
150.0
true
true
"set-plot-y-range 0 100" ""
PENS
"A" 1.0 0 -10899396 true "" "plot (idea-A )"
"B" 1.0 0 -7500403 true "" "plot (idea-B )"
"C" 1.0 0 -2674135 true "" "plot (idea-C )"
"D" 1.0 0 -14070903 true "" "plot (idea-D )"

MONITOR
20
340
195
385
temporary retirement
count turtles with [pxcor > 10]
0
1
11

SLIDER
20
50
192
83
initial-number-hpows
initial-number-hpows
5
20
8.0
1
1
NIL
HORIZONTAL

SLIDER
20
85
192
118
initial-number-lpows
initial-number-lpows
0
50
20.0
1
1
NIL
HORIZONTAL

MONITOR
20
155
105
200
A : High Power
count hpows with [ pxcor <= 10 and pycor >= (world-height / 4) ]
17
1
11

MONITOR
110
155
195
200
A : Low Power
count lpows with [ pxcor <= 10 and pycor >= (world-height / 4) ]
17
1
11

MONITOR
20
200
105
245
B : High Power
count hpows with [ pxcor <= 10 and pycor >= 0 and pycor < (world-height / 4) ]
17
1
11

MONITOR
110
200
195
245
B : Low Power
count lpows with [ pxcor <= 10 and pycor >= 0 and pycor < (world-height / 4) ]
17
1
11

MONITOR
20
245
105
290
C : High Power
count hpows with [ pxcor <= 10 and pycor < 0 and pycor > (world-height / -4)]
17
1
11

MONITOR
110
245
195
290
C : Low power
count lpows with [ pxcor <= 10 and pycor < 0 and pycor > (world-height / -4)]
17
1
11

MONITOR
20
290
105
335
D : High Power
count hpows with [ pxcor <= 10 and pycor <= (world-height / -4) ]
17
1
11

MONITOR
110
290
195
335
D : Low power
count lpows with [ pxcor <= 10 and pycor <= (world-height / -4) ]
17
1
11

@#$#@#$#@
## WHAT IS IT?

This is a model of a cocktail party.  The men and women at the party form groups.  A party-goer becomes uncomfortable and switches groups if their current group has too many members of the opposite sex.  What types of group result?

## HOW IT WORKS

The party-goers have a TOLERANCE that defines their comfort level with a group that has members of the opposite sex.  If they are in a group that has a higher percentage of people of the opposite sex than their TOLERANCE allows, then they are considered "uncomfortable", and they leave that group to find another group.  Movement continues until everyone at the party is "comfortable" with their group.

## HOW TO USE IT

The NUMBER slider controls how many people are in the party, and the NUM-GROUPS slider controls how many groups form.

The SETUP button forms random groups.  To advance the model one step at a time, use the GO ONCE button. The GO button keeps the model running until everybody is comfortable.

The numbers in the view show the sizes of the groups.  White numbers are mixed groups and gray numbers are single-sex groups.

To set the tolerance of the people for the opposite sex, use the TOLERANCE slider.  You can move the slider while the model is running.  If the TOLERANCE slider is set to 75, then each person will tolerate being in a group with less than or equal to 75% people of the opposite sex.

The NUMBER HAPPY and SINGLE SEX GROUPS plots and monitors show how the party changes over time.  NUMBER HAPPY is how many party-goers are happy (that is, comfortable).  SINGLE SEX GROUPS shows the number groups containing only men or only women.

## THINGS TO NOTICE

At the end of the simulation (when everyone is happy), notice the number of single-sex groups.  Are there more than at the start?

## THINGS TO TRY

Try varying TOLERANCE.  Is there a critical tolerance at which each all groups end up being single-sex?  At different tolerance levels, does it take longer or shorter for everyone to become comfortable?

See how many mixed groups (not a single-sex group) you can get.

Using the GO ONCE button, experiment with different tolerances.  Watch how one unhappy person can disrupt the stability of other groups.

Is it possible to have an initial grouping such that the party never reaches a stable state?  (i.e. the model never stops running)

Observe real parties.  Is this model descriptive of real social settings?  What tolerance level do real people typically have?

## EXTENDING THE MODEL

Add more attributes to the model.  Instead of male/female, try a trait that has more than two types, like race or religion.  (You might use NetLogo's breeds feature to implement that.)

Allow each breed of person to have their own tolerance.

Complicate the tolerance rules: For example, the tolerance could go up as long as there are at least two of one breed.

Allow groups to subdivide, instead of finding new groups.

Set a maximum group size, so that if there are too many people in the group, they become unhappy.

## NETLOGO FEATURES

Most NetLogo models put the origin (0,0) in the center of the world, but here, we have placed the origin near the right edge of the world and most of the patches have negative X coordinates.  This simplifies the math for situating the groups.

Horizontal wrapping is enabled, but vertical wrapping is disabled.  Thus, the world topology is a "vertical cylinder".

Notice the use of the `mod` primitive to space out the groups evenly.  Setting up the groups in this manner allows for easy movement from group to group.

## RELATED MODELS

Segregation

## CREDITS AND REFERENCES

This model is based on the work of the pioneering economist Thomas Schelling:
Schelling, T. (1978). Micro-motives and Macro-Behavior. New York: Norton.

See also:
Resnick, M. & Wilensky, U. (1998). Diving into Complexity: Developing Probabilistic Decentralized Thinking through Role-Playing Activities. Journal of Learning Sciences, Vol. 7, No. 2.  http://ccl.northwestern.edu/papers/starpeople/

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Party model.  http://ccl.northwestern.edu/netlogo/models/Party.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1997 2001 -->
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
NetLogo 6.2.0
@#$#@#$#@
setup
repeat 20 [ go ]
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
1
@#$#@#$#@
