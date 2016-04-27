class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    if !current_user
      redirect_to new_session_path
    end
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  def play
    @game = Game.find(params[:id])
    @handle = BoardHandle.new
    @cboard = eval @game.board
    @board = @handle.decompress_board @cboard
    if @game.winner != current_user
      @color = 'white'
    else
      @color = 'black'
    end
    puts @color
  end

  def check_move
    game = Game.find(params[:id])
    json = {success: true}
    if game.end_time
      json[:success] = false
      render :json => json
      return
    end
    handle = BoardHandle.new
    cboard = eval game.board
    board = handle.decompress_board cboard
    from = params[:from]
    tile=handle.get_piece from
    piece=tile.piece
    pmoves = piece.check_possible_moves.map{|c| c[0].to_s+c[1].to_s}
    json[:moves]=pmoves
    render :json => json
  end

  def move
    game = Game.find(params[:id])
    if game.end_time
      render :text => 'Game over'
      return
    end
    handle = BoardHandle.new
    cboard = eval game.board
    board = handle.decompress_board cboard
    from = params[:from]
    to = params[:to]
    # puts cboard.to_s
    tile=handle.get_piece from
    piece=tile.piece
    # handle.make_move(piece,[to[0].to_i,to[1].to_i])
    if game.winner == current_user
      color="white"
      opp_color = "black"
    else
      opp_color="white"
      color = "black"
    end
    king = handle.get_king(color)
    puts '*'*100
    puts king
    puts $Old_boards.length
    player = $Players[game.id]
    if !player
      player = Player.new(color,board,handle.get_pieces(color), king, nil, $Old_boards)
      $Players[game.id] = player
      puts player.get_statistics().length
    end
    player.set_board board
    pmoves = piece.check_possible_moves.map{|c| [c[0],c[1]]}
    cmove = [to[0].to_i,to[1].to_i]
    if !(pmoves.include?(cmove))
      puts pmoves.to_s,cmove.to_s
      puts "no"
      render :text=> 'Invalid Move'
      return
    end
    move, change = player.make_move(piece,[to[0].to_i,to[1].to_i])
    if change == true
      game.end_time = Time.now
      game.save
      player.generate_statistics player.get_boards,color,opp_color
      $Old_boards = player.get_statistics
      ::ML.write_file Rails.root.join('config/initializers','statistics2.dat'), $Old_boards
      render :text => 'Game over'
      $Players[game.id] = nil
      return
    elsif change
      puts 'need to change to '+change.class.to_s
      player.change_piece piece, change
    end
    board = player.get_board
    current_board = {board: Marshal.load(Marshal.dump(board)).dup, move: nil}
    # puts current_board
    current_board[:move] = move
    player.add_board current_board
    king = handle.get_king(opp_color)
    puts '*'*100
    opp = Player.new(opp_color,board,handle.get_pieces(opp_color), king, nil, $Old_boards)
    change = opp.play
    if change == true
      game.end_time = Time.now
      game.save
      $Old_boards = opp.get_statistics
      ::ML.write_file Rails.root.join('config/initializers','statistics2.dat'), $Old_boards
      render :text => 'Game over'
      $Players[game.id] = nil
      return
    end
    # board = opp.get_board
    # handle.set_board board
    game.board = opp.compress_board
    game.save
    render :text => 'done'
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    handle = BoardHandle.new
    handle.new_board
    bot = User.where(:bot => true).first
    @game.board = handle.compress_board
    no_players = params[:user][:no_players].to_i    
    color = params[:user][:color] 
    if no_players == 1   
      @game.start_time = Time.now
      if color == "white"
        @game.winner = current_user
        @game.loser = bot
      elsif color == "black"
        @game.winner = bot
        @game.loser = current_user
        puts 'White is gonna play'
        board = handle.decompress_board(eval @game.board)
        # board = @game.board
        opp_color = "white"
        king = handle.get_king(opp_color)
        opp = Player.new(opp_color,board,handle.get_pieces(opp_color), king, nil, $Old_boards)
        change = opp.play
        @game.board = opp.compress_board
      end
    else
      if color == "white"
        @game.winner = current_user
        @game.loser = nil
      elsif color == "black"
        @game.winner = nil
        @game.loser = current_user
      end
    end
    puts color
    @game.save
    redirect_to play_path(@game)
    # respond_to do |format|
    #   if @game.save
    #     format.html { redirect_to @game, notice: 'Game was successfully created.' }
    #     format.json { render :show, status: :created, location: @game }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @game.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:winner_id, :loser_id, :start_time, :end_time, :board, :no_players)
    end
end