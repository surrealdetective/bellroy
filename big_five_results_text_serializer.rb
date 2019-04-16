require 'rspec/autorun'
require 'pry'
require './big_five_results_example_text.rb'

class BigFiveResultsTextSerializer
  attr_reader :text
  def initialize(text)
    @text = text
  end

  def to_h
    HASH_FORMAT.dup.tap do |results_hash|
      add_name(results_hash, find_name)
      big_five.each do |category|
        add_overall_score(results_hash, category, find_score(category))
        
        category_facets(category).each do |facet|
          add_facet_score(results_hash, facet, find_score(facet))
        end
      end
    end
  end

  private
  # READ HASH
  def big_five
    HASH_FORMAT.keys.tap {
      |list| list.delete('NAME') }
  end

  def category_facets(big_five_category)
    HASH_FORMAT[big_five_category]['Facets'].keys.map do |facet_name|
      Facet.new(facet_name, big_five_category)
    end
  end

  # UPDATE HASH
  def add_facet_score(results_hash, facet, score)
    results_hash[facet.big_five_category]['Facets'][facet.name] = score
  end

  def add_overall_score(results_hash, big_five_category, score)
    results_hash[big_five_category]['Overall Score'] = score
  end

  def add_name(results_hash, name)
    results_hash['NAME'] = name
  end

  # SEARCH TEXT
  def find_name
    name_str = REGEX_NAME_FORMAT.match(text).to_s
    name_str[21..-6]
  end

  def find_score(category_or_facet)
    regex     = Regexp.new(REGEX_SCORE_FORMAT.dup.prepend(category_or_facet))
    score_str = regex.match(text).to_s
    /\d+/.match(score_str).to_s.to_i
  end

  # HELPERS
  Facet = Struct.new(:name, :big_five_category) do
    def to_str; name; end
    def to_s; name; end
  end

  # INPUT INTERFACE
  REGEX_NAME_FORMAT  = /This report compares .* from/
  REGEX_SCORE_FORMAT = '\.{2,}\d*'

  # OUTPUT INTERFACE
  HASH_FORMAT = {
    'NAME' => nil,
    'EXTRAVERSION' => {
      'Overall Score' => nil,
      'Facets' => {
        'Friendliness' => nil,
        'Gregariousness' => nil,
        'Assertiveness' => nil,
        'Activity Level' => nil,
        'Excitement-Seeking' => nil,
        'Cheerfulness' => nil
      }
    },
    'AGREEABLENESS' => {
      'Overall Score' => nil,
      'Facets' => {
        'Trust' => nil,
        'Morality' => nil,
        'Altruism' => nil,
        'Cooperation' => nil,
        'Modesty' => nil,
        'Sympathy' => nil
      }
    },
    'CONSCIENTIOUSNESS' => {
      'Overall Score' => nil,
      'Facets' => {
        'Self-Efficacy' => nil,
        'Orderliness' => nil,
        'Dutifulness' => nil,
        'Activity Level' => nil,
        'Achievement-Striving' => nil,
        'Self-Discipline' => nil,
        'Cautiousness' => nil,
      }
    },
    'OPENNESS TO EXPERIENCE' => {
      'Overall Score' => nil,
      'Facets' => {
        'Imagination' => nil,
        'Artistic Interests' => nil,
        'Emotionality' => nil,
        'Adventurousness' => nil,
        'Intellect' => nil,
        'Liberalism' => nil
      }
    },        
    'NEUROTICISM' => {
      'Overall Score' => nil,
      'Facets' => {
        'Anxiety' => nil,
        'Anger' => nil,
        'Depression' => nil,
        'Self-Consciousness' => nil,
        'Immoderation' => nil,
        'Vulnerability' => nil
      }
    },    
  }
end

describe BigFiveResultsTextSerializer do
  it 'converts text to a hash' do
    text       = EXAMPLE_TEXT
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