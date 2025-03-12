# == Schema Information
#
# Table name: bids
#
#  id               :bigint           not null, primary key
#  bitrix_synced    :integer          default("waiting"), not null
#  contacts_sent    :boolean          default(FALSE)
#  email            :string
#  message          :text
#  mobile           :boolean          default(FALSE)
#  name             :string
#  phone            :string
#  price_on_request :boolean
#  sale_price       :integer
#  sale_price_unit  :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bitrix_id        :integer
#  property_id      :bigint           indexed
#

class Bid < ApplicationRecord
  include Priceable
  include Commentable
  include ContactWayModule
  include Decoratable
  include BitrixSyncable
  include Filterable
  include QueryModule

  query_fields 'bids.name', :phone, :email

  filter_params :query

  belongs_to :property
  has_one :agency, through: :property
  has_one :country, through: :property

  # validates :name, :email, :comments, :phone, :property_id, presence: { message: I18n.t('common.must_be_specified') }
  # validates :email, format: { with: User::EMAIL_REGEX, message: I18n.t('common.incorrectly_email') }
  # validates :phone, length: { minimum: 6, message: I18n.t('common.incorrectly_phone') }

  after_create :save_old_price

  validates_with BidValidator

  PRICE = {
      cheap: 100_000,
      medium: 500_000
  }.freeze

  scope :cheap, -> { where("bids.sale_price <= :max_price",
                           max_price: PRICE[:cheap]) }
  scope :medium, -> { where("bids.sale_price <= :max_price AND bids.sale_price > :min_price",
                           max_price: PRICE[:medium],
                            min_price: PRICE[:cheap]) }
  scope :expensive, -> { where("bids.sale_price >= :min_price",
                               min_price: PRICE[:medium]) }
  scope :on_request, -> { where("bids.price_on_request = true") }

  scope :by_agency_id, ->(agency_id) { where(agencies: { id: agency_id }) }

  def price_changed?
    property.sale_price != sale_price ||
        property.sale_price_unit != sale_price_unit ||
        property.price_on_request != price_on_request
  end

  private

    # Сохранить цену недвижимости на момент создания обращения
    def save_old_price
      update(sale_price: property.sale_price,
             sale_price_unit: property.sale_price_unit,
             price_on_request: property.price_on_request)
    end
end
