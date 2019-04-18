require 'big_five_results_poster'

RSpec.describe BigFiveResultsPoster do
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

