class SeoPage::Presenter < BasicPresenter
  # include PageFieldsModule
  include PageSnippetsModule
  # enable_snippets_for fields_for: [:h1, :title, :meta_description, :description]

  attr_accessor :area

  def initialize(seo_template, area = nil)
    super(seo_template)
    @area = area
  end

end
