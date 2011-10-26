#!/usr/bin/env sh
./playgame.py --player_seed 42 --end_wait=0.25 --verbose --log_dir game_logs --turns 100 --map_file maps/tutorial/example1.map "$@" "python sample_bots/python/LeftyBot.py" "ruby ../Durandal.rb"
