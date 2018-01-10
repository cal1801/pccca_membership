class ChangeFormatForPaymentIdToString < ActiveRecord::Migration
  def change
    change_column :memberships, :payment_id, :string
  end
end
