require 'honeycomb/beeline/version'

module Honeycomb
  USER_AGENT_SUFFIX = "#{Beeline::GEM_NAME}/#{Beeline::VERSION}"

  class << self
    attr_reader :client

    def init(writekey:, dataset:, **options)
      options = options.merge(writekey: writekey, dataset: dataset)
      @without = options.delete :without || []
      options = {user_agent_addition: USER_AGENT_SUFFIX}.merge(options)
      @client = Libhoney::Client.new(options)

      after_init_hooks.each do |label, block|
        puts "Running hook '#{label}' after Honeycomb.init"
        run_hook(label, block)
      end
    end

    def after_init(label, &block)
      raise ArgumentError unless block_given?

      hook = if block.arity == 0
               ->(_) { block.call }
             elsif block.arity > 1
               raise ArgumentError, 'Honeycomb.after_init block should take 1 argument'
             else
               block
             end

      if @initialized
        puts "Running hook '#{label}' as Honeycomb already initialized"
        run_hook(label, hook)
      else
        after_init_hooks << [label, hook]
      end
    end

    private
    def after_init_hooks
      @after_init_hooks ||= []
    end

    def run_hook(label, block)
      if @without.include?(label)
        puts "Skipping hook '#{label}' due to opt-out"
      else
        block.call @client
      end
    rescue => e
      warn "Honeycomb.init hook '#{label}' raised #{e.class}: #{e}"
    end
  end

  after_init :spam do
    puts "Honeycomb inited"
  end
end