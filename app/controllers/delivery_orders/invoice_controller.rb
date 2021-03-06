module DeliveryOrders
  class InvoiceController < ApplicationController
    before_filter :authenticate
    before_filter :assign_tab
    load_and_authorize_resource :delivery_order, :through => :current_company, :class => "SalesInvoice"
    authorize_resource

    def show
      @invoice = @delivery_order.invoice
    end

    def new
      @invoice = current_company.sales_invoices.new(:delivery_order_ids => [@delivery_order.id], :user_date => Time.now.to_date, :discount => 0)
    end

    def create
      @invoice = current_company.sales_invoices.new(:delivery_order_ids => [@delivery_order.id])
      @invoice.attributes = params[:sales_invoice]
      if @invoice.save
        flash[:success] = "Invoice created"
        redirect_to delivery_order_invoice_path(@delivery_order)
      else
        render :action => "new"
      end
    end

    private
    def assign_tab
      @tab = "transactions"
      @current = "do"
    end
  end
end
