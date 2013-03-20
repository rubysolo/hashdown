require 'spec_helper'

describe Hashdown do
  describe 'cache' do
    describe 'in a Rails project' do
      before { Object.const_set('Rails', mock(cache: :rails_cache, env: 'development')) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'delegates to Rails.cache if available' do
        Hashdown.cache.should eq Rails.cache
      end

      it 'incorporates the environment in the cache key' do
        Hashdown.cache_key(:finder, 'MyModel', 'some-value').should match(/development/)
      end
    end

    it 'creates a new cache store if Rails.cache unavailable' do
      Hashdown.cache.class.should eq ActiveSupport::Cache::MemoryStore
    end
  end
end
