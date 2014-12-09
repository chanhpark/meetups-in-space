class Meetup < ActiveRecord::Base
  validates :name,
    presence: true
  validates :description,
    presence: true
  validates :location,
    presence: true
end
