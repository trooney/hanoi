class Board

	attr_reader :towers
	
	def initialize(towers = [])
		@towers = towers

		if towers.length <= 1
			raise ArgumentError.new("Board must contain 2 or more towers")
		end
	end

	def rings_on_tower(t)
		towers[t].ring_count
	end

	def has_rings(t)
		rings_on_tower(t) > 0
	end

	def move(t1, t2, enforce_order = true)

		return self unless has_rings(t1)

		r1 = towers[t1].top
		r2 = towers[t2].top
		
		if enforce_order && has_rings(t2)  && r1 > r2
			return self
		end

		new_towers = towers.map do |tower|
			if tower == towers[t1]
				tower.remove
			elsif tower == towers[t2]
				tower.add(r1)
			else
				tower
			end
		end

		Board.new(new_towers)
	end

	def won?
		# return false unless (towers.last.size == @height)
		# return false unless (towers.last.rings == towers.last.rings.sort.reverse)
		# true

		tower_states = @towers[1..-1].map do |tower|
			tower.full? && tower.sorted?
		end

		tower_states.include? true
	end

end

class Tower

	attr_reader :height, :rings

	def initialize(height, rings = [])
		@height = height
		@rings = rings
	end

	def top
		@rings.last
	end
	
	def add(ring)
		Tower.new(@height, @rings + [ring])
	end

	def remove
		Tower.new(@height, @rings[0..-2])
	end

	def ring_count
		@rings.length
	end

	def full?
		@height == @rings.length
	end

	def sorted?
		@rings == @rings.sort.reverse
	end

end

class Transformer

	def self.pad_rings(rings, height, padder = nil)
		return rings if rings.length == height
		rings + Array.new((height - rings.length), padder)
	end

	def self.towers_to_rows(towers, height)
		padded_rings = towers.map do |tower|
			self.pad_rings(tower.rings, height)
		end
		
		rows = Array.new(height) { Array.new }

		rows.each_with_index do |row, idx|
			padded_rings.each do |rings|
				row << rings[idx]
			end
		end
		
	end

end

class View

	@GUTTER_CHAR = "\s"
	@RING_CHAR = "*"
	@PEG_CHAR = "|"

	def self.render_thing(thing_width, total_width, thing_char, gutter_char)
		gutter = gutter_char * (total_width - thing_width)
		thing = thing_char * (thing_width * 2)
		return gutter + thing + gutter
	end

	def self.render_ring(ring_length, tower_height)
		self.render_thing(ring_length, tower_height, @RING_CHAR, @GUTTER_CHAR)
	end

	def self.render_peg(tower_height, peg_char = nil)
		self.render_thing(1, tower_height, @PEG_CHAR, @GUTTER_CHAR)
	end

	def self.render_board(board)
		t = board.towers
		h = board.towers.first.height
		rows = Transformer.towers_to_rows(t, h)

		# rows.map { |r| r.map { |c| c.nil? ? @PEG_CHAR : c }.join("\s") }.reverse.join("\n")
		rows.map { |r| r.map { |c| c.nil? ? self.render_peg(h) : self.render_ring(c, h) }.join("\s") }.reverse.join("\n")
	end

end

class Game 

	attr_reader :height, :towers, :board, :move_counter

	def initialize(height = 8, towers = 3, enforce_order = true)
		@height = height
		@towers = towers
		@enforce_order = enforce_order

		@board = Game.create_board(height, towers)
		@move_counter = 0
	end

	def move(t1, t2)
		@move_counter += 1
		@board = board.move(t1, t2, @enforce_order)
		self
	end

	def won?
		@board.won?
	end

	def self.create_board(height, towers)
		towers = Array.new(towers - 1) { self.create_tower(height) }
		towers.unshift(self.create_tower(height, height))

		Board.new(towers)
	end

	def self.create_tower(height, ring_count = 0)
		rings = ring_count <= 0 ? [] : Array(1..ring_count).reverse
		Tower.new(height, rings)
	end

end

# Recursive strategy
# If tower size is onne
#   Move from start to finish
# else 
#   Move a tower of size n - 1 from start to temp. 
#   Move a single disk from start to finish.
#   Move a tower of size n - 1 from temp to finish.

class Solver

	def initialize(game, delay = 0)
		@game = game
	end
	
	def solve(&block)
		move_tower(@game.height, 0, 1, 2, &block)
	end

	def move_tower(rings, t_start, t_finish, t_temp, &block)
		if rings == 1
			@game = @game.move(t_start, t_finish)
			yield(@game) if block_given?
			@game
		else
			@game = move_tower(rings - 1, t_start, t_temp, t_finish, &block)
			@game = @game.move(t_start, t_finish)
			yield(@game) if block_given?
			@game = move_tower(rings - 1, t_temp, t_finish, t_start, &block)
			@game
		end
	end

end