def render(game, showTip = false)
	print "\e[H\e[2J"
	puts "Tower of Hanoi"
	puts
	print View.render_board(game.board)

  if showTip
  	puts
    print "\nTip: To move ring from first to second tower"
    print "\n     Type '1 2' and pressing enter."
    print "\n     (Invalid moves are ignored)"
  end

  puts
	print "\n# #{game.move_counter} (t1, t2) > "

end

def parse_move(input)
	input.split.map { |c| c.to_i - 1 }
end