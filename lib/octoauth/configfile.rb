# frozen_string_literal: true
require 'yaml'

##
# Define Config spec
module Octoauth
  ##
  # Define default file path
  DEFAULT_FILE = '~/.octoauth.yml'.freeze

  ##
  # Configuration object
  class ConfigFile
    attr_reader :file
    attr_accessor :token

    ##
    # Create new Config object, either ephemerally or from a file
    def initialize(params = {})
      @file = params[:file] == :default ? DEFAULT_FILE : params[:file]
      @file = File.expand_path(@file) if @file
      @note = params[:note] || raise(ArgumentError, 'A note must be provided')
      @token = parse
    end

    def write
      new = get
      new[@note] = @token
      File.open(@file, 'w', 0o0600) { |fh| fh.write new.to_yaml }
    end

    private

    def get
      return {} unless @file && File.exist?(@file)
      YAML.load File.read(File.expand_path(@file))
    end

    def parse
      get[@note]
    end
  end
end
