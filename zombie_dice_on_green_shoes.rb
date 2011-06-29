require 'green_shoes'

Die = Struct.new :img, :color, :side, :imgs
Player = Struct.new :name, :score, :bangs, :brains, :runs
DICE, WIN, GUNNED = [], [], []
BRAINS, BANGS, TAKES, RUNS = [50, 100], [350, 100], [350, 200], [160, 380]
RED = [%w[brain run run bang bang bang], :red, 3]
YELLOW = [%w[brain brain run run bang bang], :yellow, 4]
GREEN = [%w[brain brain brain run run bang], :green, 6]

class Array
  def method_missing m
    self.each &m
  end
end

class Die
  def shake
    img.hide
    self.img, self.side = imgs[rand 6]
  end
end

class Shoes
  class Button
    def place top = 200
      tap{|s| s.hide.move(450, top).style width: 100, height: 100}
    end
  end
end

Shoes.app title: 'Zombie Dice v0.1' do
  def take
    (3 - @player.runs.length).times{@player.runs << @dice.pop}
    show_dice @player.runs, TAKES, :vertical
    @take.hide
    @roll.show
  end

  def roll
    @player.runs.shake
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
    @player.bangs.length > 2 ? GUNNED.show : [@ss, @kg].show
  end

  def show_dice dice, area, flag = nil
    dice.each_with_index do |d, i|
      i, j = flag ? [0, i] : [i%3, i/3]
      d.img.show.move area[0] + i * 55, area[1] + j * 55
    end
  end

  def make_score name
    @players.map do |u|
      line = "%10s\t: %2d Brains\n" % [u.name, u.score]
      u.name == name ? bg(line, yellow) : line
    end.join
  end

  def turn_next_player first = nil
    @dice = DICE.sort_by{rand}
    (@player = @players[0]; return) if first
    DICE.each{|d| d.img.hide}
    [@ss, @kg, @hand].hide
    @player.score += @player.brains.length
    if @player.score > 12
      @score.text = make_score @player.name
      WIN.show
    else
      @player = @players[(@players.index(@player) + 1) % @players.length]
      @score.text = make_score @player.name
      @player.bangs, @player.brains, @player.runs = [], [], []
      [@hand, @take].show
    end
  end

  background dimgray
  nostroke
  @hand = rect TAKES[0]-10, TAKES[1]-10, 220, 250, curve: 10, fill: gray, hidden: true
  @players = %w[ashbb April].map{|name| Player.new name, 0, [], [], []}
  @score = para make_score @players.first.name

  [RED, YELLOW, GREEN].each do |sides, color, n|
    n.times do
      imgs = sides.map{|side| [image("./dice/#{color}_#{side}.png", hidden: true), side.to_sym]}
      i = rand 6
      DICE << Die.new(imgs[i][0], color, sides[i].to_sym, imgs)
    end
  end

  @take = button("SHAKE & TAKE"){take}.place
  @roll = button("ROLL"){roll}.place
  @check = button('CHECK'){check}.place
  @ss = button('Stop and Score'){turn_next_player}.place 330
  @kg = button('Keep Going'){
    [@ss, @kg].hide
    show_dice @player.runs, TAKES, :vertical
    @player.runs.length < 3 ? @take.show : @roll.show
  }.place

  GUNNED << rect(100, 120, 400, 300, curve: 20, fill: rgb(183, 0, 0, 0.7))
  GUNNED << para('You got', left: 150, top: 170)
  GUNNED << title('SHOT GUNNED!', left: 150, top: 220)
  GUNNED << button("next player's turn"){
    @player.brains = []
    GUNNED.hide
    turn_next_player
  }
  GUNNED.last.move(350, 350).style width: 130
  GUNNED.hide

  WIN << rect(100, 120, 400, 300, curve: 20, fill: white.push(0.4))
  WIN << title('YOU WIN!!', left: 150, top: 220)
  WIN << button('Exit'){close}
  WIN.last.move(400, 350).style width: 50
  WIN << button('Start Over'){
    @players.each{|p| p.score, p.bangs, p.brains, p.runs = 0, [], [], []}
    WIN.hide
    DICE.each{|d| d.img.hide}
    turn_next_player
  }
  WIN.last.move(150, 350).style width: 150
  WIN.hide

  opening = []
  opening << para(strong("Zombie\nDice"), left: 100, top: 100, size: 72)
  opening << button('Start'){opening.clear; [@hand, @take].show}
  opening.last.move(100, 400).style width: 50
  opening << button('Exit'){close}
  opening.last.move(450, 400).style width: 50

  turn_next_player :first
end
