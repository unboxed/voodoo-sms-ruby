require 'httparty'

class VoodooSMS
  module Error
    class BadRequest < StandardError; end
    class Unauthorised < StandardError; end
    class NotEnoughCredit < StandardError; end
    class Forbidden < StandardError; end
    class MessageTooLarge < StandardError; end
    class Unexpected < StandardError; end
    class InvalidParameterFormat < StandardError; end
  end

  include HTTParty
  base_uri 'voodoosms.com'
  default_params format: 'json'
  format :json

  def initialize(username, password)
    @options = { query: { uid: username, pass: password } }
  end

  def get_credit
    make_request('getCredit')['credit']
  end

  def send_sms(originator, destination, message)
    merge_options(orig: originator, dest: destination, msg: message, validity: 1)
    make_request('sendSMS')['resultText'].to_s.include? 'OK'
  end

  private
    def merge_options(opts)
      @options[:query].merge!(opts)
    end

    def make_request(method)
      validate_parameters_for(method)

      begin
        response = self.class.get("/vapi/server/#{method}", @options)
      rescue => e
        raise Error::Unexpected.new(e.message)
      end

      case response['result']
      when 200, '200 OK'
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

    def validate_parameters_for(method)
      case method
      when 'sendSMS'
        validate_originator  @options[:query][:orig]
        validate_destination @options[:query][:dest]
      end
    end

    def validate_originator(input)
      unless input.match /^[a-zA-Z0-9]{1,11}(\d{4})?$/
        raise Error::InvalidParameterFormat.new('must be 15 numeric digits or 11 alphanumerics')
      end
    end

    def validate_destination(input)
      unless input.match /^\d{10,15}$/
        raise Error::InvalidParameterFormat.new('must be valid E.164 format')
      end
    end
end
