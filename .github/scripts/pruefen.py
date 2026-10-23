"""Prüft die Anweisungen: relative Links in Markdown, YAML-Vorlagen, Shell-Vorlagen."""
import pathlib, re, subprocess, sys

import yaml

wurzel = pathlib.Path(__file__).resolve().parents[2]
fehler = []

# 1. Relative Links in Markdown zeigen auf vorhandene Dateien
link = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
for md in sorted(wurzel.rglob("*.md")):
    if ".git" in md.parts:
        continue
    text = md.read_text(encoding="utf-8")
    # Codeblöcke überspringen, dort stehen Beispiele
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    for ziel in link.findall(text):
        if re.match(r"^(https?:|mailto:|#)", ziel):
            continue
        pfad = (md.parent / ziel.split("#")[0]).resolve()
        if not pfad.exists():
            fehler.append(f"{md.relative_to(wurzel)}: Link ins Leere → {ziel}")

# 2. YAML-Dateien lassen sich lesen
for yml in sorted([*wurzel.glob("anweisungen/vorlagen/*.y*ml"), *wurzel.glob(".github/workflows/*.y*ml")]):
    try:
        yaml.safe_load(yml.read_text(encoding="utf-8"))
    except yaml.YAMLError as e:
        fehler.append(f"{yml.relative_to(wurzel)}: kein gültiges YAML ({e.problem})")

# 3. Shell-Vorlagen sind syntaktisch korrekt
for sh in sorted(wurzel.glob("anweisungen/vorlagen/*.sh")):
    r = subprocess.run(["bash", "-n", str(sh)], capture_output=True, text=True)
    if r.returncode:
        fehler.append(f"{sh.relative_to(wurzel)}: {r.stderr.strip()}")

for f in fehler:
    print(f"::error::{f}")
print(f"{len(fehler)} Fehler" if fehler else "Alles in Ordnung")
sys.exit(1 if fehler else 0)
