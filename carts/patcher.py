import sys
import os

def apply_patch(orig_path, patch_path, out_path):
    # バイナリモードで読み込む（P8SCIIの特殊文字が壊れるのを防ぐため）
    if not os.path.exists(orig_path):
        print(f"エラー: オリジナルファイルが見つかりません: {orig_path}")
        return
    if not os.path.exists(patch_path):
        print(f"エラー: パッチファイルが見つかりません: {patch_path}")
        return

    with open(orig_path, 'rb') as f:
        orig_data = f.read()

    with open(patch_path, 'rb') as f:
        patch_data = f.read()

    # ==========================================
    # UTF-8絵文字をP8SCIIの1バイトコードに置換
    # ==========================================
    replacements = [
        (b'\xE2\xAC\x85\xEF\xB8\x8F', b'\x8b'), # ⬅️
        (b'\xE2\xAC\x85', b'\x8b'),             # ⬅
        (b'\xE2\x9E\xA1\xEF\xB8\x8F', b'\x91'), # ➡️
        (b'\xE2\x9E\xA1', b'\x91'),             # ➡
        (b'\xE2\xAC\x86\xEF\xB8\x8F', b'\x94'), # ⬆️
        (b'\xE2\xAC\x86', b'\x94'),             # ⬆
        (b'\xE2\xAC\x87\xEF\xB8\x8F', b'\x83'), # ⬇️
        (b'\xE2\xAC\x87', b'\x83'),             # ⬇
        (b'\xF0\x9F\x85\xBE\xEF\xB8\x8F', b'\x8e'), # 🅾️
        (b'\xF0\x9F\x85\xBE', b'\x8e'),             # 🅾
        (b'\xE2\x9D\x8E\xEF\xB8\x8F', b'\x97'), # ❎
        (b'\xE2\x9D\x8E', b'\x97')              # ❎
    ]

    for old_b, new_b in replacements:
        patch_data = patch_data.replace(old_b, new_b)

    # BOM (Byte Order Mark) がある場合はスキップする
    if patch_data.startswith(b'\xEF\xBB\xBF'):
        patch_data = patch_data[3:]

    # CRLFをLFに統一して行ごとに分割
    patch_lines = patch_data.replace(b'\r', b'').split(b'\n')
    
    current_script = orig_data
    
    state = 0 # 0: none, 1: search, 2: replace
    search_lines = []
    replace_lines = []
    
    def do_replace(script, search_bytes, replace_bytes):
        # 空白・改行のバイトコード
        ws = {b' '[0], b'\t'[0], b'\r'[0], b'\n'[0]}
        
        s_list = list(script)
        # 検索文字列から空白と改行を除外したリストを作成
        search_list = [b for b in search_bytes if b not in ws]
        
        if not search_list:
            return script
            
        script_len = len(s_list)
        search_len = len(search_list)
        
        # スクリプトを走査して一致するブロックを探す
        for i in range(script_len):
            if s_list[i] in ws:
                continue
                
            s_idx = i
            f_idx = 0
            while s_idx < script_len and f_idx < search_len:
                if s_list[s_idx] in ws:
                    s_idx += 1
                    continue
                    
                if s_list[s_idx] == search_list[f_idx]:
                    s_idx += 1
                    f_idx += 1
                else:
                    break
                    
            if f_idx == search_len:
                # マッチ成功：一致した範囲をごっそり置換
                return bytes(s_list[:i]) + replace_bytes + bytes(s_list[s_idx:])
                
        print("警告: 以下の[SEARCH]ブロックが見つかりませんでした（スキップします）:")
        try:
            print(search_bytes.decode('utf-8', errors='ignore').strip()[:100] + "...")
        except:
            print("[Binary data]")
        return script

    print("パッチの適用を開始します...")
    
    for line in patch_lines:
        if line.startswith(b'[SEARCH]'):
            state = 1
            search_lines = []
            replace_lines = []
        elif line.startswith(b'[REPLACE]'):
            state = 2
        elif line.startswith(b'[/]') or line.startswith(b'[\\]'):
            state = 0
            s_bytes = b'\n'.join(search_lines) + b'\n' if search_lines else b''
            r_bytes = b'\n'.join(replace_lines) + b'\n' if replace_lines else b''
            current_script = do_replace(current_script, s_bytes, r_bytes)
        else:
            if state == 1:
                search_lines.append(line)
            elif state == 2:
                replace_lines.append(line)
                
    with open(out_path, 'wb') as f:
        f.write(current_script)
        
    print(f"完了！ パッチ適用後のファイルを保存しました: {out_path}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("使い方: python patcher.py <元のLuaファイル> <パッチファイル(.p8t)> <出力ファイル名>")
        print("例: python patcher.py Desert_Drift_orig.lua \"Desert Drift.p8t\" patched.lua")
        sys.exit(1)
        
    apply_patch(sys.argv[1], sys.argv[2], sys.argv[3])