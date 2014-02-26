module Chefcard
  class RecipeDecorator
    def initialize(recipe)
      @recipe = recipe
    end
  
    def raw
      @recipe
    end
  
    def id
      @recipe['rezept_show_id']
    end
  
    def name
      @recipe['rezept_name']
    end
  
    def description(fallback: true)
      @recipe['rezept_name2'].to_s.empty? && fallback ? name : @recipe['rezept_name2']
    end
  
    def instructions
      @recipe['rezept_zubereitung']
    end
  
    def ingredients
      Array(@recipe['rezept_zutaten']).map { |i| format_ingredient(i) }
    end
    
    def servings
      @recipe['rezept_user_portionen'] # @recipe['rezept_portionen']
    end
  
    def level
      @recipe['rezept_schwierigkeit'] || 'k.A.'
    end
  
    def kcal
      format_if_present @recipe['rezept_kcal'], unit: 'kcal'
    end
  
    def preparation_time(short=true)
      format_time @recipe['rezept_preparation_time'], short
    end
  
    def cooking_time(short=true)
      format_time @recipe['rezept_cooking_time'], short
    end
  
    def resting_time(short=true)
      format_time @recipe['rezept_resting_time'], short
    end
  
    def user_name
      @recipe['rezept_user_name']
    end
  
    def user_link
      %Q[<a href="http://www.chefkoch.de/user/profil/#{@recipe['rezept_user_id']}">#{user_name}</a>]
    end
  
    def chefkoch_url
      @recipe['rezept_frontend_url']
    end
  
    def chefkoch_link
      %Q[<a href="#{chefkoch_url}">Rezept bei Chefkoch.de ansehen</a>]
    end
    
    def votes
      @recipe['rezept_votes']
    end
    
    def voting_sentence
      "Im Durchschnitt #{votes['average']} von 5 Sternen bei #{votes['votes']} Stimmabgaben."
    end
    
    def stars
      ('★' * votes['average'].round).ljust(5, '☆')
    end
    
    # available image sizes
    # ["224x148-fix", "112x74-fix", "168x111-fix", "420x280-fix", "200x200-fix"]
    
    def thumbnail_url
      image_url("200x200-fix") || image_url("224x148-fix") || strip_url
    end
    
    def strip_url
      image_url("420x280-fix")
    end
    
    def icon_url
      image_url("112x74-fix")
    end
    
    def background_url
      strip_url
    end
    
    private
    
    def image_url(size, i=0)
      @recipe["rezept_bilder"][i][size]["file"] rescue nil
    end
    
    def format_if_present(value, unit: nil)
      "#{value} #{unit||''}".strip if value && value.to_i > 0
    end
    
    def format_ingredient(i)
      menge = format_if_present(i['menge_berechnet'], unit: i['einheit'])
      "#{ menge } #{ i['name'] }#{ i['eigenschaft'] }".strip
    end
    
    def format_time(min, short)
      return nil unless (min && min.to_i > 0)

      prefix = short ? '' : 'ca. '
      words  = human_seconds(min*60).map do |value, label|
        unit = short ? 2 : (value==1 ? 0 : 1)
        "#{value} #{TimeDict[label][unit]}"
      end
      
      prefix + words.join(', ')
    end
    
    def human_seconds(secs)
      [
        [:second, 60],
        [:minute, 60],
        [:hour,   24],
        [:day,     7],
        [:week,    4],
        [:month,  12],
        [:year,   10000]
      ].map do |name, s|
        if secs > 0
          secs, n = secs.divmod(s)
          [n, name] if n > 0
        end
      end.compact.reverse
    end

    TimeDict = {
      year:   ['Jahr',    'Jahre',    'a'],
      month:  ['Monat',   'Monate',   'M'],
      week:   ['Woche',   'Wochen',   'W'],
      day:    ['Tag',     'Tage',     'd'],
      hour:   ['Stunde',  'Stunden',  'h'],
      minute: ['Minute',  'Minuten',  'min'],
      second: ['Sekunde', 'Sekunden', 's']
    }
  end
end