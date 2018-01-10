class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :first_name
      t.string :last_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :email
      t.string :phone_number
      t.string :fax
      t.string :membership_type
      t.string :organization
      t.string :url
      t.integer :valid_year
      t.date :payment_date

      t.timestamps null: false
    end
  end
end
