require 'octokit'
require 'userinput'

##
# Define Auth object and related info for Octoauth
module Octoauth
  ##
  # Default OAuth scopes for tokens
  DEFAULT_SCOPES = []

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
    attr_reader :token

    def initialize(params = {})
      params[:config_note] = "#{params[:note]}"
      if params[:api_endpoint]
        params[:config_note] << "--#{params[:api_endpoint]}"
      end
      @config = ConfigFile.new file: params[:file], note: params[:config_note]
      @token = load_token params
    end

    def save
      fail 'No token to save' unless @token
      fail 'No file given for config' unless @config.file
      @config.token = @token
      @config.write
    end

    private

    def load_token(params = {})
      return @config.token if @config.token
      params[:login] ||= PROMPTS[:login].ask
      params[:password] ||= PROMPTS[:password].ask
      params[:twofactor] ||= PROMPTS[:twofactor].ask if params[:needs2fa]
      params[:scopes] ||= DEFAULT_SCOPES
      if params[:twofactor]
        params[:headers] = { 'X-GitHub-OTP' => params[:twofactor] }
      end
      authenticate! params
    end

    def authenticate!(params = {})
      client = Octokit::Client.new(
        params.subset(:login, :password, :api_endpoint)
      )
      client.create_authorization(
        params.subset(:note, :scopes, :headers)
      ).token
    rescue Octokit::OneTimePasswordRequired
      load_token params.merge(needs2fa: true)
    rescue Octokit::UnprocessableEntity
      check_existing_token client, params
    end

    def check_existing_token(client, params = {})
      client.authorizations(params.subset(:headers))
        .find { |x| x[:note] == params[:note] }.token
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
