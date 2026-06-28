# Verification and Encoding Rules
- Always double-check the `git diff` or the file contents after making file edits, especially before pushing to a repository, to ensure no unintended changes (like character encoding corruption or garbled text) have been introduced.
- When working with files containing Japanese text (or other multi-byte characters) on Windows, always explicitly specify UTF-8 encoding (e.g. `Set-Content -Encoding UTF8`) to prevent character corruption, or use the built-in `replace_file_content` tool which handles UTF-8 automatically.
