require 'socket'
require 'rubycards'
include RubyCards
system('cls')

port = 2000 + ARGV[0].to_i

s = TCPSocket.new 'localhost', port
puts s.gets
#waits for reponse from server
while (s.gets.chomp != 'Server Ready') 
	puts 'Waiting on server'
end

puts "Press Enter when ready"
STDIN.gets
s.send 'Player Ready', 0
puts s.gets
keystroke = ""
while keystroke != 'q' 
	puts s.gets	
end
#while line = s.gets # Read lines from socket
	#puts line         # and print them
	#puts "Press Enter when ready"
	#s.write "Player 1 ready"
#end

s.close  
