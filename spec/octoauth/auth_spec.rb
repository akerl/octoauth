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
          VCR.use_cassette('load_existing_token') do
            auth = Octoauth::Auth.new(
              note: 'foo',
              file: 'spec/examples/conf_a.yml'
            )
            expect(auth.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
          end
        end
      end
      context 'if there is a note conflict' do
        it 'creates_a_new_token' do
          VCR.use_cassette('creates_new_token') do
            auth = Octoauth::Auth.new(
              note: 'existing',
              login: 'user',
              password: 'pw'
            )
            expect(auth.token).to eql 'existing_token'
          end
        end
      end
      context 'if the file does not exist' do
        it 'requests user input to create token' do
          VCR.use_cassette('request_user_input') do
            auth = Octoauth::Auth.new(
              note: 'foo',
              login: 'user',
              password: 'pw'
            )
            expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
          end
        end
        it 'handles users with 2 factor auth enabled' do
          VCR.use_cassette('handle_two_factor') do
            allow(STDIN).to receive(:gets).and_return("user\n", "pw\n", "1234\n")
            auth = Octoauth::Auth.new(note: 'foo')
            expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
          end
        end
      end
      it 'supports alternate endpoints' do
        VCR.use_cassette('alternate_endpoints') do
          auth = Octoauth::Auth.new(
            note: 'foo',
            login: 'user',
            password: 'pw',
            api_endpoint: 'https://sekrit.com/api/v3/'
          )
          expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
        end
      end
      it 'supports requesting scopes' do
        VCR.use_cassette('requesting_scopes') do
          auth = Octoauth::Auth.new(
            note: 'foo',
            login: 'user',
            password: 'pw',
            scopes: %w(gist delete_repo)
          )
          expect(auth.token).to eql 'qwertyqwertyqwertyqwerty'
        end
      end
      it 'supports autosaving the config file' do
        VCR.use_cassette('autosaving_config_file') do
          random = rand(36**30).to_s(30)
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
            VCR.use_cassette('Write_to_first_file') do
              random = rand(36**30).to_s(30)
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
    end

    describe '#save' do
      it 'saves the config to disk' do
        VCR.use_cassette('save_to_disk') do
          random = rand(36**30).to_s(30)
          FileUtils.rm_f 'spec/examples/tmp.yml'
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
end
