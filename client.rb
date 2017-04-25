require 'socket'
require 'rubycards'
include RubyCards

port = 2000 + ARGV[0].to_i

s = TCPSocket.new 'localhost', port

loop do 
	puts s.gets
	puts "press Enter when ready"
	STDIN.gets
	s.send 'Player 1 ready', 0
	puts s.gets
end
#while line = s.gets # Read lines from socket
	#puts line         # and print them
	#puts "Press Enter when ready"
	#s.write "Player 1 ready"
#end

s.close  
