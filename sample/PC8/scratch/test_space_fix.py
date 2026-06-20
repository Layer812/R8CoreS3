import re

def fix_digit_alphabetic_boundaries(code):
    pattern = re.compile(
        r'("(?:\\.|[^"])*"|\'(?:\\.|[^\'])*\'|--[^\n]*)'
        r'|'
        r'(\b0[xX][0-9a-fA-F]+|\b0[bB][01]+|\b\d+\.\d*(?:[eE][+-]?\d+)?|\b\.\d+(?:[eE][+-]?\d+)?|\b\d+(?:[eE][+-]?\d+)?)'
    )
    
    def replace_func(match):
        if match.group(1):
            return match.group(1)
        elif match.group(2):
            num_str = match.group(2)
            end_pos = match.end(2)
            if end_pos < len(code):
                next_char = code[end_pos]
                if next_char.isalpha() or next_char == '_':
                    return num_str + " "
            return num_str
        return match.group(0)

    return pattern.sub(replace_func, code)

# Test content
test_cases = [
    ("G=0function eK()", "G=0 function eK()"),
    ("x=0.5xyz", "x=0.5 xyz"),
    ("y=.5abc", "y=.5 abc"),
    ("local a=0x1f_var", "local a=0x1f _var"),
    ("print('0function')", "print('0function')"), # inside string
    ("-- comment 0function", "-- comment 0function"), # inside comment
    ("1e3", "1e3"), # scientific notation, shouldn't split
    ("1e3x", "1e3 x"), # scientific notation with variable
    ("a = 0band", "a = 0 band"), # interpreted as 0 + band, correct
]

print("Running tests...")
success = True
for inp, expected in test_cases:
    out = fix_digit_alphabetic_boundaries(inp)
    if out != expected:
        print(f"FAILED: {inp!r} -> {out!r} (expected {expected!r})")
        success = False
    else:
        print(f"PASSED: {inp!r} -> {out!r}")

if success:
    print("All tests passed!")
