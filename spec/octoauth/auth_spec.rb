require 'spec_helper'
require 'fileutils'

##
# Grab creds for setting up VCR
LOGIN = ENV['OCTOAUTH_LOGIN'] || 'user'
PASSWORD = ENV['OCTOAUTH_PASSWORD'] || 'pw'

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
              note: 'existing_token',
              file: 'spec/examples/existing_token.yml'
            )
            expect(auth.token).to eql 'an_existing_token'
          end
        end
      end
      context 'if there is a note conflict' do
        it 'recreates the token' do
          VCR.use_cassette('recreate_token') do
            tokens = (1..2).map do
              Octoauth::Auth.new(
                note: 'existing_token',
                login: LOGIN,
                password: PASSWORD
              ).token
            end
            expect(tokens.first).not_to eql tokens.last
          end
        end
      end
      context 'if the file does not exist' do
        it 'use user input to create token' do
          VCR.use_cassette('create_token') do
            auth = Octoauth::Auth.new(
              note: 'create_token',
              login: LOGIN,
              password: PASSWORD
            )
            expect(auth.token).to eql 'created_token'
          end
        end
        it 'handles users with 2 factor auth enabled' do
          VCR.use_cassette('handle_two_factor') do
            auth = Octoauth::Auth.new(
              note: 'two_factor_token',
              login: LOGIN,
              password: PASSWORD,
              twofactor: '123456'
            )
            expect(auth.token).to eql '2fa_required_token'
          end
        end
      end
      it 'supports alternate endpoints' do
        VCR.use_cassette('alternate_endpoints') do
          auth = Octoauth::Auth.new(
            note: 'alternate_endpoint',
            login: LOGIN,
            password: PASSWORD,
            api_endpoint: 'https://example.org/api/v3/'
          )
          expect(auth.token).to eql 'created_token'
        end
      end
      it 'supports requesting scopes' do
        VCR.use_cassette('requesting_scopes') do
          auth = Octoauth::Auth.new(
            note: 'requesting_scopes',
            login: LOGIN,
            password: PASSWORD,
            scopes: %w(gist delete_repo)
          )
          expect(auth.token).to eql 'token_with_scopes'
        end
      end
      it 'supports autosaving the config file' do
        VCR.use_cassette('autosaving_config_file') do
          FileUtils.rm_f 'spec/examples/autosave.yml'
          Octoauth::Auth.new(
            note: 'autosave_test',
            file: 'spec/examples/autosave.yml',
            login: LOGIN,
            password: PASSWORD,
            autosave: true
          )
          new_auth = Octoauth::Auth.new(
            note: 'autosave_test',
            file: 'spec/examples/autosave.yml'
          )
          expect(new_auth.token).to eql 'autosaved_token'
        end
      end
    end
    context 'when given multiple file paths' do
      context 'when the first file exists' do
        it 'reads the first file' do
          auth = Octoauth::Auth.new(
            note: 'existing_token',
            files: ['spec/examples/existing_token.yml', 'bogus.yml']
          )
          expect(auth.token).to eql 'an_existing_token'
        end
      end
      context 'when the first file does not exist' do
        context 'when the second file exists' do
          it 'reads the second file' do
            auth = Octoauth::Auth.new(
              note: 'existing_token',
              files: ['bogus.yml', 'spec/examples/existing_token.yml']
            )
            expect(auth.token).to eql 'an_existing_token'
          end
        end
        context 'when the second file does not exist' do
          it 'reads nil from the first file' do
            auth = Octoauth::Auth.new(
              note: 'nonexistent_token',
              files: ['nil.yml', 'nil2.yml']
            )
            expect(auth.send(:config).token).to be_nil
          end
          it 'writes to the first file' do
            VCR.use_cassette('write_to_first_file') do
              FileUtils.rm_f 'spec/examples/write_first_test.yml'
              auth = Octoauth::Auth.new(
                note: 'write_first_test',
                files: ['spec/examples/write_first_test.yml', 'bogus.yml'],
                login: LOGIN,
                password: PASSWORD
              )
              auth.save
              new_auth = Octoauth::Auth.new(
                note: 'write_first_test',
                file: 'spec/examples/write_first_test.yml'
              )
              expect(new_auth.token).to eql 'write_first_test_token'
            end
          end
        end
      end
    end
  end
end
