require 'spec_helper'
require 'fileutils'

##
# Shim object for mocking auth resources
AuthShim = Struct.new(:note, :token)

module UserInput
  ##
  # Mask prints from UserInput
  class Prompt
    def print(*)
    end

    def puts(*)
    end
  end
end

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
            .with(body: "{\"note\":\"existing\",\"scopes\":[]}")
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
            .with(body: "{\"note\":\"foo\",\"scopes\":[]}")
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
            .with(body: "{\"note\":\"foo\",\"scopes\":[]}")
            .to_return(
              status: 401,
              headers: { 'X-GitHub-OTP' => 'required; app' }
            )
          stub_request(:post, 'https://user:pw@api.github.com/authorizations')
            .with(
              body: "{\"note\":\"foo\",\"scopes\":[]}",
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
      it 'supports alternate endpoints' do
        stub_request(:post, 'https://user:pw@sekrit.com/api/v3/authorizations')
          .with(body: "{\"note\":\"foo\",\"scopes\":[]}")
          .to_return(
            status: 200,
            body: AuthShim.new('foo', 'qwertyqwertyqwertyqwerty')
          )
        auth = Octoauth::Auth.new(
          note: 'foo',
          login: 'user',
          password: 'pw',
          api_endpoint: 'https://sekrit.com/api/v3/'
        )
        expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
      end
      it 'supports requesting scopes' do
        stub_request(:post, 'https://user:pw@api.github.com/authorizations')
          .with(body: '{"note":"foo","scopes":["gist","delete_repo"]}')
          .to_return(
            status: 200,
            body: AuthShim.new('foo', 'qwertyqwertyqwertyqwerty')
          )
        auth = Octoauth::Auth.new(
          note: 'foo',
          login: 'user',
          password: 'pw',
          scopes: %w(gist delete_repo)
        )
        expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
      end
      it 'supports autosaving the config file' do
        random = rand(36**30).to_s(30)
        stub_request(:post, 'https://user:pw@api.github.com/authorizations')
          .with(body: "{\"note\":\"autosave_test\",\"scopes\":[]}")
          .to_return(
            status: 200,
            body: AuthShim.new('foo', random)
          )
        FileUtils.rm_f 'spec/examples/autosave.yml'
        Octoauth::Auth.new(
          note: 'autosave_test',
          file: 'spec/examples/autosave.yml',
          login: 'user',
          password: 'pw',
          autosave: true
        )
        new_auth = Octoauth::Auth.new(
          note: 'autosave_test',
          file: 'spec/examples/autosave.yml'
        )
        expect(new_auth.token).to eql random
      end
    end
    context 'when given multiple file paths' do
      context 'when the first file exists' do
        it 'reads the first file' do
          auth = Octoauth::Auth.new(
            note: 'foo',
            files: ['spec/examples/conf_a.yml', 'spec/examples/bogus.yml']
          )
          expect(auth.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
        end
      end
      context 'when the first file does not exist' do
        context 'when the second file exists' do
          it 'reads the second file' do
            FileUtils.rm_f 'spec/examples/nil.yml'
            auth = Octoauth::Auth.new(
              note: 'foo',
              files: ['spec/examples/bogus.yml', 'spec/examples/conf_a.yml']
            )
            expect(auth.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
          end
        end
        context 'when the second file does not exist' do
          it 'reads nil' do
            FileUtils.rm_f ['spec/examples/nil.yml', 'spec/examples/nil2.yml']
            auth = Octoauth::Auth.new(
              note: 'foo',
              files: ['spec/examples/nil.yml', 'spec/examples/nil2.yml']
            )
            expect(auth.send(:config).token).to be_nil
          end
          it 'writes to the first file' do
            random = rand(36**30).to_s(30)
            stub_request(:post, 'https://user:pw@api.github.com/authorizations')
              .with(body: "{\"note\":\"foo\",\"scopes\":[]}")
              .to_return(
                status: 200,
                body: AuthShim.new('foo', random)
              )
            FileUtils.rm_f ['spec/examples/nil.yml', 'spec/examples/nil2.yml']
            auth = Octoauth::Auth.new(
              note: 'foo',
              files: ['spec/examples/nil.yml', 'spec/examples/nil2.yml'],
              login: 'user',
              password: 'pw'
            )
            auth.save
            new_auth = Octoauth::Auth.new(
              note: 'foo',
              file: 'spec/examples/nil.yml'
            )
            expect(new_auth.token).to eql random
          end
        end
      end
    end

    describe '#save' do
      it 'saves the config to disk' do
        random = rand(36**30).to_s(30)
        FileUtils.rm_f 'spec/examples/tmp.yml'
        stub_request(:post, 'https://user:pw@api.github.com/authorizations')
          .with(body: "{\"note\":\"write_test\",\"scopes\":[]}")
          .to_return(
            status: 200,
            body: AuthShim.new('foo', random)
          )
        auth = Octoauth::Auth.new(
          note: 'write_test',
          file: 'spec/examples/tmp.yml',
          login: 'user',
          password: 'pw'
        )
        auth.save
        new_auth = Octoauth::Auth.new(
          note: 'write_test',
          file: 'spec/examples/tmp.yml'
        )
        expect(new_auth.token).to eql random
      end
    end
  end
end
