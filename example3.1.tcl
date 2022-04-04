set ns [new Simulator]
set cir0 1000000
set cbs0 3000
set rate0 2000000
set cir1 1000000
set cbs1 10000
set rate1 3000000
set testTime 85.0
set packetSize 1000

# Set up the network topology shown at the top of this
set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set core [$ns node]
set e2 [$ns node]
set dest [$ns node]

$ns duplex-link $s1 $e1 10Mb 5ms DropTail
$ns duplex-link $s2 $e1 10Mb 5ms DropTail
$ns simplex-link $e1 $core 10Mb 5ms dsRED/edge
$ns simplex-link $core $e1 10Mb 5ms dsRED/core
$ns simplex-link $core $e2 5Mb 5ms dsRED/core
$ns simplex-link $e2 $core 5Mb 5ms dsRED/edge
$ns duplex-link $e2 $dest 10Mb 5ms DropTail

set qE1C [[$ns link $e1 $core] queue]
set qE2C [[$ns link $e2 $core] queue]
set qCE1 [[$ns link $core $e1] queue]
set qCE2 [[$ns link $core $e2] queue]

# Set DS RED parameters from Edge1 to Core:
$qE1C meanPktSize $packetSize
$qE1C set numQueues_ 1
$qE1C setNumPrec 2
$qE1C addPolicyEntry [$s1 id] [$dest id] TokenBucket 10
$cir0 $cbs0
$qE1C addPolicyEntry [$s2 id] [$dest id] TokenBucket 10
$cir1 $cbs1
$qE1C addPolicerEntry TokenBucket 10 11
$qE1C addPHBEntry 10 0 0
$qE1C addPHBEntry 11 0 1
$qE1C configQ 0 0 20 40 0.02
$qE1C configQ 0 1 10 20 0.10

# Set DS RED parameters from Edge2 to Core:
$qE2C meanPktSize $packetSize
$qE2C set numQueues_ 1
$qE2C setNumPrec 2
$qE2C addPolicyEntry [$dest id] [$s1 id] TokenBucket 10
$cir0 $cbs0
$qE2C addPolicyEntry [$dest id] [$s2 id] TokenBucket 10
$cir1 $cbs1
$qE2C addPolicerEntry TokenBucket 10 11
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10

# Set DS RED parameters from Core to Edge1:
$qCE1 meanPktSize $packetSize
$qCE1 set numQueues_ 1
$qCE1 setNumPrec 2
$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10

# Set DS RED parameters from Core to Edge2:
$qCE2 meanPktSize $packetSize
$qCE2 set numQueues_ 1
$qCE2 setNumPrec 2
$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10

# Set up one CBR connection between each source and the
destination:
set cbr0 [new Agent/CBR]
$ns attach-agent $s1 $cbr0
$cbr0 set packetSize_ $packetSize
$cbr0 set interval_ [expr 1.0 / [expr $rate0 / 8000.0]]
set null0 [new Agent/Null]
$ns attach-agent $dest $null0
$ns connect $cbr0 $null0
set cbr1 [new Agent/CBR]
$ns attach-agent $s2 $cbr1
$cbr1 set packetSize_ $packetSize
$cbr1 set interval_ [expr 1.0 / [expr $rate1 / 8000.0]]
set null1 [new Agent/Null]
$ns attach-agent $dest $null1
$ns connect $cbr1 $null1

proc finish {} {
 global ns
 exit 0
}

$qE1C printPolicyTable
$qE1C printPolicerTable
$ns at 0.0 "$cbr0 start"
$ns at 0.0 "$cbr1 start"
$ns at 20.0 "$qCE2 printCoreStats"
$ns at 40.0 "$qCE2 printCoreStats"
$ns at 60.0 "$qCE2 printCoreStats"
$ns at 80.0 "$qCE2 printCoreStats"
$ns at $testTime "$cbr0 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"
$ns run

