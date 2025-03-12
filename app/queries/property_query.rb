class PropertyQuery
  class << self
    # Пока что это просто метод-заглушка
    def popular
      Property.active.with_associations
          .order(created_at: :desc).first(5).reverse
    end

    def popular_for_sale
      Property.active.for_sale.with_associations
          .order(created_at: :desc).first(5).reverse
    end
  end
end
