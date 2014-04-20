require 'spec_helper'

AuthShim = Struct.new(:note, :token)

describe Octoauth do
  describe Octoauth::Auth do
    describe '#initialize' do
      context 'if the file and note already exist' do
        it 'loads the existing token' do
          auth = Octoauth::Auth.new(
            note: 'foo',
            file: 'spec/examples/conf_a.yml'
          )
          expect(auth.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
        end
      end
      context 'if there is a note conflict' do
        it 'returns the existing token' do
          stub_request(:post, 'https://user:pw@api.github.com/authorizations')
            .with(body: "{\"note\":\"existing\"}")
            .to_return(status: 422)
          stub_request(:get, 'https://user:pw@api.github.com/authorizations')
            .to_return(
              status: 200,
              body: [
                AuthShim.new('not_match', 'bad'),
                AuthShim.new('existing', 'existing_token')
              ]
            )
          auth = Octoauth::Auth.new(
            note: 'existing',
            login: 'user',
            password: 'pw'
          )
          expect(auth.token).to eql 'existing_token'
        end
      end
      context 'if the file does not exist' do
        it 'requests user input to create token' do
          stub_request(:post, 'https://user:pw@api.github.com/authorizations')
            .with(body: "{\"note\":\"foo\"}")
            .to_return(
              status: 200,
              body: AuthShim.new('foo', 'qwertyqwertyqwertyqwerty')
            )
          auth = Octoauth::Auth.new(
            note: 'foo',
            login: 'user',
            password: 'pw'
          )
          expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
        end
        it 'handles users with 2 factor auth enabled' do
          stub_request(:post, 'https://user:pw@api.github.com/authorizations')
            .with(
              body: "{\"note\":\"foo\"}",
              headers: {
                'Accept' => 'application/vnd.github.v3+json',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Octokit Ruby Gem 3.1.0'
              }
            )
            .to_return(
              status: 401,
              headers: { 'X-GitHub-OTP' => 'required; app' }
            )
          stub_request(:post, 'https://user:pw@api.github.com/authorizations')
            .with(
              body: "{\"note\":\"foo\"}",
              headers: { 'X-GitHub-OTP' => '1234' }
            )
            .to_return(
              status: 200,
              body: AuthShim.new('foo', 'qwertyqwertyqwertyqwerty')
            )
          allow(STDIN).to receive(:gets).and_return("user\n", "pw\n", "1234\n")
          auth = Octoauth::Auth.new(note: 'foo')
          expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
        end
      end
    end
  end
end
