$: << File.join(File.dirname(__FILE__), "../lib/proto")

require "grpc"
require "planner_services_pb"

MODES = %w(start vote)
ACCEPTED_RATES = [1, 2, 3, 5, 8]

mode = ARGV[0]
number = ARGV[1].to_i
name = ARGV[2]
poker_id = ARGV[3]

abort("Mode should be one of #{MODES.join(', ')}") unless MODES.include? mode

abort("Rate should be one of #{ACCEPTED_RATES.join(', ')}") if mode == 'vote' && !ACCEPTED_RATES.include?(number)

planner_server = Planner::Poker::Stub.new("localhost:50051", :this_channel_is_insecure)

if mode == 'start'
    poker_id = planner_server.new_poker(Planner::NewPokerRequest.new(team_size: number)).poker_id
    print "Poker started now. Poker id:\n"
    print poker_id + "\n"
elsif mode == 'vote'
    resp = planner_server.vote_poker(Planner::VotePokerRequest.new(poker_id: poker_id, vote: {name: name, note: number.to_i}))
    error = resp.error
    if error.length > 0
        abort(error)
    end
    team_size = resp.team_size
    votes = resp.votes
    votes_count = votes.length
    votes_left = team_size - votes.length
    while votes_left > 0
        info = "=> [#{'#'*votes_count}#{' '*votes_left}] [#{votes_count} out of #{team_size} votes added]\r"
        print info
        sleep 1
        $stdout.flush
        resp = planner_server.get_poker(Planner::GetPokerRequest.new(poker_id: poker_id))
        team_size = resp.team_size
        votes = resp.votes
        votes_count = votes.length
        votes_left = team_size - votes.length
    end

    merged_votes = votes.inject({}) { |hash, planner_vote| hash.merge({planner_vote.name => planner_vote.note})}
    votes_array = ACCEPTED_RATES.map {|r| merged_votes.select {|k, v| v == r}.keys }
    votes_count_map = votes_array.map(&:length)
    biggest_vote_count = votes_count_map.max

    winning_indices = ACCEPTED_RATES.each_index.select { |i| votes_count_map[i] == biggest_vote_count }
    final_notes = winning_indices.map{|i| ACCEPTED_RATES[i] }

    print "Final note: #{final_notes.join(", ")}\n"
    print "______________________\n"
    votes_array.each_with_index do |el, i|
        print "#{ACCEPTED_RATES[i]} #{el.empty? ? "-" : el.join(", ")}\n"
    end
end

