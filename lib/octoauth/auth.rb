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
    def initialize(params = {})
      parse_params!(params)
      save if @options[:autosave]
    end

    def save
      fail 'No token to save' unless token
      fail 'No file given for config' unless config.file
      config.token = token
      config.write
    end

    def token
      @token ||= load_token
    end

    private

    def config
      return @config if @config
      configs = config_files.map do |file|
        ConfigFile.new file: file, note: config_note
      end
      @config = configs.find(&:token) || configs.first
    end

    def config_files
      @options[:files] ||= [@options[:file]]
    end

    def parse_params!(params)
      @options = params.subset(
        :file, :files, :note, :autosave, :scopes,
        :login, :password, :twofactor, :api_endpoint
      )
    end

    def config_note
      return @options[:note] unless @options[:api_endpoint]
      "#{@options[:note]}--#{@options[:api_endpoint]}"
    end

    def fingerprint
      @fingerprint ||= "#{config_note}/#{hostname}"
    end

    def hostname
      return @hostname if @hostname
      res = `hostname`.split.first
      @hostname = $?.exitstatus == 0 ? res : 'NULL'
    end

    def prompt!(needs2fa = false)
      @options[:login] ||= PROMPTS[:login].ask
      @options[:password] ||= PROMPTS[:password].ask
      @options[:scopes] ||= DEFAULT_SCOPES
      @options[:fingerprint] = fingerprint
      return unless needs2fa
      @options[:twofactor] ||= PROMPTS[:twofactor].ask
      @options[:headers] = { 'X-GitHub-OTP' => @options[:twofactor] }
    end

    def load_token(needs2fa = false)
      return config.token if config.token
      prompt!(needs2fa)
      authenticate
    end

    def authenticate
      client = Octokit::Client.new(
        @options.subset(:login, :password, :api_endpoint)
      )
      client.create_authorization(
        @options.subset(:note, :scopes, :headers, :fingerprint)
      ).token
    rescue Octokit::OneTimePasswordRequired
      load_token(true)
    rescue Octokit::UnprocessableEntity
      check_existing_token client
    end

    def check_existing_token(client)
      client.authorizations(@options.subset(:headers))
        .find { |x| x[:note] == @options[:note] }.token
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
