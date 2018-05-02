# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class Skin
  def delete_deprecated_skin_cards
    skin_cards.each do |name_parts|
      next unless Card.fetch(name_parts).pristine?
      delete_card name_parts
    end
  end

  def skin_cards
    [[skin_name, "bootswatch theme"],
     [skin_name, "style"],
     [skin_name, "variables"]]
  end
end


class DeleteDeprecatedSkinCards < Card::Migration::Core
  def up
    Skin.each do |skin|
      skin.delete_deprecated_skin_cards
    end
    Skin.new("bootstrap default").delete_deprecated_skin_cards
    delete_card "default bootstrap skin"
  end
end
