#!/usr/bin/env ruby

require "curses"
include Curses

LEVELS = 26
ROWS = 24
COLS = 80

class Tile
	attr_accessor :tile_type, :contents, :hidden, :closed, :direction

	def initialize(options)
		@tile_type = options[:tile_type] || :floor
		@contents = options[:contents] || []
		@hidden = options[:hidden] || false
		@closed = options[:closed] || true
		@direction = options[:direction] || :up
	end

	def to_s
		if @hidden then
			" "
		elsif @contents.length > 0 then
			@contents.first.to_s
		else
			case @tile_type
			when :floor:
				"."
			when :wall:
				"\#"
			when :door:
				if @closed then
					"+"
				else
					"\\"
				end
			when :stair:
				if @direction == :up then
					"<"
				else
					">"
				end
			else
				" "
			end
		end
	end
end

class Item
	attr_accessor :action

	def action(g)
		g
	end

	def to_s
		"i"
	end
end

class Player < Item
	def to_s
		"@"
	end
end

class Level
	attr_accessor :tiles

	def initialize(tiles = [[Tile.new(:tile_type => :floor)] * COLS] * ROWS)
		@tiles = tiles
	end

	def get_tile(pos)
		@tiles[pos[1]][pos[0]]
	end

	def put_tile(pos, t)
		x, y = pos

		rows_before = @tiles.slice(0, y)
		rows_cur = @tiles[y]
		rows_after = @tiles.slice(y + 1, @tiles.length)
		cols_before = rows_cur.slice(0, x)
		cols_after = rows_cur.slice(x + 1, rows_cur.length)
		
		Level.new(tiles = rows_before + [cols_before + [t] + cols_after] + rows_after)

		# lev_1 = Level.new(tiles = @tiles.collect { |row| row.collect { |t| t.dup }})
		# lev_1.tiles[y][x] = t
		# lev_1
	end

	def get_item(pos)
		c = get_tile(pos).contents

		if c.length < 1
			nil
		else
			c.first
		end
	end

	def put_item(pos, i)
		t = get_tile(pos)
		t_1 = t.dup
		t_1.contents << i
		put_tile(pos, t)
	end

	def to_s
		@tiles.collect { |row| row.collect { |t| t.to_s }.join "" }.join "\n"
	end
end

class Game
	attr_accessor :levels, :player_level, :player_pos

	def makeStairs
		upstairPos = [rand(COLS), rand(ROWS)]

		downstairPos = upstairPos

		while downstairPos[0] == upstairPos[0] || downstairPos[1] == upstairPos[1]
			downstairPos = [rand(COLS), rand(ROWS)]
		end

		[upstairPos, downstairPos]
	end

	def initialize
		lev = Level.new

		upstairPos, downstairPos = makeStairs

		lev_1 = lev.put_tile(upstairPos, Tile.new(:tile_type => :stair, :direction => :up))

		lev_2 = lev_1.put_tile(downstairPos, Tile.new(:tile_type => :stair, :direction => :down))

		@levels = [lev_2] * LEVELS
		@player_level = 0
		@player_pos = upstairPos
	end

	def to_s
		lev = @levels[@player_level]

		lev_1 = lev.put_item(@player_pos, Player.new)
		lev_1.to_s
	end
end

def main
	puts Game.new

	# begin
	# 	init_screen
	# 	crmode
	# 	noecho
	# 	timeout = 0
	# 
	# 	loop do
	# 		case getch
	# 		when ?Q, ?q: break
	# 		# when Key::UP: paddle.up 
	# 		# when Key::DOWN: paddle.down 
	# 		# when Key::RIGHT: paddle.right
	# 		# when Key::LEFT: paddle.left 
	# 		else 
	# 			#beep
	# 		end
	# 
	# 		# ...
	# 	end
	# ensure
	# 	close_screen
	# end
end

if __FILE__==$0
	begin
		main
	rescue Interrupt => e
		nil
	end
end