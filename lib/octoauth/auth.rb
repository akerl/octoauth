module Octoauth
  ##
  # Authentication object
  class Auth
    def initialize(params = {})
      @config = Config.new params.subset(:file, :note)
      @token = get_token
    end

    def get_token
      return @config.token if @config.token && valid_scope?(@config.token)
    end
  end
end

class Hash
  def subset(*keys)
    select { |k| keys.include? k }
  end
end
