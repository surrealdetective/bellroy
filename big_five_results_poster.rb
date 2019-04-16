require 'rspec/autorun'
require 'net/http'
require 'json'
require 'dry/monads/result'
require 'dry-struct'
require 'pry'

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

class BigFiveResultsPoster::ResponseSuccess < Dry::Struct
  attribute :response_code, Types::Coercible::Integer
  attribute :token, Types::Strict::String
end

class BigFiveResultsPoster::ResponseError < Dry::Struct
  attribute :response_code, Types::Coercible::Integer
  attribute :error, Types::Strict::String
end

describe BigFiveResultsPoster do
  it 'returns a 201 and a receipt token in the body of the response' do
    results_hash =       {
        "NAME"=>"Alex", 
        "EXTRAVERSION"=>{
          "Overall Score"=>59, 
          "Facets"=>{
            "Friendliness"=>82,
            "Gregariousness"=>64,
            "Assertiveness"=>63,
            "Activity Level"=>27,
            "Excitement-Seeking"=>10,
            "Cheerfulness"=>84}
          },
        "AGREEABLENESS"=>{
          "Overall Score"=>95, 
          "Facets"=>{
            "Trust"=>99,
            "Morality"=>81,
            "Altruism"=>80,
            "Cooperation"=>72,
            "Modesty"=>55,
            "Sympathy"=>95}
          },
        "CONSCIENTIOUSNESS"=>{
          "Overall Score"=>65, 
          "Facets"=>{
            "Self-Efficacy"=>97,
            "Orderliness"=>33,
            "Dutifulness"=>54,
            "Activity Level"=>27,
            "Achievement-Striving"=>66,
            "Self-Discipline"=>77,
            "Cautiousness"=>47}
          },

        "OPENNESS TO EXPERIENCE"=>{
          "Overall Score"=>67, 
          "Facets"=>{
            "Imagination"=>72,
            "Artistic Interests"=>31,
            "Emotionality"=>75,
            "Adventurousness"=>28,
            "Intellect"=>37,
            "Liberalism"=>99}
          },
        "NEUROTICISM"=>{
          "Overall Score"=>10, 
          "Facets"=>{
            "Anxiety"=>6,
            "Anger"=>1,
            "Depression"=>22,
            "Self-Consciousness"=>48,
            "Immoderation"=>38,
            "Vulnerability"=>19}
        }
      }
    email = 'thefifth@gmail.com'.prepend(rand(10**10).to_s)
    poster = BigFiveResultsPoster.new(results_hash: results_hash, email: email)
    response = poster.post 
    
    expect(response.value!.response_code).to eq 201
    expect(response.value!.token).to_not eq nil
  end

  it 'returns 422 with helpful error messages in the body of the response' do
    results_hash = {
      "NAME"=>"Alex", 
      "EXTRAVERSION"=>{
        "Overall Score"=>59, 
        "Facets"=>{
          "Friendliness"=>82,
          "Gregariousness"=>64,
          "Assertiveness"=>63,
          "Activity Level"=>27,
          "Excitement-Seeking"=>10,
          "Cheerfulness"=>84}
        },
      "AGREEABLENESS"=>{
        "Overall Score"=>95, 
        "Facets"=>{
          "Trust"=>99,
          "Morality"=>81,
          "Altruism"=>80,
          "Cooperation"=>72,
          "Modesty"=>55,
          "Sympathy"=>95}
        },
      "CONSCIENTIOUSNESS"=>{
        "Overall Score"=>65, 
        "Facets"=>{
          "Self-Efficacy"=>97,
          "Orderliness"=>33,
          "Dutifulness"=>54,
          "Activity Level"=>27,
          "Achievement-Striving"=>66,
          "Self-Discipline"=>77,
          "Cautiousness"=>47}
        },

      "OPENNESS TO EXPERIENCE"=>{
        "Overall Score"=>67, 
        "Facets"=>{
          "Imagination"=>72,
          "Artistic Interests"=>31,
          "Emotionality"=>75,
          "Adventurousness"=>28,
          "Intellect"=>37,
          "Liberalism"=>99}
        },
      "NEUROTICISM"=>{
        "Overall Score"=>10, 
        "Facets"=>{
          "Anxiety"=>6,
          "Anger"=>1,
          "Depression"=>22,
        }
      }
    }
    email    = 'thefifth@gmail.com'.prepend(rand(10**10).to_s)
    poster   = BigFiveResultsPoster.new(results_hash: results_hash, email: email)
    response = poster.post 

    expect(response.to_result.to_s).to include('response_code=422')
  end
end

