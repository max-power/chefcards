require 'sinatra/base'
require 'passbook'
require 'base64'
require_relative 'chefkoch'
require_relative 'recipe_card'

module Chefcard
  class Server < Sinatra::Base
    set :public_folder, Pathname.new(__FILE__).dirname.parent + 'public'

    set :pass_signer, Passbook::Authority.new(
      Base64.decode64(ENV['CHEFCARD_CERTIFICATE']),
      ENV['CHEFCARD_PASSWORD']
    )
    set :pass_config, {
      passTypeIdentifier: ENV['CHEFCARD_PASSTYPE_ID'],
      teamIdentifier:     ENV['CHEFCARD_TEAM_ID'],
      organizationName:   ENV['CHEFCARD_ORG_NAME']
    }

    get '/' do
      send_file settings.public_folder + 'index.html'
    end
    
    # get '/:id.pkpass' do
    # end
    
    post '/' do
      begin
        recipe = Chefkoch.recipe(params[:id], divisor: params[:p])
        pass   = Chefcard::RecipeCard.new(recipe, (params[:t] || :generic).to_sym)
        pkpass = Passbook::PKPass.new(pass.specs.merge(settings.pass_config), pass.assets, settings.pass_signer)
        
        content_type pkpass.content_type
        body pkpass.to_s
      rescue
        halt 404
      end
    end
    
    not_found do
      send_file settings.public_folder + '404.html'
    end
    
    error do
      send_file settings.public_folder + '500.html'
    end
  end
end