set simulation_time 60

  set ns [new Simulator]
  set nf [open out.nam w]
  $ns namtrace-all $nf

  for {set i_ 1} {$i_ < 3} {incr i_} {
   set current_tr($i_) [open queuelen-$i_.tr w]
   set average_tr($i_) [open average-$i_.tr w]
  }

  proc finish {} {
      global ns nf current_tr average_tr
      $ns flush-trace
      close $nf
      exec nam -a out.nam &
      for {set i_ 1} {$i_ < 3} {incr i_} {
       close $current_tr($i_)
       close $average_tr($i_)
       exec xgraph queuelen-$i_.tr average-$i_.tr -geometry 600x450 &
      }
      exit 0
  }

  set s1     [$ns node]
  set s2     [$ns node]
  set e1     [$ns node]
  set core   [$ns node]
  set e2     [$ns node]
  set dest1  [$ns node]
  set dest2  [$ns node]

  $ns color 1  Green
  $ns color 2  Red

#   s1             dest1
#     \           / 
#      e1--core--e2
#     /           \
#   s2             dest2
#
     
  $ns duplex-link  $s1 $e1 2Mb 15ms DropTail
  $ns duplex-link  $s2 $e1 2Mb 15ms DropTail

  $ns simplex-link $e1 $core 2Mb 15ms dsRED/edge
  $ns simplex-link $core $e1 2Mb 15ms dsRED/core 
  $ns simplex-link $core $e2 409600 10ms dsRED/core 
  $ns simplex-link $e2 $core 409600 10ms dsRED/edge

  $ns duplex-link  $e2 $dest1 2Mb 60ms DropTail
  $ns duplex-link  $e2 $dest2 409600 60ms DropTail

  $ns duplex-link-op $s1     $e1 orient right-down
  $ns duplex-link-op $s2     $e1 orient right-up
  $ns duplex-link-op $e1     $core orient right
  $ns duplex-link-op $core     $e2 orient right
  $ns duplex-link-op $e2     $dest1 orient right-up
  $ns duplex-link-op $e2     $dest2 orient right-down

  $ns queue-limit $core $e2 100
  $ns queue-limit $e2 $dest1 100

  $ns duplex-link-op $core $e2 queuePos 0.5

  set qE1C [[$ns link $e1 $core] queue]  
  set qE2C [[$ns link $e2 $core] queue]  
  set qCE1 [[$ns link $core $e1] queue]  
  set qCE2 [[$ns link $core $e2] queue]  

  $qE1C meanPktSize 1000
  $qE1C set numQueues_ 3
  $qE1C setNumPrec 3    
  $qE1C setSchedularMode RR 
  $qE1C setMREDMode RIO-C
  
  $qE1C addPolicyEntry [$s1 id] -1 TokenBucket 18  5000000  4000  
  $qE1C addPolicyEntry [$s2 id] -1 TokenBucket 26  5000000  4000

  $qE1C addPolicerEntry TokenBucket 18 20  
  $qE1C addPolicerEntry TokenBucket 26 28  

  $qE1C addPHBEntry 18       1           0
  $qE1C addPHBEntry 20       1           1

  $qE1C addPHBEntry 26       2           0
  $qE1C addPHBEntry 28       2           1

  $qE1C configQ 0           0            8             16             0.02
  $qE1C configQ 0           1            4              8             0.10
  $qE1C configQ 0           2            2              4             0.50

  $qE1C configQ 1           0            8             16             0.02
  $qE1C configQ 1           1            4              8             0.10
  $qE1C configQ 1           2            2              4             0.50

  $qE1C configQ 2           0            8             16             0.02
  $qE1C configQ 2           1            4              8             0.10
  $qE1C configQ 2           2            2              4             0.50


  $qE2C meanPktSize 1000
  $qE2C set numQueues_ 3
  $qE2C setNumPrec 3    
  $qE2C setSchedularMode RR 
  $qE2C setMREDMode RIO-C
  
  $qE2C addPolicyEntry -1 [$s1 id] TokenBucket 18  5000000  4000  
  $qE2C addPolicyEntry -1 [$s2 id] TokenBucket 26  5000000  4000

  $qE2C addPolicerEntry TokenBucket 18 20  
  $qE2C addPolicerEntry TokenBucket 26 28  

  $qE2C addPHBEntry 18       1           0
  $qE2C addPHBEntry 20       1           1

  $qE2C addPHBEntry 26       2           0
  $qE2C addPHBEntry 28       2           1

  $qE2C configQ 0           0            8             16             0.02
  $qE2C configQ 0           1            4              8             0.10
  $qE2C configQ 0           2            2              4             0.50

  $qE2C configQ 1           0            8             16             0.02
  $qE2C configQ 1           1            4              8             0.10
  $qE2C configQ 1           2            2              4             0.50

  $qE2C configQ 2           0            8             16             0.02
  $qE2C configQ 2           1            4              8             0.10
  $qE2C configQ 2           2            2              4             0.50

  $qCE1 meanPktSize 1000
  $qCE1 set numQueues_ 3 
  $qCE1 setNumPrec 3
  $qCE1 setSchedularMode RR 
  $qCE1 setMREDMode RIO-C

  $qCE1 addPHBEntry 18       1           0
  $qCE1 addPHBEntry 20       1           1
  $qCE1 addPHBEntry 22       1           2

  $qCE1 addPHBEntry 26       2           0
  $qCE1 addPHBEntry 28       2           1
  $qCE1 addPHBEntry 30       2           2

  $qCE1 configQ 0           0            8             16             0.02
  $qCE1 configQ 0           1            4              8             0.10
  $qCE1 configQ 0           2            2              4             0.50

  $qCE1 configQ 1           0            8             16             0.02
  $qCE1 configQ 1           1            4              8             0.10
  $qCE1 configQ 1           2            2              4             0.50
  
  $qCE1 configQ 2           0            8             16             0.02
  $qCE1 configQ 2           1            4              8             0.10
  $qCE1 configQ 2           2            2              4             0.50

  $qCE2 meanPktSize 1000
  $qCE2 set numQueues_ 3
  $qCE2 setNumPrec 3 
  $qCE2 setSchedularMode RR  
  $qCE2 setMREDMode RIO-D

  $qCE2 addPHBEntry 18       1           0
  $qCE2 addPHBEntry 20       1           1
  $qCE2 addPHBEntry 22       1           2

  $qCE2 addPHBEntry 26       2           0
  $qCE2 addPHBEntry 28       2           1
  $qCE2 addPHBEntry 30       2           2

  $qCE2 configQ 0           0            8             16             0.01
  $qCE2 configQ 0           1            4              8             0.02
  $qCE2 configQ 0           2            2              4             0.05

  $qCE2 configQ 1           0            16            32             0.01
  $qCE2 configQ 1           1            8             16             0.02
  $qCE2 configQ 1           2            4              8             0.04

  $qCE2 configQ 2           0            4             12             0.01
  $qCE2 configQ 2           1            4              8             0.02
  $qCE2 configQ 2           2            2              4             0.04
 
  set udp0 [new Agent/UDP]
  $udp0 set class_ 1 
  set cbr0 [new Application/Traffic/CBR]
  $ns attach-agent $s1 $udp0
  $cbr0 attach-agent $udp0
  $cbr0 set packetSize_ 1000
  $cbr0 set interval_ 0.005
  set null0 [new Agent/Null]
  $ns attach-agent $dest1 $null0
  $ns connect $udp0 $null0

  set udp1 [new Agent/UDP]
  $udp1 set class_ 2 
  set cbr1 [new Application/Traffic/CBR]
  $ns attach-agent $s2 $udp1
  $cbr1 attach-agent $udp1
  $cbr1 set packetSize_ 1000
  $cbr1 set interval_ 0.005
  set null1 [new Agent/Null]
  $ns attach-agent $dest2 $null1
  $ns connect $udp1 $null1

proc ds_stats {} {
    global qE1C qCE1 qE2C qCE2
    puts "\n\n**** edge1 -> core ****"
    $qE1C printStats
    puts "\n\n**** core -> edge2 ****"
    $qCE2 printStats
    puts "\n\n**** edge2 -> core ****"
    $qE2C printStats
    puts "\n\n**** core -> edge1 ****"
    $qCE1 printStats
}

proc queue_stats {queue} {
    global current_tr average_tr
    set time 0.1
    set ns [Simulator instance]
    set now [$ns now]
    for {set i_ 1} {$i_ < 3} {incr i_} {
     set current_ [$queue getCurrent $i_]
     set average_ [$queue getAverage $i_]
     puts $current_tr($i_)  "$now $current_"
     puts $average_tr($i_)  "$now $average_"
    }
    $ns at [expr $now+$time] "queue_stats $queue"   
}

  $ns at 0.0 "$cbr0 start"
  $ns at 0.0 "$cbr1 start"
  $ns at 0.0 "queue_stats $qCE2"
  $ns at $simulation_time  "$cbr0 stop"
  $ns at $simulation_time  "$cbr1 stop"
  $ns at [expr $simulation_time + 5] "ds_stats"
  $ns at [expr $simulation_time + 5] "finish"

 $ns run
