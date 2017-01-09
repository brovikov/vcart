require "vcart/version"


require "rails"
require "vcart/models"
require "vcart/controllers"
require "vcart/views/carts"
require "vcart/views/products"
require "vcart/views/orders"
require "configatron"
require "adaptivepayments-sdk-ruby"
require "will_paginate"


module Vcart
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'database.db'

    ActiveRecord::Schema.define do
        unless ActiveRecord::Base.connection.tables.include? 'carts', 'orders','products'
            create_table :carts do |table|
                table.column :use_id, :integer
            end


            create_table :orders do |table|
             table.column :cart_id, :integer
             table.column :seller_id, :integer
             table.column :buyer_id, :integer
             table.column :product_id, :integer
             table.column :quantity_id, default: 0, :integer
             table.column :shipping_cost, precision: 9, scale: 2, :decimal
             table.column :shipping_method, :string
             table.column :transaction_status, :string
             table.column :status, :string

            end


            create_table :products do |table|
             table.column :name, :string
             table.column :price, :integer
              table.column :detail, :text
             table.column :quantity, default: 0, :integer
              table.column :status, :string

            end

        end


    end



ActionController::Routing::Routes.draw do |map|  
  map.connect '/carts/add/:id', :controller => 'carts', :action => 'add'
end  


end
