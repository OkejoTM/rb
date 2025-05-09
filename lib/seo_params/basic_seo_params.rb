# Агрегирует параметры страницы на сайте
module SeoParams
  class BasicSeoParams
    attr_accessor :subtitle,
                  :meta_canonical_path,
                  :edit_path

    class << self
      # Если страница canonical, вернет путь на оригинал, иначе nil
      def canonical_path(request)
        # Если есть GET параметры, то страница canonical
        return "#{request.host_with_port}#{request.path}" if request.GET.length != 0
        nil
      end
    end

    # Каноническая ли страница?
    def canonical?
      meta_canonical_path.present?
    end
  end
end
