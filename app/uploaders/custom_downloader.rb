class CustomDownloader < CarrierWave::Downloader::Base
  def skip_ssrf_protection?(uri)
    %w[imagekit.io ik.imagekit.io].include?(uri.hostname)
  end
end
