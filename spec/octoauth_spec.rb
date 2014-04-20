require 'spec_helper'

describe Octoauth do
  describe '#new' do
    it 'creates auth objects' do
      stub_request(:post, 'https://good:sekrit@api.github.com/authorizations')
        .to_return(
          status: 200,
          body: Struct.new(:token).new('abcdabcdabcdabcdabcdabcdabcdabcdabcd')
        )
      auth = Octoauth.new note: 'testing', login: 'good', password: 'sekrit'
      expect(auth).to be_an_instance_of Octoauth::Auth
    end
  end
end
