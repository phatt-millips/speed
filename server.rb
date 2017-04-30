require 'socket'
require 'rubycards'
include RubyCards
#setup 
origin_deck = Deck.new.shuffle!
player1_main_deck = Hand.new.draw origin_deck,15
player2_main_deck = Hand.new.draw origin_deck,15
refresh_deck1 = Hand.new.draw origin_deck,5
refresh_deck2 = Hand.new.draw origin_deck,5
discard_card1 = Hand.new.draw origin_deck,1
discard_card2 = Hand.new.draw origin_deck,1
player1_hand = Hand.new.draw origin_deck,5
player2_hand = Hand.new.draw origin_deck,5

system('cls')
puts "Server Running"
server = TCPServer.open(2000)
puts "player 1 opened"
Thread.fork(p1 = server.accept) do |player1|
	puts "player 1 accepted"
	player1.puts "Hello player 1" 
	player1.puts "Waiting on player 2"
end
puts "player 2 opened"
Thread.fork(p2 = server.accept) do |player2|
	puts "player 2 accepted"
	player2.puts "Hello player 2"	
end
p1.puts "Both Players Connected"
p2.puts "Both Players Connected"

#server2 = TCPServer.new 2002 # Server bind to port 2001
#player1 = server1.accept    # Wait for a client to connect
#player1.puts "Connected. Waiting for player 2"
#player2 = server2.accept
#player2.puts "Connected"
#puts "Both Players Connected"
#puts "Server Ready"
#player1.puts "Server Ready" 
#player2.puts "Server Ready"
#
#while player1.recv(12).chomp != "Player Ready" do
#end
#while player2.recv(12).chomp != "Player Ready" do
#end
#
#player1.puts "Begin Game"
#player2.puts "Begin Game"
#
	

#loop do
	#player1.puts player1_hand
#end

#player1.close
#player2.close
