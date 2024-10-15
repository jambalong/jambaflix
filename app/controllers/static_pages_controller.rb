class StaticPagesController < ApplicationController
  def home
    @user_photos = []

    if params[:flickr_user_id].present?
      flickr_user_id = params[:flickr_user_id]
      @user_photos = fetch_photos(flickr_user_id)
    end
  end

  private

  def fetch_photos(user_id)
    api_key = Rails.application.credentials.dig(:flickr, :key)
    url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{api_key}&user_id=#{user_id}&format=json&nojsoncallback=1"

    response = Faraday.get(url)

    if response.success?
      photos = JSON.parse(response.body).dig("photos", "photo") || []

      photos.map do |photo|
        {
          title: photo["title"],
          url: "https://live.staticflickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}.jpg"
        }
      end
    else
      Rails.logger.error("Error fetching photos: #{response.status} - #{response.body}")
      []
    end
  end
end
