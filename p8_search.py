
def find_match(haystack, needle):
    for h in range(len(haystack)):
        if haystack[h] in ' \t\r\n': continue
        h_ptr = h
        n_ptr = 0
        while n_ptr < len(needle):
            while h_ptr < len(haystack) and haystack[h_ptr] in ' \t\r\n': h_ptr += 1
            while n_ptr < len(needle) and needle[n_ptr] in ' \t\r\n': n_ptr += 1
            if n_ptr >= len(needle): break
            if h_ptr >= len(haystack): break
            if haystack[h_ptr] != needle[n_ptr]: break
            h_ptr += 1
            n_ptr += 1
        while n_ptr < len(needle) and needle[n_ptr] in ' \t\r\n': n_ptr += 1
        if n_ptr >= len(needle):
            return h, h_ptr
    return -1, -1
