
# require File.join File.dirname(__FILE__), 'send_code'
class User < ActiveRecord::Base
  extend FriendlyId

  friendly_id :first_name, use: [:slugged, :history]



  before_create { generate_token(:auth_token) }
 after_commit :send_user_welcome, :on => :create
 # before_create :confirmation_token

  has_one :vitrine, dependent: :destroy
  has_one :cart, dependent: :destroy

  has_many :orders, foreign_key: 'buyer_id'
  belongs_to :city, touch: true
  belongs_to :state, touch: true

 




 

  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([name, id], expires_in: 5.minutes) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def cached_user
    User.cached_find(user_id)
  end

  def full_name
    "#{name} #{surname}"
  end

  def user_address
    address.to_s
  end

  def user_city
    city.name.to_s
  end

  def user_state
    state.code.to_s
  end

  def user_neighborhood
    neighborhood.to_s
  end

  def user_postal_code
    postal_code.to_s
  end

  def user_address_supplement
    address_supplement.to_s
  end


 

  validates_format_of :postal_code, with: /\A(\d{5})([-]{0,1})(\d{3})\Z/, allow_blank: true

  accepts_nested_attributes_for :vitrine, allow_destroy: true

  attr_accessible :email, :confirm_token, :email_confirmation, :email_confirmed, :password, :password_confirmation, :first_name,
                  :last_name, :avatar, :avatar_id, :gender, :vitrine_attributes, :address, :state_id,
                  :city_id, :postal_code, :neighborhood, :address_supplement, :about

  has_secure_password

  validates_presence_of :email, :password, :first_name, :last_name, :gender, on: :create

  validates :email, email: true,
                    uniqueness: { case_sensitive: false }

  validates :password, length: { within: 6..60 },
                       format: { with: /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/, message: "Deve ter pelo menos 6 caracteres e incluir um número e uma letra" },
                       confirmation: true,
                       if: :is_password_validation_needed?

  validates :first_name, :last_name, length: { within: 1..70 }

  validates :email, confirmation: true,
                    email: true,
                    on: :update

  # Two Factor Authentication

  # def authenticate(email, password)
  #  if email.eql?(self.email) && password.eql?(self.password)
  #      send_auth_code
  #  end
  #  end

  #  def send_auth_code
  #    SendCode.new.send_sms(:to => self.phone, :body => "Codigo #{self.otp_code}")
  #  end

  def send_user_welcome
    UserMailer.user_welcome(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  
  private

  def is_password_validation_needed?
    new_record? || password
  end

  def confirmation_token
    if confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
end
end
