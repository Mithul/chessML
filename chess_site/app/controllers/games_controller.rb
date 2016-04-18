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
    if !@game.winner == current_user
      @color = 'white'
    else
      @color = 'black'
    end
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
      puts player.get_statistics().length
    end
    pmoves = piece.check_possible_moves.map{|c| [c[0],c[1]]}
    cmove = [to[0].to_i,to[1].to_i]
    if !(pmoves.include?(cmove))
      puts pmoves.to_s,cmove.to_s
      puts "no"
      render :text=> 'Invalid Move'
      return
    end
    move, change = player.make_move(piece,[to[0].to_i,to[1].to_i])
    current_board = {board: Marshal.load(Marshal.dump(board)).dup, move: nil}
    # puts current_board
    current_board[:move] = move
    player.add_board current_board
    if change == true
      game.end_time = Time.now
      game.save
      player.generate_statistics player.get_boards,color,opp_color
      $Old_boards = player.get_statistics
      ::ML.write_file Rails.root.join('config/initializers','statistics2.dat'), $Old_boards
      render :text => 'Game over'
      return
    end
    board = player.get_board
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
      return
    end
    board = opp.get_board
    handle.set_board board
    game.board = handle.compress_board
    game.save
    render :text => 'done'
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)
    handle = BoardHandle.new
    handle.new_board
    @game.board = handle.compress_board
    @game.start_time = Time.now
    @game.winner = current_user
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
      params.require(:game).permit(:winner_id, :loser_id, :start_time, :end_time, :board)
    end
end
