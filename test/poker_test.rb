require "../lib/mongo_resources/mongo_resource"
require "../lib/mongo_resources/poker"
require "test/unit"

class PokerTest
    extend Test::Unit::Assertions

    def self.create_poker
        poker_id = Poker.new.create_poker(2)
        assert_instance_of String, poker_id
        poker_id
    end

    def self.create_and_find_poker_test
        poker_id = self.create_poker
        result = Poker.new.find_poker(poker_id)
        assert_instance_of BSON::Document, result
    end

    def self.create_and_vote_raises_ResourceNotFoundError_when_poker_not_found_test
        assert_raise MongoResource::ResourceNotFoundError do
            result = Poker.new.vote(BSON::ObjectId("5e21d7935c6eca3da01519db"), {"kamil" => 2})
        end
    end

    def self.create_and_vote_raises_VotingClosedError_when_poker_closed_test
        assert_raise Poker::VotingClosedError do
            poker_id = self.create_poker
            poker = Poker.new
            poker.vote(poker_id, {"kamil" => 2})
            poker.vote(poker_id, {"kamil1" => 2})
            poker.vote(poker_id, {"kamil2" => 2})
        end
    end


end

methods = PokerTest.methods.grep(/test/)
methods.each { |method| PokerTest.send(method) }
# TODO - database clean after tests