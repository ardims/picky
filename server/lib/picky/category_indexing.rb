module Picky

  #
  #
  class Category

    attr_reader :exact,
                :partial

    # Prepares and caches this category.
    #
    # This one should be used by users.
    #
    def index
      prepare
      cache
    end

    # Indexes, creates the "prepared_..." file.
    #
    def prepare
      empty
      with_data_snapshot do
        indexer.index [self]
      end
    end

    # Empty all the indexes.
    #
    def empty
      exact.empty
      partial.empty
    end

    # Take a data snapshot if the source offers it.
    #
    def with_data_snapshot
      if source.respond_to? :with_snapshot
        source.with_snapshot(@index) do
          yield
        end
      else
        yield
      end
    end

    # Generates all caches for this category.
    #
    def cache
      empty
      retrieve
      dump
      clear_realtime_mapping # TODO To call or not to call, that is the question.
    end

    # Retrieves the prepared index data into the indexes and
    # generates the necessary derived indexes.
    #
    def retrieve
      prepared.retrieve { |id, token| add_tokenized_token id, token, :<< }
    end

    # Return an appropriate source.
    #
    # If we have no explicit source, we'll check the index for one.
    #
    def source
      extract_source || @index.source
    end
    # Extract the actual source if it is wrapped in a time
    # capsule, i.e. a block/lambda.
    #
    def extract_source
      @source = @source.respond_to?(:call) ? @source.call : @source
    end

    # Return the key format.
    #
    # If no key_format is defined on the category
    # and the source has no key format, ask
    # the index for one.
    #
    # Default is to_i.
    #
    def key_format
      @key_format ||= source.respond_to?(:key_format) && source.key_format || @index.key_format || :to_i
    end

    # Where the data is taken from.
    #
    def from
      @from || name
    end

    # The indexer is lazily generated and cached.
    #
    def indexer
      @indexer ||= source.respond_to?(:each) ? Indexers::Parallel.new(self) : Indexers::Serial.new(self)
    end

    # Returns an appropriate tokenizer.
    # If one isn't set on this category, will try the index,
    # and finally the default index tokenizer.
    #
    def tokenizer
      @tokenizer || @index.tokenizer
    end

    # Checks the caches for existence.
    #
    def check
      timed_exclaim "Checking #{identifier}."
      exact.raise_unless_cache_exists
      partial.raise_unless_cache_exists
    end

    # Deletes the caches.
    #
    def clear
      timed_exclaim "Deleting #{identifier}."
      exact.delete
      partial.delete
    end

    # Backup the caches.
    # (Revert with restore_caches)
    #
    def backup
      timed_exclaim "Backing up #{identifier}."
      exact.backup
      partial.backup
    end

    # Restore the caches.
    # (Revert with backup_caches)
    #
    def restore
      timed_exclaim "Restoring #{identifier}."
      exact.restore
      partial.restore
    end

  end

end