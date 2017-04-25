require 'socket'
require 'rubycards'
include RubyCards

port = 2000 + ARGV[0].to_i

s = TCPSocket.new 'localhost', port
puts s.gets

#waits for reponse from server
while (s.gets.chomp != 'Server Ready') 
	system('cls')
	puts 'Waiting on server'
end

puts "Press Enter when ready"
STDIN.gets 
s.send 'Begin', 0

#while keystroke != 'q' 
	#puts s.gets	
	#keystroke = STDIN.gets
#end
#while line = s.gets # Read lines from socket
	#puts line         # and print them
	#puts "Press Enter when ready"
	#s.write "Player 1 ready"
#end

s.close  
