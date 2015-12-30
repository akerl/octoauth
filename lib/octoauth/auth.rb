require 'octokit'
require 'userinput'
require 'English'

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
      return unless @token_changed
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

    def note
      @note ||= "#{@options[:note]}/#{hostname}"
    end

    def hostname
      return @hostname if @hostname
      res = `hostname`.split.first
      @hostname = $CHILD_STATUS.exitstatus == 0 ? res : 'NULL'
    end

    def prompt!(needs2fa = false)
      @options[:login] ||= PROMPTS[:login].ask
      @options[:password] ||= PROMPTS[:password].ask
      @options[:scopes] ||= DEFAULT_SCOPES
      return unless needs2fa
      @options[:twofactor] ||= PROMPTS[:twofactor].ask
      @options[:headers] = { 'X-GitHub-OTP' => @options[:twofactor] }
    end

    def load_token(needs2fa = false)
      return config.token if config.token
      @token_changed = true
      prompt!(needs2fa)
      authenticate(needs2fa)
    end

    def authenticate(using2fa)
      client = Octokit::Client.new(
        @options.subset(:login, :password, :api_endpoint)
      )
      delete_existing_token(client)
      client.create_authorization(
        { note: note }.merge(@options.subset(:scopes, :headers, :fingerprint))
      ).token
    rescue Octokit::OneTimePasswordRequired
      raise('Invalid 2fa code') if using2fa
      load_token(true)
    end

    def delete_existing_token(client)
      headers = @options.subset(:headers)
      client.authorizations(headers)
        .select { |x| x[:note] == note }
        .map { |x| client.delete_authorization(x[:id], headers) }
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
