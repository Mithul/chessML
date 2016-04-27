json.array!(@games) do |game|
  json.extract! game, :id, :winner_id, :loser_id, :start_time, :end_time, :board
  json.url game_url(game, format: :json)
end
