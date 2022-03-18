graph [
  directed 1
  node [
    id 0
    label "TPMS"
    alias "Tire Pressure Monitoring System"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 1
    label "VIBS"
    alias "Vibration Sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 2
    label "SPES"
    alias "Speed Sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 3
    label "POSI"
    alias "Position Sensor Interface"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 4
    label "USOS"
    alias "Ultrasonic Sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 5
    label "FBU1"
    alias "Frame Buffer - Left Camera, Upper-Left Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 6
    label "FBU2"
    alias "Frame Buffer - Left Camera, Upper-Right Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 7
    label "FBU3"
    alias "Frame Buffer - Left Camera, Lower-Left Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 8
    label "FBU4"
    alias "Frame Buffer - Left Camera, Lower-Right Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 9
    label "FBU5"
    alias "Frame Buffer - Right Camera, Upper-Left Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 10
    label "FBU6"
    alias "Frame Buffer - Right Camera, Upper-Right Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 11
    label "FBU7"
    alias "Frame Buffer - Right Camera, Lower-Left Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 12
    label "FBU8"
    alias "Frame Buffer - Right Camera, Lower-Right Quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 13
    label "STAC"
    alias "Stability Control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 14
    label "TPRC"
    alias "Tire Pressure Control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 15
    label "DIRC"
    alias "Direction Control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 16
    label "NAVC"
    alias "Navigation Control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 17
    label "OBDB"
    alias "Obstacle Databse"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 18
    label "BFE1"
    alias "Background Estimation and Feature Extraction 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 19
    label "BFE2"
    alias "Background Estimation and Feature Extraction 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 20
    label "BFE3"
    alias "Background Estimation and Feature Extraction 3"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 21
    label "BFE4"
    alias "Background Estimation and Feature Extraction 4"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 22
    label "BFE5"
    alias "Background Estimation and Feature Extraction 5"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 23
    label "BFE6"
    alias "Background Estimation and Feature Extraction 6"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 24
    label "BFE7"
    alias "Background Estimation and Feature Extraction 7"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 25
    label "BFE8"
    alias "Background Estimation and Feature Extraction 8"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 26
    label "FDF1"
    alias "Feature Data Fusion 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 27
    label "FDF2"
    alias "Feature Data Fusion 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 28
    label "STPH"
    alias "Stereo Photogrammetry"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 29
    label "THRC"
    alias "Throttle Control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 30
    label "VOD1"
    alias "Visual Odometry 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 31
    label "VOD2"
    alias "Visual Odometry 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 32
    label "OBMG"
    alias "Obstacle Database Manager"
    period 0
    capacity 0
    deadline 0
  ]


  edge [
    source 3
    target 16
    label "f1"
    period 50
    datasize 1024
    deadline 50
  ]

  edge [
    source 16
    target 17
    label "f2"
    period 50
    datasize 2048
    deadline 50
  ]

  edge [
    source 17
    target 16
    label "f3"
    period 50
    datasize 16384
    deadline 50
  ]

  edge [
    source 17
    target 32
    label "f4"
    period 50
    datasize 16384
    deadline 50
  ]

  edge [
    source 16
    target 13
    label "f5"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source 2
    target 16
    label "f6"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source 16
    target 29
    label "f7"
    period 10
    datasize 1024
    deadline 10
  ]

  edge [
    source 7
    target 30
    label "f8"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 12
    target 31
    label "f9"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 30
    target 16
    label "f10"
    period 4
    datasize 512
    deadline 4
  ]

  edge [
    source 31
    target 16
    label "f11"
    period 4
    datasize 512
    deadline 4
  ]

  edge [
    source 5
    target 18
    label "f12"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 6
    target 19
    label "f13"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 7
    target 20
    label "f14"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 8
    target 21
    label "f15"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 9
    target 22
    label "f16"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 10
    target 23
    label "f17"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 11
    target 24
    label "f18"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 12
    target 25
    label "f19"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source 18
    target 26
    label "f20"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 19
    target 26
    label "f21"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 20
    target 26
    label "f22"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 21
    target 26
    label "f23"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 22
    target 27
    label "f24"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 23
    target 27
    label "f25"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 24
    target 27
    label "f26"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 25
    target 27
    label "f27"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source 26
    target 28
    label "f28"
    period 4
    datasize 8192
    deadline 4
  ]

  edge [
    source 27
    target 28
    label "f29"
    period 4
    datasize 8192
    deadline 4
  ]

  edge [
    source 28
    target 32
    label "f30"
    period 4
    datasize 4096
    deadline 4
  ]

  edge [
    source 3
    target 32
    label "f31"
    period 50
    datasize 1024
    deadline 50
  ]

  edge [
    source 4
    target 32
    label "f32"
    period 10
    datasize 1024
    deadline 10
  ]

  edge [
    source 32
    target 17
    label "f33"
    period 100
    datasize 4096
    deadline 100
  ]

  edge [
    source 0
    target 13
    label "f34"
    period 50
    datasize 2048
    deadline 50
  ]

  edge [
    source 1
    target 13
    label "f35"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source 13
    target 14
    label "f36"
    period 100
    datasize 2048
    deadline 100
  ]

  edge [
    source 2
    target 13
    label "f37"
    period 10
    datasize 1024
    deadline 10
  ]


  edge [
    source 13
    target 29
    label "f38"
    period 10
    datasize 1024
    deadline 10
  ]

]
