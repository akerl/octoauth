require 'spec_helper'

describe Octoauth do
  describe Octoauth::ConfigFile do
    describe '#initialize' do
      it 'sets the file attribute' do
        config = Octoauth::ConfigFile.new(note: 'a', file: 'foobar')
        expect(config.file).to eql 'foobar'
      end
      it 'uses the default location if none is given' do
        config = Octoauth::ConfigFile.new(note: 'a')
        expect(config.file).to eql Octoauth::DEFAULT_FILE
      end
      it 'requires a note' do
        expect { Octoauth::ConfigFile.new }.to raise_error ArgumentError
      end
      context 'when given a file path' do
        it 'loads that config' do
          config = Octoauth::ConfigFile.new(note: 'foo', file: 'spec/examples/conf_a.yml')
          expect(config.token).to eql 'bcdebcdebcdebcdebcdebcdebcde'
        end
      end
    end
  end
end
