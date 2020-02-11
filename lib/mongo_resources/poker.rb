
class Poker < MongoResource

    def find_poker_with_conditions(team_name, task_id)
        find_pokers(team_name: team_name, task_id: task_id).last
    end

    def find_poker(poker_id)
        client[:pokers].find(_id: BSON::ObjectId(poker_id)).map {|poker| poker}.last
    end

    def create_poker(team_size)
        doc = { team_size: team_size}
        result = client[:pokers].insert_one doc
        result.inserted_id.to_s
    end

    def vote(poker_id, vote)
        poker = find_poker(poker_id)
        current_votes = poker["votes"] || {}
        vote_limit = poker["team_size"]
        return false unless current_votes.length < vote_limit
        updated_votes = current_votes.merge(vote)
        client[:pokers].update_one({"_id" => poker["_id"]}, {'$set' => {votes: updated_votes}})
    end
end