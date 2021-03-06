class User < ActiveRecord::Base
  has_secure_password

  validates :username, :email, presence: true
  validates :username, :email, uniqueness: true

  has_many :user_games
  has_many :games, through: :user_games

  has_many :comments

  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"

  def friends
    friends_array = friendships.map { |friendship| friendship.friend if friendship.confirmed }
    inverse_friends = inverse_friendships.map { |friendship| friendship.user if friendship.confirmed }

    friends_array += inverse_friends

    friends_array.compact

  end

  # Users who have yet to confirme friend requests
  def pending_friends
    friendships.map{|friendship| friendship.friend if !friendship.confirmed}.compact
  end

  # Users who have requested to be friends
  def friend_requests
    inverse_friendships.map{|friendship| friendship.user if !friendship.confirmed}.compact
  end

  def confirm_friend(user)
    friendship = inverse_friendships.find{|friendship| friendship.user == user}
    friendship.confirmed = true
    friendship.save
  end

  def delete_friend(friend)
    friendship = friendships.find{ |friendship| friendship.user == user }
    friendship.confirmed = false
    friendship.save
  end

  def friend?(user)
    friends.include?(user)
  end

  def common_friends(game)
    self.friends.select { |friend| friend.games.include? game }
  end

end
