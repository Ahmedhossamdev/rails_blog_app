class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true

  after_create :create_notification

  private

  def create_notification
    notification = Notification.create(
      user: followed,
      notified_by: follower,
      notification_type: "follow",
      read: false
    )
  end
end
