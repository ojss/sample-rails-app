module ApplicationHelper
#   Returns the full title per page basis

  def full_title(page_title='')
    base_title = "Sample App"
    if page_title.empty?
      base_title
    else
      return "#{page_title} | #{base_title}"
    end
  end
end
