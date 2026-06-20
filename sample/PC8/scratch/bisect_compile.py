import subprocess
import os
import re

def try_compile(lua_content, sections):
    # 一時ファイルを作成してコンパイルを試みる
    temp_p8 = "g:/PC8/tools/bisect_temp.p8"
    header = "pico-8 cartridge\nversion 8\n__lua__\n"
    
    with open(temp_p8, 'w', encoding='utf-8') as f:
        f.write(header)
        f.write(lua_content)
        f.write("\n\n")
        f.write("\n".join(sections))
        
    try:
        # toolsフォルダで実行
        cwd = os.getcwd()
        os.chdir("g:/PC8/tools")
        res = subprocess.run(
            ["pc8_compile.exe", "game", "bisect_temp.p8", "bisect_temp.pc8c"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        os.chdir(cwd)
        if os.path.exists(temp_p8):
            os.remove(temp_p8)
        if os.path.exists("g:/PC8/tools/bisect_temp.pc8c"):
            os.remove("g:/PC8/tools/bisect_temp.pc8c")
            
        stdout = res.stdout.decode('utf-8', errors='ignore')
        stderr = res.stderr.decode('utf-8', errors='ignore')
        return res.returncode == 0, stdout, stderr
    except Exception as e:
        return False, "", str(e)

def main():
    # 元ファイルを読み込む
    with open('g:/PC8/top4_min_std.p8', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    lua_match = re.search(r'__lua__(.*?)(?:__gfx__|__gff__|__map__|__sfx__|__mus__|__label__|$)', content, re.DOTALL)
    pico8_lua = lua_match.group(1)
    
    # セクションの抽出
    sections = []
    for sec_name in ["__gfx__", "__map__", "__gff__", "__music__", "__sfx__"]:
        idx = content.find(sec_name)
        if idx != -1:
            next_idx = content.find("__", idx + 2)
            if next_idx != -1:
                sections.append(content[idx:next_idx])
            else:
                sections.append(content[idx:])
                
    # pico8_lua を文単位、あるいは括弧/キーワードの対応が合うように切り出すのは難しいので、
    # 単純に行単位で下から削っていく
    lines = pico8_lua.splitlines()
    print(f"Total lines of Lua code: {len(lines)}")
    
    # 下から順に削ってコンパイルを試す
    for count_to_remove in range(1, len(lines)):
        test_lua = "\n".join(lines[:-count_to_remove])
        success, out, err = try_compile(test_lua, sections)
        
        # もし success が True になるか、エラーが '__map' 以外の具体的なLuaエラーに変わったら
        if success or "syntax error near '__map'" not in err:
            print(f"\nFound boundary at removing {count_to_remove} lines (remaining: {len(lines) - count_to_remove} lines)")
            print(f"Remaining code ends with: {lines[-(count_to_remove+1)]}")
            print(f"Removed line that causes error transition: {lines[-count_to_remove]}")
            print(f"Compilation success: {success}")
            print(f"Error was: {err.strip()}")
            break
        else:
            print(f"Removed {count_to_remove} lines: still get '__map' error.")

if __name__ == '__main__':
    main()
