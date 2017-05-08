require 'socket'
require 'rubycards'
include RubyCards
def clear_screen
	system('cls')
end
#setup 
class Card
	def adjacent_to?(card)
		self == card || self.to_i + 1 == card.to_i || self.to_i - 1 == card.to_i
	end
end
class Hand
	def_delegators :cards, :<<, :[], :delete_at #allows me to delete cards from a hand
end
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
	def draw
		if @hand.count < 5
			@hand.draw << @draw_pile.shift
		end
	end
	def discard(postion, pile)
		if (puts @hand[postion].adjacent_to? pile)
			@hand.delete_at position
		else 
			pile
		end
	end	
	def to_s
		"Player #{@player_id}"
	end
end

class Game
	def initialize(port = 2000)
		clear_screen
		@server = TCPServer.open(port)
		@deck = Deck.new.shuffle!
		@refresh = []
		@discard = []
		@refresh[0] = Hand.new.draw @deck,5
		@refresh[1] = Hand.new.draw @deck,5
		@discard[0] = @deck.draw
		@discard[1] = @deck.draw
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
			to_both_players("#{@discard[0].rank}:#{@discard[0].suit}", false)
			to_both_players("#{@discard[1].rank}:#{@discard[1].suit}")
		when 1
			@p1.send("Discard")
			@p1.send("#{@discard[0].rank}:#{@discard[0].suit}")
			@p1.send("#{@discard[1].rank}:#{@discard[1].suit}")
		when 2
			@p2.send("Discard")
			@p2.send("#{@discard[0].rank}:#{@discard[0].suit}")
			@p2.send("#{@discard[1].rank}:#{@discard[1].suit}")
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
	def draw(player)
		player.draw
	end
	def discard(player, position, pile)
		@discard[pile-1] = player.discard(position, @discard[pile-1])
	end
end
game = Game.new

game.listen #listens for any responce

loop do 
	game.update(0)
	player, move = game.listen_threaded
	case move
	when "draw" || "Draw"
		puts "#{player} drew"
		game.draw(player)
	when /\d+/ #=== move.chomp
		puts "#{player} #{move}"
		card, pile = move.split('')
		game.discard(player, card.to_i, pile.to_i)
	end
end
