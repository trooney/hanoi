def render(game)
	print "\e[H\e[2J"
	puts "Tower of Hanoi"
	puts
	print View.render_board(game.board)
	puts
	print "\n# #{game.move_counter} (t1, t2) > "
end

def parse_move(input)
	input.split.map { |c| c.to_i - 1 }
end