def foo():
    start = vim.current.range.start
    end = vim.current.range.end + 1
    lines = "\n".join(vim.current.buffer[start:end])
    vim.command("e ~/tmp/scratch")
    lines = lines.upper()
    lines = [o.strip() for o in lines.split("\n")]
    vim.current.buffer.append(lines, 0)
