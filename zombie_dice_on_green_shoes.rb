require 'green_shoes'

Die = Struct.new :img, :color, :side
Player = Struct.new :name, :score, :bangs, :brains, :runs
DICE, WIN, GUNNED = [], [], []
BRAINS, BANGS, RUNS = [50, 100], [400, 100], [230, 350]

Shoes.app title: 'Zombie Dice' do
  def roll
    (3 - @player.runs.length).times{@player.runs << @dice.pop}
    show_dice @player.runs, RUNS
    @check.show
    @roll.hide
  end

  def check
    return if @player.runs.empty?
    tmp = []
    @player.runs.each do |d|
      case d.side
      when :bang; @player.bangs << d
      when :brain; @player.brains << d
      when :run; tmp << d
      else end
    end
    @player.runs = tmp
    show_dice @player.bangs, BANGS
    show_dice @player.brains, BRAINS
    show_dice @player.runs, RUNS
    @check.hide
    if @player.runs.length == 3
      alert 'Oh, Three Footprints. ROLL again.'
      @player.runs.each{|d| d.img.hide}
      @player.runs = []
      @roll.show
      return
    end
    if @player.bangs.length > 2
      GUNNED.each &:show
    else
      [@ss, @kg].each &:show
    end
  end

  def show_dice dice, area
    dice.each_with_index do |d, i|
      d.img.show.move area[0] + i * 55, area[1]
    end
  end

  def make_score name
    @players.map do |u|
      line = "%10s: %2d Brains\n" % [u.name, u.score]
      u.name == name ? bg(line, yellow) : line
    end.join
  end

  def turn_next_player first = nil
    @dice = DICE.sort_by{rand}
    if first
      @player = @players[0]
    else
      DICE.each{|d| d.img.hide}
      [@ss, @kg].each &:hide
      @player.score += @player.brains.length
      (WIN.each &:show; return) if @player.score > 12
      @player = @players[(@players.index(@player) + 1) % @players.length]
      @score.text = make_score @player.name
      @player.bangs, @player.brains, @player.runs = [], [], []
      @roll.show
    end
  end

  background tan
  nostroke
  @players = %w[ashbb kira].map{|name| Player.new name, 0, [], [], []}
  @score = para make_score @players.first.name

  copy = [1, 3, 2, 3, 1, 2, 2, 2, 2]
  Dir['./dice/*.png'].each_with_index do |file, i|
    color, side = File.basename(file, '.png').split('_')
    copy[i].times{DICE << Die.new(image(file, hidden: true), color, side.to_sym)}
  end

  @roll = button("SHAKE\nTAKE\nROLL"){roll}
  @roll.hide.move(500, 300).style width: 80, height: 60
  @check = button('CHECK'){check}.hide
  @check.move(500, 400).style width: 80

  @ss = button('Stop and Score'){turn_next_player}
  @ss.hide.move(100, 450).style width: 100
  @kg = button('Keep Going'){[@ss, @kg].each &:hide; @roll.show}
  @kg.hide.move(400, 450).style width: 100

  GUNNED << rect(100, 120, 400, 300, curve: 20, fill: rgb(183, 0, 0))
  GUNNED << para('You got', left: 150, top: 170)
  GUNNED << title('SHOT GUNNED!', left: 150, top: 220)
  GUNNED << button("next player's turn"){
    @player.brains = []
    GUNNED.each &:hide
    turn_next_player
  }
  GUNNED.last.move(350, 350).style width: 130
  GUNNED.each &:hide

  WIN << rect(100, 120, 400, 300, curve: 20, fill: white.push(0.4))
  WIN << title('YOU WIN!!', left: 150, top: 220)
  WIN << button('Exit'){close}
  WIN.last.move(400, 350).style width: 50
  WIN << button('Start Over'){
    @players.each{|p| p.score, p.bangs, p.brains, p.runs = 0, [], [], []}
    WIN.each &:hide
    DICE.each{|d| d.img.hide}
    turn_next_player
  }
  WIN.last.move(150, 350).style width: 150
  WIN.each &:hide

  opening = []
  opening << para(strong("Zombie\nDice"), left: 100, top: 100, size: 72)
  opening << button('Start'){opening.clear; @roll.show}
  opening.last.move(100, 400).style width: 50
  opening << button('Exit'){close}
  opening.last.move(450, 400).style width: 50

  turn_next_player :first
end
