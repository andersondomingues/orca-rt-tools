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
    source POSI
    target NAVC
    label "f1"
    period 50
    datasize 1024
    deadline 50
  ]

  edge [
    source NAVC
    target OBDB
    label "f2"
    period 50
    datasize 2048
    deadline 50
  ]

  edge [
    source OBDB
    target NAVC
    label "f3"
    period 50
    datasize 16384
    deadline 50
  ]

  edge [
    source OBDB
    target OBMG
    label "f4"
    period 50
    datasize 16384
    deadline 50
  ]

  edge [
    source NAVC
    target DIRC
    label "f5"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source SPES
    target NAVC
    label "f6"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source NAVC
    target THRC
    label "f7"
    period 10
    datasize 1024
    deadline 10
  ]

  edge [
    source FBU3
    target VOD1
    label "f8"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU8
    target VOD2
    label "f9"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source VOD1
    target NACV
    label "f10"
    period 4
    datasize 512
    deadline 4
  ]

  edge [
    source VOD2
    target NACV
    label "f11"
    period 4
    datasize 512
    deadline 4
  ]

  edge [
    source FBU1
    target FBE1
    label "f12"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU2
    target FBE2
    label "f13"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU3
    target FBE3
    label "f14"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU4
    target FBE4
    label "f15"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU5
    target FBE5
    label "f16"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU6
    target FBE6
    label "f17"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU7
    target FBE7
    label "f18"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source FBU8
    target FBE8
    label "f19"
    period 4
    datasize 38400
    deadline 4
  ]

  edge [
    source BFE1
    target FDF1
    label "f20"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE2
    target FDF1
    label "f21"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE3
    target FDF1
    label "f22"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE4
    target FDF1
    label "f23"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE5
    target FDF2
    label "f24"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE6
    target FDF2
    label "f25"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE7
    target FDF2
    label "f26"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source BFE8
    target FDF2
    label "f27"
    period 4
    datasize 2048
    deadline 4
  ]

  edge [
    source FDF1
    target STPH
    label "f28"
    period 4
    datasize 8192
    deadline 4
  ]

  edge [
    source FDF2
    target STPH
    label "f29"
    period 4
    datasize 8192
    deadline 4
  ]

  edge [
    source STPH
    target OBMG
    label "f30"
    period 4
    datasize 4096
    deadline 4
  ]

  edge [
    source POSI
    target OBMG
    label "f31"
    period 50
    datasize 1024
    deadline 50
  ]

  edge [
    source USOS
    target OBMG
    label "f32"
    period 10
    datasize 1024
    deadline 10
  ]

  edge [
    source OBMG
    target OBDB
    label "f33"
    period 100
    datasize 4096
    deadline 100
  ]

  edge [
    source TPMS
    target STAC
    label "f34"
    period 50
    datasize 2048
    deadline 50
  ]

  edge [
    source VIBS
    target STAC
    label "f35"
    period 10
    datasize 512
    deadline 10
  ]

  edge [
    source STAC
    target TPRC
    label "f36"
    period 100
    datasize 2048
    deadline 100
  ]

  edge [
    source SPES
    target STAC
    label "f37"
    period 10
    datasize 1024
    deadline 10
  ]


  edge [
    source STAC
    target THRC
    label "f38"
    period 10
    datasize 1024
    deadline 10
  ]

]
