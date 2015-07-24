require 'active_record'

################################################
## TERRIBLE CODE ALERT!
################################################

system('rm musical_cat_universe.db')

################################################
## BASIC DB CONNECTION SETUP
################################################

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'musical_cat_universe.db'
)

################################################
## BUILDING OUR TABLES!
################################################

ActiveRecord::Schema.define do
  # Cat bands
  unless ActiveRecord::Base.connection.tables.include? 'cat_bands'
    create_table :cat_bands do |table|
      table.column :name, :string

    end
  end

  # Concerts
  unless ActiveRecord::Base.connection.tables.include? 'concerts'
    create_table :concerts do |table|
      table.column :price, :integer
      table.column :title, :string
      table.column :date, :datetime
      table.column :location, :string
      table.column :cat_band_id, :integer
    end
  end

  # Users
  unless ActiveRecord::Base.connection.tables.include? 'users'
    create_table :users do |table|
      table.column :name, :string
      table.column :email, :string
    end
  end

  # Ticketmaster accounts
  unless ActiveRecord::Base.connection.tables.include? 'ticketmaster_accounts'
    create_table :ticketmaster_accounts do |table|
      table.column :vip, :boolean
      table.column :user_id, :integer
    end
  end

  # Concert tickets
  unless ActiveRecord::Base.connection.tables.include? 'tickets'
    create_table :tickets do |table|
      table.column :ticketmaster_account_id, :integer
      table.column :concert_id, :integer
    end
  end
end

################################################
## MODELS
################################################

class CatBand < ActiveRecord::Base
  validates_length_of :name, minimum: 3
  has_many :concerts
end

class Concert < ActiveRecord::Base
  validates_length_of :title, minimum: 3
  belongs_to :cat_band
  has_many :tickets
  has_many :ticketmaster_account, through: :tickets
end

class TicketmasterAccount < ActiveRecord::Base
  has_many :tickets
  has_many :concerts, through: :tickets
  belongs_to :tickets
  belongs_to :user
end

class Ticket < ActiveRecord::Base
  belongs_to :ticketmaster_account
  belongs_to :concert

end

class User < ActiveRecord::Base
  validates_length_of :name, minimum: 3
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  has_one :ticketmaster_account
end



################################################
## DRIVER CODE
################################################

# make a new cat band: 'Princess Monster Truck and the Mousecrushers'
pmt_band = CatBand.create({name: 'Princess Monster Truck and the Mousecrushers'})
p "We made Princess Monster Truck's band:"
p pmt_band

# set up their first concert: 'Squeakblood: An Evening with Princess Monster Truck and the Mousecrushers'
pmt_concert = Concert.create({title: 'Squeakblood: An Evening with Princess Monster Truck and the Mousecrushers'})
p "We made Princess Monster Truck's concert:"
p pmt_concert
pmt_band.concerts << pmt_concert

# make a user
jen = User.create({name: "Jen Gilbert", email: "princessmonstertrucknumberonefan@gmail.com"})
p "We made a user:"
p jen

# give her a Ticketmaster account
acct = TicketmasterAccount.create({vip: true})
jen.ticketmaster_account = acct

# sign her up to see the show!
c_ticket = Ticket.create({ticketmaster_account: acct, concert: pmt_concert})

# view jen in the list of concertgoers
# p pmt_concert.users.first

p acct.user

test_user = User.new({name: "Steve", email: "Steve"})
p test_user.valid?
p test_user.errors
