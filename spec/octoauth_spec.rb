require 'spec_helper'

describe Octoauth do
  describe '#new' do
    it 'creates auth objects' do
      auth = Octoauth.new note: 'testing', login: 'good', password: 'sekrit'
      expect(auth).to be_an_instance_of Octoauth::Auth
    end
  end
end
