import re

with open("pegball-3.p8", "rb") as f:
    data = f.read()

# Find occurrences of b'btn(' and b'btnp(' and show the following bytes
for match in re.finditer(b'btnp?\\([^)]+\\)', data):
    expr = match.group(0)
    # Print clean representation
    hex_repr = " ".join(f"{b:02X}" for b in expr)
    try:
        text_repr = expr.decode('utf-8', errors='replace')
    except Exception:
        text_repr = str(expr)
    safe_text = text_repr.encode('cp932', errors='replace').decode('cp932')
    print(f"Match: {safe_text} | Hex: {hex_repr}")
