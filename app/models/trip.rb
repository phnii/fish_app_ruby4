class Trip < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :user
  belongs_to :prefecture
  has_many   :results, dependent: :destroy
  has_many   :comments, dependent: :destroy
  accepts_nested_attributes_for :results, allow_destroy: true

  validates :title, presence: true
  validates :prefecture_id, numericality: { other_than: 0, message: "can't be blank"}
end
