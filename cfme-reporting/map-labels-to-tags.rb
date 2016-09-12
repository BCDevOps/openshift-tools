# Run this by pasting into "bundle exec rails console",
# or by "bundle exec rails runner map-labels-to-tags.rb"

# Re-running this script should be safe, and will even rename 
# previously created categories if you pass a different description.

def category_for_key(key, description)
  # Keys may contain '/' e.g. 'openshift.io/build.name'.
  name = 'kubernetes:' + Classification.sanitize_name(key.tr("/", ":"))
  category = Classification.find_by_name(name)
  if category
    category.description = description
    category.save!
    category
  else
    Classification.create_category!(name: name, description: description,
                                    read_only: true, single_value: true)
  end
end

# Workaround for https://github.com/ManageIQ/manageiq/issues/9713
def entry_for_empty_value(category)
  # ":empty:" has no special meaning, just ":" ensures it won't collide with tags produced for other values.
  category.find_entry_by_name(":empty:") ||
    category.add_entry(name: ":empty:", description: "<empty value>")
end

def map_all_values(label_key, category_description)
  cat = category_for_key(label_key, category_description)
  ContainerLabelTagMapping.find_or_create_by!(label_name: label_key, tag: cat.tag)
  # 5.6.0 workaround for https://github.com/ManageIQ/manageiq/issues/9713
  # Unnecessary (though harmless) with 5.6.1.
  ContainerLabelTagMapping.find_or_create_by!(label_name: label_key, label_value: "", tag: entry_for_empty_value(cat).tag)
  
  # Uncomment one off these lines to set/unset "Capture C & U Data by Tag" on all these categories & tags
  #[cat, cat.entries].each {|c| c.update(perf_by_tag: true)}
  #[cat, cat.entries].each {|c| c.update(perf_by_tag: false)}
end

# The 2nd param below are the category names the user will see in UI, reports etc.
map_all_values("team", "Pathfinder Team (OpenShift label 'team')")
map_all_values("category", "Pathfinder Category (OpenShift label 'category')")
map_all_values("product", "Pathfinder Product (OpenShift label 'product')")
map_all_values("environment", "Pathfinder Environment (OpenShift label 'environment')")
