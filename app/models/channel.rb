class Channel < ApplicationRecord
  belongs_to :user
  has_one :setting, class_name: 'ChannelSetting', dependent: :destroy

  has_many :products, foreign_key: :channel_id, dependent: :destroy

  validates :token, uniqueness: true

  scope :active, -> { where(active: true) }

  def init_store_session
    @shopify_session = ShopifyAPI::Session.new(shopify_url, shopify_access_token)
    ShopifyAPI::Base.activate_session(@shopify_session)
  end

  def store_session_initiated?
    !!@shopify_session
  end

  def deactivate!
    update(active: false)
  end

  def inactive?
    !active?
  end

  def enqueue_job_for_pulling_store_settings
    return if setting.present?

    msg = { channel_id: id }
    opts = { to_queue: 'pull_channel_settings', persistence: true }
    Sneakers.publish(msg.to_json, opts)
  end

  def enqueue_job_for_pulling_products
    msg = { channel_id: id }
    opts = { to_queue: 'product_pulling', persistence: true }
    Sneakers.publish(msg.to_json, opts)
  end
end
