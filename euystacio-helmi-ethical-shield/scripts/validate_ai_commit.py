#!/usr/bin/env python3
import sys, re, pathlib

def main():
    msg_file = pathlib.Path(sys.argv[-1])
    msg = msg_file.read_text(encoding="utf-8")

    required = {
        "ai_tag": re.compile(r"^\[AI-assisted\]", re.MULTILINE),
        "coauthored": re.compile(r"Co-authored-by:\s*GitHub Copilot\s*<copilot@github\.com>", re.IGNORECASE),
        "dual_signature": re.compile(r"Dual Signature:", re.IGNORECASE),
    }
    missing = [k for k, rx in required.items() if not rx.search(msg)]
    if missing:
        sys.stderr.write("❌ Commit message missing required elements: " + ", ".join(missing) + "\n")
        sys.stderr.write("Hint: use the template in .gitmessage.txt\n")
        sys.exit(1)

    # Basic guardrails to prevent committing secrets or obvious keys
    banned = [
        re.compile(r"AKIA[0-9A-Z]{16}"),             # AWS Access Key ID
        re.compile(r"(?i)api[_-]?key\s*[:=]\s*['\"]?[A-Za-z0-9-_]{16,}"),
        re.compile(r"-----BEGIN (RSA|EC|DSA) PRIVATE KEY-----"),
    ]
    if any(rx.search(msg) for rx in banned):
        sys.stderr.write("❌ Potential secret detected in commit message. Remove it.\n")
        sys.exit(1)

    print("✅ AI-assisted commit message validated.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
