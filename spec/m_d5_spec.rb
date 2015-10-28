require 'spec_helper'

RSpec.describe Digest::MD5 do

    it 'should pass current expectations' do

      sample = "This is the digest"

      # Digest::MD5::hexdigest when passed "This is the digest" should return 9f12248dcddeda976611d192efaaf72a
      expect( Digest::MD5.hexdigest(sample) ).to eq("9f12248dcddeda976611d192efaaf72a")

    end
end
