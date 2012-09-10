module ActiveRecord
  class QueryCounter
    attr_reader :query_count, :queries

    def initialize
      @query_count = 0
      @queries = []
    end

    IGNORED_SQL = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/]

    def call(name, start, finish, message_id, values)
      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      unless 'CACHE' == values[:name]
        unless IGNORED_SQL.any? { |r| values[:sql] =~ r }
          @query_count += 1
          @queries << values[:sql]
        end
      end
    end
  end
end
