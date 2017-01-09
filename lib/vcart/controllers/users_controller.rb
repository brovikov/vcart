# encoding: utf-8
# require 'product_recommender'
class UsersController < ApplicationController
  before_filter :authorize, only: [:edit, :update, :destroy]
 

  def show
    @user = User.cached_find(params[:id])



  end



  def new
    @user = User.new
    @vitrine = Vitrine.new
  end

  def create
    @user = User.new(params[:user])
    @vitrine = Vitrine.new(params[:vitrine])

    if @user.save
      @user.authenticate(params[:user][:password])
      @user.update_attribute(:login_at, Time.zone.now)
      @user.update_attribute(:ip_address, request.remote_ip)
      cookies[:auth_token] = {:value => @user.auth_token, :expires => 3.month.from_now}
      redirect_to root_url
      flash[:success] = "Bem vindo a Vitrineonline #{(@user.first_name)}".html_safe
    else
      render :new
      flash[:error] = 'Ooooppss, algo deu errado!'.html_safe
    end
  end

 

  def edit
    @user = current_user

    @states = State.all
    @cities = City.where('state_id = ?', State.first.id)





  end






  def update
    @user = User.find(params[:id])
    respond_to do |format|
      format.html do
      
        if @user.update_attributes(params[:user])
          redirect_to(action: :edit, id: @user, only_path: true, format: :html)
          flash[:notice] = 'Conta atualiazada'

        else
          render :edit
        end
      end
      format.json do
        @user.update_attributes(params[:user])
        render nothing: true
      end
    end
  end

  def destroy
    if @user.destroy
      Product.reindex
      cookies.delete(:auth_token)
      redirect_to root_path
      flash[:success] = 'Conta deletada'
    else
      render :edit
    end
  end



end
