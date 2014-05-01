class Board

	attr_reader :towers, :height
	
	def initialize(towers, height = 0)
		@towers = towers

		if height > 0
			@height = height
		else
			@height = towers.first.size 
		end
	end

	def move(t1, t2, enforce_order = true)
		ring = towers[t1].top
		
		return self if ring.nil? 

		if enforce_order

			t2_ring = towers[t2].top

			if t2_ring.nil? == false && t2_ring < ring
				return self
			end
		end

		new_towers = towers.map do |tower|
			if tower == towers[t1]
				tower.remove
			elsif tower == towers[t2]
				tower.add(ring)
			else
				tower
			end
		end

		Board.new(new_towers, @height)
	end

	def won?
		return false unless (towers.last.size == @height)
		return false unless (towers.last.rings == towers.last.rings.sort.reverse)
		true
	end

end

class Tower

	attr_reader :rings

	def initialize(rings = [])
		@rings = rings
	end

	def top
		@rings.last
	end
	
	def add(ring)
		Tower.new(@rings + [ring])
	end

	def remove
		Tower.new(@rings[0..-2])
	end

	def size
		@rings.length
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
		h = board.height
		rows = Transformer.towers_to_rows(t, h)

		# rows.map { |r| r.map { |c| c.nil? ? @PEG_CHAR : c }.join("\s") }.reverse.join("\n")
		rows.map { |r| r.map { |c| c.nil? ? self.render_peg(h) : self.render_ring(c, h) }.join("\s") }.reverse.join("\n")
	end
end

class Game 
	attr_reader :board, :move_counter

	def initialize(ring_count = 8, tower_count = 3, enforce_order = true)
		@ring_count = ring_count
		@tower_count = tower_count
		@enforce_order = enforce_order

		@board = Game.create_board(ring_count, tower_count)
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

	def self.create_board(ring_count, tower_count)
		towers = Array.new(tower_count - 1) { Tower.new }
		towers.unshift(self.create_tower(ring_count))

		Board.new(towers, ring_count)
	end

	def self.create_tower(ring_count = 0)
		rings = ring_count <= 0 ? [] : Array(1..ring_count).reverse
		Tower.new(rings)
	end
end