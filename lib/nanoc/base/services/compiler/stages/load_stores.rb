module Nanoc::Int::Compiler::Stages
  class LoadStores
    include Nanoc::Int::ContractsSupport

    def initialize(checksum_store:, compiled_content_cache:, dependency_store:, action_sequence_store:, outdatedness_store:)
      @checksum_store = checksum_store
      @compiled_content_cache = compiled_content_cache
      @dependency_store = dependency_store
      @action_sequence_store = action_sequence_store
      @outdatedness_store = outdatedness_store
    end

    contract C::None => C::Any
    def run
      time('checksum_store') { @checksum_store.load }
      time('compiled_content_cache') { @compiled_content_cache.load }
      time('dependency_store') { @dependency_store.load }
      time('action_sequence_store') { @action_sequence_store.load }
      time('outdatedness_store') { @outdatedness_store.load }
    end

    def time(name)
      Nanoc::Int::NotificationCenter.post(:load_store_started, name)
      yield
    ensure
      Nanoc::Int::NotificationCenter.post(:load_store_ended, name)
    end
  end
end
