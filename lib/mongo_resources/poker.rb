
class Poker < MongoResource
    class VotingClosedError < StandardError; end

    def find_poker(poker_id)
        id = poker_id ? BSON::ObjectId(poker_id) : nil
        client[:pokers].find(_id: id).map {|poker| poker}.last
    end

    def create_poker(team_size)
        doc = { team_size: team_size}
        result = client[:pokers].insert_one doc
        result.inserted_id.to_s
    end

    def vote(poker_id, vote)
        poker = find_poker(poker_id)
        raise ResourceNotFoundError unless poker
        current_votes = poker["votes"] || {}
        vote_limit = poker["team_size"]
        raise VotingClosedError unless current_votes.length <= vote_limit - 1
        updated_votes = current_votes.merge(vote)
        client[:pokers].update_one({"_id" => poker["_id"]}, {'$set' => {votes: updated_votes}})
    end
end