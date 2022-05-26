graph [
  directed 1
  node [
    id 1
    label "TPMS"
    alias "Tire pressure monitoring system"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 2
    label "VIBS"
    alias "Vibration sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 3
    label "SPES"
    alias "Speed sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 4
    label "POSI"
    alias "Position sensor interface"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 5
    label "USOS"
    alias "Ultrasonic sensor"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 6
    label "FBU1"
    alias "Frame buffer - Left camera, upper-left quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 7
    label "FBU2"
    alias "Frame buffer - Left camera, upper-right quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 8
    label "FBU3"
    alias "Frame buffer - Left camera, lower-left quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 9
    label "FBU4"
    alias "Frame buffer - Left camera, lower-right quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 10
    label "FBU5"
    alias "Frame buffer - Right camera, upper-left quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 11
    label "FBU6"
    alias "Frame buffer - Right camera, upper-right quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 12
    label "FBU7"
    alias "Frame buffer - Right camera, lower-left quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 13
    label "FBU8"
    alias "Frame buffer - Right camera, lower-right quadrant"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 14
    label "STAC"
    alias "Stability control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 15
    label "TPRC"
    alias "Tire pressure control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 16
    label "DIRC"
    alias "Direction control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 17
    label "NAVC"
    alias "Navigation control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 18
    label "OBDB"
    alias "Obstacle database"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 19
    label "BFE1"
    alias "Background estimation and feature extraction 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 20
    label "BFE2"
    alias "Background estimation and feature extraction 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 21
    label "BFE3"
    alias "Background estimation and feature extraction 3"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 22
    label "BFE4"
    alias "Background estimation and feature extraction 4"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 23
    label "BFE5"
    alias "Background estimation and feature extraction 5"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 24
    label "BFE6"
    alias "Background estimation and feature extraction 6"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 25
    label "BFE7"
    alias "Background estimation and feature extraction 7"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 26
    label "BFE8"
    alias "Background estimation and feature extraction 8"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 27
    label "FDF1"
    alias "Feature data fusion 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 28
    label "FDF2"
    alias "Feature data fusion 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 29
    label "STPH"
    alias "Stereo photogrammetry"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 31
    label "THRC"
    alias "Throttle control"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 32
    label "VOD1"
    alias "Visual odometry 1"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 33
    label "VOD2"
    alias "Visual odometry 2"
    period 0
    capacity 0
    deadline 0
  ]
  node [
    id 34
    label "OBMG"
    alias "Obstacle database manager"
    period 0
    capacity 0
    deadline 0
  ]
  edge [
    source 4
    target 17
    label f1
    period 1000000
    datasize 4096
    deadline 1000000
  ]
  edge [
    source 17
    target 18
    label f2
    period 1000000
    datasize 8192
    deadline 1000000
  ]
  edge [
    source 18
    target 17
    label f3
    period 1000000
    datasize 65536
    deadline 1000000
  ]
  edge [
    source 18
    target 34
    label f4
    period 1000000
    datasize 65536
    deadline 1000000
  ]
  edge [
    source 17
    target 16
    label f5
    period 200000
    datasize 2048
    deadline 200000
  ]
  edge [
    source 3
    target 17
    label f6
    period 200000
    datasize 2048
    deadline 200000
  ]
  edge [
    source 17
    target 31
    label f7
    period 200000
    datasize 4096
    deadline 200000
  ]
  edge [
    source 8
    target 32
    label f8
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 13
    target 33
    label f9
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 32
    target 17
    label f10
    period 80000
    datasize 2048
    deadline 80000
  ]
  edge [
    source 33
    target 17
    label f11
    period 80000
    datasize 2048
    deadline 80000
  ]
  edge [
    source 6
    target 19
    label f12
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 7
    target 20
    label f13
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 8
    target 21
    label f14
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 9
    target 22
    label f15
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 10
    target 23
    label f16
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 11
    target 24
    label f17
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 12
    target 25
    label f18
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 13
    target 26
    label f19
    period 80000
    datasize 153600
    deadline 80000
  ]
  edge [
    source 19
    target 27
    label f20
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 20
    target 27
    label f21
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 21
    target 27
    label f22
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 22
    target 27
    label f23
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 23
    target 28
    label f24
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 24
    target 28
    label f25
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 25
    target 28
    label f26
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 26
    target 28
    label f27
    period 80000
    datasize 8192
    deadline 80000
  ]
  edge [
    source 27
    target 29
    label f28
    period 80000
    datasize 32768
    deadline 80000
  ]
  edge [
    source 28
    target 29
    label f29
    period 80000
    datasize 32768
    deadline 80000
  ]
  edge [
    source 29
    target 34
    label f30
    period 80000
    datasize 16384
    deadline 80000
  ]
  edge [
    source 4
    target 34
    label f31
    period 1000000
    datasize 4096
    deadline 1000000
  ]
  edge [
    source 5
    target 34
    label f32
    period 200000
    datasize 4096
    deadline 200000
  ]
  edge [
    source 34
    target 18
    label f33
    period 2000000
    datasize 16384
    deadline 2000000
  ]
  edge [
    source 1
    target 14
    label f34
    period 1000000
    datasize 8192
    deadline 1000000
  ]
  edge [
    source 2
    target 14
    label f35
    period 200000
    datasize 2048
    deadline 200000
  ]
  edge [
    source 14
    target 15
    label f36
    period 2000000
    datasize 8192
    deadline 2000000
  ]
  edge [
    source 3
    target 14
    label f37
    period 200000
    datasize 4096
    deadline 200000
  ]
  edge [
    source 14
    target 31
    label f38
    period 200000
    datasize 4096
    deadline 200000
  ]
]