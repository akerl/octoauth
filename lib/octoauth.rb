require 'octokit'

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
  }

  ##
  # Authentication object
  class Auth
    attr_reader :user

    def initialize(params = {})
      @user = nil
      @api = Octokit::Client.new params
    end

    def login!(params = {})
      unless params.include? 'scopes'
        
      end
      params[:user] ||= get_user
      params[:pass] ||= get_pass
      params[:twofactor] ||= get_token if params.include? :twofactor
      authenticate! params
    end

    def authenticate!(params = {})
      if params.include? :twofactor
        params[:headers] = { 'X-GitHub-OTP' => params[:twofactor] }
      end
      @api.create_authorization(
        scopes: params[:scopes],
        headers: params[:headers]
      )
    rescue Octokit::OneTimePasswordRequired
      params[:twofactor] = nil
      login! params
    end

    private

    def get_user
    end

    def get_pass
    end

    def get_token
    end
  end
end
