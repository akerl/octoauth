require 'spec_helper'
require 'fileutils'

describe Octoauth do
  describe Octoauth::ConfigFile do
    describe '#initialize' do
      it 'requires a note' do
        expect { Octoauth::ConfigFile.new }.to raise_error ArgumentError
      end
      context 'when given a file path' do
        it 'loads that config' do
          config = Octoauth::ConfigFile.new(
            note: 'existing_token',
            file: 'spec/examples/existing_token.yml'
          )
          expect(config.token).to eql 'an_existing_token'
        end
        it 'returns nil if the file does not exist' do
          config = Octoauth::ConfigFile.new(note: 'foo', file: 'wat')
          expect(config.token).to be_nil
        end
      end
      context 'when give :default' do
        it 'uses the default file' do
          config = Octoauth::ConfigFile.new(note: 'foo', file: :default)
          expect(config.file).to eql File.expand_path(Octoauth::DEFAULT_FILE)
        end
      end
      context 'when given no file' do
        it 'returns nil data' do
          config = Octoauth::ConfigFile.new(note: 'foo')
          expect(config.token).to be_nil
          expect(config.file).to be_nil
        end
      end
    end

    describe '#write' do
      it 'saves a config to disk' do
        FileUtils.rm_f 'spec/examples/config_save_test.yml'
        random = rand(36**30).to_s(30)
        config = Octoauth::ConfigFile.new(
          note: 'bar',
          file: 'spec/examples/config_save_test.yml'
        )
        config.token = random
        config.write
        new_config = Octoauth::ConfigFile.new(
          note: 'bar',
          file: 'spec/examples/config_save_test.yml'
        )
        expect(new_config.token).to eql random
      end
      it 'makes the config file owner-readable' do
        FileUtils.rm_f 'spec/examples/priv_test.yml'
        random = rand(36**30).to_s(30)
        config = Octoauth::ConfigFile.new(
          note: 'bar',
          file: 'spec/examples/priv_test.yml'
        )
        config.token = random
        config.write
        privs = File.stat('spec/examples/priv_test.yml').mode.to_s(8)
        expect(privs).to eql '100600'
      end
    end
  end
end
