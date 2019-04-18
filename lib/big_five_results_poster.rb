require 'net/http'
require 'json'
require 'dry/monads/result'
require 'dry-struct'

module Types
  include Dry::Types.module
end

class BigFiveResultsPoster
  include Dry::Monads::Result::Mixin
  attr_reader :results_json

  def initialize(results_hash:, email: 'thefifth@gmail.com')
    @results_json = JSON.generate(results_hash.merge('EMAIL' => email))
  end

  def post
    request.body = results_json
    response     = http.request(request)

    Success(response).bind do |value|
      if value.code == '201'
        Success(
          BigFiveResultsPoster::ResponseSuccess.new(
            response_code: value.code,
            token: value.body
          )
        )
      else 
        Failure(
          BigFiveResultsPoster::ResponseError.new(
            response_code: value.code,
            error: value.body 
          )
        )
      end
    end
  end
  
  private
  # JSON API INTERFACE
  URI_ID = URI.parse("https://recruitbot.trikeapps.com/api/v1/roles/senior-team-lead/big_five_profile_submissions")

  def http
    @http ||= Net::HTTP.new(URI_ID.host, URI_ID.port).tap {|h| h.use_ssl = true}
  end

  def request
    @request ||= Net::HTTP::Post.new(URI_ID.request_uri).tap do |r| 
      r.content_type = 'text/json'
    end
  end


end

## HELPERS
class BigFiveResultsPoster::ResponseSuccess < Dry::Struct
  attribute :response_code, Types::Coercible::Integer
  attribute :token, Types::Strict::String
end

class BigFiveResultsPoster::ResponseError < Dry::Struct
  attribute :response_code, Types::Coercible::Integer
  attribute :error, Types::Strict::String
end