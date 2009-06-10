require 'activesupport' unless defined? ActiveSupport
require 'activerecord' unless defined? ActiveRecord

module Rubysolo # :nodoc:
  module Hashdown
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def finder(attr_name)
        class << self
          attr_accessor :finder_attribute
        end
        self.finder_attribute = attr_name

        self.send :include, FindableModel
      end

      def selectable(options={})
        class << self
          attr_accessor :selectable_options
        end
        self.selectable_options = options

        self.send :include, SelectionList
      end
    end

    module FindableModel
      def self.included(base)
        base.instance_eval do
          validates_uniqueness_of finder_attribute

          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new

          def self.[](token)
            cache_store.fetch("[]:#{token}") {
              returning find(:first, :conditions => { finder_attribute => token.to_s}) do |record|
                raise "Could not find #{self.class_name} with #{finder_attribute} '#{token}'" unless record
              end
            }
          end
        end
      end

      def is?(token)
        self[self.class.finder_attribute] == token.to_s
      end
    end # FindableModel

    module SelectionList
      def self.included(base)
        base.instance_eval do
          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new

          def self.select_options(*args)
            cache_store.fetch("select_options:#{args.hash}") {
              options = args.extract_options!
              options[:value] ||= args.shift
              [:display_name, :name].each {|sym| options[:value] ||= sym if instance_methods.include?(sym.to_s) || columns.map{|c| c.name }.include?(sym.to_s) }
              raise "#{self} does not respond to :display_name or :name.  Please specify a value method." unless options[:value]

              options[:key] ||= args.shift
              options[:key] ||= :id

              find_options = scope(:find) || {}
              find_options[:order] ||= options[:order] || options[:value] # TODO : only default columns into order option

              find(:all, find_options).map{|record| record.to_pair(options[:key], options[:value]) }
            }.dup
          end
        end
      end

      def to_pair(key_generator, val_generator)
        key = key_generator.respond_to?(:call) ? key_generator.call(self) : self.send(key_generator)
        val = val_generator.respond_to?(:call) ? val_generator.call(self) : self.send(val_generator)

        [val, key]
      end
    end # SelectionList

  end # Hashdown
end # Rubysolo
