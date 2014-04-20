require 'octokit'
require 'userinput'

module Octoauth
  ##
  # Default OAuth scope for tokens
  DEFAULT_SCOPE = []

  ##
  # Prompt information for collecting user info
  PROMPTS = {
    login: UserInput.new(message: 'GitHub username', validation: /\w+/),
    password: UserInput.new(message: 'Password', secret: true),
    twofactor: UserInput.new(message: '2FA token', validation: /\d+/)
  }

  ##
  # Authentication object
  class Auth
    attr_reader :creds

    def initialize(params = {})
      @config = ConfigFile.new params.subset(:file, :note)
      @creds = load_creds params
    end

    def save
      fail 'No token to save' unless @token
      @config.creds = @creds
      @config.write
    end

    private

    def load_creds(params = {})
      return @config.creds if @config.creds
      params[:login] ||= PROMPTS[:login].ask
      params[:password] ||= PROMPTS[:password].ask
      params[:twofactor] = PROMPTS[:twofactor].ask if params[:twofactor] == true
      params[:scopes] ||= DEFAULT_SCOPE
      token = authenticate! params
      { login: params[:login], password: token }
    end

    def authenticate!(params = {})
      client = Octokit::Client.new params.subset(:login, :password)
      if params[:twofactor]
        params[:headers] = { 'X-GitHub-OTP' => params[:twofactor] }
      end
      client.create_authorization params.subset(:note, :scope, :headers).token
    rescue Octokit::OneTimePasswordRequired
      load_token params.merge(twofactor: true)
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
