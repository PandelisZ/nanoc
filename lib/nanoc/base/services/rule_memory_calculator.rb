module Nanoc::Int
  # Calculates rule memories for objects that can be run through a rule (item
  # representations and layouts).
  #
  # @api private
  class RuleMemoryCalculator
    extend Nanoc::Int::Memoization

    # @api private
    attr_accessor :rules_collection

    # @param [Nanoc::Int::Site] site
    # @param [Nanoc::Int::RulesCollection] rules_collection
    def initialize(site:, rules_collection:)
      @site = site
      @rules_collection = rules_collection
    end

    # @param [#reference] obj
    #
    # @return [Nanoc::Int::RuleMemory]
    def [](obj)
      case obj
      when Nanoc::Int::ItemRep
        new_rule_memory_for_rep(obj)
      when Nanoc::Int::Layout
        new_rule_memory_for_layout(obj)
      else
        raise "Do not know how to calculate the rule memory for #{obj.inspect}"
      end
    end
    memoize :[]

    # @param [Nanoc::Int::ItemRep] rep The item representation for which to fetch
    #   the list of snapshots
    #
    # @return [Array] A list of snapshots, represented as arrays where the
    #   first element is the snapshot name (a Symbol) and the last element is
    #   a Boolean indicating whether the snapshot is final or not
    def snapshots_defs_for(rep)
      self[rep].snapshot_actions.map do |a|
        Nanoc::Int::SnapshotDef.new(a.snapshot_name, a.final?)
      end
    end

    # @param [Nanoc::Int::ItemRep] rep The item representation to get the rule
    #   memory for
    #
    # @return [Nanoc::Int::RuleMemory]
    def new_rule_memory_for_rep(rep)
      executor = Nanoc::Int::RecordingExecutor.new(rep)
      @rules_collection
        .compilation_rule_for(rep)
        .apply_to(rep, executor: executor, site: @site, view_context: nil)
      executor.record_write(rep, rep.path)
      executor.rule_memory
    end

    # @param [Nanoc::Int::Layout]
    #
    # @return [Nanoc::Int::RuleMemory]
    def new_rule_memory_for_layout(layout)
      res = @rules_collection.filter_for_layout(layout)
      # FIXME: what if res is nil?
      Nanoc::Int::RuleMemory.new(layout).tap do |rm|
        rm.add_filter(res[0], res[1])
      end
    end
  end
end