Membership.delete_all

require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'oldmembership.csv'))
csv = CSV.parse(csv_text, :headers => true, :quote_char => "|")
csv.each do |row|
  t = Membership.new
  t.last_name = row['LastName']
  t.first_name = row['FirstName']
  t.address1 = row['Address1']
  t.address2 = row['Address2']
  t.city = row['City']
  t.state = row['State']
  t.zipcode = row['ZipCode']
  t.email = row['Email']
  t.phone_number = row['Phone']
  t.fax = row['Fax']
  t.membership_type = row['MembershipType']
  t.organization = row['Organization']
  t.url = row['WebUrl']
  t.valid_year = row['MembValidYear']
  t.payment_date = row['PaymentDate']
  t.payment_id = 'previous system'
  t.save
  puts "#{t.first_name} #{t.last_name} saved"
end

puts "There are now #{Membership.count} rows in the Memberships table"
