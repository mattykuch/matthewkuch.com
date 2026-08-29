-- Emit schema.org BlogPosting JSON-LD for blog posts.
-- Reads title/date/description/image/categories from each post's front matter,
-- so there is nothing to maintain per post. Only runs for HTML output, and only
-- for files under posts/ (skips listing pages, About, CV, etc.).

local SITE     = "https://matthewkuch.com"
local AUTHOR   = "Matthew Kuch"
local LINKEDIN = "https://www.linkedin.com/in/matthew-k-ab0134122/"

local function esc(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\"):gsub('"', '\\"')
  s = s:gsub("\n", " "):gsub("\r", "")
  return s
end

-- Flatten a metadata value (Inlines/Blocks/string) to plain text.
local function totext(v)
  if v == nil then return nil end
  if type(v) == "string" then return v end
  local ok, s = pcall(pandoc.utils.stringify, v)
  if ok and s and s ~= "" then return s end
  return nil
end

-- Quarto formats `date` for display ("November 5, 2025") before a filter sees
-- it, but schema.org requires ISO 8601. Normalise it back.
local MONTHS = {
  january = "01", february = "02", march     = "03", april   = "04",
  may     = "05", june     = "06", july      = "07", august  = "08",
  september = "09", october = "10", november = "11", december = "12"
}

local function iso_date(s)
  if not s then return nil end
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s:match("^%d%d%d%d%-%d%d%-%d%d$") then return s end          -- already ISO
  local mon, day, year = s:match("^(%a+)%s+(%d+),?%s+(%d%d%d%d)$")  -- November 5, 2025
  if not mon then
    day, mon, year = s:match("^(%d+)%s+(%a+),?%s+(%d%d%d%d)$")      -- 5 November 2025
  end
  if mon then
    local mm = MONTHS[mon:lower()]
    if mm then return string.format("%s-%s-%02d", year, mm, tonumber(day)) end
  end
  local m2, d2, y2 = s:match("^(%d+)/(%d+)/(%d%d%d%d)$")            -- MM/DD/YYYY
  if m2 then return string.format("%s-%02d-%02d", y2, tonumber(m2), tonumber(d2)) end
  return nil
end

-- Absolute URL for the page currently being rendered.
local function page_url()
  local src = quarto.doc.input_file or ""
  src = src:gsub("\\", "/")
  local slug = src:match("posts/([^/]+)/index%.qmd$")
  if slug then return SITE .. "/posts/" .. slug .. "/" end
  return nil
end

function Pandoc(doc)
  if not quarto.doc.is_format("html:js") then return nil end

  local url = page_url()
  if not url then return nil end            -- not a post; do nothing

  local m = doc.meta
  local title = totext(m.title)
  if not title then return nil end

  local desc = totext(m.description)
  local date = iso_date(totext(m.date))
  local img  = totext(m.image)
  local alt  = totext(m["image-alt"])

  -- Post images are relative to the post folder.
  local imgurl = nil
  if img then
    if img:match("^https?://") then
      imgurl = img
    else
      imgurl = url .. img:gsub("^%./", "")
    end
  end

  -- categories -> keywords
  local kw = {}
  if m.categories then
    for _, c in ipairs(m.categories) do
      local s = totext(c)
      if s then kw[#kw + 1] = '"' .. esc(s) .. '"' end
    end
  end

  local parts = {}
  local function add(s) parts[#parts + 1] = s end

  add('{')
  add('"@context":"https://schema.org",')
  add('"@type":"BlogPosting",')
  add('"headline":"' .. esc(title) .. '",')
  if desc then add('"description":"' .. esc(desc) .. '",') end
  if date then
    add('"datePublished":"' .. esc(date) .. '",')
    add('"dateModified":"' .. esc(date) .. '",')
  end
  if imgurl then
    add('"image":{"@type":"ImageObject","url":"' .. esc(imgurl) .. '"'
        .. (alt and (',"caption":"' .. esc(alt) .. '"') or '') .. '},')
  end
  if #kw > 0 then add('"keywords":[' .. table.concat(kw, ",") .. '],') end
  add('"inLanguage":"en",')
  add('"author":{"@type":"Person","name":"' .. AUTHOR .. '","url":"' .. SITE
      .. '/about.html","sameAs":["' .. LINKEDIN .. '"]},')
  add('"publisher":{"@type":"Person","name":"' .. AUTHOR .. '","url":"' .. SITE .. '/"},')
  add('"mainEntityOfPage":{"@type":"WebPage","@id":"' .. esc(url) .. '"},')
  add('"url":"' .. esc(url) .. '"')
  add('}')

  quarto.doc.include_text("in-header",
    '<script type="application/ld+json">' .. table.concat(parts) .. '</script>')

  return nil
end
