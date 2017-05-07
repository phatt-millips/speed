require 'socket'
require 'rubycards'
include RubyCards
#setup 
class Player 
	@@num_players = 0
	def initialize(deck, server)
		@hand = Hand.new.draw deck, 5
		@draw_pile = Hand.new.draw deck, 15
		@port = server.accept
		@@num_players += 1
		@player_id = @@num_players 
	end
	def send_current_cards
		self.send("Hand")
		@hand.each {|card| self.send(card.rank + ":" + card.suit)}
		self.end_msg
	end
	def send(string)
		STDOUT.puts "#{self} --> #{string}"
		@port.puts string
	end
	def gets
		ret_val = @port.gets.chomp	
		STDOUT.puts "#{self} <-- #{ret_val}"
		ret_val
	end
	def end_msg
		self.send '~~'	
	end
	def num_cards
		@hand.count + @draw_pile.count
	end
	def to_s
		"Player #{@player_id}"
	end
end

class Game
	def initialize(port = 2000)
		@server = TCPServer.open(port)
		@deck = Deck.new.shuffle!
		@refresh1 = Hand.new.draw @deck,5
		@refresh2 = Hand.new.draw @deck,5
		@discard1 = @deck.draw
		@discard2 = @deck.draw
		STDOUT.puts("Server on port #{port}")
		@p1 = Player.new(@deck, @server)
		STDOUT.puts("Player 1 Connected")
		@p1.send "Connected to server\nWaiting on opponent"
		@p2 = Player.new(@deck, @server)
		STDOUT.puts("Player 2 Connected")
		@p2.send "Connected to server"	
		self.to_both_players "Both players connected"
	end
	def to_both_players(string, ending_msg = true)
		@p1.send(string)
		@p1.end_msg if ending_msg
		@p2.send(string)
		@p2.end_msg if ending_msg
	end
	def update(player)
		send_totals(player)
		send_discard(player)
		send_cards(player)	
		to_both_players("~~~~",false) #End of Updates
	end
	def listen(player = 0)
		case player
		when 0
			[@p1.gets,@p2.gets]	
		when 1
			@p1.gets
		when 2
			@p2.gets
		end
	end
	def listen_threaded 
		STDOUT.puts "Server Listening"

		p1t = Thread.new do
			[@p1,@p1.gets]

		end
		p2t = Thread.new do
			[@p2,@p2.gets]
		end

		#Stops listening to one player when the other starts talking
		ret_thread = []
		loop do
			if (!p1t.alive?) 
				ret_thread = p1t
				p2t.kill
				break
			elsif (!p2t.alive?)
				ret_thread = p2t
				p1t.kill
				break
			end
		end
		return ret_thread.value 
	end
	def send_cards(player)
		case player
		when 0
			@p1.send_current_cards
			@p2.send_current_cards
		when 1
			@p1.send_current_cards
		when 2 
			@p2.send_current_cards
		end
	end
	def send_discard(player)
		case player
		when 0	
			to_both_players("Discard", false)
			to_both_players("#{@discard1.rank}:#{@discard1.suit}", false)
			to_both_players("#{@discard2.rank}:#{@discard2.suit}")
		when 1
			@p1.send("Discard")
			@p1.send("#{@discard1.rank}:#{@discard1.suit}")
			@p1.send("#{@discard2.rank}:#{@discard2.suit}")
		when 2
			@p2.send("Discard")
			@p2.send("#{@discard1.rank}:#{@discard1.suit}")
			@p2.send("#{@discard2.rank}:#{@discard2.suit}")
		end
	end
	def send_totals(player)
		if player == 1 || player == 0
			@p1.send("You:#{@p1.num_cards}")
			@p1.send("Opp:#{@p2.num_cards}")
			@p1.end_msg
		end
		if player == 2 || player == 0
			@p2.send("You:#{@p2.num_cards}")
			@p2.send("Opp:#{@p1.num_cards}")
			@p2.end_msg
		end
		#to_both_players("~~")
	end
end
game = Game.new

game.listen #listens for any responce

loop do 
	game.update(0)
	game.listen_threaded
end
#origin_deck = Deck.new.shuffle!
#player1_main_deck = Hand.new.draw origin_deck,15
#player2_main_deck = Hand.new.draw origin_deck,15
#refresh_deck2 = Hand.new.draw origin_deck,5
#discard_card2 = Hand.new.draw origin_deck,1
##player1_hand = Hand.new.draw origin_deck,5
##player2_hand = Hand.new.draw origin_deck,5

#Accept
##system('cls')
##puts "Server Running"
##server = TCPServer.open(2000)
##puts "player 1 opened"
##p1 = server.accept
##puts "player 1 accepted"
##p1.puts "Hello player 1" 
##p1.puts "Waiting on player 2"
##puts "player 2 opened"
##p2 = server.accept
##puts "player 2 accepted"
##p2.puts "Hello player 2"	
##p1.puts "Both Players Connected"
##p2.puts "Both Players Connected"
##p1.puts "~~"
##p2.puts "~~"

#Begin Game
##puts p1.recv(12) && p2.recv(12) #waits until both players are ready
##puts "Game Begin"
##player1_hand.each {|card| p1.puts card.rank + ':' + card.suit }
##player2_hand.each {|card| p2.puts card.rank + ':' + card.suit }
##p1.puts "~~"
##p2.puts "~~"

#OLD SERVER
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
