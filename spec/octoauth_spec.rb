require 'spec_helper'

describe Octoauth do
  describe '#new' do
    it 'creates auth objects' do
      expect(Octoauth.new).to be_an_instance_of Octoauth::Auth
    end
  end

  describe Octoauth::Auth do
    let(:subject) { Octoauth::Auth.new }

    it 'creates an auth object' do
      expect(subject).to be_an_instance_of Octoauth::Auth
    end
  end
end
