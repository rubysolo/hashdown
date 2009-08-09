module Rubysolo # :nodoc:
  module Hashdown

    module Selectable
      def self.included(base)
        base.instance_eval do
          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new

          def self.select_options(*args)
            cache_store.fetch("select_options:#{args.hash}", :force => Rubysolo::Hashdown.force_cache_miss?) {
              options = args.extract_options!
              options[:value] ||= args.shift || selectable_options[:value]

              [:display_name, :name].each {|sym| options[:value] ||= sym if instance_methods.include?(sym.to_s) || has_column?(sym) } unless options[:value]
              raise "#{self} does not respond to :display_name or :name.  Please specify a value method." unless options[:value]

              options[:key] ||= args.shift || selectable_options[:key]
              options[:key] ||= :id

              find_options = scope(:find) || {}
              find_options[:order] = options[:order] if options.has_key?(:order)
              find_options[:order] ||= options[:value] if has_column?(options[:value])

              find(:all, find_options).map{|record| record.to_pair(options[:key], options[:value]) }
            }.dup
          end

          def self.has_column?(column_name)
            columns.map{|c| c.name }.include?(column_name.to_s)
          end
        end
      end

      def to_pair(key_generator, val_generator)
        key = key_generator.respond_to?(:call) ? key_generator.call(self) : self.send(key_generator)
        val = val_generator.respond_to?(:call) ? val_generator.call(self) : self.send(val_generator)

        [val, key]
      end
    end # Selectable

  end
end
