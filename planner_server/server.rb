$: << File.join(File.dirname(__FILE__), "../lib/proto")

require "grpc"
require "planner_services_pb"

class PokerServer < Planner::Poker::Service
    def new_poker(new_poker_request, _unused_call)
        Planner::NewPokerResponse.new(error: "Hello #{new_poker_request.team_name}, #{new_poker_request.team_size}")
    end
end

s = GRPC::RpcServer.new
s.add_http2_port("0.0.0.0:50051", :this_port_is_insecure)
s.handle(PokerServer)
p s
s.run_till_terminated