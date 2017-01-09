# encoding: utf-8

class VitrinesController < ApplicationController
   before_filter :authorize_vitrine, only: [:edit, :update]

  def show
    @vitrine = Vitrine.cached_find(params[:id])

    
  end



   def vitrine_products
     
      @vitrine = Vitrine.cached_find(params[:id])
   
      @q = Product.joins(:vitrine).where('vitrines.id' => @vitrine.id).ransack(params[:q])
    @products = @q.result(distinct: true).paginate(page: params[:page], per_page: 22)

         respond_to do |format|
           format.html { render 'products'}
         end
    end


 
def products
 

      @vitrine = Vitrine.cached_find(params[:id])
   
      @q = Product.joins(:vitrine).where('vitrines.id' => @vitrine.id).ransack(params[:q])
    @products = @q.result(distinct: true).paginate(page: params[:page], per_page: 22)
    


end




  def new
    @vitrine = Vitrine.new
  end



  def create
    @vitrine = current_user.build_vitrine(params[:vitrine])
    if @vitrine.save
      redirect_to(action: :edit, id: @vitrine, only_path: true)
      flash[:success] = "#{@vitrine.name} criada com sucesso, boa sorte em seu empreendimento #{@vitrine.user.first_name}".html_safe

    else
      render :new
    end
  end

  def update
    respond_to do |format|
      format.html do
        @vitrine = current_vitrine
        if @vitrine.update_attributes(params[:vitrine])

          redirect_to(action: 'edit', id: @vitrine, format: :html, only_path: true)
          flash[:notice] = "#{@vitrine.name} atualiazada"


        else
          render :edit, format: :html
        end
      end
      format.json do
        @vitrine.update_attributes(params[:vitrine])
        render :nothing => true
      end
    end
  end


end
