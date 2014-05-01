require File.expand_path("../spec_helper", __FILE__)

describe Tower do
	let(:tower) { Tower.new }
	after(:each) { tower = nil }

	it "#add" do
		expect(tower.add(1).top).to eq(1)
	end  

	it "#add" do
		expect(tower.add(1).size).to eq(1)
	end

	it "#remove" do
		expect(tower.add(1).remove.size).to eq(0)
	end

end

describe Board do

	let(:board) { Board.new([ Tower.new([1]), Tower.new ]) }

	it "height" do 
		result = Board.new([], 1).height
		expect(result).to eq(1)
	end

	context "#won?" do
		let(:tower_of_0) { Tower.new }
		let(:tower_of_1) { Tower.new([1]) }
		let(:tower_of_2_sorted) { Tower.new([2, 1]) }
		let(:tower_of_2_unsorted) { Tower.new([1, 2]) }

		it "is true when all rings are on the right-most ring" do
			board = Board.new([ tower_of_1 ], 1)
			expect(board.won?).to eq(true)
		end

		it "is true when all rings are on the right-most ring are sorted" do
			board = Board.new([ tower_of_0, tower_of_2_sorted ], 2)
			expect(board.won?).to eq(true)
		end

		it "is false when rings on the right-most side are _not_ sorted" do
			board = Board.new([ tower_of_2_unsorted ], 2)
			expect(board.won?).to eq(false)
		end
	end

	context	"#move" do

		let(:board) { Board.new([ Tower.new([1]), Tower.new ]) }

		it "removes ring from t1" do
			b = board.move(0, 1)
			expect(b.towers[0].size).to eq(0)
		end
		it "adds ring to t2" do
			b = board.move(0, 1)
			expect(b.towers[1].size).to eq(1)
		end
		it "ignores moves on empty rings" do
			b = board.move(1, 0)
			expect(b.towers[0].size).to eq(1)
		end
		it "enforces order" do
			board = Board.new([ Tower.new([3, 2]), Tower.new([1]) ])
			board.move(0, 1)
			expect(board.towers[0].size).to eq(2)
		end
		
	end
	
end

describe Transformer do
	let (:tower_of_1) { Tower.new([1]) }
	let (:tower_of_2) { Tower.new([2, 1]) }

	context "#pad_rings" do
		it "only pads when length > rings.length" do
			result = Transformer.pad_rings([], 0)
			expect(result).to eq([])
		end
		it "pads rings to a given length" do
			result = Transformer.pad_rings([], 1).length
			expect(result).to eq(1)
		end
	end

	context "#towers_to_rows" do
		it "maps 1 tower" do
			towers = [tower_of_1]
			result = Transformer.towers_to_rows(towers, 1)
			expected = [[1]]
			expect(result).to eq(expected)
		end

		it "maps 2 towers with 3 rings" do
			towers = [tower_of_2, tower_of_1]
			result = Transformer.towers_to_rows(towers, 2)
			expected = [ [2, 1], [1, nil]]
			expect(result).to eq(expected)
		end

	end

end

describe View do
	let (:tower_of_1) { Tower.new([1]) }
	let (:tower_of_2) { Tower.new([2, 1]) }

	context '#render_thing' do
		it 'renders a thing of 1 for width of 1' do 
			result = View.render_thing(1, 1, '*', "\s")
			expect(result).to eq('**')
		end
		it 'renders a thing of 1 for width of 2' do 
			result = View.render_thing(1, 2, '*', "\s")
			expect(result).to eq(' ** ')
		end
		it 'renders a thing of 2 for width of 3' do 
			result = View.render_thing(2, 3, '*', "\s")
			expect(result).to eq(' **** ')
		end
	end

	context "#render_ring" do
		it "renders a ring of 2 for a tower height of 2" do
			result = View.render_ring(1, 2)
			expect(result).to eq(' ** ')
		end
	end

	context "#render_peg" do
		it "renders a peg for a tower height of 2" do
			result = View.render_peg(2)
			expect(result).to eq(' || ')
		end
	end

	# context "#render_board" do
	# 	it "renders a board with 1 tower and 1 ring" do
	# 		board = Board.new([tower_of_1])
	# 		result = View.render_board(board)
	# 		expect(result).to eq("1")
	# 	end
	# 	it "renders a board with 1 tower and 2 rings" do
	# 		board = Board.new([tower_of_2])
	# 		result = View.render_board(board)
	# 		expect(result).to eq("1\n2")
	# 	end
	# 	it "renders a board with 2 tower and 2 rings" do
	# 		board = Board.new([tower_of_1, tower_of_1])
	# 		result = View.render_board(board)
	# 		expect(result).to eq("1 1")
	# 	end
	# 	it "renders a board with 2 tower and 4 rings" do
	# 		board = Board.new([tower_of_2, tower_of_2])
	# 		result = View.render_board(board)
	# 		expect(result).to eq("1 1\n2 2")
	# 	end
	# 	it "renders a board with 2 tower and 3 rings" do
	# 		board = Board.new([tower_of_2, tower_of_1])
	# 		result = View.render_board(board)
	# 		expect(result).to eq("1 |\n2 1")
	# 	end
	# end
	
end

describe Game do

	it "knows when a game is won" do
		game = Game.new(1, 2).move(0, 1)
		result = game.won?
		expect(result).to eq(true)
	end

	context "#create_tower" do
		it "returns an empty tower" do
			result = Game.create_tower.size
			expect(result).to eq(0)
		end

		it "returns with 3 pieces" do
			result = Game.create_tower(3).size
			expect(result).to eq(3)
		end
	end
end