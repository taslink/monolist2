class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :following_relationships, class_name:  "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following_users, through: :following_relationships, source: :followed
  has_many :followed_relationships, class_name:  "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followed_users, through: :followed_relationships, source: :follower

  has_many :ownerships , foreign_key: "user_id", dependent: :destroy
  has_many :items ,through: :ownerships
  
  has_many :wants, class_name: "Want", foreign_key: "user_id", dependent: :destroy
  has_many :want_items , through: :wants, source: :item
  
  has_many :haves, class_name: "Have", foreign_key: "user_id", dependent: :destroy
  has_many :have_items , through: :haves, source: :item


  # 他のユーザーをフォローする
  def follow(other_user)
    following_relationships.create(followed_id: other_user.id)
  end

  # フォローしているユーザーをアンフォローする
  def unfollow(other_user)
    following_relationships.find_by(followed_id: other_user.id).destroy
  end

  # あるユーザーをフォローしているかどうか？
  def following?(other_user)
    following_users.include?(other_user)
  end


  # itemをhaveする
  def have(item)
    haves.create(item_id: item.id) 
  end

  #itemのhaveを解除する
  def unhave(item)
    haves.find_by(item_id: item.id).destroy
  end
  
  #itemをhaveしている場合true、haveしていない場合falseを返す
  def have?(item)
    have_items.include?(item)
  end

  #楽天の検索結果がwantに登録されている場合true、登録されていない場合falseを返す
  def have_item_rakuten?(item_rakuten)
    have_items.each do |item|
      if (item_rakuten['itemCode'] == item.item_code)
        return true
      end
    end
    return false
  end

  #楽天検索結果から登録されているowershipのhaveを取得
  def get_have_item_rakuten(item_rakuten)
    haves.each do |have|
      if (item_rakuten['itemCode'] == have.item.item_code)
        return have
      end
    end
    return nil
  end


  # itemをwantする
  def want(item)
    wants.create(item_id: item.id)    
  end

  #itemのwantを解除する
  def unwant(item)
    wants.find_by(item_id: item.id).destroy    
  end
  
  #itemをwantしている場合true、wantしていない場合falseを返す
  def want?(item)
    want_items.include?(item)    
  end
  
  #楽天の検索結果がwantに登録されている場合true、登録されていない場合falseを返す
  def want_item_rakuten?(item_rakuten)
    want_items.each do |item|
      if (item_rakuten['itemCode'] == item.item_code)
        return true
      end
    end
    return false
  end

  #楽天検索結果から登録されているowershipのwantを取得
  def get_want_item_rakuten(item_rakuten)
    wants.each do |want|
      if (item_rakuten['itemCode'] == want.item.item_code)
        return want
      end
    end
    return nil
  end

end