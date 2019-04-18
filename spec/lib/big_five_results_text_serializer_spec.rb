require 'big_five_results_text_serializer'

RSpec.describe BigFiveResultsTextSerializer do
  it 'converts text to a hash' do
    text       = File.open("spec/fixtures/big_five_results_example_text.txt").read
    bfr_poster = BigFiveResultsTextSerializer.new(text)
    
    expect(bfr_poster.to_h).to eq (
      {
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
    )
  end
end