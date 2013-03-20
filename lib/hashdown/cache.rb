module Hashdown
  def self.cache
    @cache ||= rails.cache || local_cache
  end

  def self.cache=(value)
    @cache = value
  end

  def self.force_cache_miss?
    rails.env.test?
  end

  def self.cache_key(source, class_name, token=nil)
    ['hashdown', rails.env, class_name, source, token].compact.join('-')
  end

  def self.uncache(source, class_name, token)
    cache.delete(cache_key(source, class_name, token))
  end

  def self.cached(cache_key)
    cache.fetch(cache_key, :force => force_cache_miss?) do
      yield
    end
  end

  class Config
    def initialize(hash={})
      @data = hash
    end

    def method_missing(method_id, *args)
      if method_id.to_s =~ /^(\w*)=$/
        @data[$1.to_sym] = args.first
      elsif method_id.to_s =~ /^(\w*)\?$/
        @data.has_key?($1.to_sym)
      else
        if @data.has_key?(method_id)
          @data[method_id]
        else
          super
        end
      end
    end
  end

  private

  def self.rails
    @rails ||= defined?(Rails) ? Rails : Config.new(cache: nil, env: Config.new)
  end

  def self.local_cache
    ActiveSupport::Cache::MemoryStore.new
  end
end
