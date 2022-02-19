tmpl = config["index_template"]
selector = config["index_selector"]

env = {}
env["entries"] = site_index

rendered_index = HTML.parse(String.render_template(tmpl, env))

index_container = HTML.select_one(page, selector)

HTML.append_child(index_container, rendered_index)
