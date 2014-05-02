require File.expand_path("../spec_helper", __FILE__)

describe Tower do
	let(:tower) { Tower.new(1, [1]) }
	after(:each) { tower = nil }

	it "#ring_count" do
		expect(tower.ring_count).to eq(1)
	end  

	it "#add" do
		expect(tower.add('foo').top).to eq('foo')
	end  

	it "#add" do
		expect(tower.add('foo').ring_count).to eq(2)
	end

	it "#remove" do
		expect(tower.remove.ring_count).to eq(0)
	end

	it "#full?" do
		expect(tower.full?).to eq(true)
	end

	context "#sorted?" do
		it "is true when sorted" do
			tower = Tower.new(2, [2, 1])
			expect(tower.sorted?).to eq(true)
		end

		it "is false when unsorted" do
			tower = Tower.new(2, [1, 2])
			expect(tower.sorted?).to eq(false)
		end
	end

end

describe Board do

	it "only creates board with 2 or more towers" do
		expect { Board.new }.to raise_error
	end

	context "#won?" do
		let(:tower_empty) { Tower.new(2) }
		let(:tower_sorted) { Tower.new(2, [2, 1]) }
		let(:tower_unsorted) { Tower.new(2, [1, 2]) }

		it "is true when all rings are moved to a new ring" do
			board = Board.new([ tower_empty, tower_sorted ])
			expect(board.won?).to eq(true)
		end

		it "is true when all rings are sorted" do
			board = Board.new([ tower_empty, tower_sorted ])
			expect(board.won?).to eq(true)
		end

		it "is false when rings rings are not sorted" do
			board = Board.new([ tower_empty, tower_unsorted ])
			expect(board.won?).to eq(false)
		end
	end

	context	"#move" do
		let(:tower_a) { Tower.new(3, [3, 2]) }
		let(:tower_b) { Tower.new(3, [1]) }
		let(:tower_c) { Tower.new(3, []) }

		let(:board) { Board.new([ tower_a, tower_b, tower_c ]) }
		after(:each) { board = nil }

		it "removes a ring" do
			b = board.move(1, 0)
			expect(b.rings_on_tower(1)).to eq(0)
		end
		it "adds ring to t2" do
			b = board.move(1, 0)
			expect(b.rings_on_tower(0)).to eq(3)
		end
		it "ignores moves on empty rings" do
			b = board.move(2, 0)
			expect(b.rings_on_tower(0)).to eq(2)
		end
		it "enforces order" do
			b = board.move(0, 1)
			expect(b.rings_on_tower(1)).to eq(1)
		end
	end
	
end

describe Transformer do
	let (:tower_of_1) { Tower.new(2, [1]) }
	let (:tower_of_2) { Tower.new(2, [2, 1]) }

	context "#pad_rings" do
		it "only pads when length > rings.length" do
			result = Transformer.pad_rings([], 0)
			expect(result).to eq([])
		end
		it "pads rings to a given length" do
			result = Transformer.pad_rings([], 1)
			expect(result.length).to eq(1)
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
	let (:tower_of_1) { Tower.new(1, [1]) }
	let (:tower_of_2) { Tower.new(2, [2, 1]) }

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

	context "#render_board" do
		it "must contain letters" do
			board = Board.new([tower_of_1, tower_of_1])
			result = View.render_board(board)

			# We don't need no stinkin' unit test!
			expect(result.length > 0).to eq(true)
		end
	end
	
end

describe Game do

	it "knows when a game is won" do
		game = Game.new(1, 2).move(0, 1)
		result = game.won?
		expect(result).to eq(true)
	end

	context "#create_board" do
		it "returns a board" do
			result = Game.create_board(3, 3)
			expect(result.class).to eq(Board)
		end
	end

	context "#create_tower" do
		it "returns an empty tower" do
			result = Game.create_tower(3).ring_count
			expect(result).to eq(0)
		end

		it "returns with 3 pieces" do
			result = Game.create_tower(3, 3).ring_count
			expect(result).to eq(3)
		end
	end

end

describe Solver do
	let (:simple_game) { Game.new(1, 3) }
	let (:normal_game) { Game.new(3, 3) }

	context "#solve" do
		it "calls a block with the game as a parameter for each step" do
			game = Solver.new(simple_game).solve do |game|
				expect(game.class).to eq(Game)
			end
		end

		it "acts on the board" do
			game = Solver.new(simple_game).solve

			board = game.board

			expect(board.rings_on_tower(0)).to eq(0)
			expect(board.rings_on_tower(1)).to eq(1)
		end

		it "can win a game" do
			game = Solver.new(normal_game).solve

			expect(game.won?).to eq(true)
		end
	end
	
end