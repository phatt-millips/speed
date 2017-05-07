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
	def initialize(port)
		@s = TCPSocket.new 'localhost', port
		@hand = Hand.new
		s.listen(true)
		puts "Press Enter when ready"
		STDIN.gets
		s.puts 'Player Ready'
	end

	def get_cards

	end

	def get_discard

	end
	
	def get_total

	end

	def reqest_new_card

	end
	
	def request_new_discard
	
	end

	def discard(card,pile)

	end

	def listen_threaded

	end
	
end
system('cls')
hand = Hand.new
puts "Welcome to Speed"
s = TCPSocket.new 'localhost', 2000 
#Intro Message
s.listen true

STDIN.gets
s.puts 'Player Ready'

discards = s.listen.map{|discard| discard.split(":")}
puts discards.shift

cards = s.listen.map{|card| card.split(":")}
puts cards.shift
cards.each do |card|
	card[0] = card[0].to_i == 0? card[0] : card[0].to_i 	
	hand.add(Card.new(card[0], card[1]))
end	
hand.sort!
puts hand
s.puts STDIN.gets
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
