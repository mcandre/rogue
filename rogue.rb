#!/usr/bin/env ruby

require "curses"
include Curses

def main
	begin
		init_screen
		crmode
		noecho
		timeout = 0

		loop do
			case getch
			when ?Q, ?q: break
			# when Key::UP: paddle.up 
			# when Key::DOWN: paddle.down 
			# when Key::RIGHT: paddle.right
			# when Key::LEFT: paddle.left 
			else 
				#beep
			end

			# ...
		end
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