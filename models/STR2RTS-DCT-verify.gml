graph [
  directed 1
  node [
    id 0
    label "AFA (78651, 36480, 78651)"
    meuattrib "asdasdsad"
  ] 
  node [
    id 1
    label "IDNT (78651, 384, 78651)"
  ]
  node [
    id 2
    label "DCT (78651, 16032, 78651)"
  ]
  node [
    id 3
    label "SPL (78651, 756, 78651)\nAFB (78651, 44, 78651)"
  ]
  node [
    id 4
    label "IDC (78651, 4096, 78651)"
  ]
  node [
    id 5
    label "JOIN (78651, 768, 78651)"
  ]
  edge [
    source 0
    target 3
    label "f1 (55, 4096, 55)"
  ]
  edge [
    source 1
    target 5
    label "f7 (55, 4096, 55)"
  ]
  edge [
    source 3
    target 2
    label "f2 (55, 4096, 55)"
  ]
  edge [
    source 3
    target 1
    label "f6 (55, 4096, 55)"
  ]
  edge [
    source 2
    target 4
    label "f3 (55, 4096, 55)"
  ]
  edge [
    source 4
    target 5
    label "f4(55, 4096, 55)"
  ]
  edge [
    source 5
    target 3
    label "f5(55, 8192, 55)"
  ]
]