require 'ants'
class AI
    # Map, as an array of arrays.
    attr_accessor :map
    # Number of current turn. If it's 0, we're in setup turn. If it's :game_over, you don't need to give any orders; instead, you can find out the number of players and their scores in this game.
    attr_accessor	:turn_number

    # Game settings. Integers.
    attr_accessor :loadtime, :turntime, :rows, :cols, :turns, :viewradius2, :attackradius2, :spawnradius2, :seed
    # Radii, unsquared. Floats.
    attr_accessor :viewradius, :attackradius, :spawnradius

    # Number of players. Available only after game's over.
    attr_accessor :players
    # Array of scores of players (you are player 0). Available only after game's over.
    attr_accessor :score

    # Initialize a new AI object. Arguments are streams this AI will read from and write to.
    def initialize stdin=$stdin, stdout=$stdout
        @stdin, @stdout = stdin, stdout

        @map=nil
        @turn_number=0

        @my_ants=[]
        @enemy_ants=[]

        @did_setup=false
    end

    # Returns a read-only hash of all settings.
    def settings
        {
            :loadtime => @loadtime,
            :turntime => @turntime,
            :rows => @rows,
            :cols => @cols,
            :turns => @turns,
            :viewradius2 => @viewradius2,
            :attackradius2 => @attackradius2,
            :spawnradius2 => @spawnradius2,
            :viewradius => @viewradius,
            :attackradius => @attackradius,
            :spawnradius => @spawnradius,
            :seed => @seed
        }.freeze
    end

    # Zero-turn logic. 
    def setup # :yields: self
        read_intro
        yield self

        @stdout.puts 'go'
        @stdout.flush

        @map = Map.new(:rows => @rows, :cols => @cols)
        @did_setup=true
    end

    # Turn logic. If setup wasn't yet called, it will call it (and yield the block in it once).
    def run &b # :yields: self
        setup &b if !@did_setup

        over=false
        until over
            over = read_turn
            yield self

            @stdout.puts 'go'
            @stdout.flush
        end
    end

    # Internal; reads zero-turn input (game settings).
    def read_intro
        rd=@stdin.gets.strip
        warn "unexpected: #{rd}" unless rd=='turn 0'

        until((rd=@stdin.gets.strip)=='ready')
            _, name, value = *rd.match(/\A([a-z0-9]+) (\d+)\Z/)

            case name
            when 'loadtime'; @loadtime=value.to_i
            when 'turntime'; @turntime=value.to_i
            when 'rows'; @rows=value.to_i
            when 'cols'; @cols=value.to_i
            when 'turns'; @turns=value.to_i
            when 'viewradius2'; @viewradius2=value.to_i
            when 'attackradius2'; @attackradius2=value.to_i
            when 'spawnradius2'; @spawnradius2=value.to_i
            when 'seed'; @seed=value.to_i
            else
                warn "unexpected: #{rd}"
            end
        end

        @viewradius=Math.sqrt @viewradius2
        @attackradius=Math.sqrt @attackradius2
        @spawnradius=Math.sqrt @spawnradius2
    end

    # Internal; reads turn input (map state).
    def read_turn
        ret=false
        rd=@stdin.gets.strip

        if rd=='end'
            @turn_number=:game_over

            rd=@stdin.gets.strip
            _, players = *rd.match(/\Aplayers (\d+)\Z/)
            @players = players.to_i

            rd=@stdin.gets.strip
            _, score = *rd.match(/\Ascore (\d+(?: \d+)+)\Z/)
            @score = score.split(' ').map{|s| s.to_i}

            ret=true
        else
            _, num = *rd.match(/\Aturn (\d+)\Z/)
            @turn_number=num.to_i
        end

        # reset the map data
        @map.reset!

        @my_ants=[]
        @enemy_ants=[]

        until((rd=@stdin.gets.strip)=='go')
            _, type, row, col, owner = *rd.match(/(w|f|h|a|d) (\d+) (\d+)(?: (\d+)|)/)
            row, col = row.to_i, col.to_i
            owner = owner.to_i if owner

            case type
            when 'w'
                @map[row][col].water=true
            when 'f'
                @map[row][col].food=true
            when 'h'
                @map[row][col].hill=owner
            when 'a'
                a=Ant.new( :alive => true, :owner => owner, :square => @map[row][col])
                @map[row][col].ant = a

                if a.mine?
                    my_ants.push a
                else
                    enemy_ants.push a
                end
            when 'd'
                d = Ant.new( :alive => false, :owner => owner, :square => @map[row][col])
                @map[row][col].ant = d
            when 'r'
                # pass
            else
                warn "unexpected: #{rd}"
            end
        end

        return ret
    end

    # call-seq:
    #   order(ant, direction)
    #   order(row, col, direction)
    #
    # Give orders to an ant, or to whatever happens to be in the given square (and it better be an ant).
    def order a, b, c=nil
        if !c # assume two-argument form: ant, direction
            ant, direction = a, b
            @stdout.puts "o #{ant.row} #{ant.col} #{direction.to_s.upcase}"
        else # assume three-argument form: row, col, direction
            col, row, direction = a, b, c
            @stdout.puts "o #{row} #{col} #{direction.to_s.upcase}"
        end
    end

    # Returns an array of your alive ants on the gamefield.
    def my_ants; @my_ants; end
    # Returns an array of alive enemy ants on the gamefield.
    def enemy_ants; @enemy_ants; end

end
