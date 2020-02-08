$: << File.join(File.dirname(__FILE__), "../lib/proto")

require "grpc"
require "planner_services_pb"

planner_server = Planner::Poker::Stub.new("localhost:50051", :this_channel_is_insecure)
msg = planner_server.new_poker(Planner::NewPokerRequest.new(team_name: "the_others", team_size: "2")).error
p "Greeting: #{msg}"