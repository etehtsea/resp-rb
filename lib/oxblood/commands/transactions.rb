module Oxblood
  module Commands
    module Transactions
      # Mark the start of a transaction block
      # @see http://redis.io/commands/multi
      #
      # @return [String] 'OK'
      # @return [RError] if multi called inside transaction
      def multi
        run(:MULTI)
      end

      # Execute all commands issued after MULTI
      # @see http://redis.io/commands/exec
      #
      # @return [Array] each element being the reply to each of the commands
      #   in the atomic transaction
      # @return [nil] when WATCH was used and execution was aborted
      def exec
        run(:EXEC)
      end

      # Discard all commands issued after MULTI
      # @see http://redis.io/commands/discard
      #
      # @return [String] 'OK'
      # @return [RError] if called without transaction started
      def discard
        run(:DISCARD)
      end
    end
  end
end
