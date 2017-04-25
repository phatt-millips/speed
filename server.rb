require 'socket'
require 'rubycards'
include RubyCards

server1 = TCPServer.new 2001 # Server bind to port 2000
server2 = TCPServer.new 2002 # Server bind to port 2001

loop do
	player1 = server1.accept    # Wait for a client to connect
	player1.puts "Connected. Waiting for player 2"
	player2 = server2.accept
	player2.puts "Connected"

	#setup
	origin_deck = Deck.new.shuffle!
	player1_main_deck = Hand.new.draw origin_deck 15
	player2_main_deck = Hand.new.draw origin_deck 15
	refresh_deck1 = Hand.new.draw origin_deck 5
	refresh_deck2 = Hand.new.draw origin_deck 5
	discard_card1 = Hand.new.draw origin_deck 1
	discard_card2 = Hand.new.draw origin_deck 1
	player1_hand = Hand.new origin_deck 5
	player2_hand = Hand.new origin_deck 5

	player1.puts "Game Ready"
	player2.puts "Game Ready"
	
	player1.puts player1_hand	

	p player2.gets
		
	player1.close
	player2.close
end
