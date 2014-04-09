require 'yaml'

##
# Define Config spec
module Octoauth
  ##
  # Define default file path
  DEFAULT_FILE = '~/.octoauth.yml'

  ##
  # Configuration object
  class Config
    attr_reader :file
    attr_accessor :token

    ##
    # Create new Config object, either ephemerally or from a file
    def initialize(params = {})
      @file = params[:file] == :default ? DEFAULT_FILE : params[:file]
      @note = params[:note] || fail(ArgumentError, 'A note must be provided')
      @creds = parse
    end

    def get
      return {} unless @file
      YAML.load File.read(@file)
    end

    def parse
      get[@note]
    end

    def write
      new = get
      new[@note] = @token
      File.open(@file, 'w') { |fh| fh.write new.to_yaml }
    end
  end
end
