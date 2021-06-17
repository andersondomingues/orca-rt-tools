graph [
  directed 1
  node [
    id 0
    label "AnonFilterA"
    alias "AFA"
    period 78651
    capacity 36480
    deadline 78651
  ] 
  node [
    id 1
    label "IDNT"
    alias "Identity"
    period 78651
    capacity 384
    deadline 78651
  ]
  node [
    id 2
    label "DCT"
    alias "DCT_2D"
    period 78651
    capacity 16032
    deadline 78651
  ]
  node [
    id 3
    label "SPL"
    alias "Splitter"
    period 78651
    capacity 576
    deadline 78651
  ]
  node [
    id 4
    label "IDC"
    alias "iDCT_2D"
    period 78651
    capacity 16032
    deadline 78651
  ]
  node [
    id 5
    label "JOIN"
    alias "Joiner"
    period 78651
    capacity 768
    deadline 78651
  ]
  node [
    id 6
    label "AFB"
    alias "AnonFilterB"
    period 78651
    capacity 44
    deadline 78651
  ]
  edge [
    source 0
    target 3
    label "f1"
    period 55
    datasize 4096
    deadline 55
  ]
  edge [
    source 1
    target 5
    label "f7"
    period 55
    datasize 4096
    deadline 55
  ]
  edge [
    source 3
    target 2
    label "f2"
    period 55
    datasize 4096
    deadline 55
  ]
  edge [
    source 3
    target 1
    label "f6"
    period 55
    datasize 4096
    deadline 55
  ]
  edge [
    source 2
    target 4
    label "f3"
    period 55
    datasize 4096
    deadline 55
  ]
  edge [
    source 4
    target 5
    label "f4"
    period 55
    datasize 64
    deadline 55
  ]
  edge [
    source 5
    target 6
    label "f5"
    period 55
    datasize 8192
    deadline 55
  ]
]