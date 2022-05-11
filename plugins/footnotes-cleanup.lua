
if not Table.has_key(config, "footnote_link_selector") then
  Plugin.fail("Please specify footnote_link_selector")
end

if not Table.has_key(config, "footnotes_container_selector") then
  Plugin.fail("Please specify footnotes_container_selector")
end

-- Try to find footnote links
footnotes = HTML.select(page, config["footnote_link_selector"])

-- If there are no footnotes in the page, remove the containers meant for them
if size(footnotes) == 0 then
  footnotes_container = HTML.select_one(page, config["footnotes_container_selector"])
  HTML.delete(footnotes_container)
end
