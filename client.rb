require 'socket'
require 'rubycards'
include RubyCards
class TCPSocket 
	def listen(print = false, stop_msg = "~~")
		ret_array = []
		
		while ((msg = self.gets.chomp) != stop_msg) do
			if print
				STDOUT.puts msg
			end
			ret_array << msg
		end
		ret_array
	end
end
class Player 
	def initialize(tcp_socket)
		@s = tcp_socket
		@total = []
		@discard = []
		@hand = []

		@s.listen(true)
		puts "Press Enter when ready"
		STDIN.gets
		@s.puts 'Player Ready'
	end
	def update
		@total = get_total
		@discard = get_discard
		@hand = get_cards	
	end

	def display
		puts @total
		puts @discard
		puts @hand
	end

	def get_cards
		#Message format:
		#	Hand
		#	Ace:Spades
		#	2:Diamonds
		#	3:Clubs
		#	7:Diamonds
		#	9:Hearts
		ret_val = []
		cards = @s.listen.map{|card| card.split(":")}
		ret_val << cards.shift
		ret_val << build_hand(cards).sort!
	end

	def get_discard
		#Message format:
		#	Discard	
		#	Ace:Spades
		#	2:Diamonds
		ret_val = []
		discards = @s.listen.map{|discard| discard.split(":")}
		ret_val << discards.shift
		ret_val << build_hand(discards) 
	end
	def build_hand(cards)
		ret_hand = Hand.new
		cards.each do |card|
			card[0] = card[0].to_i == 0? card[0] : card[0].to_i 	
			ret_hand.add(Card.new(card[0], card[1]))
		end
		ret_hand
	end
	
	def get_total
		#Message format:
		#	You:20
		#	Opp:14
		totals = @s.listen.map{|player_tot| player_tot.split(':')}
	end

	def reqest_new_card
		#Message format:
		#	Request new card in hand	
		@s.puts("Request new card in hand")
	end
	
	def request_new_discard
		#Message format:
		#	Request new card in discard
		@s.puts("Request new card in discard")
	end

	def discard(card,pile)
		#Message format:
		#	Discard:1(or 2)
		#	Ace:Hearts	
		#	
		#	Server will reply with discard no matter what whether it accepted the new card or not
		@s.puts("Discard:#{pile}")
		@s.puts("#{card.rank}:#{card.suit}")
		self.update
	end

	def listening_and_sending
		listen_thread = Thread.new() do
			@s.listen(true,"~~~~")
		end
		sending_thread = Thread.new do 
			@s.puts (STDIN.gets)
		end
		loop do 
			if (!listen_thread.alive?)
				puts "listen_thread dead"	
				break
			end
		end
		
		[listen_thread.value, sending_thread.value]
	end
end
system('cls')
puts "Welcome to Speed"
s = TCPSocket.new 'localhost', 2000 
player = Player.new(s)
loop do
	player.update
	player.display
	player.listening_and_sending
end
#keystroke = "
#while keystroke != 'q' 
#	puts s.gets	
#end
#while line = s.gets # Read lines from socket
	#puts line         # and print them
	#puts "Press Enter when ready"
	#s.write "Player 1 ready"
#end
puts "Game Ended"
s.close  
