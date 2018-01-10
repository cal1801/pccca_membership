class AddPaymentIdtoMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :payment_id, :integer
  end
end
