# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: proto/planner.proto for package 'planner'

require 'grpc'
require 'planner_pb'

module Planner
  module Poker
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'planner.Poker'

      rpc :NewPoker, NewPokerRequest, NewPokerResponse
      rpc :GetPoker, GetPokerRequest, GetPokerResponse
      rpc :VotePoker, VotePokerRequest, GetPokerResponse
    end

    Stub = Service.rpc_stub_class
  end
end
