json.extract! membership, :id, :first_name, :last_name, :address1, :address2, :city, :state, :zipcode, :email, :phone_number, :fax, :membership_type, :organization, :url, :valid_year, :payment_date, :created_at, :updated_at
json.url membership_url(membership, format: :json)
