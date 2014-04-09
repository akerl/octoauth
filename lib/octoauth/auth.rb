require 'octokit'
require 'userinput'

module Octoauth
  ##
  # Authentication object
  class Auth
    def initialize(params = {})
      @config = Config.new params.subset(:file, :note)
      @token = token
    end

    def token
      return @config.token if @config.token
    end
  end
end

##
# Add .subset to Hash for selecting a subhash
class Hash
  def subset(*keys)
    select { |k| keys.include? k }
  end
end
