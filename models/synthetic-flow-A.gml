graph [
  directed 1
  node [
    id 0
    label "Task A (55, 20, 55)"
  ]
  node [
    id 1
    label "Task B (55, 20, 55)"
  ]
  node [
    id 2
    label "Task C (55, 20, 55)"
  ]
  node [
    id 3
    label "Task D (55, 20, 55)"
  ]
  edge [
    source 0
    target 1
    label "f1(55, 160, 55)"
  ]
  edge [
    source 0
    target 3
    label "f2(55, 416, 55)"
  ]
  edge [
    source 2
    target 3
    label "f3(55, 192, 55)"
  ]
  edge [
    source 2
    target 1
    label "f4(55, 256, 55)"
  ]
  edge [
    source 3
    target 0
    label "f5(55, 128, 55)"
  ]
]