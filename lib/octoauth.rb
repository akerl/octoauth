require 'octokit'
require 'userinput'

##
# Octokit wrapper for simplifying authentication
module Octoauth
  class << self
    ##
    # Insert a helper .new() method for creating a new Auth object
    def new(*args)
      self::Auth.new(*args)
    end
  end

  ##
  # Define some sane defaults
  DEFAULTS = {
    file: '~/.octoauth.yml'
  }

  ##
  # Authentication object
  class Auth
    attr_reader :user, :note, :file

    def initialize(params = {})
      @user = nil
      @file = params.delete(:file) || DEFAULTS[:file]
      @note = params.delete(:note)
      fail ArgumentError, 'Must provide a note for GitHub token' if @note.nil?
      @api = Octokit::Client.new params
    end

    def authenticate!(params = {})
    end

    private

    def login
    end

    def password
    end

    def twofactor
    end
  end
end
