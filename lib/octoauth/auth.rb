require 'octokit'
require 'userinput'

module Octoauth
  ##
  # Authentication object
  class Auth
    def initialize(params = {})
      @config = Config.new params.subset(:file, :note)
      @token = token params[:scope]
    end

    def token(scope = nil)
      return @config.token if @config.token
      auth[:user] = UserInput.new message: 'GitHub username', validation: /\w+/
      auth[:password] = UserInput.new message: 'Password'
      if needs_two_factor auth
        auth[:twofactor] = UserInput.new message: '2FA token', validation: /\d+/
      end
      auth[:scopes] = scope ? scope : DEFAULT_SCOPE
      authenticate auth
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
