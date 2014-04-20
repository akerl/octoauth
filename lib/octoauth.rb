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
end

require 'octoauth/configfile'
require 'octoauth/auth'
