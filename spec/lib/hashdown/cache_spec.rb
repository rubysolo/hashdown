require 'spec_helper'

describe Hashdown do
  describe 'cache' do
    describe 'in a Rails project' do
      before { Object.const_set('Rails', mock(cache: :rails_cache)) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'delegates to Rails.cache if available' do
        Hashdown.cache.should eq Rails.cache
      end
    end

    it 'creates a new cache store if Rails.cache unavailable' do
      Hashdown.cache.class.should eq ActiveSupport::Cache::MemoryStore
    end
  end
end
