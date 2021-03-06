# encoding: utf-8

class CartsController < VcartController
 
    
  def add
    product = Product.find(params[:id])

    if product
     if product.buyable?(current_user)
        current_user.cart = Cart.new if current_user.cart.nil?
        color = Color.find_by_id(params[:color_id])
        size =  Size.find_by_id(params[:size_id])
        quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
       order = current_user.cart.orders.find_by_product_id_and_status(product.id, nil)


 


        if order.nil? # create new order
          
          order = Order.new
          order.product = product
          order.seller = product.vitrine
          order.buyer = current_user
          order.quantity = quantity
                  
          order.size = size
          order.color = color
         
          order.condition = condition
          order.material = material
          order.brand = brand

          current_user.cart.orders << order
        else # increase quantity
          order.quantity += quantity
          order.save
        end

        redirect_to product_path(product)
        flash[:success] = "#{product.name} adicionado(a) a sacola"
      else
        redirect_to product_path(product)
        flash[:error] = " Erro ao adicionar #{product.name} a sacola"

      end
    else
      redirect_to :vitrines, flash[:error] = 'Produto não existe'
    end
 
  
  puts "product: #{product.inspect}"
  puts "size: #{product.sizes.inspect}"
   puts "Color: #{product.colors.inspect}"

  puts "Order: #{order.inspect}"
  puts "Cart: #{current_user.cart.inspect}"

  end









  def index
    @user = current_user
    if current_user && current_user.cart
      @orders = current_user.cart.orders.where('status is null').paginate(per_page: 22, page: params[:page])

    end
     end

  def user_address
    @user = current_user

    if @user.update_attributes(params[:user])
      redirect_to carts_path
      flash[:notice] = 'Conta atualiazada'
    else
      redirect_to carts_path
      flash[:error] = 'erro'
     end
  end



end




