# 04 · Sicherheit und Datenschutz

Maßstab ist **OWASP ASVS 5.0, Level 2**. Anmeldung und Sitzungen stehen in
[03](03-anmeldung-und-konten.md), Netz und Container in [05](05-betrieb.md).

## Automatische Prüfungen

| Wann | Was | Wo |
|---|---|---|
| jeder PR | Lint, Typen, Tests, Build | `ci.yml` › `pruefen` |
| jeder PR | `pnpm audit --prod` / `npm audit --omit=dev`, hoch/kritisch bricht ab | `ci.yml` › `pruefen` |
| jeder PR | Geheimnis-Scan (gitleaks) | `ci.yml` › `geheimnisse` |
| laufend | Dependabot inkl. Sicherheitsupdates | `dependabot.yml` |
| jedes Release | Image-Scan (Trivy, HIGH/CRITICAL) | `release.yml` |
| jedes Minor-Release | dynamischer Scan der laufenden App (OWASP ZAP Baseline) gegen eine Testinstanz | von Hand, Ergebnis in den Sicherheitsbericht |

Funde mit Fix werden behoben, bevor das nächste Release erscheint. Funde ohne Fix kommen
mit Begründung in den Sicherheitsbericht.

## Sicherheitsbericht

- `docs/sicherheit/` im Repo: ein Bericht, gegliedert nach den ASVS-Kapiteln, dazu eine
  **Befundliste** mit fester ID (`S-<Bereich>-nn`), Schwere, Status (offen / behoben /
  akzeptiert) und Datum.
- Jeder PR, der Anmeldung, Rechte, Uploads, Header, Geheimnisse oder Netz berührt, schreibt
  den Bericht im selben PR fort.

## HTTP

- **CSP** mit Nonce und `strict-dynamic`, kein `unsafe-inline` für Skripte,
  `frame-ancestors 'none'`, `object-src 'none'`, `base-uri 'self'`.
- Dazu: `Strict-Transport-Security` (1 Jahr, includeSubDomains),
  `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`,
  `Permissions-Policy` (Kamera, Mikrofon, Ort nur bei Bedarf).
- Seiten mit Anmeldung: `Cache-Control: no-store`.
- Nur die HTTP-Methoden, die eine Route braucht. Alles andere gibt 405 zurück.
- **CSRF:** Bei jeder ändernden Anfrage wird der `Origin`-Header gegen die eigene Adresse
  geprüft, dazu `SameSite=Lax`-Cookies.
- Fehlerseiten zeigen nie Stacktrace oder interne Pfade, nur eine Fehler-ID für das Log.

## Eingaben und Dateien

- Jede Eingabe wird auf dem Server mit **zod** geprüft. Die Prüfung in der Oberfläche ist
  nur Komfort.
- Datenbankzugriff nur über drizzle bzw. parametrisierte Abfragen. SQL wird nie aus Text
  zusammengesetzt.
- **Uploads:** Erlaubnisliste nach Inhalt (Magic Bytes), nicht nach Dateiendung. Kein SVG,
  kein HTML. Größengrenze je Art. Dateinamen werden neu vergeben. Ausgeliefert wird mit
  `Content-Disposition` und dem richtigen Typ.
- **Virenscan:** ClamAV als optionaler Dienst. Ist er eingeschaltet und nicht erreichbar,
  wird der Upload abgelehnt (fail closed).
- Abrufe auf vom Nutzer angegebene Adressen (Webhooks, Importe) nur über eine Erlaubnisliste.
  Keine internen Adressen (Schutz vor SSRF).

## Geheimnisse

- In der Konfiguration (`/etc/<projekt>/deploy.env`), nie im Repo, nie in Client-Variablen.
  Erzeugt werden sie mit einem Skript (`openssl rand`), nicht von Hand ausgedacht.
- Geheimnisse **in der Datenbank** (Zugangsdaten zu IMAP, Banken, APIs): AES-256-GCM, mit
  Schlüsselversion im Datensatz. **Rotation:** neuer Schlüssel in `*_KEY`, der alte in
  `*_KEY_OLD`. Ein Wartungsjob verschlüsselt neu, danach wird `*_OLD` entfernt.
- Wiederherstellungscodes und ähnliche Einmalwerte: HMAC mit Pepper
  ([03](03-anmeldung-und-konten.md)).

## Protokolle

- **Audit-Log:** Ein Trigger je Fachtabelle schreibt wer, wann, was (alt/neu, ohne
  Geheimnisse) in eine Tabelle, die die App nur ergänzen und nie ändern kann. Anmeldungen,
  Rechteänderungen, Exporte und Löschungen kommen zusätzlich als eigene Ereignisse dazu.
- **App-Log:** strukturiert (JSON), Stufe über `LOG_LEVEL`. Kein Passwort, Token,
  Dokumentinhalt oder vollständiger personenbezogener Datensatz im Log. Jede Anfrage hat
  eine Fehler-ID.

## Datenschutz (DSGVO)

- `docs/DATENSCHUTZ.md` im Repo mit:
  - Verarbeitungsverzeichnis: welche Daten, wozu, Rechtsgrundlage;
  - Speicherfristen: gesetzlich, z. B. GoBD 6/8/10 Jahre, und fachlich;
  - **Löschkonzept**: Papierkorb mit Frist, endgültiges Löschen, Löschnachweis ohne Inhalt;
  - Auskunft und Export (Art. 15/20) als Funktion in der App;
  - Liste der Auftragsverarbeiter (Hosting, Mail, KI-Anbieter) mit Ort der Verarbeitung;
  - technische und organisatorische Maßnahmen (TOM): Verweis auf diese Anweisungen und den
    Sicherheitsbericht.
- Daten an KI-Anbieter nur, wenn der Nutzer die Funktion bewusst nutzt, so wenig wie nötig
  und bei Anbietern mit Auftragsverarbeitungsvertrag.
- Impressum- und Datenschutz-Adresse sind einstellbar und in jeder App verlinkt.
