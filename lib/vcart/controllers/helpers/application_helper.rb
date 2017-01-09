# encoding: utf-8
module ApplicationHelper









  def remove_user
    cookies.delete(:auth_token)
    current_user = nil
    redirect_to root_url
  end

  def order_count
    if current_user
      unless current_user.cart.nil?
        total = 0
        current_user.cart.orders.each do |order|
          total += order.quantity if order.status.nil?
        end
        total > 0 ? " #{total}" : ''
      end
    end
  end

  def order_subtotal
    if current_user
      unless current_user.cart.nil?
        total = 0
        current_user.cart.orders.each do |order|
          total += order.total_price if order.status.nil?
        end
        total > 0 ? " #{total}" : ''
      end
    end
    end











end
