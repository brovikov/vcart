class Vitrine < ActiveRecord::Base
  extend FriendlyId
  # include ActiveModel::Validations
  friendly_id :name, use: [:slugged, :history]

  belongs_to :user



  has_many :products, dependent: :destroy


  has_many :orders, foreign_key: 'seller_id'
 

   
  
  
  
  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([name, id], expires_in: 5.minutes) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def cached_vitrine
    Vitrine.cached_find(vitrine_id)
  end

  def vitrine_name
    name.to_s
  end

  def vitrine_address
    address.to_s
  end

  def vitrine_city
    "#{city.name}, #{state.code}"
  end

  def vitrine_neighborhood
    neighborhood.to_s
  end

  def vitrine_postal_code
    postal_code.to_s
  end

  def views_count
    views.count
  end

  def owner?(user)
    self.user == user
  end

  def vitrine_name
    name.to_s
  end

 
  before_create :build_default_models

  accepts_nested_attributes_for :policy, :products,
                                :marketing, allow_destroy: true

  validates :name, uniqueness: { case_sensitive: false },
                   length: { within: 1..70 }

  attr_accessible :name, :about,                  :address, :neighborhood,:postal_code, :address_supplement, :code, :about

  # CACHE

  private

  def build_default_models
    build_policy
    build_marketing

    true
  end
end
