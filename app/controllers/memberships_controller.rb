class MembershipsController < ApplicationController
  require 'paypal-sdk-rest'
  include PayPal::SDK::REST

  before_action :set_membership, only: [:show, :edit, :update, :destroy]

  # GET /memberships
  # GET /memberships.json
  def index
    @type = params["type"]
    @members = []

    case @type
      when 'org', 'twoyrorg', 'small'
        4.times do
          @members << Membership.new
        end
      when 'student', 'assoc'
        @members << Membership.new
      when
        3.times do
          @members << Membership.new
        end
    end
    #@memberships = Membership.all
  end

  def all
    @members = Membership.all.order(:valid_year)
    render layout: "all_layout"
  end

  # GET /memberships/1
  # GET /memberships/1.json
  def show
  end

  # GET /memberships/new
  def new
    @membership = Membership.new
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.json
  def create
    # Build Payment object
    @payment = Payment.new({
      :intent =>  "sale",
      :payer =>  {
        :payment_method =>  "paypal"
      },
      :redirect_urls => {
        :return_url => "#{success_memberships_url}",
        :cancel_url => "#{error_memberships_url}"
      },
      :transactions =>  [{
        :item_list => {
          :items => [{
            :name => "#{params[:type]}",
            :price => "#{params[:price]}",
            :currency => "USD",
            :quantity => 1
          }]
        },
        :amount =>  {
          :total =>  "#{params[:price]}",
          :currency =>  "USD"
        },
        :description =>  "This is the payment for an #{params[:type]} membership."
      }]
    })

    if @payment.create
      params[:members].each do |member|
        member[:organization] = params["organization"]
        member[:address1] = params[:address1]
        member[:address2] = params[:address2]
        member[:city] = params[:city]
        member[:state] = params[:state]
        member[:zipcode] = params[:zipcode]
        member[:url] = params[:url]
        member[:fax] = params[:fax]
        member[:payment_id] = @payment.id

        member = Membership.create(member_params(member))
      end

      if params["provide_benefit"] == "yes"
        MembershipMailer.provide_benefit_email(params["organization"]).deliver_later
      end

      # Capture redirect url
      redirect_url = @payment.links.find{|v| v.rel == "approval_url" }.href
      redirect_to redirect_url
    else
      @payment.error  # Error Hash
    end

    #@membership = Membership.new(membership_params)

    #respond_to do |format|
      #format.html { redirect_to :index, notice: "#{@created.count} Memberships #{'were'.pluralize(@created.count)} successfully created." }
      #format.json { render :show, status: :created, location: @membership }
    #end
  end

  # PATCH/PUT /memberships/1
  # PATCH/PUT /memberships/1.json
  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to @membership, notice: 'Membership was successfully updated.' }
        format.json { render :show, status: :ok, location: @membership }
      else
        format.html { render :edit }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to memberships_url, notice: 'Membership was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def error
    @members = []
    Membership.where(payment_id: "pending").each do |member|
      member.update_attribute("payment_id", "no payment")
      @members << member.first_name + " " + member.last_name + " - " + member.membership_type
    end

    MembershipMailer.error_email(@members).deliver_later
  end

  def success
    payment = Payment.find(params[:paymentId])
    if payment.execute(:payer_id => payment.payer.payer_info.payer_id)
      @members = []
      Membership.where(payment_id: payment.id).each do |member|
        member.update_attributes(payment_date: Date.today(), payment_id: payment.id)
        @members << member.first_name + " " + member.last_name + " - " + member.membership_type
        @organization = member.try(&:organization)
      end

      MembershipMailer.success_email(@members, @organization).deliver_later
    else
      @members = []
      Membership.where(payment_id: "pending").each do |member|
        member.update_attributes(payment_id: "failed")
        @members << member.first_name + " " + member.last_name + " - " + member.membership_type
        @organization = member.try(&:organization)
      end
      MembershipMailer.error_email(@members).deliver_later
    end
  end

  def add_member
    @member = Membership.new
    @type = params["type"]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    def member_params(member)
      member.permit(:first_name, :last_name, :address1, :address2, :city, :state, :zipcode, :email, :phone_number, :fax, :membership_type, :organization, :url, :valid_year, :payment_date, :payment_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:first_name, :last_name, :address1, :address2, :city, :state, :zipcode, :email, :phone_number, :fax, :membership_type, :organization, :url, :valid_year, :payment_date, :payment_id)
    end
end
