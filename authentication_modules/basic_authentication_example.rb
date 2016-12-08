module AuthenticationModules
  class BasicAuthenticationExample
    class << self
      def authentic?(request)
        if request.env['HTTP_AUTHORIZATION'] && request.env['HTTP_AUTHORIZATION'].split(' ').length == 2
          auth_value = request.env['HTTP_AUTHORIZATION'].split(' ')[1]
          if auth_value == ENV['BASIC_AUTHENTICATION_PASSWORD']
            return true
          else
            return false
          end
        end
      end
    end
  end
end
