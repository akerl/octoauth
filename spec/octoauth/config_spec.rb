require 'spec_helper'

describe Octoauth do
  describe Octoauth::ConfigFile do
    describe '#initialize' do
      it 'requires a note' do
        expect { Octoauth::ConfigFile.new }.to raise_error ArgumentError
      end
      context 'when given a file path' do
        it 'loads that config' do
          config = Octoauth::ConfigFile.new(
            note: 'foo',
            file: 'spec/examples/conf_a.yml'
          )
          expect(config.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
        end
        it 'returns nil if the file does not exist' do
          config = Octoauth::ConfigFile.new(note: 'foo', file: 'wat')
          expect(config.token).to be_nil
        end
      end
      context 'when give :default' do
        it 'uses the default file' do
          config = Octoauth::ConfigFile.new(note: 'foo', file: :default)
          expect(config.file).to eql Octoauth::DEFAULT_FILE
        end
      end
      context 'when given no file' do
        it 'returns an empty hash' do
          config = Octoauth::ConfigFile.new(note: 'foo')
          expect(config.token).to be_nil
          expect(config.file).to be_nil
        end
      end
    end

    describe '#write' do
      it 'saves a config to disk' do
        random = rand(36**30).to_s(30)
        config = Octoauth::ConfigFile.new(
          note: 'bar',
          file: 'spec/examples/tmp.yml'
        )
        config.token = random
        config.write
        new_config = Octoauth::ConfigFile.new(
          note: 'bar',
          file: 'spec/examples/tmp.yml'
        )
        expect(new_config.token).to eql random
      end
    end
  end
end
