require 'httparty'

class VoodooSMS
  module Error
    class BadRequest < StandardError; end
    class Unauthorised < StandardError; end
    class NotEnoughCredit < StandardError; end
    class Forbidden < StandardError; end
    class MessageTooLarge < StandardError; end
    class Unexpected < StandardError; end
  end

  include HTTParty
  base_uri 'voodoosms.com'
  default_params format: 'json'
  format :json

  def initialize(username, password)
    @options = { query: { uid: username, pass: password } }
  end

  def get_credit
    make_request('getCredit')
  end

  private
    def make_request(method)
      begin
        response = self.class.get("/vapi/server/#{method}", @options)
      rescue => e
        raise Error::Unexpected.new(e.message)
      end

      case response['result']
      when 200
        return response
      when 400
        raise Error::BadRequest.new(response.values.join(', '))
      when 401
        raise Error::Unauthorised.new(response.values.join(', '))
      when 402
        raise Error::NotEnoughCredit.new(response.values.join(', '))
      when 403
        raise Error::Forbidden.new(response.values.join(', '))
      when 513
        raise Error::MessageTooLarge.new(response.values.join(', '))
      else
        raise Error::Unexpected.new(response.values.join(', '))
      end
    end
end
