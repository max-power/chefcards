require 'net/http'
require 'json'

module Chefkoch
  ADAM_ID = 478618165
  Host    = 'api.chefkoch.de'
  Path    = '/api/1.2/api-recipe.php'
  
  class RecipeNotFound < StandardError; end
  
  module_function
  
  def uri(query={})
    URI::HTTP.build(host: Host, path: Path, query: URI.encode_www_form(query))
  end
  
  def recipe(id, options={})
    response = Net::HTTP.get uri(options.merge(ID: id))
    JSON.parse(response.strip)["result"][0] or raise RecipeNotFound
  end
end
