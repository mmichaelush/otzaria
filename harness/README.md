# רתמת הצילומים של סבב 10–11.11

הרתמה שצילמה את התמונות ב-PR. היא לא חלק מהמאגר, כדי לא להוסיף קבצים ל-`test/`.

הרצה מקומית:
1. להעתיק את `test_shots/` ל-`test/_shots/` בענף של ה-PR.
2. להריץ סצנה:
   `flutter test test/_shots/scenes/a_audit_test.dart --dart-define=DARK=0 --dart-define=NARROW=0 --dart-define=OUT=out`
   - `DARK=1` למצב כהה, `NARROW=1` לרוחב צר, `ONLY=<מזהה>` לסצנה אחת.
3. התמונות נשמרות ב-`out/<variant>/<scene>.png`. ל"לפני": אותה סצנה על `dev`.

`shoot.sh` מריץ את ארבע הווריאציות (lw, ld, nw, nd) ברצף.
