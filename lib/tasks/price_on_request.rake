namespace :price_on_request do
  desc "Обновляет состояние флага price_on_request"
  task update_flag: :environment do
    Bid.where(sale_price: nil).or(Bid.where(sale_price: 0)).each do |bid|
      bid.update(price_on_request: true)
    end
  end
end
