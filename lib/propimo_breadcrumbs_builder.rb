class PropimoBreadcrumbsBuilder < CustomBreadcrumbsBuilder
  def render
    divider = ''
    @context.render "/shared/breadcrumbs", elements: @elements, divider: divider
  end
end
