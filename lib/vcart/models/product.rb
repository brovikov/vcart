class Product < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :history]

  default_scope -> { order('created_at DESC') }

  belongs_to :vitrine

  has_many :orders

  attr_accessible  :name, :detail, :price,
                  :quantity, :status, :vitrine_id, :products, :price,
                  :state
                 


  validates :name, presence: true, length: { maximum: 140 }
  validates :price, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }



  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([name, id], expires_in: 5.minutes) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def cached_product
    Product.cached_find(product_id)
  end


  # CACHE

  def subtotal
    quantity * price
  end

  # CHECK IF CAN BUY
  def buyable?(user)
    if user.cart
      orders = user.cart.orders.where('seller_id = ?', vitrine.id)
      orders.each do |order|
        return false if order.product.id == id && (order.quantity == quantity)
      end

    end
    vitrine.owner?(user) == false && quantity > 0
   end

  after_touch :reindex


 

 end
