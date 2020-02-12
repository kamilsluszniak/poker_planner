$: << File.join(File.dirname(__FILE__), "../lib/proto")

require "grpc"
require "planner_services_pb"
require "../lib/mongo_resources/mongo_resource"
require "../lib/mongo_resources/poker"

class PokerServer < Planner::Poker::Service
    def new_poker(new_poker_request, _unused_call)
        team_size = new_poker_request.team_size
        poker_id = Poker.new.create_poker(team_size)
        Planner::NewPokerResponse.new(poker_id: poker_id, error: "")
    end

    def get_poker(get_poker_request, _unused_call)
        poker_id = get_poker_request.poker_id
        result = Poker.new.find_poker(poker_id)
        if result
            votes = result[:votes].map {|k, v| {name: k, note: v} }
            team_size = result[:team_size]
            Planner::GetPokerResponse.new(team_size: team_size, votes: votes, error: "")
        else
            Planner::GetPokerResponse.new(error: "Poker #{poker_id} not found")
        end
    end

    def vote_poker(vote_poker_request, _unused_call)
        poker_id = vote_poker_request.poker_id
        vote_obj = vote_poker_request.vote
        poker_resource = Poker.new
        begin
            result = poker_resource.vote(poker_id, {vote_obj.name => vote_obj.note})
            poker = poker_resource.find_poker(poker_id)
            votes = poker[:votes].map {|k, v| {name: k, note: v} }
            team_size = poker[:team_size]
            Planner::GetPokerResponse.new(team_size: team_size, votes: votes, error: "")
        rescue MongoResource::ResourceNotFoundError
            Planner::GetPokerResponse.new(error: "Poker #{poker_id} not found")
        rescue Poker::VotingClosedError
            Planner::GetPokerResponse.new(error: "Voting fot poker #{poker_id} ended")
        end
    end
end

s = GRPC::RpcServer.new
s.add_http2_port("0.0.0.0:50051", :this_port_is_insecure)
s.handle(PokerServer)
s.run_till_terminated