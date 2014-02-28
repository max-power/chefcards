require 'sinatra/base'
require 'passbook'
require 'base64'
require_relative 'chefkoch'
require_relative 'recipe_card'

module Chefcard
  class Server < Sinatra::Base
    Passbook.certificate = Base64.decode64 ENV['CHEFCARD_CERTIFICATE']
    Passbook.password    = ENV['CHEFCARD_PASSWORD']
    
    set :public_folder, Pathname.new(__FILE__).dirname.parent + 'public'

    set :pass_config, {
      passTypeIdentifier: ENV['CHEFCARD_PASSTYPE_ID'],
      teamIdentifier:     ENV['CHEFCARD_TEAM_ID'],
      organizationName:   ENV['CHEFCARD_ORG_NAME']
    }

    get '/' do
      send_file File.join(settings.public_folder, 'index.html')
    end
    
    get '/:id.pkpass' do
    end
    
    post '/' do
      begin
        recipe = Chefkoch.recipe(params[:id], divisor: params[:p])
        pass   = Chefcard::RecipeCard.new(recipe, (params[:t] || :generic).to_sym)
        pkpass = Passbook::PKPass.new(pass.specs.merge(settings.pass_config), pass.assets)
        
        content_type pkpass.content_type
        body pkpass.to_s
      rescue Chefkoch::RecipeNotFound
        halt 404
      end
    end
    
    not_found do
      send_file 'public/404.html'
    end
    
    error do
      send_file 'public/500.html'
    end
  end
end