# encoding: utf-8
class ProductsController < ApplicationController

 
  def new
    @product = Product.new


  
  end





#TODO
#report





  def edit
    @product = Product.cached_find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    respond_to do |format|
      format.html do
        if @product.update_attributes(params[:product])
     

          redirect_to(action: :show, id: @product, only_path: true)
          flash[:success] = "#{@product.name} atualizado"
        else
          render :edit
        end
      end
    
        render :nothing => true
      end
    end
 

  def show
    @product = Product.cached_find(params[:id])
      @colors_for_dropdown = @product.colors.collect{ |co| [co.name, co.id]}
      
  
  @sizes_for_dropdown = @product.sizes.collect { |s| [s.size, s.id] }

  
  end



  def create
    @product = current_vitrine.products.build(params[:product])
    if @product.save
      # redirect_to wizard_path(steps.first, product_id: @product.id)
      redirect_to product_step_path(@product, Product.form_steps.first, only_path: true, format: :html)

    else
      render :new, format: :html
    end
  end

  def destroy
    @product = Product.find(params[:id])

    if @product.destroy
      Product.reindex
      expire_fragment('product')
      flash[:success] = "#{@product.name} removido"
    end
  end



  protected



  private

  def correct_product
    @product = Product.cached_find(params[:id])
    redirect_to login_path unless current_vitrine?(@product.vitrine)
  end


end
