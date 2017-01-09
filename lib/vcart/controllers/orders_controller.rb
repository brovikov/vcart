# encoding: utf-8
class OrdersController < ApplicationController
  #skip_before_filter :authorize, only: :ipn_notification
 # protect_from_forgery except: [:ipn_notification]


  def checkout
    @order = current_user.cart.orders.find(params[:id])
    if current_user.address.blank?
      redirect_to :back
      flash[:error] = 'Antes de prosseguir por favor, preencha o seu endereço'
    end
  end

  def update
    order = Order.find(params[:id])
    flash = if order.update_attributes(params[:order])
              { success: 'Frete Salvo.' }
            else
              { error: 'Preço Inválido.' }
            end
    if request.xhr?
      render json: flash
    else
      redirect_to checkout_order_path(order), flash: flash
    end
  end

  def destroy
    if current_user.cart
      order = current_user.cart.orders.find(params[:id])
      order.destroy
      redirect_to carts_path
    end
  end

  def buy
order = Order.find(params[:id])
    


 
    store_amount = (order.total_price * configatron.store_fee).round(2)
    seller_amount = (order.total_price - store_amount) + order.shipping_cost



   @api = PayPal::SDK::AdaptivePayments.new


      @pay = @api.build_pay({
        :actionType => "PAY",
        :cancelUrl => carts_url,
        :currencyCode => "BRL",
        :feesPayer => "SENDER",
        :ipnNotificationUrl => ipn_notification_order_url(order),

        :receiverList => {
          :receiver => [{
            :email =>  order.product.vitrine.paypal,
          

            :amount => seller_amount,
         
            :primary => true,
            :email => configatron.paypal.merchant,
         
             :amount => store_amount, 
             
               :primary => false}]},
             :returnUrl => carts_url })



             @response = @api.pay(@pay)

             # Access response
             if @response.success? && @response.payment_exec_status != "ERROR"
               @response.payKey
               redirect_to @api.payment_url(@response)  # Url to complete payment
             else
               @response.error[0].message
               redirect_to fail_order_path(order)

             end
 end


  
  def fail
  end

  def ipn_notification
    ipn = PayPal::SDK::Core::API::IPN.new
    
    ipn.send_back(request.raw_post)


 if PayPal::SDK::Core::API::IPN.valid?(request.raw_post)
      logger.info("IPN message: VERIFIED")


   # if ipn.verified?
      order = Order.find(params[:id])
      if order
        if params[:status] == 'COMPLETED'
          order.status = Order.statuses[0]
          order.decrease_products_count
          transaction = Transaction.new
          transaction.store_fee = order.store_fee
          transaction.transaction_id = params[:transaction]['0']['.id_for_sender_txn']
          transaction.status = params[:status]
          order.transaction = transaction
          order.save

        end
      end
    end

    render nothing: true
  end



  def index
  end

end
