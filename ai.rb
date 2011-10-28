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

  def read_intro
    line=@stdin.gets.strip
    warn "unexpected: #{line}" unless line =='turn 0'

    until((line=@stdin.gets.strip)=='ready')
      parse_intro(line)
    end

  end

  # Internal; reads zero-turn input (game settings).
  def parse_intro(line)
    _, name, value = *line.match(/\A([a-z0-9]+) (\d+)\Z/)

    case name
    when 'loadtime'
      @loadtime=value.to_i
    when 'turntime'
      @turntime=value.to_i
    when 'rows'
      @rows=value.to_i
    when 'cols'
      @cols=value.to_i
    when 'turns'
      @turns=value.to_i
    when 'viewradius2'
      @viewradius2=value.to_i
      @viewradius=Math.sqrt @viewradius2
    when 'attackradius2'
      @attackradius2=value.to_i
      @attackradius=Math.sqrt @attackradius2
    when 'spawnradius2'
      @spawnradius2=value.to_i
      @spawnradius=Math.sqrt @spawnradius2
    when 'seed'
      @seed=value.to_i
    else
      warn "unexpected: #{line}"
    end
  end

  # Internal; reads turn input (map state).
  def read_turn
    rd=@stdin.gets.strip

    if rd=='end'
      parse_end
    else
      _, num = *rd.match(/\Aturn (\d+)\Z/)
      @turn_number=num.to_i
    end

    # reset the map data
    @map.reset!

    until((line=@stdin.gets.strip)=='go')
      parse_turn(line)
    end

    return game_over?
  end

  def parse_end
      @turn_number=:game_over

      rd=@stdin.gets.strip
      _, players = *rd.match(/\Aplayers (\d+)\Z/)
      @players = players.to_i

      rd=@stdin.gets.strip
      _, score = *rd.match(/\Ascore (\d+(?: \d+)+)\Z/)
      @score = score.split(' ').map{|s| s.to_i}
  end

  def parse_turn(line)
      _, type, row, col, owner = *line.match(/(w|f|h|a|d) (\d+) (\d+)(?: (\d+)|)/)
      row, col = row.to_i, col.to_i
      owner = owner.to_i if owner

      case type
      when 'w'
        @map[row][col].water=true
      when 'f'
        @map[row][col].food=true
        @map.food << @map[row][col]
      when 'h'
        @map[row][col].hill = owner
      when 'a'
        a=Ant.new( :alive => true, :owner => owner, :square => @map[row][col])

        if a.mine?
          map.my_ants.push(a)
        else
          map.enemy_ants.push(a)
        end
      when 'd'
        Ant.new( :alive => false, :owner => owner, :square => @map[row][col])
      when 'r'
        # pass
      else
        warn "unexpected: #{line}"
      end
  end

  def game_over?
    return @turn_number == :game_over
  end
end
