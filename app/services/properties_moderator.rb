# module Services
class PropertiesModerator
  PICTURE_MIN_HEIGHT = 600
  PICTURE_MIN_WIDTH = 800

  DESCRIPTION_MIN_LENGTH = 150
  SALE_PRICE_MIN = 5000

  # Автоматически задает полю moderated значение true для недвижимости, которая удовлетворяет условиям
  # Не забыть запустить rails location:update_counters
  def perform
    properties = premoderated_properties
    moderated_properties_ids = []

    properties.each_with_index do |property, index|
      if pictures_valid?(property.pictures)
        # property.update_attribute(:moderated, true)
        moderated_properties_ids << property.id
      end

      if index % 1000 == 0
        Property.where(id: moderated_properties_ids).update_all(moderated: true)
        moderated_properties_ids = []
      end
    end
  end

  private

    # Возвращает список недвижимости, у которой:
    #  - есть описание на русском или английском языках и оно больше DESCRIPTION_MIN_LENGTH
    #  - цена в евро больше SALE_PRICE_MIN
    #  - больше трех изображений
    #  - moderated установлен false
    def premoderated_properties
      Property.where("(
                        (description_ru IS NOT NULL AND description_ru <> '' AND
                          length(description_ru) > ?) OR
                        (description_en IS NOT NULL AND description_en <> '' AND
                          length(description_en) > ?)
                      ) AND
                      sale_price > ? AND
                      moderated = ?", DESCRIPTION_MIN_LENGTH, DESCRIPTION_MIN_LENGTH, SALE_PRICE_MIN, false)
          .joins(:pictures)
          .group('properties.id')
          .having('count(pictures.id) > 3')
    end


    # Изображение валидно, если оно есть и его высота и ширина больше либо равны PICTURE_MIN_HEIGHT и PICTURE_MIN_WIDTH
    def picture_valid?(picture)
      if picture.pic.present?
        mini_magick_picture = MiniMagick::Image.open("#{Dir.pwd}/public#{picture.pic.url}")

        return (mini_magick_picture.width >= PICTURE_MIN_WIDTH && mini_magick_picture.height >= PICTURE_MIN_HEIGHT) ||
                (mini_magick_picture.width >= PICTURE_MIN_HEIGHT && mini_magick_picture.height >= PICTURE_MIN_WIDTH)
      end

      false
    end

    # Изображения валидны, если хотя бы одно из них валидно
    def pictures_valid?(pictures)
      pictures.each do |picture|
        return true if picture_valid?(picture)
      end
    end
end
# end
