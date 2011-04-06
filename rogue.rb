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
		t_1.contents = [i] + t_1.contents
		# t_1 = Tile.new(:tile_type => t.tile_type, :contents => [i] + t.contents, :hidden => t.hidden, :closed => t.closed, :direction => t.direction)

		put_tile(pos, t_1)
	end

	def to_s
		@tiles.collect { |row| row.collect { |t| t.to_s }.join "" }.join "\n"
	end
end

class Game
	attr_accessor :levels, :player_level, :player_pos

	def self.makeStairs
		upstairPos = [rand(COLS), rand(ROWS)]

		downstairPos = upstairPos

		while downstairPos[0] == upstairPos[0] || downstairPos[1] == upstairPos[1]
			downstairPos = [rand(COLS), rand(ROWS)]
		end

		[upstairPos, downstairPos]
	end

	def initialize(levels = [Level.new] * LEVELS, player_level = 0, player_pos = [0, 0])
		@levels = levels
		@player_level = player_level
		@player_pos = player_pos
	end

	def self.gen
		g = Game.new

		lev = Level.new

		upstairPos, downstairPos = makeStairs

		lev_1 = lev.put_tile(upstairPos, Tile.new(:tile_type => :stair, :direction => :up))

		lev_2 = lev_1.put_tile(downstairPos, Tile.new(:tile_type => :stair, :direction => :down))

		g.levels = [lev_2] * LEVELS
		g.player_level = 0
		g.player_pos = upstairPos

		g
	end

	def to_s
		lev = @levels[@player_level]

		lev_1 = lev.put_item(@player_pos, Player.new)
		lev_1.to_s
	end

	def draw
		s = to_s.split "\n"
		0.upto(ROWS).each { |y|
			setpos(y, 0)
			addstr(s[y])
		}
	end

	def loop
		draw

		g = case getch
		when ?Q, ?q: return
		when Key::UP: move(:up)
		when Key::DOWN: move(:down)
		when Key::LEFT: move(:left)
		when Key::RIGHT: move(:right)
		else
			self
		end

		g.loop
	end

	def move(direction)
		x, y = @player_pos

		pos_1 = case direction
			when :up
				if y == 0 then
					[x, y]
				else
					[x, y - 1]
				end
			when :down
				if y == ROWS - 1 then
					[x, y]
				else
					[x, y + 1]
				end
			when :left
				if x == 0 then
					[x, y]
				else
					[x - 1, y]
				end
			when :right
				if x == COLS - 1 then
					[x, y]
				else
					[x + 1, y]
				end
		end

		g_2 = dup
		g_2.player_pos = pos_1
		g_2
	end
end

def main
	begin
		init_screen
		crmode
		noecho
		timeout = 0
		stdscr.keypad(true)

		Game.gen.loop
	ensure
		close_screen
	end
end

if __FILE__==$0
	begin
		main
	rescue Interrupt => e
		nil
	end
end