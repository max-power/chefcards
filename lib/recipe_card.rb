require_relative 'chefkoch'
require_relative 'recipe_decorator'

module Chefcard
  class RecipeCard
    PassTypeImages = {
      boardingPass: %w(logo icon footer),
      coupon:       %w(logo icon strip),
      eventTicket:  %w(logo icon strip background thumbnail),
      generic:      %w(logo icon thumbnail),
      storeCard:    %w(logo icon strip)
    }
    
    def initialize(recipe, pass_type=:generic)
      @recipe, @pass_type = RecipeDecorator.new(recipe), pass_type.to_sym
    end
    
    def specs
      base_info.merge(@pass_type => fields)
    end
    
    def assets
      recipe_assets.merge({
        "logo.png"     => "./assets/logo.png",
        "logo@2x.png"  => "./assets/logo@2x.png"
      })
    end
    
    private
    
    def recipe_assets
      PassTypeImages[@pass_type][1..-1].each_with_object({}) do |image_type, files|
        if @recipe.respond_to?(:"#{image_type}_url") && url = @recipe.send(:"#{image_type}_url")
          files["#{image_type}.png"]    = url.to_s
          files["#{image_type}@2x.png"] = url.to_s
        end
      end
    end
    
    def base_info
      {
        formatVersion: 1,
        # Optional for event tickets and boarding passes; otherwise not allowed.
        # NOTE: this seems to work no matter which type
        groupingIdentifier: "Chefcard",
#        appLaunchURL: '',
        associatedStoreIdentifiers: [Chefkoch::ADAM_ID],
        
        backgroundColor: "#618d04",
        foregroundColor: "#ffffff",
        labelColor:      "rgba(255,255,255,0.5)",

        serialNumber:    @recipe.id,
        description:     @recipe.name,
        logoText:        @recipe.name
      }
    end
    
    def fields
      {
        headerFields:    [],
        primaryFields:   Array(primaryFields),
        secondaryFields: Array(secondaryFields),
        auxiliaryFields: Array(auxiliaryFields),
        backFields:      Array(backFields)
      }
    end

    def primaryFields
      unless PassTypeImages[@pass_type].include?('strip')
        [
          { key: 'name', label: '', value: @recipe.description }
        ]
      end
    end
    
    def secondaryFields
      [].tap do |f|
        f << { key: 'prep_time',    label: 'Arbeitszeit', value: @recipe.preparation_time } if @recipe.preparation_time
        f << { key: 'cooking_time', label: 'Kochzeit',    value: @recipe.cooking_time }     if @recipe.cooking_time
        f << { key: 'resting_time', label: 'Ruhezeit',    value: @recipe.resting_time }     if @recipe.resting_time
      end
    end
    
    def auxiliaryFields
      [].tap do |f|
        f << { key: 'schwierigkeit', label: 'Schwierigkeit', value: @recipe.level }
        f << { key: 'kcal',          label: 'Brennwert',     value: @recipe.kcal } if @recipe.kcal
      end
    end
    
    def backFields
      [].tap do |f|
        f << { key: 'back_title',   label: @recipe.name, value: @recipe.description(fallback: false) }
        f << {
          key:  'zutaten',
          label: "Zutaten für " + pluralize(@recipe.servings, 'Portion', 'Portionen'),
          value: @recipe.ingredients.join("\n")
        }
        f << { key: 'prep_time',    label: 'Arbeitszeit', value: @recipe.preparation_time(false) } if @recipe.preparation_time
        f << { key: 'cooking_time', label: 'Kochzeit',    value: @recipe.cooking_time(false) }     if @recipe.cooking_time
        f << { key: 'resting_time', label: 'Ruhezeit',    value: @recipe.resting_time(false) }     if @recipe.resting_time
        f << { key: 'zubereitung',  label: 'Zubereitung', value: @recipe.instructions }
        f << { key: 'kcal',         label: "Brennwert pro Portion",      value: @recipe.kcal } if @recipe.kcal
        f << { key: 'votes',        label: "Bewertung #{@recipe.stars}", value: @recipe.voting_sentence }
        f << { key: 'user_name',    label: 'Verfasser',   value: @recipe.user_name,    attributedValue: @recipe.user_link }
        f << { key: 'frontend_url', label: 'URL',         value: @recipe.chefkoch_url, attributedValue: @recipe.chefkoch_link }
        f << {
          key: 'chefcard_url',
          label: 'CHEFCARDS',
          value: 'Erstelle eigene Chefcards auf http://chefcards.herokuapp.com',
          attributedValue: %Q[<a href="http://chefcards.herokuapp.com">Erstelle eigene Chefcards!</a>]
        }
      end
    end
    
    def pluralize(num, singular, plural)
      "#{num} #{num.to_i==1 ? singular : plural}"
    end
  end
end