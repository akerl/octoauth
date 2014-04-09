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
end

require 'octoauth/config'
require 'octoauth/auth'
