class Order < ActiveRecord::Base
  
   STATUSES = %w(paid sent).freeze
  belongs_to :orderable, polymorphic: true
 
  belongs_to :seller, foreign_key: 'seller_id', class_name: 'Vitrine'
  belongs_to :buyer, foreign_key: 'buyer_id', class_name: 'User'
  belongs_to :product, touch: true
  belongs_to :color
  belongs_to :size
  belongs_to :cart
 
  has_one    :transaction




   
  attr_accessible :cart_id, :product_id, :purchased_at, :quantity,
                  :buyer_id, :quantity, :seller_id, :shipping_cost, :shipping_method, 
                  :status,  :color, :size

   
    validates :shipping_cost, numericality: { greater_than: 0, allow_nil: true }


  scope :awaiting_feedback, ->(user) { joins('left join feedbacks on feedbacks.id = orders.feedback_id').where('(buyer_id = ? and buyer_feedback_date is null) or (seller_id = ? and seller_feedback_date is null)', user.id, user.vitrine ? user.vitrine.id : 0).where('status is not null').order(:created_at) }

  after_update :create_product_data



  def shipping_cost=(shipping_cost)
    write_attribute(:shipping_cost, shipping_cost.tr(',', '.'))
  end

  STATUSES.each do |method|
    define_method "#{method}?" do
      status == method
    end
  end

  def self.statuses
    STATUSES
  end

  def total_price
    product.price * quantity
  end

  def decrease_products_count
    product.quantity -= quantity
    product.save
    OrderMailer.delay.order_confirmation(self)
  end

  def store_fee
    total_price * configatron.store_fee
  end
end
