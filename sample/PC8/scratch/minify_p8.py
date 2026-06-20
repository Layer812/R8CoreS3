import re
import os
import shutil

def strip_comments_and_whitespace(lua_text):
    # 複数行コメント --[[ ... ]] の削除
    lua_text = re.sub(r'--\[\[.*?\]\]', '', lua_text, flags=re.DOTALL)
    
    lines = lua_text.splitlines()
    cleaned_lines = []
    for line in lines:
        in_string = False
        str_char = None
        comment_start = -1
        i = 0
        n = len(line)
        while i < n:
            c = line[i]
            if not in_string:
                if c in ('"', "'"):
                    in_string = True
                    str_char = c
                elif c == '[' and i + 1 < n and line[i+1] == '[':
                    in_string = True
                    str_char = ']]'
                    i += 1
                elif c == '-' and i + 1 < n and line[i+1] == '-':
                    comment_start = i
                    break
            else:
                if str_char == ']]':
                    if c == ']' and i + 1 < n and line[i+1] == ']':
                        in_string = False
                        i += 1
                else:
                    if c == str_char:
                        esc_count = 0
                        k = i - 1
                        while k >= 0 and line[k] == '\\':
                            esc_count += 1
                            k -= 1
                        if esc_count % 2 == 0:
                            in_string = False
            i += 1
            
        if comment_start != -1:
            line = line[:comment_start]
            
        line_stripped = line.strip()
        if line_stripped:
            cleaned_lines.append(line_stripped)
            
    return "\n".join(cleaned_lines)

def minify_p8(filepath):
    # バックアップを作成
    bak_filepath = filepath + ".bak"
    if not os.path.exists(bak_filepath):
        shutil.copyfile(filepath, bak_filepath)
        print(f"Backup created at: {bak_filepath}")

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # __lua__ セクションを探す
    # PICO-8 のセクションは __section__ のように定義される
    sections = re.split(r'(__[a-z0-9_]+__)', content)
    
    new_sections = []
    in_lua = False
    
    for part in sections:
        if part == "__lua__":
            in_lua = True
            new_sections.append(part)
        elif part.startswith("__") and part.endswith("__"):
            in_lua = False
            new_sections.append(part)
        else:
            if in_lua:
                # Lua コードを Minify する
                minified_code = strip_comments_and_whitespace(part)
                new_sections.append("\n" + minified_code + "\n")
            else:
                new_sections.append(part)

    with open(filepath, "w", encoding="utf-8", newline="\n") as f:
        f.write("".join(new_sections))
        
    print(f"Successfully minified: {filepath}")

if __name__ == "__main__":
    target = "G:/PC8/top4.p8"
    minify_p8(target)
