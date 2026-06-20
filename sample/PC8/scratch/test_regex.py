import re

def test():
    line = 'n.s-=1l(n.e,n.d,0,f[c%#f+1],0,2)'
    lookahead = (
        r"(?=\s*(?:"
        r"local\b|if\b|then\b|do\b|end\b|for\b|while\b|function\b|return\b|else\b|elseif\b|break\b|goto\b|repeat\b|until\b|"
        r"(?<!\.)[a-zA-Z_][a-zA-Z0-9_\.\[\]'\"]*\s*(?<![~<>=!])[-+*/]?=(?!=)"
        r")|"
        r"(?<!\band)(?<!\bor)(?<!\bnot)(?<=[\]\)}])\s*(?=(?!and\b|or\b|not\b)[a-zA-Z_])|"
        r"(?<!\band)(?<!\bor)(?<!\bnot)(?<=[0-9])\s*(?=(?!and\b|or\b|not\b)[a-zA-Z_])|"
        r"(?<!\band)(?<!\bor)(?<!\bnot)(?<=[a-zA-Z_])\s+(?=(?!and\b|or\b|not\b)[a-zA-Z_])|"
        r"$)"
    )
    
    # test -=
    res = re.sub(r"(\b[a-zA-Z_][a-zA-Z0-9_\.\[\]'\"]*)\s*-=\s*(.*?)" + lookahead, r"\1 = \1 - (\2)", line)
    print("Result:", res)

    # test math.sin
    line2 = "n.s-=math.sin(x)"
    res2 = re.sub(r"(\b[a-zA-Z_][a-zA-Z0-9_\.\[\]'\"]*)\s*-=\s*(.*?)" + lookahead, r"\1 = \1 - (\2)", line2)
    print("Result2:", res2)

    # test and/or
    line3 = "n.s-=a and b"
    res3 = re.sub(r"(\b[a-zA-Z_][a-zA-Z0-9_\.\[\]'\"]*)\s*-=\s*(.*?)" + lookahead, r"\1 = \1 - (\2)", line3)
    print("Result3:", res3)

    # test multiple statements on one line with spaces
    line4 = "n.s-=1 l(n.e,n.d)"
    res4 = re.sub(r"(\b[a-zA-Z_][a-zA-Z0-9_\.\[\]'\"]*)\s*-=\s*(.*?)" + lookahead, r"\1 = \1 - (\2)", line4)
    print("Result4:", res4)

if __name__ == '__main__':
    test()
