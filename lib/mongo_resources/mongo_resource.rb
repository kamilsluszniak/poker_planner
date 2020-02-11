require 'mongo'

Mongo::Logger.logger.level = ::Logger::FATAL

class MongoResource
    CLIENT_ADDR = '127.0.0.1:27017'
    DATABASE = 'planner'

    def client
        @client ||= Mongo::Client.new([ CLIENT_ADDR ], database: DATABASE)
    end
end