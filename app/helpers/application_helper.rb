module ApplicationHelper
  def nav_link_class(page_name)
    target_path = page_name == "home" ? root_path : send("#{page_name}_path")
    current_page?(target_path) ? "active" : ""
  end
end
