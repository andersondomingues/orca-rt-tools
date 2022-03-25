graph [
  directed 1
  node [
    id 0
    label "Task A"
    period 55
    capacity 20
    deadline 55
  ]
  node [
    id 1
    label "Task B"
    period 55
    capacity 20
    deadline 55
  ]
  node [
    id 2
    label "Task C"
    period 55
    capacity 20
    deadline 55
  ]
  node [
    id 3
    label "Task D"
    period 55
    capacity 20
    deadline 55
  ]

  edge [
    source 0
    target 1
    label "f1"
    period 55
    datasize 160
    deadline 55
  ]
  edge [
    source 0
    target 3
    label "f2"
    period 55
    datasize 416
    deadline 55
  ]
  edge [
    source 2
    target 3
    label "f3"
    period 55
    datasize 192
    deadline 55
  ]
  edge [
    source 2
    target 1
    label "f4"
    period 55
    datasize 256
    deadline 55
  ]
  edge [
    source 3
    target 0
    label "f5"
    period 55
    datasize 128
    deadline 55
  ]
]