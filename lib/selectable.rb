module Rubysolo # :nodoc:
  module Hashdown

    module Selectable
      def self.included(base)
        base.instance_eval do
          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new
          after_save :clear_selectable_cache
          after_destroy :clear_selectable_cache

          def self.select_options(*args)
            cache_key = ((scope(:find) || {}).to_a + args).hash
            cache_store.fetch("select_options:#{cache_key}", :force => Rubysolo::Hashdown.force_cache_miss?) {
              options = args.extract_options!
              options[:value] ||= args.shift || selectable_options[:value]

              [:display_name, :name].each {|sym| options[:value] ||= sym if instance_methods.include?(sym.to_s) || has_column?(sym) } unless options[:value]
              raise "#{self} does not respond to :display_name or :name.  Please specify a value method." unless options[:value]

              options[:key] ||= args.shift || selectable_options[:key]
              options[:key] ||= :id

              find_options = scope(:find) || {}
              find_options[:order] = options[:order] if options.has_key?(:order)
              find_options[:order] ||= options[:value] if has_column?(options[:value])

              if grouping = options[:group]
                find(:all, find_options).group_by{ |record|
                  call_or_send(record, grouping)
                }.map{ |group, records|
                  [group, records.map{|record| record.generate_option_pair(options[:key], options[:value]) }]
                }
              else
                find(:all, find_options).map{|record| record.generate_option_pair(options[:key], options[:value]) }
              end
            }.dup
          end

          def self.has_column?(column_name)
            columns.map{|c| c.name }.include?(column_name.to_s)
          end

          def self.call_or_send(receiver, operator)
            operator.respond_to?(:call) ? operator.call(receiver) : receiver.send(operator)
          end
        end
      end

      def generate_option_pair(key_generator, val_generator)
        [self.class.call_or_send(self, val_generator), self.class.call_or_send(self, key_generator)]
      end

      private

      def clear_selectable_cache
        self.class.cache_store.clear
      end

    end # Selectable

  end
end
