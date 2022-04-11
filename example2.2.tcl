#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM) 
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create four nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Create links between the nodes
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n4 1.5Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms SFQ
$ns duplex-link $n4 $n5 1.5Mb 10ms SFQ
$ns duplex-link $n5 $n6 1.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 1.5Mb 60ms DropTail
$ns duplex-link $n1 $n6 1.5Mb 60ms SFQ

#Give node position (for NAM)
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n4 orient down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n4 $n5 orient right
$ns duplex-link-op $n5 $n6 orient right
$ns duplex-link-op $n3 $n4 orient left-down
$ns duplex-link-op $n1 $n6 orient right-down

#Monitor the queue for link (n2-n3, n4-n5, n1-n6). (for NAM)
$ns duplex-link-op $n3 $n4 queuePos 0.5
$ns duplex-link-op $n4 $n5 queuePos 0.5
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Create a UDP agent and attach it to node n1
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n1 $udp0

#Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 328
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#Create a UDP agent and attach it to node n5
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n5 $udp1

#Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 328
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

#Create a TCP agent and attaching it to node n4
set tcp1 [new Agent/TCP]
$ns attach-agent $n4 $tcp1

#Create an FTP application and attaching it to the tcp1 agent
set ftp [new Application/FTP]
$ftp attach-agent $tcp1

#Create a Null agent (a traffic sink) and attach it to node n3
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

#Create a recipient agent for tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1

#Connect the traffic sources with the traffic sink
$ns connect $udp0 $null0
$ns connect $udp1 $null0  
$ns connect $tcp1 $sink1

#Schedule events for the CBR agents
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"

#Call the finish procedure after 17 seconds of simulation time
$ns at 17.0 "finish"

#Run the simulation
$ns run

