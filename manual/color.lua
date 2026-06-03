-- color.lua
-- Converts [text]{.red} spans to \textcolor{red}{...} in LaTeX/PDF output.
-- In HTML output, the span class is preserved as-is (<span class="red">).
--
-- Also handles tables for LaTeX output:
--   - <br> inside cells → \makecell[l]{...} so line breaks work in any column type
--   - Alternating row background colors (odd rows: TBTableAlt, even rows: white)
--     Header rows are not affected.
-- Requires \usepackage{colortbl} and \colorlet{TBTableAlt}{...} in the LaTeX header.

local function has_class(el, cls)
  for _, c in ipairs(el.classes) do
    if c == cls then return true end
  end
  return false
end

function Span(el)
  if has_class(el, "red") then
    if FORMAT:match("latex") then
      local result = { pandoc.RawInline("latex", "\\textcolor{red}{") }
      for _, v in ipairs(el.content) do
        table.insert(result, v)
      end
      table.insert(result, pandoc.RawInline("latex", "}"))
      return result
    end
  end
  return el
end

-- Returns true if the inline list contains a <br> raw HTML element.
local function has_br(inlines)
  for _, inline in ipairs(inlines) do
    if inline.t == "RawInline" and inline.format == "html"
       and inline.text:match("^<br%s*/?>$") then
      return true
    end
  end
  return false
end

-- Replace <br> with \\ and wrap the whole inline list in \makecell[l]{...}.
local function wrap_makecell(inlines)
  local result = { pandoc.RawInline("latex", "\\makecell[l]{") }
  for _, inline in ipairs(inlines) do
    if inline.t == "RawInline" and inline.format == "html"
       and inline.text:match("^<br%s*/?>$") then
      table.insert(result, pandoc.RawInline("latex", "\\\\"))
    else
      table.insert(result, inline)
    end
  end
  table.insert(result, pandoc.RawInline("latex", "}"))
  return result
end

-- Process a single Cell, replacing <br> with \makecell when needed.
local function process_cell(cell)
  if #cell.content == 1 then
    local block = cell.content[1]
    if (block.t == "Plain" or block.t == "Para") and has_br(block.content) then
      cell.content[1] = pandoc.Plain(wrap_makecell(block.content))
    end
  end
  return cell
end

-- Process a list of Rows (handle <br> in cells).
local function process_rows(rows)
  for i, row in ipairs(rows) do
    for j, cell in ipairs(row.cells) do
      row.cells[j] = process_cell(cell)
    end
    rows[i] = row
  end
  return rows
end

-- Prepend \rowcolor{TBTableAlt} to the first cell of a row.
local function add_rowcolor(row)
  local first_cell = row.cells[1]
  if not first_cell then return row end

  local color_cmd = pandoc.RawInline("latex", "\\rowcolor{TBTableAlt}")

  if #first_cell.content == 0 then
    -- Empty cell: create a Plain block containing only the color command.
    first_cell.content = { pandoc.Plain({ color_cmd }) }
  else
    local block = first_cell.content[1]
    if block.t == "Plain" or block.t == "Para" then
      table.insert(block.content, 1, color_cmd)
    end
  end

  row.cells[1] = first_cell
  return row
end

-- Apply alternating row colors to body rows.
-- Odd rows (1st, 3rd, …) get TBTableAlt; even rows stay white (no command needed).
local function colorize_rows(rows)
  for i, row in ipairs(rows) do
    if i % 2 == 1 then
      rows[i] = add_rowcolor(row)
    end
  end
  return rows
end

function Table(tbl)
  if not FORMAT:match("latex") then
    return tbl
  end

  -- 1. Handle <br> → \makecell in all rows (head and body).
  tbl.head.rows = process_rows(tbl.head.rows)
  for i, body in ipairs(tbl.bodies) do
    body.head = process_rows(body.head)
    body.body = process_rows(body.body)
    tbl.bodies[i] = body
  end
  tbl.foot.rows = process_rows(tbl.foot.rows)

  -- 2. Add alternating background colors to body rows only (not the header).
  for i, body in ipairs(tbl.bodies) do
    body.body = colorize_rows(body.body)
    tbl.bodies[i] = body
  end

  return tbl
end
