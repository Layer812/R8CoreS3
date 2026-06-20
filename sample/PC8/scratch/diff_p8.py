import re
import sys
sys.path.append('g:/PC8')
from pc8c import convert_pico8_to_standard_lua

def check_parentheses(text):
    # 括弧のバランスをチェックする
    # 文字列リテラルは除外する
    # 退避
    placeholders = []
    def repl_str(m):
        placeholders.append(m.group(0))
        return ""
    pattern_str = r'(?:"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|\[\[.*?\]\])'
    clean_text = re.sub(pattern_str, repl_str, text, flags=re.DOTALL)
    
    # 括弧のカウント
    p_open = clean_text.count('(')
    p_close = clean_text.count(')')
    b_open = clean_text.count('[')
    b_close = clean_text.count(']')
    c_open = clean_text.count('{')
    c_close = clean_text.count('}')
    
    return p_open == p_close and b_open == b_close and c_open == c_close, (p_open, p_close, b_open, b_close, c_open, c_close)

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    with open('g:/PC8/top4_min.p8', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    lua_match = re.search(r'__lua__(.*?)(?:__gfx__|__gff__|__map__|__sfx__|__mus__|__label__|$)', content, re.DOTALL)
    pico8_lua = lua_match.group(1)
    
    # 全体をトランスパイルしてチェック
    print("Transpiling the entire lua code...")
    transpiled = convert_pico8_to_standard_lua(pico8_lua)
    
    # 括弧チェック
    ok, counts = check_parentheses(transpiled)
    if not ok:
        print("--- Unbalanced parentheses in the entire transpiled output! ---")
        print("Counts ( (, ), [, ], {, } ):", counts)
        # 括弧のバランスが崩れている場合、どこで崩れたかを特定するために
        # 開き括弧と閉じ括弧の累積バランスをスキャンする
        bal_p, bal_b, bal_c = 0, 0, 0
        
        # 文字列リテラルは除外
        placeholders = []
        def repl_str(m):
            placeholders.append(m.group(0))
            return f"__STR_{len(placeholders)-1}__"
        pattern_str = r'(?:"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|\[\[.*?\]\])'
        clean_text = re.sub(pattern_str, repl_str, transpiled, flags=re.DOTALL)
        
        for pos, char in enumerate(clean_text):
            if char == '(': bal_p += 1
            elif char == ')':
                bal_p -= 1
                if bal_p < 0:
                    print(f"Excess ')' at clean char {pos}: {clean_text[max(0, pos-50):pos+50]}")
                    break
            elif char == '[': bal_b += 1
            elif char == ']':
                bal_b -= 1
                if bal_b < 0:
                    print(f"Excess ']' at clean char {pos}: {clean_text[max(0, pos-50):pos+50]}")
                    break
            elif char == '{': bal_c += 1
            elif char == '}':
                bal_c -= 1
                if bal_c < 0:
                    print(f"Excess '}}' at clean char {pos}: {clean_text[max(0, pos-50):pos+50]}")
                    break
    else:
        print("Parentheses are balanced! No unmatched parentheses detected.")

if __name__ == '__main__':
    main()
