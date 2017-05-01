require 'socket'
require 'rubycards'
include RubyCards
system('cls')

hand = Hand.new
s = TCPSocket.new 'localhost', 2000 
while msg = s.gets do
	puts msg 
	break if  msg.chomp == "~~"
end

puts "Press Enter when ready"
STDIN.gets
s.send 'Player Ready', 0

msg = s.gets.chomp.split(":")
while msg[0] != "~~"
	msg[0] = msg[0].to_i == 0? msg[0] : msg[0].to_i 	
	hand.add(Card.new(msg[0], msg[1]))
	msg = s.gets.chomp.split(":")
end	
hand.sort!
puts hand
#puts s.gets
#keystroke = ""
#while keystroke != 'q' 
#	puts s.gets	
#end
#while line = s.gets # Read lines from socket
	#puts line         # and print them
	#puts "Press Enter when ready"
	#s.write "Player 1 ready"
#end

s.close  
